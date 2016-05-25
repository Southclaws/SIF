/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

A complex script that allows 'virtual inventories' to be created in order to
store items in. Containers can be interacted with just like anything else with a
button or a virtual container can be created without a way of interacting in the
game world so the contents of if can be shown from a script function instead.

This script hooks a lot of Inventory functions and uses the interface functions
to allow players to switch between a container item list and their own inventory
to make swapping items or looting quick and easy.

## Dependencies
	
- SIF\Button
- SIF\Item
- SIF\Inventory
- Streamer Plugin
- YSI\y_hooks
- YSI\y_timers

## Hooks

- OnScriptInit: Zero initialised array cells.
- OnItemDestroy: To remove destroyed items from containers.
- OnItemCreateInWorld: To clean item container IDs that may be left over.
- OnButtonPress: Allowing container entities to be interacted with.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_CONTAINER_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include <SIF\Debug.pwn>
#endif

#if !defined _SIF_ITEM_INCLUDED
	#include <SIF\Item.pwn>
#endif

#if !defined _SIF_INVENTORY_INCLUDED
	#include <SIF\Inventory.pwn>
#endif

#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_CONTAINER_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Maximum amount of containers that can be created.
#if !defined CNT_MAX
	#define CNT_MAX						(4096)
#endif

// Maximum string length for container names.
#if !defined CNT_MAX_NAME
	#define CNT_MAX_NAME				(32)
#endif

// Maximum slot size amount for containers.
#if !defined CNT_MAX_SLOTS
	#define CNT_MAX_SLOTS				(24)
#endif


#define INVALID_CONTAINER_ID			(-1)


// Functions


forward CreateContainer(name[], size, buttonid = INVALID_BUTTON_ID);
/*
# Description
Creates a container to store items in, can be specified as virtual to not create
a button or label so the container is only accessible via the script.

# Parameters
- name: A name given to the container, for menus etc.
- size: The maximum capacity of items the container can store.
- buttonid: If specified, the container is associated with a button which, when
  pressed, opens the container UI for a player.

# Returns
ID of the newly created container or INVALID_CONTAINER_ID if the function failed
due to CNT_MAX limit being reached.
*/

forward DestroyContainer(containerid, destroyitems = true, destroybutton = true);
/*
# Description
Removes a container from memory and frees the ID.

# Parameters
- destroyitems: If true, items inside will also be deleted.
- destroybutton: If true, and if a button is associated, button will be deleted.
*/

forward AddItemToContainer(containerid, itemid, playerid = INVALID_PLAYER_ID);
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

forward RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID, call = 1);
/*
# Description
Removes an item from a container slot.

# Parameters
- slotid: The slot to remove an item from (not the item ID).
- playerid: If set, can tell other modules that a player triggered the removal.
- call: If true, will call OnItemRemoveFromContainer
*/

forward IsValidContainer(containerid);
/*
# Description
Checks if a container ID is valid.
*/

forward GetContainerButton(containerid);
/*
# Description
Returns the button ID used by a container (if not virtual).
*/

forward GetContainerName(containerid, name[]);
/*
# Description
Returns a container's name.

# Returns
Boolean to indicate success or failure.
*/

forward GetContainerSize(containerid);
/*
# Description
Returns a container's item capacity.
*/

forward SetContainerSize(containerid, size);
/*
# Description
Sets a container's item capacity.

# Returns
Boolean to indicate success or failure.
*/

forward GetContainerItemCount(containerid);
/*
# Description
Returns the amount of items inside a container.
*/

forward GetContainerSlotItem(containerid, slotid);
/*
# Description
Returns the item stored in the specified slot.
*/

forward IsContainerSlotUsed(containerid, slotid);
/*
# Description
Checks if a slot in a container is occupied by an item.
*/

forward IsContainerFull(containerid);
/*
# Description
Checks if a container is full.
*/

forward IsContainerEmpty(containerid);
/*
# Description
Checks if a container is empty.
*/

forward WillItemTypeFitInContainer(containerid, ItemType:itemtype);
/*
# Description
Checks if an item type will fit into a container.
*/

forward GetContainerFreeSlots(containerid);
/*
# Description
Returns the number of free item slots in a container.
*/

forward GetItemContainer(itemid);
/*
# Description
Returns the ID of the container that itemid is stored in.
*/

forward GetItemContainerSlot(itemid);
/*
# Description
Returns the container slot that the item is stored in if inside a container.
*/

