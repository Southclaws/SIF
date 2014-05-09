/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	Version: 2.0.1


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
#include <YSI\y_va>

#define _SIF_DEBUG_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


#if !defined MAX_DEBUG_HANDLER
	#define MAX_DEBUG_HANDLER			(128)
#endif

#if !defined MAX_DEBUG_HANDLER_NAME
	#define MAX_DEBUG_HANDLER_NAME		(32)
#endif

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
		printf("%s[%s:%d]: %s", DEBUG_PREFIX, dbg_Name[handler], level, msg);
	}

	return 1;
}

stock sif_debug_printf(handler, level, playerid, string[], va_args<>)
{
	if(!SIF_IS_VALID_HANDLER(handler))
		return 0;

	if(dbg_Level[handler] < level)
		return 0;

	if(playerid != INVALID_PLAYER_ID && dbg_PlayerLevel[playerid][handler] < level)
		return 0;

	new str[256];
	va_format(str, sizeof(str), string, va_start<4>);
	sif_debug_print(handler, level, playerid, str);

	return 1;
}

stock sif_debug_handler_search(name[], thresh = 3)
{
	new
		bestmatch = -1,
		longest,
		len,
		j;

	for(new i; i < dbg_Total; i++)
	{
		len = strlen(dbg_Name[i]);

		while(j < len)
		{
			if(name[j] != dbg_Name[i][j])
			{
				if(j > longest)
				{
					longest = j;

					if(j > thresh)
						bestmatch = i;
				}
				break;
			}

			j++;
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
