/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

A simple object movement manager that supports buttons as the default method of
interacting. Doors support multiple buttons, so a button on the inside and
outside of a door is possible. Doors can be opened and closed manually by
calling OpenDoor or CloseDoor. The door state change callbacks can be used to
restrict the use of doors by returning 1.

## Dependencies

- SIF/Button
- Streamer Plugin
- YSI/y_hooks
- YSI/y_timers

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_DOOR_INCLUDED
	#endinput
#endif

#include "SIF/debug.inc"
#include "SIF/button.inc"

#include <YSI_Coding\y_iterate>
#include <YSI_Coding\y_timers>
#include <YSI_Coding\y_hooks>
#include <streamer>

#define _SIF_DOOR_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// DR_MAX: Maximum amount of doors that can be created.
#if !defined DR_MAX
	#define DR_MAX				(64)
#endif

// DR_MAX_BUTTONS_PER: Maximum amount of buttons that can be assigned to a door.
#if !defined DR_MAX_BUTTONS_PER
	#define DR_MAX_BUTTONS_PER	(4)
#endif

// Validity check constant
#define INVALID_DOOR_ID			(-1)

// Invalid door state.
#define DR_STATE_INVALID		(-1)

// Door is open.
#define DR_STATE_OPEN			(0)

// Door is closed.
#define DR_STATE_CLOSED			(1)

// Door is moving from closed to open position.
#define DR_STATE_OPENING		(2)

// Door is moving from open to closed position.
#define DR_STATE_CLOSING		(3)


// Functions


forward CreateDoor(model, buttonids[], Float:px,  Float:py,  Float:pz,  Float:rx,  Float:ry,  Float:rz, Float:mpx, Float:mpy, Float:mpz, Float:mrx, Float:mry, Float:mrz, Float:movespeed = 1.0, closedelay = 3000, maxbuttons = sizeof(buttonids), movesound = 1186, stopsound = 1186, worldid = 0, interiorid = 0, initstate = DR_STATE_CLOSED);
/*
# Description
Creates a world object that is assigned a move position and a set of buttons
that will trigger it's movement.

# Parameters

- model: The GTA model ID of the door.
- buttonids[]: An array of buttons that will be used to activate the door.
- px, py, pz: The world position of the door object.
- rx, ry, rz: The rotation of the door object.
- mpx, mpy, mpz: The world position which the door will move to.
- mrx, mry, mrz: The rotation which the door will rotate to when moved.
- movespeed: The speed at which the door will move (both open and close)
- closedelay: Time to stay open, 0 to disable automatic closing.
- maxbuttons: Size of button array.
- movesound: The sound that will be played when the door moves.
- stopsound: The sound that will be played when the door stops moving.
- worldid: The virtual world in which the door object will be made.
- interiorid: The interior world in which the door object will be made.
- initstate: The initial state for the door, either open or closed.

# Returns
ID of the newly created door or INVALID_DOOR_ID upon failure.
*/

forward DestroyDoor(doorid);
/*
# Description
Destroys a door object and clears it's memory. This does not destroy the buttons
associated with the door.
*/

forward OpenDoor(doorid);
/*
# Description
Moves a door object to it's open position.
*/

forward CloseDoor(doorid);
/*
# Description
Moves a door object to it's closed position.
*/

forward IsValidDOor(doorid);
/*
# Description
Checks if a door is valid.
*/

forward GetDoorObjectID(doorid);
/*
# Description
Returns the object ID used for the door.
*/

forward GetDoorModel(doorid);
/*
# Description
Returns the model ID used for the door.
*/

forward SetDoorModel(doorid, model);
/*
# Description
Changes a door object model.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorButton(doorid, slot);
/*
# Description
Returns the button ID handle in the specified slot of a door.
*/

forward GetDoorButtonCount(doorid);
/*
# Description
Returns the amount of buttons assigned to a door.
*/

forward GetDoorCloseDelay(doorid);
/*
# Description
Returns the close delay for a door in milliseconds.
*/

