/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


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
				accessible via showing the dialog in a script.

			Parameters:
				<name> (string)
					The title displayed in the contents dialog and the button
					label if there is one.

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
				-

			Parameters:
				-

			Returns:
				-
		}

		native AddItemToContainer(containerid, itemid, playerid = INVALID_PLAYER_ID)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native DisplayContainerInventory(playerid, containerid, showoptions = 0)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Container/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Container/Callbacks
		native -

		native OnPlayerOpenContainer(playerid, containerid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerCloseContainer(playerid, containerid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerAddToContainer(playerid, containerid, itemid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerAddedToContainer(playerid, containerid, itemid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerTakeFromContainer(playerid, containerid, slotid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerTakenFromContainer(playerid, containerid, slotid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerViewContainerOpt(playerid, containerid);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerSelectContainerOpt(playerid, containerid, option);
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
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
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerButton(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerName(containerid, name[])
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerPos(containerid, &Float:x, &Float:y, &Float:z)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerPos(containerid, Float:x, Float:y, Float:z)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerSize(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerSize(containerid, size)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerWorld(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerWorld(containerid, world)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerInterior(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native SetContainerInterior(containerid, interior)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerCurrentContainer(playerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerContainerButtonArea(playerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerContainerSlot(playerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}

		native GetContainerSlotItem(containerid, slot)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
		native IsContainerSlotUsed(containerid, slotid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
		native IsContainerFull(containerid)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/Container/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		DisplayContainerOptions(playerid, slotid)
		{
			Description:
				-
		}
	}

	SIF/Container/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerConnect
		{
			Reason:
				-
		}
		SAMP/OnDialogResponse
		{
			Reason:
				-
		}
		SIF/Button/OnButtonPress
		{
			Reason:
				-
		}
	}

==============================================================================*/


#if !defined _SIF_ITEM_INCLUDED
	#include <SIF/Item.pwn>
#endif

#if !defined _SIF_INVENTORY_INCLUDED
	#include <SIF/Inventory.pwn>
#endif

#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_CONTAINER_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


#define CNT_MAX						(4096)
#define CNT_MAX_NAME				(32)
#define CNT_MAX_SLOTS				(24)
#define DIALOG_CONTAINER_LIST		(9002)
#define DIALOG_CONTAINER_OPTIONS	(9003)
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


static
			cnt_Data					[CNT_MAX][E_CONTAINER_DATA],
			cnt_Items					[CNT_MAX][CNT_MAX_SLOTS],
Iterator:	cnt_Index<CNT_MAX>;

static
			cnt_CurrentContainer		[MAX_PLAYERS],
			cnt_SelectedSlot			[MAX_PLAYERS],
			cnt_OptionsList				[MAX_PLAYERS][128],
			cnt_OptionsCount			[MAX_PLAYERS],
			cnt_InventoryContainerItem	[MAX_PLAYERS],
			cnt_InventoryOptionID		[MAX_PLAYERS];


forward OnPlayerOpenContainer(playerid, containerid);
forward OnPlayerCloseContainer(playerid, containerid);
forward OnPlayerAddToContainer(playerid, containerid, itemid);
forward OnPlayerAddedToContainer(playerid, containerid, itemid);
forward OnPlayerTakeFromContainer(playerid, containerid, slotid);
forward OnPlayerTakenFromContainer(playerid, containerid, slotid);
forward OnPlayerViewContainerOpt(playerid, containerid);
forward OnPlayerSelectContainerOpt(playerid, containerid, option);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
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
		cnt_Data[id][cnt_button] = CreateButton(x, y, z, "Press F to open", world, interior, 1.0, label, name);

	else
		cnt_Data[id][cnt_button] = INVALID_BUTTON_ID;

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

	DestroyButton(cnt_Data[containerid][cnt_button]);
	cnt_Data[containerid][cnt_button] = INVALID_BUTTON_ID;

	for(new i; i < cnt_Data[containerid][cnt_size]; i++)
		DestroyItem(cnt_Items[containerid][i]);

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

	if(playerid != INVALID_PLAYER_ID)
	{
		if(CallLocalFunction("OnPlayerAddToContainer", "ddd", playerid, containerid, itemid))
			return 1;
	}

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
		return -2;

	cnt_Items[containerid][i] = itemid;

	RemoveItemFromWorld(itemid);

	if(playerid != INVALID_PLAYER_ID)
		CallLocalFunction("OnPlayerAddedToContainer", "ddd", playerid, containerid, itemid);
	
	return 1;
}

stock RemoveItemFromContainer(containerid, slotid, playerid = INVALID_PLAYER_ID)
{
	if(!(0 <= slotid < cnt_Data[containerid][cnt_size]))
		return 0;

	if(playerid != INVALID_PLAYER_ID)
	{
		if(CallLocalFunction("OnPlayerTakeFromContainer", "ddd", playerid, containerid, slotid))
			return 1;
	}

	cnt_Items[containerid][slotid] = INVALID_ITEM_ID;
	
	if(slotid < (cnt_Data[containerid][cnt_size] - 1))
	{
		for(new i = slotid; i < (cnt_Data[containerid][cnt_size] - 1); i++)
		    cnt_Items[containerid][i] = cnt_Items[containerid][i+1];

		cnt_Items[containerid][(cnt_Data[containerid][cnt_size] - 1)] = INVALID_ITEM_ID;
	}

	if(playerid != INVALID_PLAYER_ID)
		CallLocalFunction("OnPlayerTakenFromContainer", "ddd", playerid, containerid, slotid);

	return 1;
}

stock DisplayContainerInventory(playerid, containerid)
{
	if(!Iter_Contains(cnt_Index, containerid))
		return 0;

	new
		list[CNT_MAX_SLOTS * (ITM_MAX_NAME + 1)],
		tmp[ITM_MAX_NAME];

	for(new i; i < cnt_Data[containerid][cnt_size]; i++)
	{
		if(!IsValidItem(cnt_Items[containerid][i])) strcat(list, "<Empty>\n");
		else
		{
			GetItemName(cnt_Items[containerid][i], tmp);
			strcat(list, tmp);
			strcat(list, "\n");
		}
	}

	strcat(list, "My Inventory >");

	cnt_CurrentContainer[playerid] = containerid;

	if(CallLocalFunction("OnPlayerOpenContainer", "dd", playerid, containerid))
		return 0;

	ShowPlayerDialog(playerid, DIALOG_CONTAINER_LIST, DIALOG_STYLE_LIST, cnt_Data[containerid][cnt_name], list, "Options", "Close");

	SelectTextDraw(playerid, 0xFFFF00FF);

	return 1;
}

stock ClosePlayerContainer(playerid)
{
	ShowPlayerDialog(playerid, -1, 0, "", "", "", "");
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayContainerOptions(playerid, slotid)
{
	new
		tmp[ITM_MAX_NAME];

	GetItemName(cnt_Items[cnt_CurrentContainer[playerid]][slotid], tmp);

	if(GetItemTypeSize(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][slotid])) == ITEM_SIZE_SMALL)
		cnt_OptionsList[playerid] = "Equip\nMove to inventory\n";

	else
		cnt_OptionsList[playerid] = "Equip\n";

	cnt_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewContainerOpt", "dd", playerid, cnt_CurrentContainer[playerid]);

	ShowPlayerDialog(playerid, DIALOG_CONTAINER_OPTIONS, DIALOG_STYLE_LIST, tmp, cnt_OptionsList[playerid], "Accept", "Back");
}

public OnButtonPress(playerid, buttonid)
{
	foreach(new i : cnt_Index)
	{
		if(buttonid == cnt_Data[i][cnt_button])
		{
			DisplayContainerInventory(playerid, i);
			break;
		}
	}

	return CallLocalFunction("cnt_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress cnt_OnButtonPress
forward OnButtonPress(playerid, buttonid);

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_CONTAINER_LIST)
	{
		if(response)
		{
			if(listitem == cnt_Data[cnt_CurrentContainer[playerid]][cnt_size])
				DisplayPlayerInventory(playerid);

			else
			{
				if(!IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][listitem]))
				{
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
				else
				{
					cnt_SelectedSlot[playerid] = listitem;
					DisplayContainerOptions(playerid, listitem);
				}
			}
		}
		else
		{
			CallLocalFunction("OnPlayerCloseContainer", "dd", playerid, cnt_CurrentContainer[playerid]);
			CancelSelectTextDraw(playerid);
			cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
		}
	}

	if(dialogid == DIALOG_CONTAINER_OPTIONS)
	{
		if(!response)
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			return 1;
		}
		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

					RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
					CreateItemInWorld(id);
					GiveWorldItemToPlayer(playerid, id, 1);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
				else
				{
					ShowMsgBox(playerid, "You are already holding something", 3000, 200);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
			}
			case 1:
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]])) != ITEM_SIZE_SMALL)
				{
					CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, cnt_CurrentContainer[playerid], 0);
					return 1;
				}

				new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

				if(IsPlayerInventoryFull(playerid) || !IsValidItem(id))
				{
					ShowMsgBox(playerid, "Inventory full", 3000, 100);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
					return 0;
				}

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
				AddItemToInventory(playerid, id);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			}
			default:
			{
				CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, cnt_CurrentContainer[playerid], listitem - 2);
			}
		}
	}

	return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(Iter_Contains(cnt_Index, cnt_CurrentContainer[playerid]))
		{
			ClosePlayerContainer(playerid);
		}
	}

	return 1;
}

