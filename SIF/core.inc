/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

A fundamental library with features used by SIF modules.

## Dependencies

- Streamer Plugin
- YSI/y_hooks
- YSI/y_timers

## Hooks

- OnFilterScriptInit: -
- OnFilterScriptExit: -
- OnPlayerConnect: -
- OnPlayerDisconnect: -
- OnPlayerSpawn: -
- OnPlayerEnterDynamicArea: -
- OnPlayerLeaveDynamicArea: -

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_CORE_INCLUDED
	#endinput
#endif

#include "SIF/debug.inc"

#include <YSI_Coding\y_iterate>
#include <YSI_Coding\y_timers>
#include <YSI_Coding\y_hooks>
#include <streamer>

#define _SIF_CORE_INCLUDED


// Functions


forward IsPlayerInPlayerArea(playerid, targetid);
/*
# Description
Checks if a player is standing next to another player.
*/

forward Float:sif_absoluteangle(Float:angle);
/*
# Description
Returns an absolute angle (0-360).
*/

forward Float:sif_GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY);
/*
# Description
Returns the angle in degrees from one point to another with 0 being along +Y.
*/

forward Float:sif_Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);
/*
# Description
Return a 3D distance from one point to another.
*/

forward sif_IsIdleAnim(animidx);
/*
# Description
Checks if the specified animation index is an idle animation.
*/

forward sif_abs(int);
/*
# Description
Returns the absolute value of an integer.
*/

forward sif_intdiffabs(tick1, tick2);
/*
# Description
Used in sif_GetTickCountDiff to get an absolute integer difference.
*/

forward sif_GetTickCountDiff(a, b);
/*
# Description
Returns a corrected difference between two tick values (GetTickCount fix).
*/


// Events


forward OnPlayerEnterPlayerArea(playerid, targetid);
/*
# Called
When a player walks within 2m of another player.
*/

forward OnPlayerLeavePlayerArea(playerid, targetid);
/*
# Called
When a player leaves the 2m boundary of another player.
*/


/*==============================================================================

	Setup

==============================================================================*/


new
			gPlayerArea				[MAX_PLAYERS];


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
}

sif_UnloadPlayer(playerid, doTD = false)
{
	DestroyDynamicArea(gPlayerArea[playerid]);
	gPlayerArea[playerid] = -1;
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
		case 320, 471, 1164, 1183, 1188, 1189:
			return 1;
	}

	return 0;
}

/*
	Allows interval checking with GetTickCount regardless of overflow.
*/
stock sif_abs(int)
{
	if(int < 0)
		return -int;

	return int;
}

stock sif_intdiffabs(tick1, tick2)
{
	if(tick1 > tick2)
		return sif_abs(tick1 - tick2);

	else
		return sif_abs(tick2 - tick1);
}

stock sif_GetTickCountDiff(a, b)
{
	if ((a < 0) && (b > 0))
	{

		new dist;

		dist = sif_intdiffabs(a, b);

		if(dist > 2147483647)
			return sif_intdiffabs(a - 2147483647, b - 2147483647);

		else
			return dist;
	}

	return sif_intdiffabs(a, b);
}