forward SetDoorCloseDelay(doorid, closedelay);
/*
# Description
Sets the close delay for a door in milliseconds.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorMoveSpeed(doorid);
/*
# Description
Returns a door open/close move speed.
*/

forward SetDoorMoveSpeed(doorid, Float:movespeed);
/*
# Description
Sets a door open/close move speed.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorMoveSound(doorid);
/*
# Description
Returns a door sound ID for when it moves.
*/

forward SetDoorMoveSound(doorid, movesound);
/*
# Description
Sets the door sound ID for when it moves.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorStopSound(doorid);
/*
# Description
Returns the door sound ID for when it stops moving.
*/

forward SetDoorStopSound(doorid, stopsound);
/*
# Description
Sets the door sound ID for when it stops moving.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorPos(doorid, &Float:x, &Float:y, &Float:z);
/*
# Description
Assigns the door object position into the referenced variables.

# Returns
Boolean to indicate success or failure.
*/

forward SetDoorPos(doorid, Float:x, Float:y, Float:z);
/*
# Description
Sets the door object position.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorRot(doorid, &Float:rx, &Float:ry, &Float:rz);
/*
# Description
Assigns the door object rotation into the referenced variables.

# Returns
Boolean to indicate success or failure.
*/

forward SetDoorRot(doorid, Float:rx, Float:ry, Float:rz);
/*
# Description
Sets the door object rotation.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorMovePos(doorid, &Float:x, &Float:y, &Float:z);
/*
# Description
Assigns the door object move position into the referenced variables.
*/

forward SetDoorMovePos(doorid, Float:x, Float:y, Float:z);
/*
# Description
Sets the door object move position.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorMoveRot(doorid, &Float:rx, &Float:ry, &Float:rz);
/*
# Description
Assigns the door object move rotation into the referenced variables.
*/

forward SetDoorMoveRot(doorid, Float:rx, Float:ry, Float:rz);
/*
# Description
Sets the door object move rotation.

# Returns
Boolean to indicate success or failure.
*/

forward GetDoorState(doorid);
/*
# Description
Returns the state of a door.
*/


// Events


forward OnPlayerActivateDoor(playerid, doorid, newstate);
/*
# Called
Called when a player presses a door button. Depending on whether the door is
currently open, closed, opening or closing the door will act differently.

# Returns
1 To cancel the door action request. This will stop the door from opening or
closing. Useful for a door lock system.
*/

forward OnDoorStateChange(doorid, doorstate);
/*
# Called
Called when a door changes state between: DOOR_STATE_OPEN, DOOR_STATE_CLOSED,
DOOR_STATE_OPENING, DOOR_STATE_CLOSING. Note: A door can never change state
between OPEN and CLOSED without CLOSING or OPENING in between.
*/


/*==============================================================================

	Setup

==============================================================================*/


enum E_DOOR_DATA
{
			dr_objectid,
			dr_model,
			dr_buttonArray[DR_MAX_BUTTONS_PER],
			dr_buttonCount,
			dr_closeDelay,
Float:		dr_moveSpeed,
			dr_moveSound,
			dr_stopSound,

Float:		dr_posX,
Float:		dr_posY,
Float:		dr_posZ,
Float:		dr_rotX,
Float:		dr_rotY,
Float:		dr_rotZ,

Float:		dr_posMoveX,
Float:		dr_posMoveY,
Float:		dr_posMoveZ,
Float:		dr_rotMoveX,
Float:		dr_rotMoveY,
Float:		dr_rotMoveZ
}

