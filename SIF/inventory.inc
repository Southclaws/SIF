/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

Offers extended item functionality using the virtual item feature in SIF/Item.
This enables multiple items to be stored by players and retrieved when needed.
It contains functions and callbacks for complete control from external scripts
over inventory actions by players.

## Dependencies

- SIF/Item
- Streamer Plugin
- YSI/y_hooks

## Hooks

- OnScriptInit: To zero module globals and initialise debugger.
- OnPlayerConnect: Zeroing variables relating to players.
- OnPlayerDisconnect: To destroy player inventory items.
- OnItemDestroy: To remove an itemid from the inventory list when destroyed.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_INVENTORY_INCLUDED
	#endinput
#endif

#include "SIF/debug.inc"
#include "SIF/item.inc"

#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_INVENTORY_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Maximum amount of item slots available in a player inventory.
#if !defined INV_MAX_SLOTS
	#define INV_MAX_SLOTS	(4)
#endif


// Functions


forward AddItemToInventory(playerid, itemid, call = 1);
/*
# Description
Adds specified item to players inventory and removes item from world.

# Parameters
- call: Determines whether or not to call OnItemAddToInventory.

# Returns
Returns 0 on success. If item doesn't fit, returns a positive integer
representing required item slots, otherwise -1 if itemid invalid, -2 if item is
already in container, -4 if OnItemAddToInventory returned non-zero, -5 if item
is in the inventory of another player, -6 if item is inside a container from the
SIF/Container module.
*/

forward RemoveItemFromInventory(playerid, slotid, call = 1);
/*
# Description
Removes the item from the specified slot if there is one.

# Parameters
- slotid: Inventory slot to remove from, not an itemid.
- call: If true, will call OnItemRemoveFromInventory.
*/

forward GetInventorySlotItem(playerid, slotid);
/*
# Description
Returns the ID handle of the item stored in the specified slot.
*/

forward IsInventorySlotUsed(playerid, slotid);
/*
# Description
Checks if the specified inventory slot contains an item.
*/

forward IsPlayerInventoryFull(playerid);
/*
# Description
Checks if a players inventory is full. This is simply done by checking if the
last slot is full as items are automatically shifted up the index when an item
is removed.
*/

forward WillItemTypeFitInInventory(playerid, ItemType:itemtype);
/*
# Description
Checks if an item type will fit into a player's inventory.
*/

forward GetInventoryFreeSlots(playerid);
/*
# Description
Returns the amount of free slots in a player's inventory.
*/

forward GetItemPlayerInventory(itemid);
/*
# Description
Returns the ID of a player if itemid is stored in their inventory.
*/

forward GetItemPlayerInventorySlot(itemid);
/*
# Description
Returns inventory slot of an item if it's stored inside a player's inventory.
*/

forward SetPlayerInventorySize(playerid, slots);
/*
# Description
Sets the maximum amount of slots a player's inventory has.
*/

forward GetPlayerInventorySize(playerid);
/*
# Description
Returns the capacity of a player's inventory.
*/


// Events


forward OnItemAddToInventory(playerid, itemid, slot);
/*
# Called
Before an item is added to a player's inventory by the function AddItemToInventory.

# Returns
1 to cancel item being added.
*/

forward OnItemAddedToInventory(playerid, itemid, slot);
/*
# Called
After an item is added to a player's inventory by the function AddItemToInventory.
*/

forward OnItemRemoveFromInventory(playerid, itemid, slot);
/*
# Called
Before an item is removed from a player's inventory by the function RemoveItemFromInventory.

# Returns
1 to cancel item being removed.
*/

forward OnItemRemovedFromInventory(playerid, itemid, slot);
/*
# Called
After an item is removed from a player's inventory by the function RemoveItemFromInventory.
*/


/*==============================================================================

	Setup

==============================================================================*/


static
		inv_Data			[MAX_PLAYERS][INV_MAX_SLOTS],
		inv_Size			[MAX_PLAYERS] = {INV_MAX_SLOTS, ...},
		inv_ItemPlayer		[ITM_MAX] = {INVALID_PLAYER_ID, ...},
		inv_ItemPlayerSlot	[ITM_MAX] = {-1, ...};


static INV_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	INV_DEBUG = sif_debug_register_handler("SIF/Inventory");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:INV_DEBUG("[OnScriptInit]");

	for(new i; i < MAX_PLAYERS; i++)
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			inv_Data[i][j] = INVALID_ITEM_ID;
		}
	}
}

