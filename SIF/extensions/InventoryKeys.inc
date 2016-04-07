/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.4.0
	Module Version: 1.1.4


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/FILENAME/Description
	{
		An extension script for SIF/Inventory that allows players to interact
		with their inventory using key presses.
	}

	SIF/FILENAME/Dependencies
	{
		SIF/Inventory
	}

	SIF/FILENAME/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/FILENAME/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/FILENAME/Core
		native -

		native Func(params)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/FILENAME/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/FILENAME/Callbacks
		native -

		native OnPlayerAddToInventory(playerid, itemid);
		{
			Called:
				When a player adds an item to his inventory by pressing Y.

			Parameters:
				<playerid> (int)
					The player who added an item to his inventory.

				<itemid> (int, itemid)
					The ID handle of the item that was added.

			Returns:
				1
					To cancel the action and disallow the player to add the
					item to his inventory.
		}

		native OnPlayerAddedToInventory(playerid, itemid);
		{
			Called:
				After a player has added an item to their inventory and the
				inventory index has been updated with the new item.

			Parameters:
				<playerid> (int)
					The player who added an item to his inventory.

				<itemid> (int, itemid)
					The ID handle of the item that was added.

			Returns:
				(none)
		}

	}

	SIF/FILENAME/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/FILENAME/Interface
		native -

		native Func(params)
		{
			Description:
				-

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/FILENAME/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		Func(params)
		{
			Description:
				-
		}
	}

	SIF/FILENAME/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerSomething
		{
			Reason:
				-
		}
	}

==============================================================================*/


#if defined _SIF_INVENTORY_KEYS_INCLUDED
	#endinput
#endif

#include <YSI_4\y_hooks>

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


