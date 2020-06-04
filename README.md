# Archived

**This repository is archived. The only reason this fork exists is to fix a couple of very minor compatibility issues to bootstrap a build of Scavenge and Survive with sampctl. Aside from that, don't use this library. Instead, use the packages in the ScavengeSurvive org.**

---

# SIF - Southclaw's Interaction Framework

SIF is a collection of high-level include scripts to make the development of
interactive features easy for the developer while maintaining quality front-end
gameplay for players.

# The Libraries

SIF Comes with 5 main libraries (and a couple of internally used extras),
each of which can be individually included and their dependencies will be
managed automatically.

There is also a debug library with some basic runtime debugging functions that
are used in all SIF libraries.

## `button.inc`

A simple framework using streamer areas and key checks to give the in-game
effect of physical buttons that players must press instead of using a command.
It was created as an alternative to the default GTA:SA spinning pickups for a
few reasons:

1. A player might want to stand where a pickup is but not use it
   (if the pickup is a building entrance or interior warp, he might
   want to stand in the doorway without being teleported.)

2. Making hidden doors or secrets that can only be found by walking
   near the button area and seeing the textdraw. (or spamming F!)

3. Spinning objects don't really add immersion to a role-play
   environment!

## `door.inc`

A simple object movement manager that supports buttons as the default method of
interacting. Doors support multiple buttons, so a button on the inside and
outside of a door is possible. Doors can be opened and closed manually by
calling OpenDoor or CloseDoor. The door state change callbacks can be used to
restrict the use of doors by returning 1.

## `item.inc`

A complex and flexible script to replace the use of pickups as a means of
displaying objects that the player can pick up and use. Item offers picking up,
dropping and even giving items to other players. Items in the game world consist
of static objects combined with buttons from SIF/Button to provide a means of
interacting.

Item aims to be an extremely flexible script offering a callback for almost
every action the player can do with an item. The script also allows the ability
to add the standard GTA:SA weapons as items that can be dropped, given and
anything else you script items to do.

When picked up, items will appear on the character model bone specified in the
item definition. This combines the visible aspect of weapons and items that are
already in the game with the scriptable versatility of server created and
scriptable entities.

## `inventory.inc`

Offers extended item functionality using the virtual item feature in SIF/Item.
This enables multiple items to be stored by players and retrieved when needed.
It contains functions and callbacks for complete control from external scripts
over inventory actions by players.

## `container.inc`

A complex script that allows 'virtual inventories' to be created in order to
store items in. Containers can be interacted with just like anything else with a
button or a virtual container can be created without a way of interacting in the
game world so the contents of if can be shown from a script function instead.

This script hooks a lot of Inventory functions and uses the interface functions
to allow players to switch between a container item list and their own inventory
to make swapping items or looting quick and easy.

## `core.inc`

A fundamental library with features used by multiple SIF scripts.

## `debug.inc`

Basic debugging library offering runtime debug functions used throughout SIF.

# Extensions

Extension scripts are smaller modules not essential to the core functionality
but offer some useful additions to the existing SIF libraries.

## ContainerDialog

Offers functions that represent the contents of containers with dialogs. Also
includes dynamic menu options for each item in the container.

## Craft

Basic two-item combination crafting script. Offers a function for binding two
items then the rest is done through container menu options.

## DebugLabels

Entity labelling library used throughout SIF. Debug labels can be enabled and
disabled in runtime and display various pieces of useful information.

## InventoryDialog

Offers a method of viewing player inventory contents with dialogs. Also contains
dynamic menu options for each item in the inventory.

## InventoryKeys

Basically just assigns a key to opening inventory and adding items to it.

## ItemArrayData

Extends the amount of data available to store with items. Includes functions for
setting, getting and appending the data.

## ItemList

Data library for compacting a list of items into a long string of item's types
and array data as well as other pieces of information. Used mainly for storage.

# Usage

`git clone` the repo into your includes path then:

```c
#include <SIF/SIF>
```

Or you can include individual scripts:

```c
#include <SIF/item>
#include <SIF/extensions/item-array0data>
```

You are welcome to fork, submit issues and improve the code any way you like!
