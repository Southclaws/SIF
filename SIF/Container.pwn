/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.3.0
	Module Version: 1.2.4


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Container/Description
	{
		A complex script that allows 'virtual inventories' to be created in
		order to store items in. Containers can be interacted with just like
		anything else with a button or a virtual container can be created
		without a way of interacting in the game world so the contents of if can
		be shown from a script function instead.

		This script hooks a lot of Inventory functions and uses the interface
		functions to allow players to switch between a container item list and
		their own inventory to make swapping items or looting quick and easy.
	}

	SIF/Container/Dependencies
	{
		SIF/Button
		SIF/Item
		SIF/Inventory
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Container/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Container/Constants
	{
		These can be altered by defining their values before the include line.

		CNT_MAX
			Maximum amount of containers that can be created.

		CNT_MAX_NAME
			Maximum string length for container names.

		CNT_MAX_SLOTS
			Maximum slot size amount for containers.
	}

	SIF/Container/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Container/Core
		native -

		native CreateContainer(name[], size, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, world = 0, interior = 0, label = 1, virtual = 0, max_med = -1, max_large = -1, max_carry = -1)
		{
			Description:
				Creates a container to store items in, can be specified as
				virtual to not create a button or label so the container is only
				accessible via the script.

			Parameters:
				<name> (string)
					The name given to the container. Also applied to the button
					label if created in the world.

				<size> (int)
					The maximum capacity of items the container can store.

				<x>, <y>, <z> (float, absolute world position)
					The position to create the container access button if the
					container isn't virtual.

				<world> (int)
					The virtual world to create the access button.

				<interior> (int)
					The interior to create the access button.

				<label> (boolean)
					Determines whether or not the container button is created
					with a 3D Text Label at it's position.

				<virtual> (boolean)
					Determines whether or not the container is a virtual
					container. If it is, a button will not be created and thus
					the container won't be directly accessibly in the game world
					by players, the only way to access the container would be
					through the function DisplayContainerInventory.

				<max_med> (int)
					The limit for medium sized items.

				<max_large> (int)
					The limit for large items.

				<max_carry> (int)
					The limit for carry-only items.

			Returns:
				(int, containerid)
					Container ID handle of the newly created container.

				INVALID_CONTAINER_ID
					If another container cannot be created due to CNT_MAX
					limit.
		}

		native DestroyContainer(containerid)
		{
			Description:
				Removes a container from memory and frees the ID.

			Parameters:
				-

			Returns:
				0
					If the containerid is invalid.
		}

		native AddItemToContainer(containerid, itemid, playerid = INVALID_PLAYER_ID)
		{
			Description:
				Adds an item to a container list, calls OnItemAddToContainer.

			Parameters:
				<containerid> (int, containerid)
					The container to add the item to.

				<itemid> (int)
					The item to add (must be valid, may be virtual)

				<playerid> (int)
					Can tell other scripts that the item was added by a player
					and not automatically.

			Returns:
				1
					On success.

				0
					If the item or container are invalid.

				-1
					If the item won't fit.
		}

		native RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID)
		{
			Description:
				Removes an item from a container slot.

			Parameters:
				<containerid> (int)
					The container to remove from.

				<slotid> (int)
					The slot in the container to remove an item from. NOT an
					itemid!

				<playerid> (int)
					Can tell other scripts that a player caused the item
					removal rather than the script.

			Returns:
				1
					On success.

				0
					If the specified slot was out of bounds.

				-1
					If the specified slot contained an invalid item ID.
		}
	}

	SIF/Container/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Container/Callbacks
		native -

		native OnItemAddToContainer(containerid, itemid, playerid);
		{
			Called:
				When an item is added to a container. Note that the item won't
				actually be in the container list when this is called.

			Parameters:
				<containerid> (int)
					The container the item will be added to.

				<itemid> (int)
					The item that will be added.

				<playerid> (int)
					The player who is adding it (specified in
					AddItemToContainer)

			Returns:
				1
					To cancel the item being added.
		}

		native OnItemAddedToContainer(containerid, itemid, playerid);
		{
			Called:
				After an item has been added to a container.

			Parameters:
				<containerid> (int)
					The container the item was added to.

				<itemid> (int)
					The item that was added.

				<playerid> (int)
					The player who added it (specified in AddItemToContainer)

			Returns:
				(nothing)
		}

		native OnItemRemoveFromContainer(containerid, slotid, playerid);
		{
			Called:
				As an item is removed from a container. Note that the item will
				still be in the container list when this is called.

			Parameters:
				<containerid> (int)
					The container the item will be removed from.

				<itemid> (int)
					The item that will be removed.

				<playerid> (int)
					The player who is removing it (specified in
					RemoveItemFromContainer)

			Returns:
				1
					To cancel the item being removed.
		}

		native OnItemRemovedFromContainer(containerid, slotid, playerid);
		{
			Called:
				After an item has been removed from a container.

			Parameters:
				<containerid> (int)
					The container the item was removed from.

				<itemid> (int)
					The item that was removed.

				<playerid> (int)
					The player who removed it (specified in
					RemoveItemFromContainer)

			Returns:
				(nothing)
		}
	}

	SIF/Container/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Container/Interface
		native -

		native IsValidContainer(containerid)
		{
			Description:
				Checks if a container ID is valid.

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerButton(containerid)
		{
			Description:
				Returns the button ID used by a container (if not virtual).

			Parameters:
				-

			Returns:
				(int, buttonid)
		}

		native GetContainerName(containerid, name[])
		{
			Description:
				Returns a container's name.

			Parameters:
				-

			Returns:
				(bool)
					Success state.
		}

		native GetContainerPos(containerid, &Float:x, &Float:y, &Float:z)
		{
			Description:
				Returns a container's button position.

			Parameters:
				-

			Returns:
				(bool)
					Success state.
		}

		native SetContainerPos(containerid, Float:x, Float:y, Float:z)
		{
			Description:
				Updates a container's button position in the world.

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerSize(containerid)
		{
			Description:
				Returns a container's item capacity.

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerSize(containerid, size)
		{
			Description:
				Sets a container's item capacity.

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerWorld(containerid)
		{
			Description:
				Returns the virtual world a container's button exists in.

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerWorld(containerid, world)
		{
			Description:
				Sets the virtual world that a container's button will exist in.

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerInterior(containerid)
		{
			Description:
				Returns the interior world a container's button exists in.

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerInterior(containerid, interior)
		{
			Description:
				Sets the interior world that a container's button will exist in.

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerSlotItem(containerid, slot)
		{
			Description:
				Returns the item stored in the specified slot.

			Parameters:
				-

			Returns:
				(int, itemid)
		}

		native IsContainerSlotUsed(containerid, slotid)
		{
			Description:
				Checks if a slot in a container is occupied by an item.

			Parameters:
				-

			Returns:
				-
		}

		native IsContainerFull(containerid)
		{
			Description:
				Checks if a container is full.

			Parameters:
				-

			Returns:
				-
		}

		native IsContainerEmpty(containerid)
		{
			Description:
				Checks if a container is empty.

			Parameters:
				-

			Returns:
				-
		}

		native WillItemTypeFitInContainer(containerid, ItemType:itemtype)
		{
			Description:
				Checks if an item type will fit into a container.

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerFreeSlots(containerid)
		{
			Description:
				Returns the number of free item slots in a container.

			Parameters:
				-

			Returns:
				-
		}

		native GetItemContainer(itemid)
		{
			Description:
				Returns the ID of the container that <itemid> is stored in.

			Parameters:
				-

			Returns:
				(int, containerid)
		}

		native GetButtonContainer(buttonid)
		{
			Description:
				Returns the ID of the container that <buttonid> is created for.

			Parameters:
				-

			Returns:
				(int, containerid)
		}
	}

	SIF/Container/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		-
	}

	SIF/Container/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		YSI/OnScriptInit
		{
			Reason:
				Zero initialised array cells.
		}
	}

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

	Setup

==============================================================================*/


#if !defined CNT_MAX
	#define CNT_MAX						(4096)
#endif

#if !defined CNT_MAX_NAME
	#define CNT_MAX_NAME				(32)
#endif

#if !defined CNT_MAX_SLOTS
	#define CNT_MAX_SLOTS				(24)
#endif


#define INVALID_CONTAINER_ID		(-1)


enum E_CONTAINER_DATA
{
			cnt_button,
			cnt_name[CNT_MAX_NAME],
Float:		cnt_posX,
Float:		cnt_posY,
Float:		cnt_posZ,
			cnt_size,
			cnt_maxOfSize[3],
			cnt_world,
			cnt_interior
}


new
			cnt_Data					[CNT_MAX][E_CONTAINER_DATA],
			cnt_Items					[CNT_MAX][CNT_MAX_SLOTS],
Iterator:	cnt_Index<CNT_MAX>,
			cnt_ItemContainer			[ITM_MAX] = {INVALID_CONTAINER_ID, ...},
			cnt_ButtonContainer			[BTN_MAX] = {INVALID_CONTAINER_ID, ...};


forward OnItemAddToContainer(containerid, itemid, playerid);
forward OnItemAddedToContainer(containerid, itemid, playerid);
forward OnItemRemoveFromContainer(containerid, slotid, playerid);
forward OnItemRemovedFromContainer(containerid, slotid, playerid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new i; i < ITM_MAX; i++)
		cnt_ItemContainer[i] = INVALID_CONTAINER_ID;

	for(new i; i < BTN_MAX; i++)
		cnt_ButtonContainer[i] = INVALID_CONTAINER_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateContainer(name[], size,
	Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, world = 0, interior = 0, label = 1, virtual = 0,
	max_med = -1, max_large = -1, max_carry = -1)
{
	new id = Iter_Free(cnt_Index);

	if(id == -1)
	{
		print("ERROR: Container limit reached.");
		return INVALID_CONTAINER_ID;
	}

	if(!virtual)
	{
		cnt_Data[id][cnt_button] = CreateButton(x, y, z, "Press F to open", world, interior, 1.0, label, name);
		cnt_ButtonContainer[cnt_Data[id][cnt_button]] = id;
	}
	else
	{
		cnt_Data[id][cnt_button] = INVALID_BUTTON_ID;
	}

	strcpy(cnt_Data[id][cnt_name], name, CNT_MAX_NAME);
	cnt_Data[id][cnt_posX]			= x;
	cnt_Data[id][cnt_posY]			= y;
	cnt_Data[id][cnt_posZ]			= z;
	cnt_Data[id][cnt_size]			= size;
	cnt_Data[id][cnt_maxOfSize][0]	= max_med;
	cnt_Data[id][cnt_maxOfSize][1]	= max_large;
	cnt_Data[id][cnt_maxOfSize][2]	= max_carry;
	cnt_Data[id][cnt_world]			= world;
	cnt_Data[id][cnt_interior]		= interior;

	for(new i; i < CNT_MAX_SLOTS; i++)
		cnt_Items[id][i] = INVALID_ITEM_ID;

	Iter_Add(cnt_Index, id);

	return id;
}

stock DestroyContainer(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	if(IsValidButton(cnt_Data[containerid][cnt_button]))
	{
		DestroyButton(cnt_Data[containerid][cnt_button]);
		cnt_ButtonContainer[cnt_Data[containerid][cnt_button]] = INVALID_CONTAINER_ID;
	}

	cnt_Data[containerid][cnt_button] = INVALID_BUTTON_ID;

	for(new i; i < cnt_Data[containerid][cnt_size]; i++)
	{
		if(cnt_Items[containerid][i] == INVALID_ITEM_ID)
			break;

		DestroyItem(cnt_Items[containerid][i]);
		cnt_Items[containerid][i] = INVALID_ITEM_ID;
	}

	cnt_Data[containerid][cnt_name][0]	= EOS;
	cnt_Data[containerid][cnt_posX]		= 0.0;
	cnt_Data[containerid][cnt_posY]		= 0.0;
	cnt_Data[containerid][cnt_posZ]		= 0.0;
	cnt_Data[containerid][cnt_size]		= 0;
	cnt_Data[containerid][cnt_world]	= 0;
	cnt_Data[containerid][cnt_interior]	= 0;

	Iter_Remove(cnt_Index, containerid);

	return 1;
}

stock AddItemToContainer(containerid, itemid, playerid = INVALID_PLAYER_ID)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	if(!IsValidItem(itemid))
		return 0;

	if(CallLocalFunction("OnItemAddToContainer", "ddd", containerid, itemid, playerid))
		return 1;

	new
		i,
		count;

	while(i < cnt_Data[containerid][cnt_size])
	{
		if(IsValidItem(cnt_Items[containerid][i]))
		{
			if(GetItemTypeSize(GetItemType(itemid)) == ITEM_SIZE_MEDIUM && cnt_Data[containerid][cnt_maxOfSize][0] != -1)
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_MEDIUM)
					count++;

				if(count >= cnt_Data[containerid][cnt_maxOfSize][0])
					return -1;
			}
			else if(GetItemTypeSize(GetItemType(itemid)) == ITEM_SIZE_LARGE && cnt_Data[containerid][cnt_maxOfSize][1] != -1)
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_LARGE)
					count++;

				if(count >= cnt_Data[containerid][cnt_maxOfSize][1])
					return -1;
			}
			else if(GetItemTypeSize(GetItemType(itemid)) == ITEM_SIZE_CARRY && cnt_Data[containerid][cnt_maxOfSize][2] != -1)
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_CARRY)
					count++;

				if(count >= cnt_Data[containerid][cnt_maxOfSize][2])
					return -1;
			}
		}
		else
		{
			break;
		}
		i++;
	}

	if(i == cnt_Data[containerid][cnt_size])
		return -1;

	cnt_Items[containerid][i] = itemid;
	cnt_ItemContainer[itemid] = containerid;

	RemoveItemFromWorld(itemid);

	CallLocalFunction("OnItemAddedToContainer", "ddd", containerid, itemid, playerid);
	
	return 1;
}

