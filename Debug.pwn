/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	Version: 1.0.0


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Debug/Description
	{
		Basic debugging that can be activated/deactivated during runtime.
	}

	SIF/Debug/Dependencies
	{
		YSI\y_hooks
	}

	SIF/Debug/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Debug/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Debug/Core
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

	SIF/Debug/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Debug/Callbacks
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

	SIF/Debug/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Debug/Interface
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

	SIF/Debug/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		Func(params)
		{
			Description:
				-
		}
	}

	SIF/Debug/Hooks
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


#include <YSI\y_hooks>

#define _SIF_DEBUG_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


enum
{
	SIF_DEBUG_LEVEL_NONE,
	SIF_DEBUG_LEVEL_CALLBACKS,
	SIF_DEBUG_LEVEL_CALLBACKS_DEEP,
	SIF_DEBUG_LEVEL_CORE,
	SIF_DEBUG_LEVEL_CORE_DEEP,
	SIF_DEBUG_LEVEL_INTERNAL,
	SIF_DEBUG_LEVEL_INTERNAL_DEEP,
	SIF_DEBUG_LEVEL_INTERFACE,
	SIF_DEBUG_LEVEL_INTERFACE_DEEP,
	SIF_DEBUG_LEVEL_LOOPS
}

static
	dbg_Level,
	dbg_PlayerLevel[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	dbg_PlayerLevel[playerid] = 0;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock sif_debug_level(playerid, level)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	dbg_PlayerLevel[playerid] = level;

	return 1;
}

stock sif_debug_plevel(playerid, level)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	dbg_PlayerLevel[playerid] = level;

	return 1;
}

stock sif_debug(level, msg[], playerid = INVALID_PLAYER_ID)
{
	if(playerid != INVALID_PLAYER_ID)
	{
		if(!IsPlayerConnected(playerid))
			return 0;

		if(level <= dbg_PlayerLevel[playerid] && dbg_PlayerLevel[playerid] != 0)
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			SendClientMessage(playerid, -1, msg);
			printf("[DEBUG:SIF%d] %s (%d: %s)", level, msg, playerid, name);
		}
	}
	else
	{
		if(level <= dbg_Level && dbg_Level != 0)
		{
			printf("[DEBUG:SIF%d] %s", level, msg);
		}
	}

	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


/*==============================================================================

	Interface

==============================================================================*/


