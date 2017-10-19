/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

An extension for SIF/Inventory that uses SA:MP dialog menus for player
interaction with their inventory items.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_INVENTORY_DIALOG_INCLUDED
	#endinput
#endif

#include <YSI\y_hooks>
#include <easyDialog>

#define _SIF_INVENTORY_DIALOG_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Functions


forward DisplayPlayerInventory(playerid);
/*
# Description:
-
*/

forward ClosePlayerInventory(playerid, call = false);
/*
# Description:
-
*/

forward GetPlayerSelectedInventorySlot(playerid);
/*
# Description:
-
*/

forward AddInventoryListItem(playerid, itemname[]);
/*
# Description:
-
*/

forward AddInventoryOption(playerid, option[]);
/*
# Description:
-
*/

forward GetInventoryListItems(playerid);
/*
# Description:
-
*/

forward GetInventoryOptions(playerid);
/*
# Description:
-
*/

forward GetInventoryListItemCount(playerid);
/*
# Description:
-
*/

forward GetInventoryOptionCount(playerid);
/*
# Description:
-
*/

forward IsPlayerViewingInventory(playerid);
/*
# Description:
-
*/


// Events


forward OnPlayerOpenInventory(playerid);
/*
# Called:
-
*/

forward OnPlayerCloseInventory(playerid);
/*
# Called:
-
*/

forward OnPlayerSelectExtraItem(playerid, item);
/*
# Called:
-
*/

forward OnPlayerRemoveFromInventory(playerid, slotid); // TODO
/*
# Called:
-
*/

forward OnPlayerRemovedFromInventory(playerid, slotid); // TODO
/*
# Called:
-
*/

forward OnPlayerViewInventoryOpt(playerid);
/*
# Called:
-
*/