hook OnPlayerConnect(playerid)
{
	for(new j; j < INV_MAX_SLOTS; j++)
	{
		inv_Data[playerid][j] = INVALID_ITEM_ID;
	}

	return;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock AddItemToInventory(playerid, itemid, call = 1)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:INV_DEBUG("[AddItemToInventory] %d %d %d", playerid, itemid, call);
	if(!IsValidItem(itemid))
		return -1;

	new
		ItemType:itemtype = GetItemType(itemid),
		itemsize = GetItemTypeSize(itemtype),
		slots,
		idx;

	while(idx < inv_Size[playerid])
	{
		sif_d:SIF_DEBUG_LEVEL_LOOPS:INV_DEBUG("[AddItemToInventory] Looping %d/%d item: %d", idx, inv_Size[playerid], inv_Data[playerid][idx]);
		if(!IsValidItem(inv_Data[playerid][idx]))
			break;

		if(inv_Data[playerid][idx] == itemid)
		{
			sif_d:SIF_DEBUG_LEVEL_LOOPS:INV_DEBUG("[AddItemToInventory] ERROR: Item is already in inventory");
			return -2;
		}

		slots += GetItemTypeSize(GetItemType(inv_Data[playerid][idx]));
		idx++;
	}

	if((slots + itemsize) > inv_Size[playerid])
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:INV_DEBUG("[AddItemToInventory] ERROR: Item doesn't fit, size: %d free: %d required: %d.", itemsize, inv_Size[playerid] - slots, (itemsize + slots) - inv_Size[playerid]);
		return (slots + itemsize) - inv_Size[playerid];
	}

	if(call)
	{
		if(CallLocalFunction("OnItemAddToInventory", "ddd", playerid, itemid, idx))
		{
			sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:INV_DEBUG("[AddItemToInventory] ERROR: OnItemAddToInventory event returned 1");
			return -4;
		}
	}

	if(inv_ItemPlayer[itemid] != INVALID_PLAYER_ID)
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:INV_DEBUG("[AddItemToInventory] WARNING: Item is currently in player inventory %d slot %d, removing.", inv_ItemPlayer[itemid], inv_ItemPlayerSlot[itemid]);
		if(!RemoveItemFromInventory(inv_ItemPlayer[itemid], inv_ItemPlayerSlot[itemid]))
			return -5;
	}

	#if defined _SIF_CONTAINER_INCLUDED
	if(GetItemContainer(itemid) != INVALID_CONTAINER_ID)
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNTINV_DEBUG("[AddItemToInventory] WARNING: Item is currently in container %d slot %d, removing.", GetItemContainer(itemid), GetItemContainerSlot(itemid));
		if(!RemoveItemFromContainer(GetItemContainer(itemid), GetItemContainerSlot(itemid)))
			return 1;
	}
	#endif

	inv_Data[playerid][idx] = itemid;
	inv_ItemPlayer[itemid] = playerid;
	inv_ItemPlayerSlot[itemid] = idx;

	sif_d:SIF_DEBUG_LEVEL_CORE:INV_DEBUG("[AddItemToInventory] Added item %d to player inventory %d at slot %d", itemid, playerid, idx);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));

	if(call)
		CallLocalFunction("OnItemAddedToInventory", "ddd", playerid, itemid, idx);

	return 0;
}

stock RemoveItemFromInventory(playerid, slotid, call = 1)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:INV_DEBUG("[RemoveItemFromInventory] %d %d %d", playerid, slotid, call);
	if(!(0 <= slotid < inv_Size[playerid]))
		return 0;

	if(!IsValidItem(inv_Data[playerid][slotid]))
	{
		if(inv_Data[playerid][slotid] != INVALID_ITEM_ID)
		{
			inv_Data[playerid][slotid] = INVALID_ITEM_ID;

			if(slotid < (inv_Size[playerid] - 1))
			{
				for(new i = slotid; i < (inv_Size[playerid] - 1); i++)
				{
				    inv_Data[playerid][i] = inv_Data[playerid][i+1];

					if(inv_Data[playerid][i] != INVALID_ITEM_ID)
						inv_ItemPlayerSlot[inv_Data[playerid][i]] = i;
				}

				inv_Data[playerid][(inv_Size[playerid] - 1)] = INVALID_ITEM_ID;
			}
		}

		return -1;
	}

	new itemid = inv_Data[playerid][slotid];

	if(call)
	{
		if(CallLocalFunction("OnItemRemoveFromInventory", "ddd", playerid, itemid, slotid))
			return 0;
	}

	inv_ItemPlayer[inv_Data[playerid][slotid]] = INVALID_PLAYER_ID;
	inv_ItemPlayerSlot[inv_Data[playerid][slotid]] = -1;
	inv_Data[playerid][slotid] = INVALID_ITEM_ID;
	
	if(slotid < (inv_Size[playerid] - 1))
	{
		for(new i = slotid; i < (inv_Size[playerid] - 1); i++)
		{
		    inv_Data[playerid][i] = inv_Data[playerid][i+1];

			if(inv_Data[playerid][i] != INVALID_ITEM_ID)
				inv_ItemPlayerSlot[inv_Data[playerid][i]] = i;
		}

		inv_Data[playerid][(inv_Size[playerid] - 1)] = INVALID_ITEM_ID;
	}

	if(call)
		CallLocalFunction("OnItemRemovedFromInventory", "ddd", playerid, itemid, slotid);

	return 1;
}