stock RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID, call = 1)
{
	if(!(0 <= slotid < cnt_Data[containerid][cnt_size]))
		return 0;

	if(!IsValidItem(cnt_Items[containerid][slotid]))
	{
		if(cnt_Data[containerid][cnt_size] != INVALID_ITEM_ID)
		{
			cnt_Data[containerid][cnt_size] = INVALID_ITEM_ID;

			if(slotid < (cnt_Data[containerid][cnt_size] - 1))
			{
				for(new i = slotid; i < (cnt_Data[containerid][cnt_size] - 1); i++)
				    cnt_Items[containerid][i] = cnt_Items[containerid][i+1];

				cnt_Items[containerid][(cnt_Data[containerid][cnt_size] - 1)] = INVALID_ITEM_ID;
			}
		}

		return -1;
	}

	if(call)
	{
		if(CallLocalFunction("OnItemRemoveFromContainer", "ddd", containerid, slotid, playerid))
			return 1;
	}

	cnt_ItemContainer[cnt_Items[containerid][slotid]] = INVALID_CONTAINER_ID;
	cnt_Items[containerid][slotid] = INVALID_ITEM_ID;

	if(slotid < (cnt_Data[containerid][cnt_size] - 1))
	{
		for(new i = slotid; i < (cnt_Data[containerid][cnt_size] - 1); i++)
		    cnt_Items[containerid][i] = cnt_Items[containerid][i+1];

		cnt_Items[containerid][(cnt_Data[containerid][cnt_size] - 1)] = INVALID_ITEM_ID;
	}

	if(call)
		CallLocalFunction("OnItemRemovedFromContainer", "ddd", containerid, slotid, playerid);

	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnItemDestroy(itemid)
{
	cnt_ItemContainer[itemid] = INVALID_CONTAINER_ID;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsValidContainer(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return 1;
}

// cnt_button
stock GetContainerButton(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return cnt_Data[containerid][cnt_button];
}

// cnt_name
stock GetContainerName(containerid, name[])
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	name[0] = EOS;
	strcat(name, cnt_Data[containerid][cnt_name], CNT_MAX_NAME);

	return 1;
}

// cnt_posX
// cnt_posY
// cnt_posZ
stock GetContainerPos(containerid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	x = cnt_Data[containerid][cnt_posX];
	y = cnt_Data[containerid][cnt_posY];
	z = cnt_Data[containerid][cnt_posZ];

	return 1;
}
stock SetContainerPos(containerid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	SetButtonPos(cnt_Data[containerid][cnt_button], x, y, z);

	cnt_Data[containerid][cnt_posX] = x;
	cnt_Data[containerid][cnt_posY] = y;
	cnt_Data[containerid][cnt_posZ] = z;

	return 1;
}

// cnt_size
stock GetContainerSize(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return -1;

	return cnt_Data[containerid][cnt_size];
}
stock SetContainerSize(containerid, size)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	cnt_Data[containerid][cnt_size] = size;

	return 1;
}

