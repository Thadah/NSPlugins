# NutScript 1.1 Plugin Repository

## Safebox Plugin

This plugin allows players to have a safe place to store their items. No one except the player can access this safe inventories, as the data is stored in the character. This also allows to use only one entity that every character can use at the same time, as it will not
interfere with other inventories that are opened at the same time.

## Readers Plugin

Similar to the Access plugin, but simpler, allows adding some card readers next to the doors which can only be opened with a card that's the same level of the reader or higher.

Usage: Spawn a reader and put it near a door with a physgun. Then, use the /addlock command in the reader and afterwards use /addlock in the door.

## Looting Plugin

This plugin will make a player drop all its inventory in the form of a bag when they die, so that they can be 'looted'. However, this will
not make the player drop the money they have.

## World Item Container Plugin 

This plugin will spawn a list of items inside a container for players to find and loot. It must be configured in sh_plugin.lua to add the item lists and container models, in PLUGIN.itemTable and PLUGIN.containerModel.

All other configurations can be done inside NutScript.
