/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.3.0
	Module Version: 1.2.1


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Core/Description
	{
		A fundamental library with features used by multiple SIF scripts.
	}

	SIF/Core/Dependencies
	{
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Core/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Core/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Core/Core
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

	SIF/Core/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Core/Callbacks
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

	SIF/Core/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Core/Interface
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

	SIF/Core/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		Func(params)
		{
			Description:
				-
		}
	}

	SIF/Core/Hooks
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


#if defined _SIF_CORE_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include <SIF\Debug.pwn>
#endif

#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_CORE_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


new
			gPlayerArea				[MAX_PLAYERS],
PlayerText:	ActionText				[MAX_PLAYERS],
bool:		gViewingActionText		[MAX_PLAYERS],
Timer:		gPlayerActionTextTimer	[MAX_PLAYERS];


forward OnPlayerEnterPlayerArea(playerid, targetid);
forward OnPlayerLeavePlayerArea(playerid, targetid);


/*==============================================================================

	Connection

==============================================================================*/


#if defined FILTERSCRIPT
hook OnFilterScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
			sif_SetUpPlayer(i);
	}
}

hook OnFilterScriptExit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
			sif_UnloadPlayer(i, true);
	}
}
#endif

hook OnPlayerConnect(playerid)
{
	sif_SetUpPlayer(playerid);
}

sif_SetUpPlayer(playerid)
{
	if(!IsValidDynamicArea(gPlayerArea[playerid]))
		gPlayerArea[playerid] = CreateDynamicSphere(0.0, 0.0, 0.0, 2.0);

	ActionText[playerid]			=CreatePlayerTextDraw(playerid, 320.000000, 320.000000, "_");
	PlayerTextDrawAlignment			(playerid, ActionText[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ActionText[playerid], 255);
	PlayerTextDrawFont				(playerid, ActionText[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ActionText[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, ActionText[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ActionText[playerid], 1);
}

sif_UnloadPlayer(playerid, doTD = false)
{
	DestroyDynamicArea(gPlayerArea[playerid]);
	gPlayerArea[playerid] = -1;

	if(doTD)
	{
		PlayerTextDrawHide(playerid, ActionText[playerid]);
		PlayerTextDrawDestroy(playerid, ActionText[playerid]);
	}
}

hook OnPlayerDisconnect(playerid)
{
	sif_UnloadPlayer(playerid);
}

hook OnPlayerSpawn(playerid)
{
	AttachDynamicAreaToPlayer(gPlayerArea[playerid], playerid);
}


/*==============================================================================

	Player Area

==============================================================================*/


hook OnPlayerEnterDynArea(playerid, areaid)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING && !IsPlayerInAnyVehicle(playerid))
	{
		#if defined _FOREACH_BOT
			foreach(new i : Character)
		#else
			foreach(new i : Player)
		#endif
		{
			if(i == playerid)
				continue;

			if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
				continue;

			if(IsPlayerInAnyVehicle(i))
				continue;

			if(areaid == gPlayerArea[i])
			{
				CallLocalFunction("OnPlayerEnterPlayerArea", "dd", playerid, i);
			}
		}
	}
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING && !IsPlayerInAnyVehicle(playerid))
	{
		#if defined _FOREACH_BOT
			foreach(new i : Character)
		#else
			foreach(new i : Player)
		#endif
		{
			if(i == playerid)
				continue;

			if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
				continue;

			if(IsPlayerInAnyVehicle(i))
				continue;

			if(areaid == gPlayerArea[i])
			{
				CallLocalFunction("OnPlayerLeavePlayerArea", "dd", playerid, i);
			}
		}
	}
}

stock IsPlayerInPlayerArea(playerid, targetid)
{
	if(playerid == targetid)
		return 0;
	
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
		return 0;

	if(IsPlayerInAnyVehicle(targetid))
		return 0;

	return IsPlayerInDynamicArea(playerid, gPlayerArea[targetid]);
}


/*==============================================================================

	Message Box

==============================================================================*/


stock ShowActionText(playerid, message[], time=0, width=200)
{
	PlayerTextDrawSetString(playerid, ActionText[playerid], message);
	PlayerTextDrawTextSize(playerid, ActionText[playerid], width, 300);
	PlayerTextDrawShow(playerid, ActionText[playerid]);
	if(time != 0)
	{
	    stop gPlayerActionTextTimer[playerid];
		gPlayerActionTextTimer[playerid] = defer Internal_HideActionText(playerid, time);
	}
	gViewingActionText[playerid] = true;
}
timer Internal_HideActionText[time](playerid, time)
{
#pragma unused time
	HideActionText(playerid);
}

stock HideActionText(playerid)
{
	PlayerTextDrawHide(playerid, ActionText[playerid]);
	gViewingActionText[playerid] = false;
}

stock bool:IsPlayerViewingActionText(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	return gViewingActionText[playerid];
}


/*==============================================================================

	Utils

==============================================================================*/


/*
	Returns the absolute value of an angle
*/
stock Float:sif_absoluteangle(Float:angle)
{
	while(angle < 0.0)angle += 360.0;
	while(angle > 360.0)angle -= 360.0;
	return angle;
}

/*
	Angle from point to dest
*/
stock Float:sif_GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY)
	return sif_absoluteangle(-(90-(atan2((fDestY - fPointY), (fDestX - fPointX)))));

/*
	Distance between 2 points in 3D space
*/
stock Float:sif_Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
	return floatsqroot((((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2))+((z1-z2)*(z1-z2))));


/*
	Checks if an animation index is an idle stance.
*/
stock sif_IsIdleAnim(animidx)
{
	switch(animidx)
	{
		case 320, 1164, 1183, 1188, 1189:
			return 1;
	}

	return 0;
}
