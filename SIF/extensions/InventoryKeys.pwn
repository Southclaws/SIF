/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

An extension script for SIF/Inventory that allows players to interact with their
inventory using key presses.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_INVENTORY_KEYS_INCLUDED
	#endinput
#endif

#include <YSI\y_hooks>

#define _SIF_INVENTORY_KEYS_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


static
		inv_PutAwayTick				[MAX_PLAYERS],
Timer:	inv_PutAwayTimer			[MAX_PLAYERS];


forward OnPlayerAddToInventory(playerid, itemid);
forward OnPlayerAddedToInventory(playerid, itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


/*==============================================================================

	Core Functions

==============================================================================*/


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		if(newkeys & KEY_CTRL_BACK)
		{
			DisplayPlayerInventory(playerid);
		}

		if(newkeys & KEY_YES)
		{
			_HandlePutItemAway(playerid);
		}
	}

	return 1;
}

_HandlePutItemAway(playerid)
{
	if(sif_GetTickCountDiff(GetTickCount(), inv_PutAwayTick[playerid]) < 1000)
		return;

	new itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return;

	new
		itemsize = GetItemTypeSize(GetItemType(itemid)),
		freeslots = GetInventoryFreeSlots(playerid);

	if(itemsize > freeslots)
	{
		new message[37];
		format(message, sizeof(message), "Extra %d slots required", itemsize - freeslots);
		ShowActionText(playerid, message, 3000, 150);
		return;
	}

	if(CallLocalFunction("OnPlayerAddToInventory", "dd", playerid, itemid))
		return;

	inv_PutAwayTick[playerid] = GetTickCount();

	ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
	stop inv_PutAwayTimer[playerid];
	inv_PutAwayTimer[playerid] = defer PlayerPutItemInInventory(playerid, itemid);

	return;
}

timer PlayerPutItemInInventory[300](playerid, itemid)
{
	AddItemToInventory(playerid, itemid);
	CallLocalFunction("OnPlayerAddedToInventory", "dd", playerid, itemid);
}


/*==============================================================================

	Interface

==============================================================================*/