public OnPlayerViewInventoryOpt(playerid)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		new str[8 + CNT_MAX_NAME];
		str = "Move to ";
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		cnt_InventoryOptionID[playerid] = AddInventoryOption(playerid, str);
	}

	return CallLocalFunction("cnt_OnPlayerViewInventoryOpt", "d", playerid);
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt cnt_OnPlayerViewInventoryOpt
forward OnPlayerViewInventoryOpt(playerid);

public OnPlayerSelectInventoryOpt(playerid, option)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		if(option == cnt_InventoryOptionID[playerid])
		{
			new
				slot,
				itemid;

			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][cnt_Data[cnt_CurrentContainer[playerid]][cnt_size]-1]) || !IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return 0;
			}

			RemoveItemFromInventory(playerid, slot);
			AddItemToContainer(cnt_CurrentContainer[playerid], itemid, playerid);
			DisplayPlayerInventory(playerid);
		}
	}

	return CallLocalFunction("cnt_OnPlayerSelectInventoryOpt", "dd", playerid, option);
}
#if defined _ALS_OnPlayerSelectInventoryOpt
	#undef OnPlayerSelectInventoryOpt
#else
	#define _ALS_OnPlayerSelectInventoryOpt
#endif
#define OnPlayerSelectInventoryOpt cnt_OnPlayerSelectInventoryOpt
forward OnPlayerSelectInventoryOpt(playerid, option);

