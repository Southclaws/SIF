/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

An extension script for SIF/Container that adds SA:MP dialogs for player
interaction with containers. Also allows containers and inventories to
work together.

## Hooks

- OnPlayerConnect: Zero initialised array cells.
- OnPlayerViewInvOpt: Insert an option to move inventory item to container.
- OnPlayerSelectInvOpt: To trigger moving an item from inventory to container.
- OnPlayerOpenInventory: Insert a link to the container inventory.
- OnPlayerSelectExtraItem: To open the container inventory from inventory.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_CONTAINER_DIALOG_INCLUDED
	#endinput
#endif

#include <YSI\y_hooks>
#include <easyDialog>

#define _SIF_CONTAINER_DIALOG_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


forward DisplayContainerInventory(playerid, containerid);
/*
# Description:
-
*/

forward ClosePlayerContainer(playerid, call = false);
/*
# Description:
-
*/

forward GetPlayerCurrentContainer(playerid);
/*
# Description:
-
*/

forward GetPlayerContainerSlot(playerid);
/*
# Description:
-
*/

forward AddContainerOption(playerid, option[]);
/*
# Description:
-
*/


// Events


forward OnPlayerOpenContainer(playerid, containerid);
/*
# Description:
-
*/

forward OnPlayerCloseContainer(playerid, containerid);
/*
# Description:
-
*/

forward OnPlayerViewContainerOpt(playerid, containerid);
/*
# Description:
-
*/

forward OnPlayerSelectContainerOpt(playerid, containerid, option);
/*
# Description:
-
*/

forward OnMoveItemToContainer(playerid, itemid, containerid);
/*
# Description:
-
*/

