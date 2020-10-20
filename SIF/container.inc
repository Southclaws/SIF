/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

A complex script that allows 'virtual inventories' to be created in order to
store items in. Containers are created with a static size and can have items
added to and removed at any time. Player interactions are to be handled via
external calls to the API.

## Dependencies
	
- item
- inventory
- Streamer Plugin
- y_hooks
- y_timers

## Hooks

- OnScriptInit: Zero initialised array cells.
- OnItemDestroy: To remove destroyed items from containers.
- OnItemCreateInWorld: To clean item container IDs that may be left over.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_CONTAINER_INCLUDED
	#endinput
#endif

#include "SIF/debug.inc"
#include "SIF/item.inc"
#include "SIF/inventory.inc"

#include <YSI_Coding\y_iterate>
#include <YSI_Coding\y_timers>
#include <YSI_Coding\y_hooks>
#include <streamer>

#define _SIF_CONTAINER_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Maximum amount of containers that can be created.
#if !defined CNT_MAX
	#define CNT_MAX						(Container:4096)
#endif

// Maximum string length for container names.
#if !defined CNT_MAX_NAME
	#define CNT_MAX_NAME				(32)
#endif

// Maximum slot size amount for containers.
#if !defined CNT_MAX_SLOTS
	#define CNT_MAX_SLOTS				(24)
#endif


#define INVALID_CONTAINER_ID			(Container:-1)


// Functions


forward Container:CreateContainer(const name[], size);
/*
# Description
Creates a container to store items in with a static size.

# Parameters
- name: A name given to the container, for menus etc.
- size: The maximum capacity of items the container can store.

# Returns
ID of the newly created container or INVALID_CONTAINER_ID if the function failed
due to CNT_MAX limit being reached.
*/

forward DestroyContainer(Container:containerid, destroyitems = true);
/*
# Description
Removes a container from memory and frees the ID.

# Parameters
- destroyitems: If true, items inside will also be deleted.
*/

forward AddItemToContainer(Container:containerid, Item:itemid, playerid = INVALID_PLAYER_ID);
/*
# Description
Adds an item to a container list, calls OnItemAddToContainer.

# Parameters
- playerid: If set, can tell other modules that a player triggered the event.

# Returns
Returns 0 on success. If item doesn't fit, returns a positive integer
representing required item slots, otherwise -1 if containerid invalid, -2 if
itemid invalid, -3 if item is already in container, -4 if OnItemAddToContainer
returned non-zero, -5 if item is inside another container, -6 if item is inside
a player inventory from the SIF/Inventory module.
*/

forward RemoveItemFromContainer(Container:containerid, slotid, playerid = INVALID_PLAYER_ID, call = 1);
/*
# Description
Removes an item from a container slot.

# Parameters
- slotid: The slot to remove an item from (not the item ID).
- playerid: If set, can tell other modules that a player triggered the removal.
- call: If true, will call OnItemRemoveFromContainer
*/

forward IsValidContainer(Container:containerid);
/*
# Description
Checks if a container ID is valid.
*/

forward GetContainerName(Container:containerid, name[]);
/*
# Description
Returns a container's name.

# Returns
Boolean to indicate success or failure.
*/

forward GetContainerSize(Container:containerid);
/*
# Description
Returns a container's item capacity.
*/

forward SetContainerSize(Container:containerid, size);
/*
# Description
Sets a container's item capacity.

# Returns
Boolean to indicate success or failure.
*/

forward GetContainerItemCount(Container:containerid);
/*
# Description
Returns the amount of items inside a container.
*/

forward Item:GetContainerSlotItem(Container:containerid, slotid);
/*
# Description
Returns the item stored in the specified slot.
*/

forward IsContainerSlotUsed(Container:containerid, slotid);
/*
# Description
Checks if a slot in a container is occupied by an item.
*/

forward IsContainerFull(Container:containerid);
/*
# Description
Checks if a container is full.
*/

forward IsContainerEmpty(Container:containerid);
/*
# Description
Checks if a container is empty.
*/

forward WillItemTypeFitInContainer(Container:containerid, ItemType:itemtype);
/*
# Description
Checks if an item type will fit into a container.
*/

forward GetContainerFreeSlots(Container:containerid);
/*
# Description
Returns the number of free item slots in a container.
*/

forward Container:GetItemContainer(Item:itemid);
/*
# Description
Returns the ID of the container that itemid is stored in.
*/

forward GetItemContainerSlot(Item:itemid);
/*
# Description
Returns the container slot that the item is stored in if inside a container.
*/