static
			dr_Data[DR_MAX][E_DOOR_DATA],
			dr_State[DR_MAX char],
   Iterator:dr_Index<DR_MAX>;


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateDoor(model, buttonids[], Float:px,  Float:py,  Float:pz,  Float:rx,  Float:ry,  Float:rz, Float:mpx, Float:mpy, Float:mpz, Float:mrx, Float:mry, Float:mrz, Float:movespeed = 1.0, closedelay = 3000, maxbuttons = sizeof(buttonids), movesound = 1186, stopsound = 1186, worldid = 0, interiorid = 0, initstate = DR_STATE_CLOSED)
{
	new id = Iter_Free(dr_Index);

	if(id == -1)
		return INVALID_DOOR_ID;

	if(initstate == DR_STATE_CLOSED)
		dr_Data[id][dr_objectid] = CreateDynamicObject(model, px, py, pz, rx, ry, rz, worldid, interiorid);

	else
		dr_Data[id][dr_objectid] = CreateDynamicObject(model, mpx, mpy, mpz, mrx, mry, mrz, worldid, interiorid);

	dr_Data[id][dr_model] = model;
	dr_Data[id][dr_buttonCount] = maxbuttons;
	dr_Data[id][dr_closeDelay] = closedelay;
	dr_Data[id][dr_moveSpeed] = movespeed;

	for(new i; i < maxbuttons; i++)
		dr_Data[id][dr_buttonArray][i] = buttonids[i];

	dr_Data[id][dr_moveSound] = movesound;
	dr_Data[id][dr_stopSound] = stopsound;

	dr_Data[id][dr_posX] = px;
	dr_Data[id][dr_posY] = py;
	dr_Data[id][dr_posZ] = pz;
	dr_Data[id][dr_rotX] = rx;
	dr_Data[id][dr_rotY] = ry;
	dr_Data[id][dr_rotZ] = rz;

	dr_Data[id][dr_posMoveX] = mpx;
	dr_Data[id][dr_posMoveY] = mpy;
	dr_Data[id][dr_posMoveZ] = mpz;
	dr_Data[id][dr_rotMoveX] = mrx;
	dr_Data[id][dr_rotMoveY] = mry;
	dr_Data[id][dr_rotMoveZ] = mrz;

	dr_State{id} = initstate;

	Iter_Add(dr_Index, id);
	return id;
}

stock DestroyDoor(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	for(new i; i < dr_Data[id][dr_buttonCount]; i++)
		dr_Data[id][dr_buttonArray][i] = INVALID_BUTTON_ID;

	DestroyDynamicObject(dr_Data[id][dr_objectid]);
	dr_Data[id][dr_buttonCount] = 0;
	dr_Data[id][dr_closeDelay] = 0;
	dr_Data[id][dr_moveSpeed] = 0.0;

	dr_Data[id][dr_moveSound] = 0;
	dr_Data[id][dr_stopSound] = 0;

	dr_Data[id][dr_posX] = 0.0;
	dr_Data[id][dr_posY] = 0.0;
	dr_Data[id][dr_posZ] = 0.0;
	dr_Data[id][dr_rotX] = 0.0;
	dr_Data[id][dr_rotY] = 0.0;
	dr_Data[id][dr_rotZ] = 0.0;

	dr_Data[id][dr_posMoveX] = 0.0;
	dr_Data[id][dr_posMoveY] = 0.0;
	dr_Data[id][dr_posMoveZ] = 0.0;
	dr_Data[id][dr_rotMoveX] = 0.0;
	dr_Data[id][dr_rotMoveY] = 0.0;
	dr_Data[id][dr_rotMoveZ] = 0.0;

	dr_State{id} = 0;

	Iter_Remove(dr_Index, id);
	return 1;
}

stock OpenDoor(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))return 0;

	MoveDynamicObject(dr_Data[doorid][dr_objectid],
		dr_Data[doorid][dr_posMoveX], dr_Data[doorid][dr_posMoveY], dr_Data[doorid][dr_posMoveZ], dr_Data[doorid][dr_moveSpeed],
		dr_Data[doorid][dr_rotMoveX], dr_Data[doorid][dr_rotMoveY], dr_Data[doorid][dr_rotMoveZ]);

	dr_State{doorid} = DR_STATE_OPENING;

	if(dr_Data[doorid][dr_moveSound] != -1)
		dr_PlaySoundForAll(dr_Data[doorid][dr_moveSound], dr_Data[doorid][dr_posX], dr_Data[doorid][dr_posY], dr_Data[doorid][dr_posZ]);

	CallLocalFunction("OnDoorStateChange", "dd", doorid, DR_STATE_OPENING);

	return 1;
}

