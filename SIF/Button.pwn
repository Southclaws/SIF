/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

A simple framework using streamer areas and key checks to give
the in-game effect of physical buttons that players must press instead
of using a command. It was created as an alternative to the default
GTA:SA spinning pickups for a few reasons:

1. A player might want to stand where a pickup is but not use it (if the pickup
   is a building entrance or interior warp, he might want to stand in the doorway
   without being teleported.)

2. Making hidden doors or secrets that can only be found by walking near the
   button area and seeing the textdraw. (or spamming F!)

3. Spinning objects don't really add immersion to a role-play environment!

## Dependencies

- Streamer Plugin
- YSI\y_hooks
- YSI\y_timers

## Hooks

- OnScriptInit: Zero initialised array cells.
- OnPlayerConnect: Zero y_iterator and some player array data.
- OnPlayerKeyStateChange: Catch F/Enter key presses for button interaction.
- OnPlayerEnterDynamicArea: Monitor what buttons the player has walked near.
- OnPlayerLeaveDynamicArea: Detect when a player has walked away from a button.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_BUTTON_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include <SIF\Debug.pwn>
#endif

#if !defined _SIF_CORE_INCLUDED
	#include <SIF\Core.pwn>
#endif

#if defined DEBUG_LABELS_BUTTON
	#include <SIF\extensions\DebugLabels.pwn>
#endif

#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_BUTTON_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Maximum amount of buttons that can be created.
#if !defined BTN_MAX
	#define BTN_MAX (8192)
#endif

// Maximum string length for labels and action-text strings.
#if !defined BTN_MAX_TEXT
	#define BTN_MAX_TEXT (128)
#endif

// Default maximum stream range for button label text.
#if !defined BTN_DEFAULT_STREAMDIST
	#define BTN_DEFAULT_STREAMDIST (4.0)
#endif

// Maximum amount of buttons to record the player being near to.
#if !defined BTN_MAX_INRANGE
	#define BTN_MAX_INRANGE (8)
#endif

// A value to identify streamer object EXTRA_ID data array type.
#if !defined BTN_STREAMER_AREA_IDENTIFIER
	#define BTN_STREAMER_AREA_IDENTIFIER (100)
#endif

// Time in milliseconds to freeze a player upon using a linked teleport button.
#if !defined BTN_TELEPORT_FREEZE_TIME
	#define BTN_TELEPORT_FREEZE_TIME (1000)
#endif

// Validity check constant
#define INVALID_BUTTON_ID (-1)


DEFINE_HOOK_REPLACEMENT(Button , Btn);


// Functions


forward CreateButton(Float:x, Float:y, Float:z, text[], world = 0, interior = 0, Float:areasize = 1.0, label = 0, labeltext[] = "", labelcolour = 0xFFFF00FF, Float:streamdist = BTN_DEFAULT_STREAMDIST, testlos = true);
/*
# Description
Creates an interactive button players can activate by pressing F.

# Parameters
- x, y, z: World position.
- text: Message box text for when the player approaches the button.
- world: The virtual world to show the button in.
- interior: The interior world to show the button in.
- areasize: Size of the button's detection area.
- label: Determines whether a 3D Text Label should be at the button.
- labeltext: The text that the label should show.
- labelcolour: The colour of the label.
- streamdist: Stream distance of the label.
- testlos: test line of sight for the label.

# Returns
Button ID handle of the newly created button or INVALID_BUTTON_ID if another
button cannot be created due to BTN_MAX limit.
*/

forward DestroyButton(buttonid);
/*
# Description
Destroys a button.

# Returns
Boolean to indicate success or failure.
*/

forward LinkTP(buttonid1, buttonid2);
/*
# Description
Links two buttons to be teleport buttons, if a user presses buttonid1 he will be
teleported to the position of buttonid2 and vice versa.

# Returns
Boolean to indicate success or failure.
*/

forward UnLinkTP(buttonid1, buttonid2);
/*
# Description
Un-links two linked buttons

# Returns
-1 if buttons are not linked at all. -2 if either is linked to another button.
*/

