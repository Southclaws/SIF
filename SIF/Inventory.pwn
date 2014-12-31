/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.4.0
	Module Version: 2.4.0


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Inventory/Description
	{
		Offers extended item functionality using the virtual item feature in
		SIF/Item. This enables multiple items to be stored by players and
		retrieved when needed. It contains functions and callbacks for complete
		control from external scripts over inventory actions by players.
	}

	SIF/Inventory/Dependencies
	{
		SIF/Item
		Streamer Plugin
		YSI\y_hooks
	}

	SIF/Inventory/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Inventory/Constants
	{
		These can be altered by defining their values before the include line.

		INV_MAX_SLOTS
			Maximum amount of item slots available in a player inventory.
	}

	SIF/Inventory/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Inventory/Core
		native -

		native AddItemToInventory(playerid, itemid, call)
		{
			Description:
				Adds the specified item to a players inventory and removes the
				item from the world.

			Parameters:
				<playerid> (int)
					The player to add the item to.

				<itemid> (int, itemid)
					The ID handle of the item to add.

				<call>
					Determines whether or not to call OnItemAddToInventory.

			Returns:
				0
					If the item specified is an invalid item ID.

				-1
					If the inventory is full.

				1
					If the function completed successfully.
		}

		native RemoveItemFromInventory(playerid, slotid)
		{
			Description:
				Removes the item from the specified slot if there is one.

			Parameters:
				<playerid> (int)
					The player to remove the item from.
				
				<slotid>
					The inventory slot, must be between 0 and INV_MAX_SLOTS.

			Returns:
				0
					If the specified slot is invalid.
		}
	}

	SIF/Inventory/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Inventory/Callbacks
		native -

		native OnItemAddToInventory(playerid, itemid, slot);
		{
			Called:
				Before an item is added to a player's inventory by the function
				AddItemToInventory.

			Parameters:
				<playerid> (int)
					The player ID of the inventory the item will be added to.

				<itemid> (int)
					ID handle of the item that will be added. 

				<slot> (int)
					Inventory slot that the item will be added to.

			Returns:
				1
					To cancel the item being added.
		}

		native OnItemAddedToInventory(playerid, itemid, slot);
		{
			Called:
				After an item is added to a player's inventory by the function
				AddItemToInventory.

			Parameters:
				<playerid> (int)
					The player ID of the inventory the item was added to.

				<itemid> (int)
					ID handle of the item that was added. 

				<slot> (int)
					Inventory slot that the item was added to.

			Returns:
				-
		}

		native OnItemRemoveFromInventory(playerid, itemid, slot);
		{
			Called:
				Before an item is removed from a player's inventory by the
				function RemoveItemFromInventory.

			Parameters:
				<playerid> (int)
					The player ID of the inventory the item will be removed from.

				<itemid> (int)
					ID handle of the item that will be removed. 

				<itemid> (int)
					Inventory slot that the item will be removed from.

			Returns:
				1
					To cancel the item being removed.
		}

		native OnItemRemovedFromInventory(playerid, itemid, slot);
		{
			Called:
				After an item is removed from a player's inventory by the
				function RemoveItemFromInventory.

			Parameters:
				<playerid> (int)
					The player ID of the inventory the item was removed from.

				<itemid> (int)
					ID handle of the item that was removed. 

				<itemid> (int)
					Inventory slot that the item was removed from.

			Returns:
				-
		}
	}

	SIF/Inventory/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Inventory/Interface
		native -

		native GetInventorySlotItem(playerid, slotid)
		{
			Description:
				Returns the ID handle of the item stored in the specified slot.

			Parameters:
				<slotid> (int)
					The slot to get the item ID of, from 0 to
					INV_MAX_SLOTS - 1.

			Returns:
				(int, itemid)
					ID handle of the item in the specified slot.

				INVALID_ITEM_ID
					If the slot was invalid or the slot is empty.
		}

		native IsInventorySlotUsed(playerid, slotid)
		{
			Description:
				Checks if the specified inventory slot contains an item.

			Parameters:
				<slotid> (int)
					The slot to check, from 0 to INV_MAX_SLOTS - 1.

			Returns:
				-1
					If the specified slot is invalid.

				0
					If the slot is used.

				1
					If the slot is empty.
		}

		native IsPlayerInventoryFull(playerid)
		{
			Description:
				Checks if a players inventory is full. This is simply done by
				checking if the last slot is full as items are automatically
				shifted up the index when an item is removed.

			Parameters:
				-

			Returns:
				0
					If it isn't full.

				1
					If it is full.
		}

		native WillItemTypeFitInInventory(playerid, ItemType:itemtype)
		{
			Description:
				Checks if an item type will fit into a player's inventory.

			Parameters:
				-

			Returns:
				-
		}

		native GetInventoryFreeSlots(playerid)
		{
			Description:
				Returns the amount of free slots in a player's inventory.

			Parameters:
				-

			Returns:
				-
		}

		native GetItemPlayerInventory(itemid)
		{
			Description:
				Returns the ID of a player if <itemid> is stored in their
				inventory.

			Parameters:
				-

			Returns:
				-
		}

		native GetItemPlayerInventorySlot(itemid)
		{
			Description:
				Returns the inventory slot of an item if it's stored inside a
				player's inventory.

			Parameters:
				-

			Returns:
				-
		}

		native SetPlayerInventorySize(playerid, slots)
		{
			Description:
				Sets the maximum amount of slots a player's inventory has.

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerInventorySize(playerid)
		{
			Description:
				Returns the capacity of a player's inventory.

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Inventory/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	}

	SIF/Inventory/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerConnect
		{
			Reason:
				Zeroing variables relating to players.
		}
		SAMP/OnPlayerDisconnect
		{
			Emptying player inventory and clearing memory space.
		}
		SAMP/OnPlayerKeyStateChange
		{
			Reason:
				To detect if a player presses Y to put an item in their
				inventory or H to access their inventory.
		}
		SIF/Item/OnItemDestroy
		{
			Reason:
				To remove an itemid from the inventory list when destroyed.
		}
	}