stock CloseDoor(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))return 0;

	MoveDynamicObject(dr_Data[doorid][dr_objectid],
		dr_Data[doorid][dr_posX], dr_Data[doorid][dr_posY], dr_Data[doorid][dr_posZ], dr_Data[doorid][dr_moveSpeed],
		dr_Data[doorid][dr_rotX], dr_Data[doorid][dr_rotY], dr_Data[doorid][dr_rotZ]);

	dr_State{doorid} = DR_STATE_CLOSING;

	if(dr_Data[doorid][dr_moveSound] != -1)
		dr_PlaySoundForAll(dr_Data[doorid][dr_moveSound], dr_Data[doorid][dr_posX], dr_Data[doorid][dr_posY], dr_Data[doorid][dr_posZ]);

	CallLocalFunction("OnDoorStateChange", "dd", doorid, DR_STATE_CLOSING);

	return 1;
}

stock IsValidDOor(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	return 1;
}

// dr_objectid
stock GetDoorObjectID(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_objectid];
}

// dr_model
stock GetDoorModel(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_model];
}
stock SetDoorModel(doorid, model)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	Streamer_SetIntData(STREAMER_TYPE_OBJECT, dr_Data[doorid][dr_objectid], E_STREAMER_MODEL_ID, model);
	dr_Data[doorid][dr_model] = model;

	return 1;
}

// dr_buttonArray[DR_MAX_BUTTONS_PER]
stock GetDoorButton(doorid, slot)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	if(!(0 <= slot < dr_Data[doorid][dr_buttonCount]))
		return -2;

	return dr_Data[doorid][dr_buttonArray][slot];
}

// dr_buttonCount
stock GetDoorButtonCount(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_buttonCount];
}

// dr_closeDelay
stock GetDoorCloseDelay(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_closeDelay];
}
stock SetDoorCloseDelay(doorid, closedelay)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_closeDelay] = closedelay;

	return 1;
}

// dr_moveSpeed
stock GetDoorMoveSpeed(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_moveSpeed];
}
stock SetDoorMoveSpeed(doorid, Float:movespeed)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_moveSpeed] = movespeed;

	return 1;
}

// dr_moveSound
stock GetDoorMoveSound(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_moveSound];
}
stock SetDoorMoveSound(doorid, movesound)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_moveSound] = movesound;

	return 1;
}

// dr_stopSound
stock GetDoorStopSound(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	return dr_Data[doorid][dr_stopSound];
}
stock SetDoorStopSound(doorid, stopsound)
{
	if(!Iter_Contains(dr_Index, doorid))
		return -1;

	dr_Data[doorid][dr_stopSound] = stopsound;

	return 1;
}

// dr_posX
// dr_posY
// dr_posZ
stock GetDoorPos(doorid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	x = dr_Data[doorid][dr_posX];
	y = dr_Data[doorid][dr_posY];
	z = dr_Data[doorid][dr_posZ];
	
	return 1;
}
stock SetDoorPos(doorid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_posX] = x;
	dr_Data[doorid][dr_posY] = y;
	dr_Data[doorid][dr_posZ] = z;

	SetDynamicObjectPos(dr_Data[doorid][dr_objectid], x, y, z);
	
	return 1;
}

// dr_rotX
// dr_rotY
// dr_rotZ
stock GetDoorRot(doorid, &Float:rx, &Float:ry, &Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	rx = dr_Data[doorid][dr_rotX];
	ry = dr_Data[doorid][dr_rotY];
	rz = dr_Data[doorid][dr_rotZ];
	
	return 1;
}
stock SetDoorRot(doorid, Float:rx, Float:ry, Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_rotX] = rx;
	dr_Data[doorid][dr_rotY] = ry;
	dr_Data[doorid][dr_rotZ] = rz;

	SetDynamicObjectRot(dr_Data[doorid][dr_objectid], rx, ry, rz);
	
	return 1;
}