forward IsValidButton(buttonid);
/*
# Description
Checks if buttonid is a valid button ID handle.
*/

forward GetButtonArea(buttonid);
/*
# Description
Returns the streamer area ID used by a button.
*/

forward SetButtonArea(buttonid, areaid);
/*
# Description
Updates a button's streamer area ID. Note that this does not remove the existing
area from memory.

# Returns
Boolean to indicate success or failure.
*/

forward SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = BTN_DEFAULT_STREAMDIST, testlos = true);
/*
# Description
Creates a 3D Text Label at the specified button ID handle, if a label already
exists it updates the text, colour and range.
*/

forward DestroyButtonLabel(buttonid);
/*
# Description
Removes the label from a button.

# Returns
Boolean to indicate success or failure. -1 if the button did not have a label.
*/

forward GetButtonPos(buttonid, &Float:x, &Float:y, &Float:z);
/*
# Description
Stores the button's X, Y and Z into parameters.

# Returns
Boolean to indicate success or failure.
*/

forward SetButtonPos(buttonid, Float:x, Float:y, Float:z);
/*
# Description
Changes the button position (area, label, etc).

# Returns
Boolean to indicate success or failure.
*/

forward Float:GetButtonSize(buttonid);
/*
# Description
Returns the size of the specified button's dynamic area.

# Returns
0.0 if the specified button ID handle is invalid.
*/

forward SetButtonSize(buttonid, Float:size);
/*
# Description
Sets a button's detection area size.

# Returns
Boolean to indicate success or failure.
*/

forward GetButtonWorld(buttonid);
/*
# Description
Returns the virtual world that a button exists in.
*/

forward SetButtonWorld(buttonid, world);
/*
# Description
Updates a button's virtual world. Moves all streamer entities to the world too.

# Returns
Boolean to indicate success or failure.
*/

forward GetButtonInterior(buttonid);
/*
# Description
Returns the interior that a button exists in.
*/

forward SetButtonInterior(buttonid, interior);
/*
# Description
Updates a button's interior. Moves all streamer entities to the interior too.

# Returns
Boolean to indicate success or failure.
*/

forward GetButtonLinkedID(buttonid);
/*
# Description
Returns the linked button of buttonid.
*/

forward GetButtonText(buttonid, text[]);
/*
# Description
Returns the text assigned to a button that appears on-screen when a player walks near it.
*/

forward SetButtonText(buttonid, text[]);
/*
# Description
Updates the text that appears on-screen when a player walks near the button.

# Returns
Boolean to indicate success or failure.
*/

forward SetButtonExtraData(buttonid, data);
/*
# Description
Sets the button's extra data field, this is one cell of blank space allocated for each button.

# Returns
Boolean to indicate success or failure.
*/

forward GetButtonExtraData(buttonid);
/*
# Description
Retrieves the integer assigned to the button set with SetButtonExtraData.
*/

forward GetPlayerPressingButton(playerid);
/*
# Description
Returns the ID of the button that the player is currently pressing. This will
only return a value while playerid is holding down the interact key at a button.
*/

forward GetPlayerButtonID(playerid);
/*
# Description
Returns the closest button that a player is standing within the area of.
*/

forward GetPlayerButtonList(playerid, list[], &size, bool:validate = false);
/*
# Description
Returns a list of buttons that a player is standing in the areas of.

# Parameters
- playerid: Player to get a list of buttons from.

- list: Array to store the buttons in (Must be BTN_MAX_INRANGE size)

- size: Stores the amount of buttons in the list.

- validate: If true, the function will check if the player is actually in each
  button in the list. This is a small workaround for a larger problem that is
  currently unknown that results in a button not being removed from a player's
  list when they leave the area for it.

# Returns
Boolean to indicate success or failure.
*/

forward Float:GetPlayerAngleToButton(playerid, buttonid);
/*
# Description
Returns the angle in degrees from a player to a button.
*/

forward Float:GetButtonAngleToPlayer(playerid, buttonid);
/*
# Description
Returns the angle in degrees from a button to a player.
*/


// Events