// Events


forward OnContainerCreate(Container:containerid);
/*
# Called
Upon the creation of a container.
*/

forward OnContainerDestroy(Container:containerid);
/*
# Called
Upon the destruction of a container.
*/

forward OnItemAddToContainer(Container:containerid, Item:itemid, playerid);
/*
# Called
When an item is added to a container. Note that the item won't actually be in the container list when this is called.

# Returns
1 to cancel the item being added.
*/

forward OnItemAddedToContainer(Container:containerid, Item:itemid, playerid);
/*
# Called
After an item has been added to a container.
*/

forward OnItemRemoveFromContainer(Container:containerid, slotid, playerid);
/*
# Called
As an item is removed from a container. Note that the item will still be in the container list when this is called.

# Returns
1 to cancel the item being removed.
*/

forward OnItemRemovedFromContainer(Container:containerid, slotid, playerid);
/*
# Called
After an item has been removed from a container.
*/


/*==============================================================================

	Setup

==============================================================================*/


enum E_CONTAINER_DATA
{
			cnt_name[CNT_MAX_NAME],
			cnt_size
}


const CNT_ITER_SIZE = _:CNT_MAX;
new
			cnt_Data					[CNT_MAX][E_CONTAINER_DATA],
       Item:cnt_Items					[CNT_MAX][CNT_MAX_SLOTS],
   Iterator:cnt_Index<CNT_ITER_SIZE>,
  Container:cnt_ItemContainer			[ITM_MAX] = {INVALID_CONTAINER_ID, ...},
			cnt_ItemContainerSlot		[ITM_MAX] = {-1, ...};


static CNT_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	CNT_DEBUG = sif_debug_register_handler("SIF/Container");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CNT_DEBUG("[OnScriptInit]");
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock Container:CreateContainer(const name[], size)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[CreateContainer] '%s' %d", name, size);
	new Container:id = Container:Iter_Free(cnt_Index);

	if(_:id == ITER_NONE)
	{
		print("ERROR: Container limit reached.");
		return INVALID_CONTAINER_ID;
	}

	size = (size > CNT_MAX_SLOTS) ? CNT_MAX_SLOTS : size;

	strcpy(cnt_Data[id][cnt_name], name, CNT_MAX_NAME);
	cnt_Data[id][cnt_size]			= size;

	for(new i; i < CNT_MAX_SLOTS; i++)
		cnt_Items[id][i] = INVALID_ITEM_ID;

	Iter_Add(cnt_Index, _:id);

	CallLocalFunction("OnContainerCreate", "d", _:id);

	return id;
}

stock DestroyContainer(Container:containerid, destroyitems = true)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[DestroyContainer] %d", _:containerid);
	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	CallLocalFunction("OnContainerDestroy", "d", _:containerid);

	if(destroyitems)
	{
		for(new i; i < cnt_Data[containerid][cnt_size]; i++)
		{
			if(cnt_Items[containerid][i] == INVALID_ITEM_ID)
				break;

			cnt_ItemContainer[cnt_Items[containerid][i]] = INVALID_CONTAINER_ID;
			DestroyItem(cnt_Items[containerid][i]);
			cnt_Items[containerid][i] = INVALID_ITEM_ID;
		}
	}

	cnt_Data[containerid][cnt_name][0]	= EOS;
	cnt_Data[containerid][cnt_size]		= 0;

	Iter_Remove(cnt_Index, _:containerid);

	return 1;
}