// dr_posMoveX
// dr_posMoveY
// dr_posMoveZ
stock GetDoorMovePos(doorid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	x = dr_Data[doorid][dr_posMoveX];
	y = dr_Data[doorid][dr_posMoveY];
	z = dr_Data[doorid][dr_posMoveZ];
	
	return 1;
}
stock SetDoorMovePos(doorid, Float:x, Float:y, Float:z)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_posMoveX] = x;
	dr_Data[doorid][dr_posMoveY] = y;
	dr_Data[doorid][dr_posMoveZ] = z;

	return 1;
}

// dr_rotMoveX
// dr_rotMoveY
// dr_rotMoveZ
stock GetDoorMoveRot(doorid, &Float:rx, &Float:ry, &Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	rx = dr_Data[doorid][dr_rotMoveX];
	ry = dr_Data[doorid][dr_rotMoveY];
	rz = dr_Data[doorid][dr_rotMoveZ];
	
	return 1;
}
stock SetDoorMoveRot(doorid, Float:rx, Float:ry, Float:rz)
{
	if(!Iter_Contains(dr_Index, doorid))
		return 0;

	dr_Data[doorid][dr_rotMoveX] = rx;
	dr_Data[doorid][dr_rotMoveY] = ry;
	dr_Data[doorid][dr_rotMoveZ] = rz;
	
	return 1;
}

// dr_State
stock GetDoorState(doorid)
{
	if(!Iter_Contains(dr_Index, doorid))
		return DR_STATE_INVALID;

	return dr_State{doorid};
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnButtonPress(playerid, buttonid)
{
	foreach(new i : dr_Index)
	{
		for(new j; j < dr_Data[i][dr_buttonCount]; j++)
		{
			if(buttonid == dr_Data[i][dr_buttonArray][j])
			{
				if(dr_State{i} == DR_STATE_CLOSED || dr_State{i} == DR_STATE_CLOSING)
				{
					if(CallLocalFunction("OnPlayerActivateDoor", "ddd", playerid, i, DR_STATE_OPENING))
						return 0;

					OpenDoor(i);
				}
				else if(dr_State{i} == DR_STATE_OPEN || dr_State{i} == DR_STATE_OPENING)
				{
					if(CallLocalFunction("OnPlayerActivateDoor", "ddd", playerid, i, DR_STATE_CLOSING))
						return 0;

					CloseDoor(i);
				}
			}
		}
	}

	return 1;
}

timer _CloseDoorTimer[ dr_Data[doorid][dr_closeDelay] ](doorid)
{
	CloseDoor(doorid);
}

dr_PlaySoundForAll(sound, Float:x, Float:y, Float:z)
{
	foreach(new i : Player)
	{
		PlayerPlaySound(i, sound, x, y, z);
	}
	return 1;
}

hook OnDynamicObjectMoved(objectid)
{
	foreach(new i : dr_Index)
	{
		if(objectid == dr_Data[i][dr_objectid] && dr_State{i} == DR_STATE_OPENING)
		{
			dr_State{i} = DR_STATE_OPEN;
			if(dr_Data[i][dr_closeDelay] >= 0)
				defer _CloseDoorTimer(i);

			if(dr_Data[i][dr_stopSound] != -1)
				dr_PlaySoundForAll(dr_Data[i][dr_stopSound], dr_Data[i][dr_posX], dr_Data[i][dr_posY], dr_Data[i][dr_posZ]);

			CallLocalFunction("OnDoorStateChange", "dd", i, DR_STATE_OPEN);
		}
		if(objectid == dr_Data[i][dr_objectid] && dr_State{i} == DR_STATE_CLOSING)
		{
			dr_State{i} = DR_STATE_CLOSED;

			if(dr_Data[i][dr_stopSound] != -1)
				dr_PlaySoundForAll(dr_Data[i][dr_stopSound], dr_Data[i][dr_posX], dr_Data[i][dr_posY], dr_Data[i][dr_posZ]);

			CallLocalFunction("OnDoorStateChange", "dd", i, DR_STATE_CLOSED);
		}
	}
}
