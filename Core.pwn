/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


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


#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_CORE_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


new
			gPlayerArea			[MAX_PLAYERS],
PlayerText:	ActionText,
bool:		gViewingActionText		[MAX_PLAYERS],
Timer:		gPlayerActionTextTimer	[MAX_PLAYERS];


forward OnPlayerEnterPlayerArea(playerid, targetid);
forward OnPlayerLeavePlayerArea(playerid, targetid);


/*==============================================================================

	Connection

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	if(!IsValidDynamicArea(gPlayerArea[playerid]))
		gPlayerArea[playerid] = CreateDynamicSphere(0.0, 0.0, 0.0, 2.0);

	ActionText						=CreatePlayerTextDraw(playerid, 320.000000, 320.000000, "_");
	PlayerTextDrawAlignment			(playerid, ActionText, 2);
	PlayerTextDrawBackgroundColor	(playerid, ActionText, 255);
	PlayerTextDrawFont				(playerid, ActionText, 1);
	PlayerTextDrawLetterSize		(playerid, ActionText, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, ActionText, -1);
	PlayerTextDrawSetOutline		(playerid, ActionText, 1);
}

hook OnPlayerDisconnect(playerid)
{
	DestroyDynamicArea(gPlayerArea[playerid]);
	gPlayerArea[playerid] = -1;

	PlayerTextDrawDestroy(playerid, ActionText);
}

hook OnPlayerSpawn(playerid)
{
	AttachDynamicAreaToPlayer(gPlayerArea[playerid], playerid);
}


/*==============================================================================

	Player Area

==============================================================================*/


public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : Character)
	{
		if(i == playerid)
			continue;

		if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
			continue;

		if(areaid == gPlayerArea[i])
		{
			CallLocalFunction("OnPlayerEnterPlayerArea", "dd", playerid, i);
		}
	}

	return CallLocalFunction("SIF_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea SIF_OnPlayerEnterDynamicArea
forward SIF_OnPlayerEnterDynamicArea(playerid, areaid);

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	foreach(new i : Character)
	{
		if(i == playerid)
			continue;

		if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
			continue;

		if(areaid == gPlayerArea[i])
		{
			CallLocalFunction("OnPlayerLeavePlayerArea", "dd", playerid, i);
		}
	}

	return CallLocalFunction("SIF_OnPlayerLeaveDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea SIF_OnPlayerLeaveDynamicArea
forward SIF_OnPlayerLeaveDynamicArea(playerid, areaid);

stock IsPlayerInPlayerArea(playerid, targetid)
{
	if(playerid == targetid)
		return 0;
	
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
		return 0;

	return IsPlayerInDynamicArea(playerid, gPlayerArea[targetid]);
}


/*==============================================================================

	Message Box

==============================================================================*/


stock ShowActionText(playerid, message[], time=0, width=200)
{
	PlayerTextDrawSetString(playerid, ActionText, message);
	PlayerTextDrawTextSize(playerid, ActionText, width, 300);
	PlayerTextDrawShow(playerid, ActionText);
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
	PlayerTextDrawHide(playerid, ActionText);
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