public OnPlayerOpenInventory(playerid)
{
	if(Iter_Contains(cnt_Index, cnt_CurrentContainer[playerid]))
	{
		new str[CNT_MAX_NAME + 2];
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		strcat(str, " >");
		cnt_InventoryContainerItem[playerid] = AddInventoryListItem(playerid, str);
	}

	return CallLocalFunction("cnt_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory cnt_OnPlayerOpenInventory
forward OnPlayerOpenInventory(playerid);

public OnPlayerSelectExtraItem(playerid, item)
{
	if(Iter_Contains(cnt_Index, cnt_CurrentContainer[playerid]))
	{
		if(item == cnt_InventoryContainerItem[playerid])
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
		}
	}

	return CallLocalFunction("cnt_OnPlayerSelectExtraItem", "dd", playerid, item);
}
#if defined _ALS_OnPlayerSelectExtraItem
	#undef OnPlayerSelectExtraItem
#else
	#define _ALS_OnPlayerSelectExtraItem
#endif
#define OnPlayerSelectExtraItem cnt_OnPlayerSelectExtraItem
forward OnPlayerSelectExtraItem(playerid, item);


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

// cnt_CurrentContainer
stock GetPlayerCurrentContainer(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_CONTAINER_ID;

	return cnt_CurrentContainer[playerid];
}
stock GetPlayerContainerButtonArea(playerid)
{
	new button = GetPlayerButtonID(playerid);

	foreach(new i : cnt_Index)
		if(button == cnt_Data[i][cnt_button]) return i;

	return INVALID_CONTAINER_ID;
}

// cnt_SelectedSlot
stock GetPlayerContainerSlot(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	return cnt_SelectedSlot[playerid];
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
		count;

	while(i < cnt_Data[containerid][cnt_size])
	{
		if(IsValidItem(cnt_Items[containerid][i]))
		{
			if(GetItemTypeSize(itemtype) == ITEM_SIZE_MEDIUM && cnt_Data[containerid][cnt_maxOfSize][0] != -1)
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_MEDIUM)
					count++;

				if(count >= cnt_Data[containerid][cnt_maxOfSize][0])
					return 0;
			}
			else if(GetItemTypeSize(itemtype) == ITEM_SIZE_LARGE && cnt_Data[containerid][cnt_maxOfSize][1] != -1)
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_LARGE)
					count++;

				if(count >= cnt_Data[containerid][cnt_maxOfSize][1])
					return 0;
			}
			else if(GetItemTypeSize(itemtype) == ITEM_SIZE_CARRY && cnt_Data[containerid][cnt_maxOfSize][2] != -1)
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[containerid][i])) == ITEM_SIZE_CARRY)
					count++;

				if(count >= cnt_Data[containerid][cnt_maxOfSize][2])
					return 0;
			}
		}
		else
		{
			break;
		}
		i++;
	}
	
	return 1;
}

stock AddContainerOption(playerid, option[])
{
	if(strlen(cnt_OptionsList[playerid]) + strlen(option) > sizeof(cnt_OptionsList[]))
		return 0;

	strcat(cnt_OptionsList[playerid], option);
	strcat(cnt_OptionsList[playerid], "\n");

	return cnt_OptionsCount[playerid]++;
}