forward OnButtonPress(playerid, buttonid);
/*
# Called
When a player presses the F/Enter key while at a button.

# Returns
If the button is a linked teleporter, return 1 to prevent teleporting.
*/

forward OnButtonRelease(playerid, buttonid);
/*
# Called
When a player releases the F/Enter key after pressing it while at a button.
*/

forward OnPlayerEnterButtonArea(playerid, buttonid);
/*
# Called
When a player enters the dynamic streamed area of a button.
*/

forward OnPlayerLeaveButtonArea(playerid, buttonid);
/*
# Called
When a player leaves the dynamic streamed area of a button.
*/


/*==============================================================================

	Setup

==============================================================================*/


enum E_BTN_DATA
{
			btn_area,
Text3D:		btn_label,
Float:		btn_posX,
Float:		btn_posY,
Float:		btn_posZ,
Float:		btn_size,
			btn_world,
			btn_interior,
			btn_link,
			btn_text[BTN_MAX_TEXT],

			btn_exData
}

enum e_button_range_data
{
			btn_buttonId,
Float:		btn_distance
}


new
			btn_Data[BTN_MAX][E_BTN_DATA],
   Iterator:btn_Index<BTN_MAX>
	#if defined DEBUG_LABELS_BUTTON
		,
			btn_DebugLabelType,
			btn_DebugLabelID[BTN_MAX]
	#endif
		;

static
			btn_Near[MAX_PLAYERS][BTN_MAX_INRANGE],
   Iterator:btn_NearIndex[MAX_PLAYERS]<BTN_MAX_INRANGE>,
			btn_Pressing[MAX_PLAYERS];


static BUTTON_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	BUTTON_DEBUG = sif_debug_register_handler("SIF/Button");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnScriptInit]");

	Iter_Init(btn_NearIndex);

	for(new i; i < MAX_PLAYERS; i++)
	{
		btn_Pressing[i] = INVALID_BUTTON_ID;
	}

	#if defined DEBUG_LABELS_BUTTON
		btn_DebugLabelType = DefineDebugLabelType("BUTTON", 0xFF0000FF);
	#endif
}

hook OnPlayerConnect(playerid)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerConnect]")<playerid>;
	Iter_Clear(btn_NearIndex[playerid]);
	btn_Pressing[playerid] = INVALID_BUTTON_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateButton(Float:x, Float:y, Float:z, text[], world = 0, interior = 0, Float:areasize = 1.0, label = 0, labeltext[] = "", labelcolour = 0xFFFF00FF, Float:streamdist = BTN_DEFAULT_STREAMDIST, testlos = true)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:BUTTON_DEBUG("[CreateButton]");
	new id = Iter_Free(btn_Index);

	if(id == -1)
	{
		print("ERROR: BTN_MAX reached, please increase this constant!");
		return INVALID_BUTTON_ID;
	}

	btn_Data[id][btn_area]				= CreateDynamicSphere(x, y, z, areasize, world, interior);

	strcpy(btn_Data[id][btn_text], text, BTN_MAX_TEXT);
	btn_Data[id][btn_posX]				= x;
	btn_Data[id][btn_posY]				= y;
	btn_Data[id][btn_posZ]				= z;
	btn_Data[id][btn_size]				= areasize;
	btn_Data[id][btn_world]				= world;
	btn_Data[id][btn_interior]			= interior;
	btn_Data[id][btn_link]				= INVALID_BUTTON_ID;

	if(label)
		btn_Data[id][btn_label] = CreateDynamic3DTextLabel(labeltext, labelcolour, x, y, z, streamdist, .testlos = testlos, .worldid = world, .interiorid = interior, .streamdistance = streamdist);

	else
		btn_Data[id][btn_label] = Text3D:INVALID_3DTEXT_ID;

	new data[2];

	data[0] = BTN_STREAMER_AREA_IDENTIFIER;
	data[1] = id;

	Streamer_SetArrayData(STREAMER_TYPE_AREA, btn_Data[id][btn_area], E_STREAMER_EXTRA_ID, data, 2);

	Iter_Add(btn_Index, id);

	#if defined DEBUG_LABELS_BUTTON
		btn_DebugLabelID[id] = CreateDebugLabel(btn_DebugLabelType, id, x, y, z);
		UpdateButtonDebugLabel(id);
	#endif

	return id;
}