stock AddItemToContainer(Container:containerid, Item:itemid, playerid = INVALID_PLAYER_ID)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[AddItemToContainer] %d %d %d", _:containerid, _:itemid, playerid);
	if(!Iter_Contains(cnt_Index, _:containerid))
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] ERROR: Invalid container ID");
		return -1;
	}

	if(!IsValidItem(itemid))
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] ERROR: Invalid item ID");
		return -2;
	}

	new
		slots,
		idx;

	while(idx < cnt_Data[containerid][cnt_size])
	{
		sif_d:SIF_DEBUG_LEVEL_LOOPS:CNT_DEBUG("[AddItemToContainer] Looping %d/%d item: %d", idx, cnt_Data[containerid][cnt_size], _:cnt_Items[containerid][idx]);
		if(!IsValidItem(cnt_Items[containerid][idx]))
			break;

		if(cnt_Items[containerid][idx] == itemid)
		{
			sif_d:SIF_DEBUG_LEVEL_LOOPS:CNT_DEBUG("[AddItemToContainer] ERROR: Item is already in container");
			return -3;
		}

		slots += GetItemTypeSize(GetItemType(cnt_Items[containerid][idx]));
		idx++;
	}

	new itemsize = GetItemTypeSize(GetItemType(itemid));

	if((itemsize + slots) > cnt_Data[containerid][cnt_size])
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] ERROR: Item doesn't fit, size: %d free: %d required: %d.", itemsize, cnt_Data[containerid][cnt_size] - slots, (itemsize + slots) - cnt_Data[containerid][cnt_size]);
		return (itemsize + slots) - cnt_Data[containerid][cnt_size];
	}

	if(CallLocalFunction("OnItemAddToContainer", "ddd", _:containerid, _:itemid, playerid))
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] ERROR: OnItemAddToContainer event returned 1");
		return -4;
	}

	if(cnt_ItemContainer[itemid] != INVALID_CONTAINER_ID)
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] WARNING: Item is currently in container %d slot %d, removing.", _:cnt_ItemContainer[itemid], cnt_ItemContainerSlot[itemid]);
		if(!RemoveItemFromContainer(cnt_ItemContainer[itemid], cnt_ItemContainerSlot[itemid]))
			return -5;
	}

	#if defined _SIF_INVENTORY_INCLUDED
	if(GetItemPlayerInventory(itemid) != INVALID_PLAYER_ID)
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] WARNING: Item is currently in player inventory %d slot %d, removing.", GetItemPlayerInventory(itemid), GetItemPlayerInventorySlot(itemid));
		if(!RemoveItemFromInventory(GetItemPlayerInventory(itemid), GetItemPlayerInventorySlot(itemid)))
			return -6;
	}
	#endif

	cnt_Items[containerid][idx] = itemid;
	cnt_ItemContainer[itemid] = containerid;
	cnt_ItemContainerSlot[itemid] = idx;

	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[AddItemToContainer] Added item %d to container %d at slot %d", _:itemid, _:containerid, idx);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));

	CallLocalFunction("OnItemAddedToContainer", "ddd", _:containerid, _:itemid, playerid);
	
	return 0;
}

stock RemoveItemFromContainer(Container:containerid, slotid, playerid = INVALID_PLAYER_ID, call = 1)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[RemoveItemFromContainer] %d %d %d %d", _:containerid, slotid, playerid, call);
	if(!(0 <= slotid < cnt_Data[containerid][cnt_size]))
		return 0;

	if(!IsValidItem(cnt_Items[containerid][slotid]))
	{
		if(cnt_Items[containerid][slotid] != INVALID_ITEM_ID)
		{
			sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[RemoveItemFromContainer] ERROR: Container slot is pointing to an invalid item.");
			cnt_Items[containerid][slotid] = INVALID_ITEM_ID;

			if(slotid < (cnt_Data[containerid][cnt_size] - 1))
			{
				sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[RemoveItemFromContainer] Shifting items down starting from %d.", slotid);

				for(new i = slotid; i < (cnt_Data[containerid][cnt_size] - 1); i++)
				{
				    cnt_Items[containerid][i] = cnt_Items[containerid][i+1];

					if(cnt_Items[containerid][i] != INVALID_ITEM_ID)
						cnt_ItemContainerSlot[cnt_Items[containerid][i]] = i;
				}

				cnt_Items[containerid][(cnt_Data[containerid][cnt_size] - 1)] = INVALID_ITEM_ID;
			}
		}

		return -1;
	}

	if(call)
	{
		if(CallLocalFunction("OnItemRemoveFromContainer", "ddd", _:containerid, slotid, playerid))
		{
			sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[RemoveItemFromContainer] ERROR: OnItemRemoveFromContainer returned 1");
			return 1;
		}
	}

	cnt_ItemContainer[cnt_Items[containerid][slotid]] = INVALID_CONTAINER_ID;
	cnt_ItemContainerSlot[cnt_Items[containerid][slotid]] = -1;
	cnt_Items[containerid][slotid] = INVALID_ITEM_ID;

	if(slotid < (cnt_Data[containerid][cnt_size] - 1))
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[RemoveItemFromContainer] Shifting items down starting from %d.", slotid);
		for(new i = slotid; i < (cnt_Data[containerid][cnt_size] - 1); i++)
		{
			cnt_Items[containerid][i] = cnt_Items[containerid][i+1];

			if(cnt_Items[containerid][i] != INVALID_ITEM_ID)
				cnt_ItemContainerSlot[cnt_Items[containerid][i]] = i;
		}

		cnt_Items[containerid][(cnt_Data[containerid][cnt_size] - 1)] = INVALID_ITEM_ID;
	}

	if(call)
		CallLocalFunction("OnItemRemovedFromContainer", "ddd", _:containerid, slotid, playerid);

	return 1;
}