// cnt_world
stock GetContainerWorld(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return -1;

	return cnt_Data[containerid][cnt_world];
}
stock SetContainerWorld(containerid, world)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	SetButtonWorld(cnt_Data[containerid][cnt_button], world);
	cnt_Data[containerid][cnt_world] = world;

	return 1;
}

// cnt_interior
stock GetContainerInterior(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return -1;

	return cnt_Data[containerid][cnt_interior];
}
stock SetContainerInterior(containerid, interior)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	SetButtonWorld(cnt_Data[containerid][cnt_button], interior);
	cnt_Data[containerid][cnt_interior] = interior;

	return 1;
}

// cnt_Items
stock GetContainerSlotItem(containerid, slotid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return INVALID_ITEM_ID;

	if(!(0 <= slotid < CNT_MAX_SLOTS))
		return INVALID_ITEM_ID;

	return cnt_Items[containerid][slotid];
}

stock IsContainerSlotUsed(containerid, slotid)
{
	if(!(0 <= slotid < CNT_MAX_SLOTS))
		return -1;

	if(!IsValidItem(cnt_Items[containerid][slotid]))
		return 0;

	return 1;
}

stock IsContainerFull(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return IsValidItem(cnt_Items[containerid][cnt_Data[containerid][cnt_size]-1]);
}