stock DestroyButton(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:BUTTON_DEBUG("[DestroyButton]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:BUTTON_DEBUG("[DestroyButton] process_LeaveDynamicArea calls");
	foreach(new i : Player)
	{
		if(IsPlayerInDynamicArea(i, btn_Data[buttonid][btn_area]))
			process_LeaveDynamicArea(i, btn_Data[buttonid][btn_area]);
	}

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:BUTTON_DEBUG("[DestroyButton] Destroying dynamic area");
	DestroyDynamicArea(btn_Data[buttonid][btn_area]);

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:BUTTON_DEBUG("[DestroyButton] Destroying 3D text label");
	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
		DestroyDynamic3DTextLabel(btn_Data[buttonid][btn_label]);

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:BUTTON_DEBUG("[DestroyButton] Clearing array data");
	btn_Data[buttonid][btn_area]		= -1;
	btn_Data[buttonid][btn_label]		= Text3D:INVALID_3DTEXT_ID;

	btn_Data[buttonid][btn_posX]		= 0.0;
	btn_Data[buttonid][btn_posY]		= 0.0;
	btn_Data[buttonid][btn_posZ]		= 0.0;
	btn_Data[buttonid][btn_size]		= 0.0;
	btn_Data[buttonid][btn_world]		= 0;
	btn_Data[buttonid][btn_interior]	= 0;
	btn_Data[buttonid][btn_link]		= INVALID_BUTTON_ID;
	btn_Data[buttonid][btn_text][0]		= EOS;

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:BUTTON_DEBUG("[DestroyButton] Removing from button index");
	Iter_Remove(btn_Index, buttonid);

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:BUTTON_DEBUG("[DestroyButton] Destroying debug label");
	#if defined DEBUG_LABELS_BUTTON
		DestroyDebugLabel(btn_DebugLabelID[buttonid]);
	#endif

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:BUTTON_DEBUG("[DestroyButton] End of function");
	return 1;
}

stock LinkTP(buttonid1, buttonid2)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:BUTTON_DEBUG("[LinkTP]");
	if(!Iter_Contains(btn_Index, buttonid1) || !Iter_Contains(btn_Index, buttonid2))
		return 0;

	btn_Data[buttonid1][btn_link] = buttonid2;
	btn_Data[buttonid2][btn_link] = buttonid1;

	#if defined DEBUG_LABELS_BUTTON
		UpdateButtonDebugLabel(buttonid1);
		UpdateButtonDebugLabel(buttonid2);
	#endif

	return 1;
}

stock UnLinkTP(buttonid1, buttonid2)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:BUTTON_DEBUG("[UnLinkTP]");
	if(!Iter_Contains(btn_Index, buttonid1) || !Iter_Contains(btn_Index, buttonid2))
		return 0;

	if(btn_Data[buttonid1][btn_link] == INVALID_BUTTON_ID || btn_Data[buttonid1][btn_link] == INVALID_BUTTON_ID)
		return -1;

	if(btn_Data[buttonid1][btn_link] != buttonid2 || btn_Data[buttonid2][btn_link] != buttonid1)
		return -2;

	btn_Data[buttonid1][btn_link] = INVALID_BUTTON_ID;
	btn_Data[buttonid2][btn_link] = INVALID_BUTTON_ID;

	#if defined DEBUG_LABELS_BUTTON
		UpdateButtonDebugLabel(buttonid1);
		UpdateButtonDebugLabel(buttonid2);
	#endif

	return 1;
}

stock IsValidButton(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[IsValidButton]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	return 1;
}
// btn_area
stock GetButtonArea(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonWorld]");
	if(!Iter_Contains(btn_Index, buttonid))
		return -1;

	return btn_Data[buttonid][btn_area];
}
stock SetButtonArea(buttonid, areaid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonWorld]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	btn_Data[buttonid][btn_area] = areaid;

	return 1;
}