forward GetButtonContainer(buttonid);
/*
# Description
Returns the ID of the container that buttonid is created for.
*/


// Events


forward OnContainerCreate(containerid);
/*
# Called
Upon the creation of a container.
*/

forward OnContainerDestroy(containerid);
/*
# Called
Upon the destruction of a container.
*/

forward OnItemAddToContainer(containerid, itemid, playerid);
/*
# Called
When an item is added to a container. Note that the item won't actually be in the container list when this is called.

# Returns
1 to cancel the item being added.
*/

forward OnItemAddedToContainer(containerid, itemid, playerid);
/*
# Called
After an item has been added to a container.
*/

forward OnItemRemoveFromContainer(containerid, slotid, playerid);
/*
# Called
As an item is removed from a container. Note that the item will still be in the container list when this is called.

# Returns
1 to cancel the item being removed.
*/

forward OnItemRemovedFromContainer(containerid, slotid, playerid);
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
			cnt_size,
			cnt_buttonId
}


new
			cnt_Data					[CNT_MAX][E_CONTAINER_DATA],
			cnt_Items					[CNT_MAX][CNT_MAX_SLOTS],
   Iterator:cnt_Index<CNT_MAX>,
			cnt_ItemContainer			[ITM_MAX] = {INVALID_CONTAINER_ID, ...},
			cnt_ItemContainerSlot		[ITM_MAX] = {-1, ...},
			cnt_ButtonContainer			[BTN_MAX] = {INVALID_CONTAINER_ID, ...};


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


stock CreateContainer(name[], size, buttonid = INVALID_BUTTON_ID)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[CreateContainer] '%s' %d", name, size);
	new id = Iter_Free(cnt_Index);

	if(id == -1)
	{
		print("ERROR: Container limit reached.");
		return INVALID_CONTAINER_ID;
	}

	size = (size > CNT_MAX_SLOTS) ? CNT_MAX_SLOTS : size;

	strcpy(cnt_Data[id][cnt_name], name, CNT_MAX_NAME);
	cnt_Data[id][cnt_size]			= size;
	cnt_Data[id][cnt_buttonId]		= buttonid;

	if(IsValidButton(buttonid))
	{
		cnt_ButtonContainer[buttonid] = id;
	}

	for(new i; i < CNT_MAX_SLOTS; i++)
		cnt_Items[id][i] = INVALID_ITEM_ID;

	Iter_Add(cnt_Index, id);

	CallLocalFunction("OnContainerCreate", "d", id);

	return id;
}

stock DestroyContainer(containerid, destroyitems = true, destroybutton = true)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[DestroyContainer] %d", containerid);
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	CallLocalFunction("OnContainerDestroy", "d", containerid);

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

	if(IsValidButton(cnt_Data[containerid][cnt_buttonId]))
	{
		cnt_ButtonContainer[cnt_Data[containerid][cnt_buttonId]] = INVALID_CONTAINER_ID;

		if(destroybutton)
			DestroyButton(cnt_Data[containerid][cnt_buttonId]);
	}

	cnt_Data[containerid][cnt_name][0]	= EOS;
	cnt_Data[containerid][cnt_size]		= 0;
	cnt_Data[containerid][cnt_buttonId]	= INVALID_BUTTON_ID;

	Iter_Remove(cnt_Index, containerid);

	return 1;
}

stock AddItemToContainer(containerid, itemid, playerid = INVALID_PLAYER_ID)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[AddItemToContainer] %d %d %d", containerid, itemid, playerid);
	if(!Iter_Contains(cnt_Index, containerid))
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
		sif_d:SIF_DEBUG_LEVEL_LOOPS:CNT_DEBUG("[AddItemToContainer] Looping %d/%d item: %d", idx, cnt_Data[containerid][cnt_size], cnt_Items[containerid][idx]);
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

	if(CallLocalFunction("OnItemAddToContainer", "ddd", containerid, itemid, playerid))
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] ERROR: OnItemAddToContainer event returned 1");
		return -4;
	}

	if(cnt_ItemContainer[itemid] != INVALID_CONTAINER_ID)
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:CNT_DEBUG("[AddItemToContainer] WARNING: Item is currently in container %d slot %d, removing.", cnt_ItemContainer[itemid], cnt_ItemContainerSlot[itemid]);
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

	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[AddItemToContainer] Added item %d to container %d at slot %d", itemid, containerid, idx);

	RemoveItemFromWorld(itemid);

	CallLocalFunction("OnItemAddedToContainer", "ddd", containerid, itemid, playerid);
	
	return 0;
}