==============================================================================*/


#if defined _SIF_INVENTORY_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include <SIF\Debug.pwn>
#endif

#if !defined _SIF_ITEM_INCLUDED
	#include <SIF\Item.pwn>
#endif

#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_INVENTORY_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


#if !defined INV_MAX_SLOTS
	#define INV_MAX_SLOTS	(4)
#endif


static
		inv_Data			[MAX_PLAYERS][INV_MAX_SLOTS],
		inv_Size			[MAX_PLAYERS] = {INV_MAX_SLOTS, ...},
		inv_ItemPlayer		[ITM_MAX] = {INVALID_PLAYER_ID, ...},
		inv_ItemPlayerSlot	[ITM_MAX] = {-1, ...};


forward OnItemAddToInventory(playerid, itemid, slot);
forward OnItemAddedToInventory(playerid, itemid, slot);
forward OnItemRemoveFromInventory(playerid, itemid, slot);
forward OnItemRemovedFromInventory(playerid, itemid, slot);


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


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


public OnItemDestroy(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:INV_DEBUG("[OnItemDestroy] %d", itemid);
	if(inv_ItemPlayer[itemid] != INVALID_PLAYER_ID)
	{
		RemoveItemFromInventory(inv_ItemPlayer[itemid], inv_ItemPlayerSlot[itemid]);
	}

	#if defined inv_OnItemDestroy
		return inv_OnItemDestroy(itemid);
	#endif
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
#define OnItemDestroy inv_OnItemDestroy
#if defined inv_OnItemDestroy
	forward inv_OnItemDestroy(itemid);
#endif

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


/*==============================================================================

	Interface Functions

==============================================================================*/


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
		return -1;

	if(!IsValidItem(inv_Data[playerid][slotid]))
		return 0;

	return 1;
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