// btn_label
stock SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = BTN_DEFAULT_STREAMDIST, testlos = true)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[SetButtonLabel]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
	{
		UpdateDynamic3DTextLabelText(btn_Data[buttonid][btn_label], colour, text);
		return 2;
	}

	btn_Data[buttonid][btn_label] = CreateDynamic3DTextLabel(text, colour,
		btn_Data[buttonid][btn_posX],
		btn_Data[buttonid][btn_posY],
		btn_Data[buttonid][btn_posZ],
		range, _, _, testlos,
		btn_Data[buttonid][btn_world], btn_Data[buttonid][btn_interior], _, range);

	return 1;
}
stock DestroyButtonLabel(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[DestroyButtonLabel]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(!IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
		return -1;

	DestroyDynamic3DTextLabel(btn_Data[buttonid][btn_label]);
	btn_Data[buttonid][btn_label] = Text3D:INVALID_3DTEXT_ID;

	return 1;
}

// btn_posX
// btn_posY
// btn_posZ
stock GetButtonPos(buttonid, &Float:x, &Float:y, &Float:z)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonPos] %d", buttonid);
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	x = btn_Data[buttonid][btn_posX];
	y = btn_Data[buttonid][btn_posY];
	z = btn_Data[buttonid][btn_posZ];

	return 1;
}
stock SetButtonPos(buttonid, Float:x, Float:y, Float:z)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[SetButtonPos] %d, %f, %f, %f", buttonid, x, y, z);
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_X, x);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_Y, y);
	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_Z, z);

	if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
	{
		sif_d:SIF_DEBUG_LEVEL_INTERFACE_DEEP:BUTTON_DEBUG("[SetButtonPos] Updating button label");
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_X, x);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Y, y);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_Z, z);
	}

	sif_d:SIF_DEBUG_LEVEL_INTERFACE_DEEP:BUTTON_DEBUG("[SetButtonPos] Updating variables");
	btn_Data[buttonid][btn_posX] = x;
	btn_Data[buttonid][btn_posY] = y;
	btn_Data[buttonid][btn_posZ] = z;
	sif_d:SIF_DEBUG_LEVEL_INTERFACE_DEEP:BUTTON_DEBUG("[SetButtonPos] Updated to: %f, %f, %f", btn_Data[buttonid][btn_posX], btn_Data[buttonid][btn_posY], btn_Data[buttonid][btn_posZ]);

	return 1;
}

// btn_size
stock Float:GetButtonSize(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonSize] %d", buttonid);
	if(!Iter_Contains(btn_Index, buttonid))
		return 0.0;

	return btn_Data[buttonid][btn_size];
}
stock SetButtonSize(buttonid, Float:size)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[SetButtonSize] %d, %f", buttonid, size);
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	Streamer_SetFloatData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_SIZE, size);
	btn_Data[buttonid][btn_size] = size;

	#if defined DEBUG_LABELS_BUTTON
		UpdateButtonDebugLabel(buttonid);
	#endif

	return 1;
}

// btn_world
stock GetButtonWorld(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonWorld]");
	if(!Iter_Contains(btn_Index, buttonid))
		return -1;

	return btn_Data[buttonid][btn_world];
}
stock SetButtonWorld(buttonid, world)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[SetButtonWorld]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(btn_Data[buttonid][btn_world] != world)
	{
		Streamer_SetIntData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_WORLD_ID, world);

		if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
		{
			Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_WORLD_ID, world);
		}

		btn_Data[buttonid][btn_world] = world;
	}

	return 1;
}

// btn_interior
stock GetButtonInterior(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonInterior]");
	if(!Iter_Contains(btn_Index, buttonid))
		return -1;

	return btn_Data[buttonid][btn_interior];
}
stock SetButtonInterior(buttonid, interior)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[SetButtonInterior]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	if(btn_Data[buttonid][btn_interior] != interior)
	{
		Streamer_SetIntData(STREAMER_TYPE_AREA, btn_Data[buttonid][btn_area], E_STREAMER_INTERIOR_ID, interior);

		if(IsValidDynamic3DTextLabel(btn_Data[buttonid][btn_label]))
		{
			Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, btn_Data[buttonid][btn_label], E_STREAMER_INTERIOR_ID, interior);
		}

		btn_Data[buttonid][btn_interior] = interior;
	}

	return 1;
}