stock IsValidContainer(Container:containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsValidContainer] %d", _:containerid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	return 1;
}

// cnt_name
stock GetContainerName(Container:containerid, name[])
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerName] %d", _:containerid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	name[0] = EOS;
	strcat(name, cnt_Data[containerid][cnt_name], CNT_MAX_NAME);

	return 1;
}

// cnt_size
stock GetContainerSize(Container:containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerSize] %d", _:containerid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return -1;

	return cnt_Data[containerid][cnt_size];
}
stock SetContainerSize(Container:containerid, size)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[SetContainerSize] %d %d", _:containerid, size);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	cnt_Data[containerid][cnt_size] = size;

	return 1;
}

stock GetContainerItemCount(Container:containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerItemCount] %d", _:containerid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	new size;

	while(size < cnt_Data[containerid][cnt_size])
	{
		if(!IsValidItem(cnt_Items[containerid][size]))
			break;

		size++;
	}

	return size;
}

// cnt_Items
stock Item:GetContainerSlotItem(Container:containerid, slotid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerSlotItem] %d %d", _:containerid, slotid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return INVALID_ITEM_ID;

	if(!(0 <= slotid < CNT_MAX_SLOTS))
		return INVALID_ITEM_ID;

	return cnt_Items[containerid][slotid];
}

stock IsContainerSlotUsed(Container:containerid, slotid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsContainerSlotUsed] %d %d", _:containerid, slotid);

	if(!(0 <= slotid < CNT_MAX_SLOTS))
		return -1;

	if(!IsValidItem(cnt_Items[containerid][slotid]))
		return 0;

	return 1;
}

stock IsContainerFull(Container:containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsContainerFull] %d", _:containerid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	return GetContainerFreeSlots(containerid) == 0;
}

stock IsContainerEmpty(Container:containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsContainerEmpty] %d", _:containerid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	return !IsValidItem(cnt_Items[containerid][0]);
}

stock WillItemTypeFitInContainer(Container:containerid, ItemType:itemtype)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[WillItemTypeFitInContainer] %d %d", _:containerid, _:itemtype);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	new
		slots,
		idx;

	while(idx < cnt_Data[containerid][cnt_size])
	{
		if(!IsValidItem(cnt_Items[containerid][idx]))
			break;

		slots += GetItemTypeSize(GetItemType(cnt_Items[containerid][idx]));
		idx++;
	}

	if(slots + GetItemTypeSize(itemtype) > cnt_Data[containerid][cnt_size])
		return 0;

	return 1;
}

stock GetContainerFreeSlots(Container:containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerFreeSlots] %d", _:containerid);

	if(!Iter_Contains(cnt_Index, _:containerid))
		return 0;

	new
		slots,
		idx;

	while(idx < cnt_Data[containerid][cnt_size])
	{
		if(!IsValidItem(cnt_Items[containerid][idx]))
			break;

		slots += GetItemTypeSize(GetItemType(cnt_Items[containerid][idx]));
		idx++;
	}

	return cnt_Data[containerid][cnt_size] - slots;
}

stock Container:GetItemContainer(Item:itemid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetItemContainer] %d", _:itemid);

	if(!IsValidItem(itemid))
		return INVALID_CONTAINER_ID;

	return cnt_ItemContainer[itemid];
}

stock GetItemContainerSlot(Item:itemid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetItemContainerSlot] %d", _:itemid);

	if(!IsValidItem(itemid))
		return -1;

	return cnt_ItemContainerSlot[itemid];
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnItemDestroy(Item:itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CNT_DEBUG("[OnItemDestroy] %d", _:itemid);
	if(cnt_ItemContainer[itemid] != INVALID_CONTAINER_ID)
	{
		RemoveItemFromContainer(cnt_ItemContainer[itemid], cnt_ItemContainerSlot[itemid]);
	}
}

hook OnItemCreateInWorld(Item:itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CNT_DEBUG("[OnItemCreateInWorld] %d", _:itemid);
	if(cnt_ItemContainer[itemid] != INVALID_CONTAINER_ID)
	{
		RemoveItemFromContainer(cnt_ItemContainer[itemid], cnt_ItemContainerSlot[itemid]);
	}
}
