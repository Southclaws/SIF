/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.4.0
	Module Version: 1.1.1


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

		native Func(params)
		{
			Called:
				-

			Parameters:
				-

			Returns:
				-
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

#include <YSI\y_hooks>

#define _SIF_INVENTORY_KEYS_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


static
		inv_PutAwayTick				[MAX_PLAYERS],
Timer:	inv_PutAwayTimer			[MAX_PLAYERS];


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
		if(newkeys & KEY_YES)
		{
			if(tickcount() - inv_PutAwayTick[playerid] < 1000)
				return 0;

			inv_PutAwayTick[playerid] = tickcount();

			new itemid = GetPlayerItem(playerid);

			if(IsValidItem(itemid))
			{
				if(!WillItemTypeFitInInventory(playerid, GetItemType(itemid)))
				{
					ShowActionText(playerid, "Inventory full", 3000, 100);
				}
				else
				{
					ShowActionText(playerid, "Item added to inventory", 3000, 150);
					ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
					stop inv_PutAwayTimer[playerid];
					inv_PutAwayTimer[playerid] = defer PlayerPutItemInInventory(playerid, itemid);
				}
			}
		}
	}

	return 1;
}

timer PlayerPutItemInInventory[300](playerid, itemid)
{
	AddItemToInventory(playerid, itemid);
}


/*==============================================================================

	Interface

==============================================================================*/


