/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

Basic debugging that can be activated/deactivated during runtime.

## Dependencies

- YSI/y_hooks
- YSI/y_va

## Hooks

- OnPlayerConnect: Zeroing some variables and resetting stuff.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_DEBUG_INCLUDED
	#endinput
#endif

#include <YSI\y_va>
#include <YSI\y_hooks>

#define _SIF_DEBUG_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Maximum debug handlers that can be registered.
#if !defined MAX_DEBUG_HANDLER
	#define MAX_DEBUG_HANDLER			(128)
#endif

// Debug handler name length limit.
#if !defined MAX_DEBUG_HANDLER_NAME
	#define MAX_DEBUG_HANDLER_NAME		(32)
#endif


// Functions


forward sif_debug_register_handler(name[], initstate = 0);
/*
# Description
Registers a new debug handler. A debug handler is an identifier for a collection
of debug messages. A handler can be activated and deactivated during runtime
allowing for instant debugging of problems found while using a script.
*/

forward sif_debug_level(handler, level);
/*
# Description
Sets the debug level for a specific debug handler.
*/

forward sif_debug_plevel(playerid, handler, level);
/*
# Description
(scheduled for depreciation)
*/

forward sif_debug_print(handler, level, playerid, msg[]);
/*
# Description
Prints a debug message on the specified handler for the specified level. If the
level is higher than the active level for the handler, nothing will happen.
*/

forward sif_debug_printf(handler, level, playerid, string[], {Float,_}:...);
/*
# Description
Prints a formatted debug message on the specified handler for the specified
level. If the level is higher than the active level for the handler, nothing
will happen.
*/

forward sif_debug_handler_search(name[]);
/*
# Description
Searches for a debug handler name and returns the ID.
*/

forward sif_debug_get_handler_name(handler, output[]);
/*
# Description
Returns a debug handler name for the specified ID.
*/


/*==============================================================================

	Setup

==============================================================================*/


#define SIF_IS_VALID_HANDLER(%0)		(0 <= %0 < dbg_Total)
#define sif_dp:%0:%1(%2)<%3>			sif_debug_printf(%1,%0,%3,%2)
#define sif_d:%0:%1(%2)					sif_debug_printf(%1,%0,INVALID_PLAYER_ID,%2)


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

static const DEBUG_PREFIX[32] = "$ ";


static
		dbg_Name[MAX_DEBUG_HANDLER][MAX_DEBUG_HANDLER_NAME],
		dbg_Level[MAX_DEBUG_HANDLER] = {255, 0, 0, ...}, // set handler 0 to 255
		dbg_PlayerLevel[MAX_DEBUG_HANDLER][MAX_PLAYERS],
		dbg_Total = 1; // handler 0 is global


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	for(new i; i < dbg_Total; i++)
		dbg_PlayerLevel[playerid][i] = 0;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock sif_debug_register_handler(name[], initstate = 0)
{
	strcat(dbg_Name[dbg_Total], name);
	dbg_Level[dbg_Total] = initstate;

	printf("Registered SIF debug handler %d: '%s' initial state: %d", dbg_Total, dbg_Name[dbg_Total], dbg_Level[dbg_Total]);

	return dbg_Total++;
}

stock sif_debug_level(handler, level)
{
	dbg_Level[handler] = level;

	return 1;
}

stock sif_debug_plevel(playerid, handler, level)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	dbg_PlayerLevel[playerid][handler] = level;

	return 1;
}

stock sif_debug_print(handler, level, playerid, msg[])
{
	if(!SIF_IS_VALID_HANDLER(handler))
		return 0;

	if(playerid != INVALID_PLAYER_ID)
	{
		if(level <= dbg_PlayerLevel[playerid][handler])
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			SendClientMessage(playerid, -1, msg);
		}
	}

	if(level <= dbg_Level[handler])
	{
		printf("%s[%s:%d]: %s", DEBUG_PREFIX, handler == 0 ? ("SIF/Global") : dbg_Name[handler], level, msg);
	}

	return 1;
}

stock sif_debug_printf(handler, level, playerid, string[], {Float,_}:...)
{
	if(!SIF_IS_VALID_HANDLER(handler))
		return 0;

	if(dbg_Level[handler] < level)
		return 0;

	if(playerid != INVALID_PLAYER_ID && dbg_PlayerLevel[playerid][handler] < level)
		return 0;

	new str[256];
	format(str, sizeof(str), string, ___(4));
	sif_debug_print(handler, level, playerid, str);

	return 1;
}

stock sif_debug_handler_search(name[])
{
	new bestmatch = -1;

	// Needs a better search algorithm...
	for(new i; i < dbg_Total; i++)
	{
		if(strfind(dbg_Name[i], name, true) != -1)
		{
			bestmatch = i;
			break;
		}
	}

	return bestmatch;
}

stock sif_debug_get_handler_name(handler, output[])
{
	if(!SIF_IS_VALID_HANDLER(handler))
		return 0;

	output[0] = EOS;
	strcat(output, dbg_Name[handler], MAX_DEBUG_HANDLER_NAME);

	return 1;
}