stock IsContainerEmpty(containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	return !IsValidItem(cnt_Items[containerid][0]);
}

stock WillItemTypeFitInContainer(containerid, ItemType:itemtype)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	new
		i,
		count,
		size = GetItemTypeSize(itemtype);

	if(size == ITEM_SIZE_MEDIUM)
	{
		if(cnt_Data[containerid][cnt_maxOfSize][0] == -1)
			return 1;

		if(cnt_Data[containerid][cnt_maxOfSize][0] == 0)
			return 0;

		while(i < cnt_Data[containerid][cnt_size])
		{
			if(!IsValidItem(cnt_Items[containerid][i]))
				break;

			if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_MEDIUM)
				count++;

			if(count >= cnt_Data[containerid][cnt_maxOfSize][0])
				return 0;

			i++;
		}
	}
	if(size == ITEM_SIZE_LARGE)
	{
		if(cnt_Data[containerid][cnt_maxOfSize][1] == -1)
			return 1;

		if(cnt_Data[containerid][cnt_maxOfSize][1] == 0)
			return 0;

		while(i < cnt_Data[containerid][cnt_size])
		{
			if(!IsValidItem(cnt_Items[containerid][i]))
				break;

			if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_LARGE)
				count++;

			if(count >= cnt_Data[containerid][cnt_maxOfSize][1])
				return 0;

			i++;
		}
	}
	if(size == ITEM_SIZE_CARRY)
	{
		if(cnt_Data[containerid][cnt_maxOfSize][2] == -1)
			return 1;

		if(cnt_Data[containerid][cnt_maxOfSize][2] == 0)
			return 0;

		while(i < cnt_Data[containerid][cnt_size])
		{
			if(!IsValidItem(cnt_Items[containerid][i]))
				break;

			if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_CARRY)
				count++;

			if(count >= cnt_Data[containerid][cnt_maxOfSize][2])
				return 0;

			i++;
		}
	}
	
	return 1;
}


stock GetContainerFreeSlots(containerid)
{
	for(new i, j = cnt_Data[containerid][cnt_size]; i < j; i++)
	{
		if(!IsValidItem(cnt_Items[containerid][i]))
			return cnt_Data[containerid][cnt_size] - (i + 1);
	}
	return 0;
}

stock GetItemContainer(itemid)
{
	if(!IsValidItem(itemid))
		return INVALID_CONTAINER_ID;

	return cnt_ItemContainer[itemid];
}

stock GetButtonContainer(buttonid)
{
	if(!IsValidButton(buttonid))
		return INVALID_CONTAINER_ID;

	return cnt_ButtonContainer[buttonid];
}