// btn_link
stock GetButtonLinkedID(buttonid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonLinkedID]");
	if(!Iter_Contains(btn_Index, buttonid))
		return INVALID_BUTTON_ID;

	return btn_Data[buttonid][btn_link];
}

// btn_text
stock GetButtonText(buttonid, text[])
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonText]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	text[0] = EOS;
	strcat(text, btn_Data[buttonid][btn_text], BTN_MAX_TEXT);

	return 1;
}
stock SetButtonText(buttonid, text[])
{
	sif_d:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[SetButtonText]");
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	btn_Data[buttonid][btn_text][0] = EOS;
	strcat(btn_Data[buttonid][btn_text], text, BTN_MAX_TEXT);

	return 1;
}

// btn_exData
stock SetButtonExtraData(buttonid, data)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	btn_Data[buttonid][btn_exData] = data;

	#if defined DEBUG_LABELS_BUTTON
		UpdateButtonDebugLabel(buttonid);
	#endif

	return 1;
}
stock GetButtonExtraData(buttonid)
{
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	return btn_Data[buttonid][btn_exData];
}

// btn_Pressing
stock GetPlayerPressingButton(playerid)
{
	sif_dp:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetPlayerPressingButton]")<playerid>;
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	return btn_Pressing[playerid];
}

stock GetPlayerButtonID(playerid)
{
	sif_dp:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetPlayerButtonID]")<playerid>;

	if(!IsPlayerConnected(playerid))
		return INVALID_BUTTON_ID;

	if(Iter_Count(btn_NearIndex[playerid]) == 0)
		return INVALID_BUTTON_ID;

	new
		Float:x,
		Float:y,
		Float:z,
		curid,
		closestid,
		Float:curdistance,
		Float:closetsdistance = 99999.9;

	GetPlayerPos(playerid, x, y, z);

	foreach(new i : btn_NearIndex[playerid])
	{
		curid = btn_Near[playerid][i];

		curdistance = sif_Distance(x, y, z, btn_Data[curid][btn_posX], btn_Data[curid][btn_posY], btn_Data[curid][btn_posZ]);

		if(curdistance < closetsdistance)
		{
			closetsdistance = curdistance;
			closestid = curid;
		}
	}

	return closestid;
}

stock GetPlayerButtonList(playerid, list[], &size, bool:validate = false)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(Iter_Count(btn_NearIndex[playerid]) == 0)
		return 0;

	// Validate whether or not the player is actually inside the areas.
	// Caused by a bug that hasn't been found yet, this is the quick workaround.
	if(validate)
	{
		foreach(new i : btn_NearIndex[playerid])
		{
			if(!IsPlayerInDynamicArea(playerid, btn_Data[btn_Near[playerid][i]][btn_area]))
			{
				printf("ERROR: Player %d incorrectly flagged as inside button %d area, removing.", playerid, btn_Near[playerid][i]);
				Iter_SafeRemove(btn_NearIndex[playerid], i, i);
				continue;
			}

			list[size++] = btn_Near[playerid][i];
		}
	}
	else
	{
		foreach(new i : btn_NearIndex[playerid])
			list[size++] = btn_Near[playerid][i];
	}
	return 1;
}

stock Float:GetPlayerAngleToButton(playerid, buttonid)
{
	sif_dp:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetPlayerAngleToButton]")<playerid>;
	if(!Iter_Contains(btn_Index, buttonid))
		return 0.0;

	if(!IsPlayerConnected(playerid))
		return 0.0;

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	return sif_GetAngleToPoint(x, y, btn_Data[buttonid][btn_posX], btn_Data[buttonid][btn_posY]);
}