forward OnPlayerSelectInventoryOpt(playerid, option);
/*
# Called:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
		inv_ItemListTotal			[MAX_PLAYERS],
		inv_SelectedSlot			[MAX_PLAYERS],
		inv_ViewingInventory		[MAX_PLAYERS],
		inv_ExtraItemList			[MAX_PLAYERS][128],
		inv_ExtraItemCount			[MAX_PLAYERS],
		inv_OptionsList				[MAX_PLAYERS][128],
		inv_OptionsCount			[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			inv_SelectedSlot[i] = -1;
		}
	}
}

hook OnPlayerConnect(playerid)
{
	for(new j; j < INV_MAX_SLOTS; j++)
	{
		inv_SelectedSlot[playerid] = -1;
	}
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock DisplayPlayerInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new
		title[18],
		list[(INV_MAX_SLOTS * (ITM_MAX_NAME + ITM_MAX_TEXT + 1)) + 32],
		itemid,
		tmp[5 + ITM_MAX_NAME + ITM_MAX_TEXT + 1];

	inv_ItemListTotal[playerid] = 0;

	for(new i; i < GetPlayerInventorySize(playerid); i++)
	{
		itemid = GetInventorySlotItem(playerid, i);

		if(!IsValidItem(itemid))
			break;

		GetItemName(itemid, tmp);

		format(list, sizeof(list), "%s[%02d]%s\n", list, GetItemTypeSize(GetItemType(itemid)), tmp);
		inv_ItemListTotal[playerid]++;
	}

	for(new i; i < GetInventoryFreeSlots(playerid); i++)
	{
		strcat(list, "<Empty>\n");
		inv_ItemListTotal[playerid]++;
	}

	inv_ExtraItemList[playerid][0] = EOS;
	inv_ExtraItemCount[playerid] = 0;

	if(CallLocalFunction("OnPlayerOpenInventory", "d", playerid))
		return 0;

	if(!isnull(inv_ExtraItemList[playerid]))
		strcat(list, inv_ExtraItemList[playerid]);

	format(title, sizeof(title), "Inventory (%d/%d)", GetPlayerInventorySize(playerid) - GetInventoryFreeSlots(playerid), GetPlayerInventorySize(playerid));

	Dialog_Show(playerid, SIF_PlayerInventory, DIALOG_STYLE_LIST, title, list, "Options", "Close");

	inv_ViewingInventory[playerid] = true;

	return 1;
}

Dialog:SIF_PlayerInventory(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(listitem >= inv_ItemListTotal[playerid])
		{
			CallLocalFunction("OnPlayerSelectExtraItem", "dd", playerid, listitem - inv_ItemListTotal[playerid]);
			inv_ViewingInventory[playerid] = false;
			return 1;
		}

		if(!IsValidItem(GetInventorySlotItem(playerid, listitem)))
		{
			DisplayPlayerInventory(playerid);
		}
		else
		{
			inv_SelectedSlot[playerid] = listitem;
			DisplayPlayerInventoryOptions(playerid, listitem);
		}
	}
	else
	{
		ClosePlayerInventory(playerid, true);
	}

	return 1;
}

stock ClosePlayerInventory(playerid, call = false)
{
	if(!inv_ViewingInventory[playerid])
		return 0;

	if(call)
	{
		if(CallLocalFunction("OnPlayerCloseInventory", "d", playerid))
		{
			DisplayPlayerInventory(playerid);
			return 1;
		}
	}

	ShowPlayerDialog(playerid, -1, 0, NULL, NULL, NULL, NULL);
	inv_ViewingInventory[playerid] = false;

	return 1;
}

stock GetPlayerSelectedInventorySlot(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return inv_SelectedSlot[playerid];
}

stock AddInventoryListItem(playerid, itemname[])
{
	if(strlen(inv_ExtraItemList[playerid]) + strlen(itemname) > sizeof(inv_ExtraItemList[]))
		return 0;

	strcat(inv_ExtraItemList[playerid], itemname);
	strcat(inv_ExtraItemList[playerid], "\n");

	return inv_ExtraItemCount[playerid]++;
}

stock AddInventoryOption(playerid, option[])
{
	if(strlen(inv_OptionsList[playerid]) + strlen(option) > sizeof(inv_OptionsList[]))
		return 0;

	strcat(inv_OptionsList[playerid], option);
	strcat(inv_OptionsList[playerid], "\n");

	return inv_OptionsCount[playerid]++;
}

stock GetInventoryListItems(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ExtraItemList[playerid];
}

stock GetInventoryOptions(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_OptionsList[playerid];
}

stock GetInventoryListItemCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ExtraItemCount[playerid];
}

stock GetInventoryOptionCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_OptionsCount[playerid];
}

stock IsPlayerViewingInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ViewingInventory[playerid];
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayPlayerInventoryOptions(playerid, slotid)
{
	new
		name[ITM_MAX_NAME + ITM_MAX_TEXT];

	GetItemName(GetInventorySlotItem(playerid, slotid), name);
	inv_OptionsList[playerid] = "Equip\nUse\nDrop\n";
	inv_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewInventoryOpt", "d", playerid);

	Dialog_Show(playerid, SIF_PlayerInvOptions, DIALOG_STYLE_LIST, name, inv_OptionsList[playerid], "Accept", "Back");

	return 1;
}

Dialog:SIF_PlayerInvOptions(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		DisplayPlayerInventory(playerid);
		return 1;
	}

	switch(listitem)
	{
		case 0:
		{
			if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
			{
				new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

				RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
				GiveWorldItemToPlayer(playerid, itemid, 1);
				DisplayPlayerInventory(playerid);
			}
			else
			{
				ShowActionText(playerid, "You are already holding something", 3000, 200);
				DisplayPlayerInventory(playerid);
			}
		}
		case 1:
		{
			if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
			{
				new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

				RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
				GiveWorldItemToPlayer(playerid, itemid, 1);

				PlayerUseItem(playerid);

				ClosePlayerInventory(playerid, true);
			}
			else
			{
				ShowActionText(playerid, "You are already holding something", 3000, 200);
				DisplayPlayerInventory(playerid);
			}
		}
		case 2:
		{
			if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
			{
				new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

				RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
				GiveWorldItemToPlayer(playerid, itemid, 1);

				PlayerDropItem(playerid);

				ClosePlayerInventory(playerid, true);
			}
			else
			{
				ShowActionText(playerid, "You are already holding something", 3000, 200);
				DisplayPlayerInventory(playerid);
			}
		}
		default:
		{
			CallLocalFunction("OnPlayerSelectInventoryOpt", "dd", playerid, listitem - 3);
		}
	}

	return 1;
}