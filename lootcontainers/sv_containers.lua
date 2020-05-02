local PLUGIN = PLUGIN

PLUGIN.curTime = 1
function PLUGIN:Think()
    if nut.config.get("lootEnabled") then
        if (CurTime() < (self.curTime + nut.config.get("lootContainerTime"))) then return end
        self.curTime = CurTime()

        --Remove all invalid containers
        for k, v in pairs(self.spawnedContainers) do
            --If entity has removed itself after decay time we remove it from the table as well
            if (!IsValid(v[1])) then
                table.remove(self.spawnedContainers, k)
            else
                inventory = v[1]:getInv()
                items = inventory:getItems()
                local count = 0
                -- Since it's an indexed table we can't use #items to get item count
                for _, v in pairs(items) do
                    count = count + 1
                end
                --If there are no items inside the container we will remove it before decay time
                if (count == 0) then
                    v[1]:Remove()
                    table.remove(self.spawnedContainers, k)
                end
            end
        end
        
        if (#self.spawnedContainers < nut.config.get("lootMaxWorldContainers")) then
            if (#self.spawnedContainers < (nut.config.get("lootMaxContainerSpawn")*#self.contPoints)) then          
                for i=1,nut.config.get("lootMaxContainerSpawn") do
                    local point = table.Random(self.contPoints)
                    if (!point) then return end 
                    if #self.spawnedContainers >= nut.config.get("lootMaxWorldContainers") then return end
                    if nut.config.get("lootMaxContainerSpawn") == 1 then
                        for _, v in pairs(self.spawnedContainers) do
                            if point[1] == v[2] then return end
                        end
                    end

                    timer.Simple(0.5, function() self:setContainer(point) end)
                end
            end
        end	
    end
end


function PLUGIN:setContainer(point)
    local entity = ents.Create("nut_itemcontainer")
    entity:SetPos(point[1] + Vector(math.random(1, 64), math.random(1, 64), 16))
    entity:SetAngles(entity:GetAngles())
    entity:Spawn()
    entity:SetModel(point[2])
    entity:SetSolid(SOLID_VPHYSICS)
    entity:PhysicsInit(SOLID_VPHYSICS)
    local physObj = entity:GetPhysicsObject()

    if (IsValid(physObj)) then
        physObj:EnableMotion(true)
        physObj:Wake()
    end

    local invData = PLUGIN.containerModel[entity:GetModel()]["invData"]

    FindMetaTable("GridInv"):instance({w = invData["w"], h = invData["h"]})
        :next(function(inventory)
            if (IsValid(entity)) then
                inventory.isStorage = true
                entity:setInventory(inventory)
                self:saveStorage()
                container = inventory
            end
        end, function(err)
            ErrorNoHalt(
                "Unable to create storage entity\n"..
                err.."\n"
            )
            if (IsValid(storage)) then
                storage:Remove()
            end
        end)

    local result = self:chooseRandom()
    for i=1,nut.config.get("lootCount") do
        local item = table.Random(self.categoryItems[result])
        nut.item.instance(item):next(function(item) container:add(item) end)
    end
    self.spawnedContainers[#self.spawnedContainers + 1] = {entity, point[1]}
end

function PLUGIN:chooseRandom()
    local weight = 0.0
    for _, v in pairs(self.itemRarity) do
        weight = weight + v[1]
    end
    local at = math.random() * weight

    local result = 0;
    for k, v in pairs(self.itemRarity) do
        if at < v[1] then
            result = table.Random(v[2])
            break
        end
        at = at - v[1]
    end

    if !result then
        result = self.itemRarity["common"][2]
    end

    return result
end

function PLUGIN:saveStorage()
  	local data = {}

    if (nut.config.get("lootPersistentContainers")) then
        for _, entity in ipairs(ents.FindByClass("nut_itemcontainer")) do
            if (hook.Run("CanSaveStorage", entity, entity:getInv()) == false) then
                entity.nutForceDelete = true
                continue
            end
            if (entity:getInv()) then
                data[#data + 1] = {
                    entity:GetPos(),
                    entity:GetAngles(),
                    entity:getNetVar("id"),
                    entity:GetModel():lower()
                }
            end
        end
        data[#data + 1] = self.spawnedContainers
    end
    data[#data + 1] = self.contPoints

  	self:setData(data)
end

function PLUGIN:LoadData()
	local data = self:getData()
	if (not data) then return end

    if (nut.config.get("lootPersistentContainers")) then
        for _, info in ipairs(data) do
            local position, angles, invID, model = unpack(info)
            local storage = self.containerModel[model]
            if (not storage) then continue end

            local storage = ents.Create("nut_itemcontainer")
            storage:SetPos(position)
            storage:SetAngles(angles)
            storage:Spawn()
            storage:SetModel(model)
            storage:SetSolid(SOLID_VPHYSICS)
            storage:PhysicsInit(SOLID_VPHYSICS)
            
            nut.inventory.loadByID(invID)
                :next(function(inventory)
                    if (inventory and IsValid(storage)) then
                        inventory.isStorage = true
                        storage:setInventory(inventory)
                        hook.Run("StorageRestored", storage, inventory)
                    elseif (IsValid(storage)) then
                        timer.Simple(1, function()
                            if (IsValid(storage)) then
                                storage:Remove()
                            end
                        end)
                    end
                end)

            local physObject = storage:GetPhysicsObject()

            if (physObject) then
                physObject:EnableMotion()
            end
        end
        self.spawnedContainers = data[#data-1]
    end

    self.contPoints = data[#data]

	self.loadedData = true
end