stock Float:GetButtonAngleToPlayer(playerid, buttonid)
{
	sif_dp:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetButtonAngleToPlayer]")<playerid>;
	if(!Iter_Contains(btn_Index, buttonid))
		return 0.0;

	if(!IsPlayerConnected(playerid))
		return 0.0;

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	return sif_GetAngleToPoint(btn_Data[buttonid][btn_posX], btn_Data[buttonid][btn_posY], x, y);
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerKeyStateChange]")<playerid>;
	if(newkeys & 16)
	{
		if(!IsPlayerInAnyVehicle(playerid) && Iter_Count(btn_NearIndex[playerid]) > 0)
		{
			if(!IsPlayerInAnyDynamicArea(playerid))
			{
				printf("[WARNING] Player %d is not in areas but list isn't empty. Purging list.", playerid);
				Iter_Clear(btn_NearIndex[playerid]);
			}

			new
				id,
				Float:x,
				Float:y,
				Float:z,
				Float:distance,
				list[BTN_MAX_INRANGE][e_button_range_data],
				index;

			GetPlayerPos(playerid, x, y, z);

			foreach(new i : btn_NearIndex[playerid])
			{
				if(index >= BTN_MAX_INRANGE - 1)
					break;

				id = btn_Near[playerid][i];

				distance = sif_Distance(x, y, z, btn_Data[id][btn_posX], btn_Data[id][btn_posY], btn_Data[id][btn_posZ]);

				if(distance > btn_Data[id][btn_size])
					continue;

				if(!(btn_Data[id][btn_posZ] - btn_Data[id][btn_size] <= z <= btn_Data[id][btn_posZ] + btn_Data[id][btn_size]))
					continue;


				list[index][btn_buttonId] = id;
				list[index][btn_distance] = distance;

				index++;
			}

			_btn_SortButtons(list, 0, index);

			for(new i = index - 1; i >= 0; i--)
			{
				if(Internal_OnButtonPress(playerid, list[i][btn_buttonId]))
					break;
			}
		}

		if(oldkeys & 16)
		{
			if(btn_Pressing[playerid] != INVALID_BUTTON_ID)
			{
				CallLocalFunction("OnButtonRelease", "dd", playerid, btn_Pressing[playerid]);
				btn_Pressing[playerid] = INVALID_BUTTON_ID;
			}
		}
	}
	return 1;
}

_btn_SortButtons(array[][e_button_range_data], left, right)
{
	new
		tmp_left = left,
		tmp_right = right,
		Float:pivot = array[(left + right) / 2][btn_distance],
		buttonid,
		Float:distance;

	while(tmp_left <= tmp_right)
	{
		while(array[tmp_left][btn_distance] > pivot)
			tmp_left++;

		while(array[tmp_right][btn_distance] < pivot)
			tmp_right--;

		if(tmp_left <= tmp_right)
		{
			buttonid = array[tmp_left][btn_buttonId];
			array[tmp_left][btn_buttonId] = array[tmp_right][btn_buttonId];
			array[tmp_right][btn_buttonId] = buttonid;

			distance = array[tmp_left][btn_distance];
			array[tmp_left][btn_distance] = array[tmp_right][btn_distance];
			array[tmp_right][btn_distance] = distance;

			tmp_left++;
			tmp_right--;
		}
	}

	if(left < tmp_right)
		_btn_SortButtons(array, left, tmp_right);

	if(tmp_left < right)
		_btn_SortButtons(array, tmp_left, right);
}

Internal_OnButtonPress(playerid, buttonid)
{
	sif_dp:SIF_DEBUG_LEVEL_INTERNAL:BUTTON_DEBUG("[Internal_OnButtonPress]")<playerid>;
	if(!Iter_Contains(btn_Index, buttonid))
		return 0;

	new id = btn_Data[buttonid][btn_link];

	if(Iter_Contains(btn_Index, id))
	{
		if(CallLocalFunction("OnButtonPress", "dd", playerid, buttonid))
			return 1;

		TogglePlayerControllable(playerid, false);
		defer btn_Unfreeze(playerid);

		Streamer_UpdateEx(playerid,
			btn_Data[id][btn_posX], btn_Data[id][btn_posY], btn_Data[id][btn_posZ],
			btn_Data[id][btn_world], btn_Data[id][btn_interior]);

		SetPlayerVirtualWorld(playerid, btn_Data[id][btn_world]);
		SetPlayerInterior(playerid, btn_Data[id][btn_interior]);
		SetPlayerPos(playerid, btn_Data[id][btn_posX], btn_Data[id][btn_posY], btn_Data[id][btn_posZ]);
	}
	else
	{
		btn_Pressing[playerid] = buttonid;

		if(CallLocalFunction("OnButtonPress", "dd", playerid, buttonid))
			return 1;
	}

	return 0;
}