stock GetInventorySlotItem(playerid, slotid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[GetInventorySlotItem] %d %d", playerid, slotid);
	if(!(0 <= slotid < inv_Size[playerid]))
		return INVALID_ITEM_ID;

	return inv_Data[playerid][slotid];
}

stock IsInventorySlotUsed(playerid, slotid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[IsInventorySlotUsed] %d %d", playerid, slotid);
	if(!(0 <= slotid < inv_Size[playerid]))
		return 0;

	if(!IsValidItem(inv_Data[playerid][slotid]))
		return 1;

	return 0;
}

stock IsPlayerInventoryFull(playerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[IsPlayerInventoryFull] %d", playerid);
	if(!IsPlayerConnected(playerid))
		return 0;

	return GetInventoryFreeSlots(playerid) == 0;
}

stock WillItemTypeFitInInventory(playerid, ItemType:itemtype)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[WillItemTypeFitInInventory] %d %d", playerid, _:itemtype);
	if(!IsPlayerConnected(playerid))
		return 0;

	new
		slots,
		idx;

	while(idx < inv_Size[playerid])
	{
		if(!IsValidItem(inv_Data[playerid][idx]))
			break;

		slots += GetItemTypeSize(GetItemType(inv_Data[playerid][idx]));
		idx++;
	}

	if(slots + GetItemTypeSize(itemtype) > inv_Size[playerid])
		return 0;

	return 1;
}

stock GetInventoryFreeSlots(playerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[GetInventoryFreeSlots] %d", playerid);
	if(!IsPlayerConnected(playerid))
		return 0;

	new
		slots,
		idx;

	while(idx < inv_Size[playerid])
	{
		if(!IsValidItem(inv_Data[playerid][idx]))
			break;

		slots += GetItemTypeSize(GetItemType(inv_Data[playerid][idx]));
		idx++;
	}

	return inv_Size[playerid] - slots;
}

stock GetItemPlayerInventory(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[GetItemPlayerInventory] %d", itemid);
	if(!IsValidItem(itemid))
		return INVALID_PLAYER_ID;

	return inv_ItemPlayer[itemid];
}

stock GetItemPlayerInventorySlot(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[GetItemPlayerInventorySlot] %d", itemid);
	if(!IsValidItem(itemid))
		return INVALID_PLAYER_ID;

	return inv_ItemPlayerSlot[itemid];
}

stock SetPlayerInventorySize(playerid, slots)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[SetPlayerInventorySize] %d %d", playerid, slots);
	if(!IsPlayerConnected(playerid))
		return 0;

	inv_Size[playerid] = slots;

	return 1;	
}

stock GetPlayerInventorySize(playerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:INV_DEBUG("[GetPlayerInventorySize] %d", playerid);
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_Size[playerid];	
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnItemDestroy(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:INV_DEBUG("[OnItemDestroy] %d", itemid);
	if(inv_ItemPlayer[itemid] != INVALID_PLAYER_ID)
	{
		RemoveItemFromInventory(inv_ItemPlayer[itemid], inv_ItemPlayerSlot[itemid]);
	}

	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	defer DestroyPlayerInventoryItems(playerid);
}

timer DestroyPlayerInventoryItems[1](playerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:INV_DEBUG("[DestroyPlayerInventoryItems] %d", playerid);
	for(new i; i < inv_Size[playerid]; i++)
	{
		DestroyItem(inv_Data[playerid][0]);
		RemoveItemFromInventory(playerid, 0);
	}	
}