stock RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID, call = 1)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:CNT_DEBUG("[RemoveItemFromContainer] %d %d %d %d", containerid, slotid, playerid, call);
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
		if(CallLocalFunction("OnItemRemoveFromContainer", "ddd", containerid, slotid, playerid))
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
		CallLocalFunction("OnItemRemovedFromContainer", "ddd", containerid, slotid, playerid);

	return 1;
}

stock IsValidContainer(containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsValidContainer] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return 1;
}

// cnt_buttonId
stock GetContainerButton(containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerButton] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return cnt_Data[containerid][cnt_buttonId];
}

// cnt_name
stock GetContainerName(containerid, name[])
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerName] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	name[0] = EOS;
	strcat(name, cnt_Data[containerid][cnt_name], CNT_MAX_NAME);

	return 1;
}

// cnt_size
stock GetContainerSize(containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerSize] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
		return -1;

	return cnt_Data[containerid][cnt_size];
}
stock SetContainerSize(containerid, size)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[SetContainerSize] %d %d", containerid, size);

	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	cnt_Data[containerid][cnt_size] = size;

	return 1;
}

stock GetContainerItemCount(containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerItemCount] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
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
stock GetContainerSlotItem(containerid, slotid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerSlotItem] %d %d", containerid, slotid);

	if(!Iter_Contains(cnt_Index, containerid))
		return INVALID_ITEM_ID;

	if(!(0 <= slotid < CNT_MAX_SLOTS))
		return INVALID_ITEM_ID;

	return cnt_Items[containerid][slotid];
}

stock IsContainerSlotUsed(containerid, slotid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsContainerSlotUsed] %d %d", containerid, slotid);

	if(!(0 <= slotid < CNT_MAX_SLOTS))
		return -1;

	if(!IsValidItem(cnt_Items[containerid][slotid]))
		return 0;

	return 1;
}

stock IsContainerFull(containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsContainerFull] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return GetContainerFreeSlots(containerid) == 0;
}

stock IsContainerEmpty(containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[IsContainerEmpty] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return !IsValidItem(cnt_Items[containerid][0]);
}

stock WillItemTypeFitInContainer(containerid, ItemType:itemtype)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[WillItemTypeFitInContainer] %d %d", containerid, _:itemtype);

	if(!Iter_Contains(cnt_Index, containerid))
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

stock GetContainerFreeSlots(containerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetContainerFreeSlots] %d", containerid);

	if(!Iter_Contains(cnt_Index, containerid))
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

stock GetItemContainer(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetItemContainer] %d", itemid);

	if(!IsValidItem(itemid))
		return INVALID_CONTAINER_ID;

	return cnt_ItemContainer[itemid];
}

stock GetItemContainerSlot(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetItemContainerSlot] %d", itemid);

	if(!IsValidItem(itemid))
		return INVALID_CONTAINER_ID;

	return cnt_ItemContainerSlot[itemid];
}

stock GetButtonContainer(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:CNT_DEBUG("[GetButtonContainer] %d", buttonid);

	if(!IsValidButton(buttonid))
		return INVALID_CONTAINER_ID;

	return cnt_ButtonContainer[buttonid];
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnItemDestroy(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CNT_DEBUG("[OnItemDestroy] %d", itemid);
	if(cnt_ItemContainer[itemid] != INVALID_CONTAINER_ID)
	{
		RemoveItemFromContainer(cnt_ItemContainer[itemid], cnt_ItemContainerSlot[itemid]);
	}
}

hook OnItemCreateInWorld(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CNT_DEBUG("[OnItemCreateInWorld] %d", itemid);
	if(cnt_ItemContainer[itemid] != INVALID_CONTAINER_ID)
	{
		RemoveItemFromContainer(cnt_ItemContainer[itemid], cnt_ItemContainerSlot[itemid]);
	}
}

hook OnButtonPress(playerid, buttonid)
{
	new containerid = GetButtonContainer(buttonid);

	if(IsValidContainer(containerid))
	{
		ClearAnimations(playerid, 1);
		DisplayContainerInventory(playerid, containerid);
	}
}


/*==============================================================================

	Testing

==============================================================================*/


#if defined RUN_TESTS
	#include <SIF\testing\Container.pwn>
#endif