timer btn_Unfreeze[BTN_TELEPORT_FREEZE_TIME](playerid)
{
	TogglePlayerControllable(playerid, true);
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerEnterDynamicArea]")<playerid>;
	if(!IsPlayerInAnyVehicle(playerid) && Iter_Count(btn_NearIndex[playerid]) < BTN_MAX_INRANGE)
	{
		sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerEnterDynamicArea] player is valid")<playerid>;
		new data[2];

		Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

		// Due to odd streamer behavior reversing data arrays:
		// Only use this if you are using streamer v2.7.1 or lower
		// new tmp = data[0];
		// data[0] = data[1];
		// data[1] = tmp;
		// end

		if(data[0] == BTN_STREAMER_AREA_IDENTIFIER)
		{
			sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerEnterDynamicArea] area is valid")<playerid>;
			if(Iter_Contains(btn_Index, data[1]))
			{
				sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerEnterDynamicArea] in index")<playerid>;
				new cell = Iter_Free(btn_NearIndex[playerid]);

				btn_Near[playerid][cell] = data[1];
				Iter_Add(btn_NearIndex[playerid], cell);

				ShowActionText(playerid, btn_Data[data[1]][btn_text]);
				CallLocalFunction("OnPlayerEnterButtonArea", "dd", playerid, data[1]);
			}
		}
	}

	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerEnterDynamicArea] end")<playerid>;
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	process_LeaveDynamicArea(playerid, areaid);
}

process_LeaveDynamicArea(playerid, areaid)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea]")<playerid>;

	if(!IsValidDynamicArea(areaid))
	{
		sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] area ID is invalid")<playerid>;
		return 1;
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] player is in vehicle")<playerid>;
		return 1;
	}

	if(Iter_Count(btn_NearIndex[playerid]) == 0)
	{
		sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] player nearindex is empty")<playerid>;
		return 2;
	}

	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	// Due to odd streamer behavior reversing data arrays:
	// Only use this if you are using streamer v2.7.1 or lower
	// new tmp = data[0];
	// data[0] = data[1];
	// data[1] = tmp;
	// end

	if(data[0] != BTN_STREAMER_AREA_IDENTIFIER)
	{
		sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] area is not a button area")<playerid>;
		return 3;
	}

	if(!Iter_Contains(btn_Index, data[1]))
	{
		sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] button ID is invalid")<playerid>;
		return 4;
	}

	HideActionText(playerid);
	CallLocalFunction("OnPlayerLeaveButtonArea", "dd", playerid, data[1]);

	foreach(new i : btn_NearIndex[playerid])
	{
		sif_dp:SIF_DEBUG_LEVEL_LOOPS:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] looping player list")<playerid>;

		if(btn_Near[playerid][i] == data[1])
		{
			sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] removing from player list")<playerid>;
			Iter_Remove(btn_NearIndex[playerid], i);
			break;
		}
	}

	return 0;
}

#if defined DEBUG_LABELS_BUTTON
	UpdateButtonDebugLabel(buttonid)
	{
		new string[64];

		format(string, sizeof(string), "EXDATA: %d SIZE: %.1f LINK: %d", btn_Data[buttonid][btn_exData], btn_Data[buttonid][btn_size], btn_Data[buttonid][btn_link]);

		UpdateDebugLabelString(btn_DebugLabelID[buttonid], string);
	}
#endif


/*==============================================================================

	Testing

==============================================================================*/


#if defined RUN_TESTS
	#include <SIF\testing/Button.pwn>
#endif