forward OnMoveItemToInventory(playerid, itemid, containerid);
/*
# Description:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
			cnt_ItemListTotal			[MAX_PLAYERS],
			cnt_CurrentContainer		[MAX_PLAYERS],
			cnt_SelectedSlot			[MAX_PLAYERS],
			cnt_InventoryString			[MAX_PLAYERS][CNT_MAX_SLOTS * (ITM_MAX_NAME + ITM_MAX_TEXT + 1)],
			cnt_OptionsList				[MAX_PLAYERS][128],
			cnt_OptionsCount			[MAX_PLAYERS],
			cnt_InventoryContainerItem	[MAX_PLAYERS],
			cnt_InventoryOptionID		[MAX_PLAYERS];


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


stock DisplayContainerInventory(playerid, containerid)
{
	if(!IsValidContainer(containerid))
		return 0;

	new
		title[CNT_MAX_NAME + 9],
		containername[CNT_MAX_NAME],
		itemid,
		tmp[ITM_MAX_NAME + ITM_MAX_TEXT];

	cnt_InventoryString[playerid][0] = EOS;
	cnt_ItemListTotal[playerid] = 0;

	for(new i; i < GetContainerSize(containerid); i++)
	{
		itemid = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(itemid))
			break;

		GetItemName(itemid, tmp);

		format(cnt_InventoryString[playerid], sizeof(cnt_InventoryString[]), "%s[%02d]%s\n", cnt_InventoryString[playerid], GetItemTypeSize(GetItemType(itemid)), tmp);
		cnt_ItemListTotal[playerid]++;
	}

	for(new i; i < GetContainerFreeSlots(containerid); i++)
	{
		strcat(cnt_InventoryString[playerid], "<Empty>\n");
		cnt_ItemListTotal[playerid]++;
	}

	strcat(cnt_InventoryString[playerid], "Open Inventory");

	cnt_CurrentContainer[playerid] = containerid;

	if(CallLocalFunction("OnPlayerOpenContainer", "dd", playerid, containerid))
		return 0;

	GetContainerName(containerid, containername);

	format(title, sizeof(title), "%s (%d/%d)", containername, GetContainerSize(containerid) - GetContainerFreeSlots(containerid), GetContainerSize(containerid));

	if(strlen(cnt_InventoryString[playerid]) >= 2048)
		printf("ERROR: cnt_InventoryString is over 2048 chars: %d", strlen(cnt_InventoryString[playerid]));
	Dialog_Show(playerid, SIF_Container, DIALOG_STYLE_LIST, title, cnt_InventoryString[playerid], "Options", "Close");

	return 1;
}

Dialog:SIF_Container(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(!IsValidContainer(cnt_CurrentContainer[playerid]))
			return 0;

		printf("listitem %d total %d itemcount %d freeslots %d", listitem, cnt_ItemListTotal[playerid], GetContainerItemCount(cnt_CurrentContainer[playerid]), GetContainerFreeSlots(cnt_CurrentContainer[playerid]));

		if(listitem >= cnt_ItemListTotal[playerid])
		{
			DisplayPlayerInventory(playerid);
		}
		else
		{
			if(!(0 <= listitem < CNT_MAX_SLOTS))
			{
				printf("ERROR: Invalid listitem value: %d", listitem);
				return 0;
			}

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
		ClosePlayerContainer(playerid, true);
	}

	return 1;
}

stock ClosePlayerContainer(playerid, call = false)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(cnt_CurrentContainer[playerid] == INVALID_CONTAINER_ID)
		return 0;

	if(call)
	{
		if(CallLocalFunction("OnPlayerCloseContainer", "dd", playerid, cnt_CurrentContainer[playerid]))
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			return 1;
		}
	}

	ShowPlayerDialog(playerid, -1, 0, NULL, NULL, NULL, NULL);
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;

	return 1;
}

stock GetPlayerCurrentContainer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_CONTAINER_ID;

	return cnt_CurrentContainer[playerid];
}

stock GetPlayerContainerSlot(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return cnt_SelectedSlot[playerid];
}

stock AddContainerOption(playerid, option[])
{
	if(strlen(cnt_OptionsList[playerid]) + strlen(option) > sizeof(cnt_OptionsList[]))
		return 0;

	strcat(cnt_OptionsList[playerid], option);
	strcat(cnt_OptionsList[playerid], "\n");

	return cnt_OptionsCount[playerid]++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayContainerOptions(playerid, slotid)
{
	new
		tmp[ITM_MAX_NAME + ITM_MAX_TEXT];

	GetItemName(cnt_Items[cnt_CurrentContainer[playerid]][slotid], tmp);

	cnt_OptionsList[playerid] = "Equip\nMove to inventory\n";
	cnt_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewContainerOpt", "dd", playerid, cnt_CurrentContainer[playerid]);

	Dialog_Show(playerid, SIF_ContainerOptions, DIALOG_STYLE_LIST, tmp, cnt_OptionsList[playerid], "Accept", "Back");

	return 1;
}

Dialog:SIF_ContainerOptions(playerid, response, listitem, inputtext[])
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
			if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
			{
				new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
				GiveWorldItemToPlayer(playerid, id);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			}
			else
			{
				ShowActionText(playerid, "You are already holding something", 3000, 200);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			}
		}
		case 1:
		{
			new itemid = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

			if(!IsValidItem(itemid))
			{
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				return 0;
			}

			if(CallLocalFunction("OnMoveItemToInventory", "ddd", playerid, itemid, cnt_CurrentContainer[playerid]))
				return 0;

			new required = AddItemToInventory(playerid, itemid);

			if(required > 0)
			{
				new str[32];
				format(str, sizeof(str), "Extra %d slots required", required);
				ShowActionText(playerid, str, 3000, 150);
			}
			else if(required == 0)
			{
				RemoveItemFromContainer(cnt_CurrentContainer[playerid], GetItemContainerSlot(itemid), playerid);
			}

			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);

			return 1;
		}
		default:
		{
			CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, cnt_CurrentContainer[playerid], listitem - 2);
		}
	}

	return 1;
}

hook OnPlayerViewInvOpt(playerid)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		new str[8 + CNT_MAX_NAME];
		str = "Move to ";
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		cnt_InventoryOptionID[playerid] = AddInventoryOption(playerid, str);
	}

	return 0;
}

hook OnPlayerSelectInvOpt(playerid, option)
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

			new required = AddItemToContainer(cnt_CurrentContainer[playerid], itemid, playerid);

			if(required == 0)
			{
				if(CallLocalFunction("OnMoveItemToContainer", "ddd", playerid, itemid, cnt_CurrentContainer[playerid]))
					return 0;
			}

			DisplayPlayerInventory(playerid);

			return 1;
		}
	}

	return 0;
}


hook OnPlayerOpenInventory(playerid)
{
	if(IsValidContainer(cnt_CurrentContainer[playerid]))
	{
		new str[CNT_MAX_NAME + 2];
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		strcat(str, " >");
		cnt_InventoryContainerItem[playerid] = AddInventoryListItem(playerid, str);
	}

	return 0;
}


hook OnPlayerSelectExtraItem(playerid, item)
{
	if(IsValidContainer(cnt_CurrentContainer[playerid]))
	{
		if(item == cnt_InventoryContainerItem[playerid])
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
		}
	}

	return 0;
}
