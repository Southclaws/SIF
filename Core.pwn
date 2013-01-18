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


/*==============================================================================

	Setup

==============================================================================*/


#include <YSI\y_hooks>


new
			gPlayerArea			[MAX_PLAYERS],
PlayerText:	MsgBox,
bool:		gViewingMsgBox		[MAX_PLAYERS],
Timer:		gPlayerMsgBoxTimer	[MAX_PLAYERS];


forward OnPlayerEnterPlayerArea(playerid, targetid);
forward OnPlayerLeavePlayerArea(playerid, targetid);


hook OnPlayerConnect(playerid)
{
	if(!IsValidDynamicArea(gPlayerArea[playerid]))
		gPlayerArea[playerid] = CreateDynamicSphere(0.0, 0.0, 0.0, 2.0);

	MsgBox					=CreatePlayerTextDraw(playerid, 24.0, 180.0, "Test message Box");
	PlayerTextDrawUseBox	(playerid, MsgBox, 1);
	PlayerTextDrawBoxColor	(playerid, MsgBox, 0x00000055);
	PlayerTextDrawTextSize	(playerid, MsgBox, 150.0, 300.0);
	PlayerTextDrawFont		(playerid, MsgBox, 1);
	PlayerTextDrawLetterSize(playerid, MsgBox, 0.3, 1.4);
	PlayerTextDrawSetShadow	(playerid, MsgBox, 1);
}

hook OnPlayerDisconnect(playerid)
{
	DestroyDynamicArea(gPlayerArea[playerid]);
	gPlayerArea[playerid] = -1;

	PlayerTextDrawDestroy(playerid, MsgBox);
}

hook OnPlayerSpawn(playerid)
{

	AttachDynamicAreaToPlayer(gPlayerArea[playerid], playerid);
}


public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : Character)
	{
		if(areaid == gPlayerArea[i] && playerid != i)
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
		if(areaid == gPlayerArea[i] && playerid != i)
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


stock ShowMsgBox(playerid, message[], time=0, width=200)
{
	PlayerTextDrawSetString(playerid, MsgBox, message);
	PlayerTextDrawTextSize(playerid, MsgBox, width, 300);
	PlayerTextDrawShow(playerid, MsgBox);
	if(time != 0)
	{
	    stop gPlayerMsgBoxTimer[playerid];
		gPlayerMsgBoxTimer[playerid] = defer Internal_HideMsgBox(playerid, time);
	}
	gViewingMsgBox[playerid] = true;
}
timer Internal_HideMsgBox[time](playerid, time)
{
#pragma unused time
	HideMsgBox(playerid);
}

stock HideMsgBox(playerid)
{
	PlayerTextDrawHide(playerid, MsgBox);
	gViewingMsgBox[playerid] = false;
}

stock bool:IsPlayerViewingMsgBox(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	return gViewingMsgBox[playerid];
}

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

