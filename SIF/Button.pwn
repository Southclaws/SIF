/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.4.0
	Module Version: 1.5.1


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Button/Description
	{
		A simple framework using streamer areas and key checks to give
		the in-game effect of physical buttons that players must press instead
		of using a command. It was created as an alternative to the default
		GTA:SA spinning pickups for a few reasons:

			1. A player might want to stand where a pickup is but not use it
			(if the	pickup is a building entrance or interior warp, he might
			want to stand in the doorway without being teleported.)

			2. Making hidden doors or secrets that can only be found by walking
			near the button area and seeing the textdraw. (or spamming F!)

			3. Spinning objects don't really add immersion to a role-play
			environment!
	}

	SIF/Button/Dependencies
	{
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Button/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/Button/Constants
	{
		These can be altered by defining their values before the include line.

		BTN_MAX
			Maximum amount of buttons that can be created.

		BTN_MAX_TEXT
			Maximum string length for labels and action-text strings.

		BTN_DEFAULT_STREAMDIST
			Default maximum stream range for button label text.

		BTN_MAX_INRANGE
			Maximum amount of buttons to load into the list of buttons that the
			player is in range of when they press the interact key.

		BTN_STREAMER_AREA_IDENTIFIER
			A value to identify streamer object EXTRA_ID data array type.

		BTN_TELEPORT_FREEZE_TIME
			The time in milliseconds to freeze a player upon using a linked
			teleport button.
	}

	SIF/Button/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Button/Core
		native -

		native CreateButton(Float:x, Float:y, Float:z, text[], world = 0, interior = 0, Float:areasize = 1.0, label = 0, labeltext[] = "", labelcolour = 0xFFFF00FF, Float:streamdist = BTN_DEFAULT_STREAMDIST)
		{
			Description:
				Creates an interactive button players can activate by pressing F.

			Parameters:
				<x>, <y>, <z> (float)
					X, Y and Z world position.

				<text> (string)
					Message box text for when the player approaches the button.

				<world>	(int)
					The virtual world to show the button in.

				<interior> (int)
					The interior world to show the button in.

				<areasize> (float)
					Size of the button's detection area.

				<label> (boolean)
					Determines whether a 3D Text Label should be at the button.

				<labeltext> (string)
					The text that the label should show.

				<labelcolour> (int)
					The colour of the label.

				<streamdist> (float)
					Stream distance of the label.


			Returns:
				(int, buttonid)
					Button ID handle of the newly created button.

				INVALID_BUTTON_ID
					If another button cannot be created due to BTN_MAX limit.
		}

		native DestroyButton(buttonid)
		{
			Description:
				Destroys a button.

			Parameters:
				<buttonid> (int, buttonid)
					The button handle ID to delete.

			Returns:
				1
					If destroying the button was successful

				0
					If <buttonid> is an invalid button ID handle.
		}
	
		native LinkTP(buttonid1, buttonid2)
		{
			Description:
				Links two buttons to be teleport buttons, if a user presses
				<buttonid1> he will be teleported to the position of <buttonid2>
				and vice versa, the buttonids require no particular order.
	
			Parameters:
				<buttonid1> (int, buttonid)
					The first button ID to link.

				<buttonid2> (int, buttonid)
					The second button ID to link <buttonid1> to.

			Returns:
				1
					If the link was successful
				0
					If either of the button IDs are invalid.
		}
	
		native UnLinkTP(buttonid1, buttonid2)
		{
			Description:
				Un-links two linked buttons
	
			Parameters:
				<buttonid1> (int, buttonid)
					The first button ID to un-link, must be a linked button.

				<buttonid2> (int, buttonid)
					The second button ID to un-link, must be a linked button.

			Returns:
				0
					If either of the button IDs are invalid.

				-1
					If either of the button IDs are not linked.

				-2
					If both buttons are linked, but not to each other.
		}
	}

	SIF/Button/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Button/Callbacks
		native -

		native OnButtonPress(playerid, buttonid)
		{
			Called:
				When a player presses the F/Enter key while at a button.

			Parameters:
				<playerid> (int)
					The ID of the player who pressed the button.

				<buttonid> (int, buttonid)
					The ID handle of the button he pressed.

			Returns:
				0
					To allow a linked button teleport.

				1
					To deny a linked button teleport.
		}

		native OnButtonRelease(playerid, buttonid)
		{
			Called:
				When a player releases the F/Enter key after pressing it while
				at a button.

			Parameters:
				<playerid> (int)
					The ID of the player who originally pressed the button.

				<buttonid> (int, buttonid)
					The ID handle of the button he was at when he originally
					pressed the F/Enter key.

			Returns:
				(none)
		}

		native OnPlayerEnterButtonArea(playerid, buttonid)
		{
			Called:
				When a player enters the dynamic streamed area of a button.

			Parameters:
				<playerid> (int)
					The ID of the player who entered the button area.

				<buttonid> (int, buttonid)
					The ID handle of the button.

			Returns:
				(none)
		}

		native OnPlayerLeaveButtonArea(playerid, buttonid)
		{
			Called:
				When a player leaves the dynamic streamed area of a button.

			Parameters:
				<playerid> (int)
					The ID of the player who left the button area.

				<buttonid> (int, buttonid)
					The ID handle of the button.

			Returns:
				(none)
		}
	}

	SIF/Button/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Button/Interface
		native -

		native IsValidButton(buttonid)
		{
			Description:
				Checks if <buttonid> is a valid button ID handle.

			Parameters:
				<buttonid> (int, buttonid)
					The button ID handle to check.

			Returns:
				1
					If the button ID handle <buttonid> is valid.

				0
					If the button ID handle <buttonid> is invalid.
		}

		native GetButtonArea(buttonid)
		{
			Description:
				Returns the streamer area ID used by a button.

			Parameters:
				-

			Returns:
				(int, areaid)
		}

		native SetButtonArea(buttonid, areaid)
		{
			Description:
				Updates a button's streamer area ID. Note that this does not
				remove the existing area from memory so that should be got with
				GetButtonArea and deleted beforehand.

			Parameters:
				-

			Returns:
				-
		}

		native SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = BTN_DEFAULT_STREAMDIST)
		{
			Description:
				Creates a 3D Text Label at the specified button ID handle, if
				a label already exists it updates the text, colour and range.

			Parameters:
				<buttonid> (int, buttonid)
					The button ID handle to set the label of.

				<text> (string)
					The text to display in the label.

				<colour> (int)
					The colour of the label.

				<range> (float)
					The stream range of the label.

			Returns:
				0
					If the button ID handle is invalid

				1
					If the label was created successfully.

				2
					If the label already existed and was updated successfully.
		}

		native DestroyButtonLabel(buttonid)
		{
			Description:
				Removes the label from a button.

			Parameters:
				<buttonid>
					The button ID handle to remove the label from.

			Returns:
				0
					If the button ID handle is invalid

				-1
					If the button does not have a label to remove.
		}

		native GetButtonPos(buttonid, &Float:x, &Float:y, &Float:z)
		{
			Description:

			Parameters:
				<buttonid> (int, buttonid)
					The ID handle of the button to get the position of.

				<x, y, z> (float)
					The X, Y and Z values of the button's position in the world.

			Returns:
				1
					If the position was obtained successfully.

				0
					If <buttonid> is an invalid button ID handle.
		}

		native SetButtonPos(buttonid, Float:x, Float:y, Float:z)
		{
			Description:
				Sets the world position for a button area and 3D Text label
				if it exists.

			Parameters:
				<buttonid> (int, buttonid)
					The ID handle of the button to set the position of.

				<x, y, z> (float)
					The X, Y and Z position values to set the button to.

			Returns:
				1
					If the position was set successfully.

				0
					If <buttonid> is an invalid button ID handle.
		}

		native GetButtonSize(buttonid)
		{
			Description:
				Returns the size of the specified button's dynamic area.

			Parameters:
				-

			Returns:
				0.0
					If the specified button ID handle is invalid.
		}

		native SetButtonSize(buttonid, Float:size)
		{
			Description:
				Sets a button's detection area size.

			Parameters:
				<size> (float)
					The size of the button area.

			Returns:
				1
					If the size was set successfully.

				0
					If <buttonid> is an invalid button ID handle.
		}

		native GetButtonWorld(buttonid)
		{
			Description:
				Returns the virtual world that a button exists in.

			Parameters:
				-

			Returns:
				-
		}

		native SetButtonWorld(buttonid, world)
		{
			Description:
				Updates a button's virtual world. Moves all streamer entities
				to the world too.

			Parameters:
				-

			Returns:
				-
		}

		native GetButtonInterior(buttonid)
		{
			Description:
				Returns the interior that a button exists in.

			Parameters:
				-

			Returns:
				-
		}

		native SetButtonInterior(buttonid, interior)
		{
			Description:
				Updates a button's interior. Moves all streamer entities
				to the interior too.

			Parameters:
				-

			Returns:
				-
		}

		native GetButtonLinkedID(buttonid)
		{
			Description:
				Returns the linked button of <buttonid>.

			Parameters:
				<buttonid> (int, buttonid)
					The button ID handle to get the linked button from.

			Returns:
				(int, buttonid)
					The button ID handle that <buttonid> is linked to

				INVALID_BUTTON_ID
					If the button isn't linked to another button.
		}

		native GetButtonText(buttonid, text[])
		{
			Description:
				Returns the text assigned to a button that appears on-screen
				when a player walks near it.

			Parameters:
				-

			Returns:
				-
		}

		native SetButtonText(buttonid, text[])
		{
			Description:
				Updates the text that appears on-screen when a player walks near
				the button.

			Parameters:
				-

			Returns:
				-
		}

		native SetButtonExtraData(buttonid, data)
		{
			Description:
				Sets the button's extra data field, this is one cell of blank
				space allocated for each button.

			Parameters:
				-

			Returns:
				-
		}

		native GetButtonExtraData(buttonid)
		{
			Description:
				Retrieves the integer assigned to the button set with
				SetButtonExtraData.

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerPressingButton(playerid)
		{
			Description:
				Returns the ID of the button that the player is currently
				pressing. This will only return a value while <playerid> is
				holding down the interact key at a button.

			Parameters:
				-

			Returns:
				(int, buttonid)
		}

		native GetPlayerButtonID(playerid)
		{
			Description:
				Returns the ID of the closest button that a player is standing
				within the area of.

			Parameters:
				-

			Returns:
				(int, buttonid)
		}

		native GetPlayerButtonList(playerid, list[], &size, bool:validate = false)
		{
			Description:
				Returns a list of buttons that a player is standing in the areas
				of.

			Parameters:
				<playerid> (int, playerid)
					Player to get a list of buttons from.

				<list> (array)
					Array to store the buttons in (Must be BTN_MAX_INRANGE size)

				<size> (int, ref)
					Stores the amount of buttons in the list.

				<validate>
					If true, the function will check if the player is actually
					in each button in the list. This is a small workaround for a
					larger problem that is currently unknown that results in a
					button not being removed from a player's list when they
					leave the area for it.

			Returns:
				1
					On success
		}

		native GetPlayerAngleToButton(playerid, buttonid)
		{
			Description:
				Returns the angle in degrees from a player to a button.

			Parameters:
				-

			Returns:
				(float, angle, degrees)
		}

		native GetButtonAngleToPlayer(playerid, buttonid)
		{
			Description:
				Returns the angle in degrees from a button to a player.

			Parameters:
				-

			Returns:
				(float, angle, degrees)
		}

	}

	SIF/Button/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		_btn_SortButtons(array[][e_button_range_data], left, right)
		{
			Description:
				Sorts the list of buttons that a player is nearby so they can be
				triggered in order of distance from the player (closest first).
		}

		Internal_OnButtonPress(playerid, buttonid)
		{
			Description:
				Called to handle linked button teleports, 
		}
	}

	SIF/Button/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnPlayerKeyStateChange
		{
			Reason:
				To detect player key inputs to allow players to press the
				default F/Enter keys to operate buttons and call OnButtonPress
				or OnButtonRelease.
		}

		YSI/OnScriptInit
		{
			Reason:
				Zero initialised array cells.
		}

		Streamer/OnPlayerEnterDynamicArea
		{
			Reason:
				To detect if a player enters a button's area and call
				OnPlayerEnterButtonArea.
		}

		Streamer/OnPlayerLeaveDynamicArea
		{
			Reason:
				To detect if a player leaves a button's area and call
				OnPlayerLeaveButtonArea.
		}
	}

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
	#include <SIF\extensions/DebugLabels.inc>
#endif

#include <YSI\y_iterate>
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <streamer>

#define _SIF_BUTTON_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


#if !defined BTN_MAX
	#define BTN_MAX			(8192)
#endif

#if !defined BTN_MAX_TEXT
	#define BTN_MAX_TEXT	(128)
#endif

#if !defined BTN_DEFAULT_STREAMDIST
	#define BTN_DEFAULT_STREAMDIST	(4.0)
#endif

#if !defined BTN_MAX_INRANGE
	#define BTN_MAX_INRANGE	(8)
#endif

#if !defined BTN_STREAMER_AREA_IDENTIFIER
	#define BTN_STREAMER_AREA_IDENTIFIER (100)
#endif

#if !defined BTN_TELEPORT_FREEZE_TIME
	#define BTN_TELEPORT_FREEZE_TIME (1000)
#endif


#define INVALID_BUTTON_ID	(-1)


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
Iterator:	btn_Index<BTN_MAX>
	#if defined DEBUG_LABELS_BUTTON
		,
			btn_DebugLabelType,
			btn_DebugLabelID[BTN_MAX]
	#endif
		;

static
			btn_CurrentlyNear[MAX_PLAYERS][BTN_MAX_INRANGE],
Iterator:	btn_CurrentlyNearIndex[MAX_PLAYERS]<BTN_MAX_INRANGE>,
			btn_CurrentlyPressing[MAX_PLAYERS];


forward OnButtonPress(playerid, buttonid);
forward OnButtonRelease(playerid, buttonid);
forward OnPlayerEnterButtonArea(playerid, buttonid);
forward OnPlayerLeaveButtonArea(playerid, buttonid);


static BUTTON_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	BUTTON_DEBUG = sif_debug_register_handler("SIF/Button");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnScriptInit]");

	Iter_Init(btn_CurrentlyNearIndex);

	for(new i; i < MAX_PLAYERS; i++)
	{
		btn_CurrentlyPressing[i] = INVALID_BUTTON_ID;
	}

	#if defined DEBUG_LABELS_BUTTON
		btn_DebugLabelType = DefineDebugLabelType("BUTTON", 0xFF0000FF);
	#endif
}

hook OnPlayerConnect(playerid)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerConnect]")<playerid>;
	Iter_Clear(btn_CurrentlyNearIndex[playerid]);
	btn_CurrentlyPressing[playerid] = INVALID_BUTTON_ID;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateButton(Float:x, Float:y, Float:z, text[], world = 0, interior = 0, Float:areasize = 1.0, label = 0, labeltext[] = "", labelcolour = 0xFFFF00FF, Float:streamdist = BTN_DEFAULT_STREAMDIST)
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
		btn_Data[id][btn_label] = CreateDynamic3DTextLabel(labeltext, labelcolour, x, y, z, streamdist, _, _, 0, world, interior, _, streamdist);

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


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerKeyStateChange]")<playerid>;
	if(newkeys & 16)
	{
		if(!IsPlayerInAnyVehicle(playerid) && Iter_Count(btn_CurrentlyNearIndex[playerid]) > 0)
		{
			if(!IsPlayerInAnyDynamicArea(playerid))
			{
				printf("[WARNING] Player %d is not in areas but list isn't empty. Purging list.", playerid);
				Iter_Clear(btn_CurrentlyNearIndex[playerid]);
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

			foreach(new i : btn_CurrentlyNearIndex[playerid])
			{
				if(index >= BTN_MAX_INRANGE)
					break;

				id = btn_CurrentlyNear[playerid][i];

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
			if(btn_CurrentlyPressing[playerid] != INVALID_BUTTON_ID)
			{
				CallLocalFunction("OnButtonRelease", "dd", playerid, btn_CurrentlyPressing[playerid]);
				btn_CurrentlyPressing[playerid] = INVALID_BUTTON_ID;
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
		btn_CurrentlyPressing[playerid] = buttonid;

		if(CallLocalFunction("OnButtonPress", "dd", playerid, buttonid))
			return 1;
	}

	return 0;
}

timer btn_Unfreeze[BTN_TELEPORT_FREEZE_TIME](playerid)
{
	TogglePlayerControllable(playerid, true);
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerEnterDynamicArea]")<playerid>;
	if(!IsPlayerInAnyVehicle(playerid) && Iter_Count(btn_CurrentlyNearIndex[playerid]) < BTN_MAX_INRANGE)
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
				new cell = Iter_Free(btn_CurrentlyNearIndex[playerid]);

				btn_CurrentlyNear[playerid][cell] = data[1];
				Iter_Add(btn_CurrentlyNearIndex[playerid], cell);

				ShowActionText(playerid, btn_Data[data[1]][btn_text]);
				CallLocalFunction("OnPlayerEnterButtonArea", "dd", playerid, data[1]);
			}
		}
	}

	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerEnterDynamicArea] end")<playerid>;

	#if defined btn_OnPlayerEnterDynamicArea
		return btn_OnPlayerEnterDynamicArea(playerid, areaid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea btn_OnPlayerEnterDynamicArea
#if defined btn_OnPlayerEnterDynamicArea
	forward btn_OnPlayerEnterDynamicArea(playerid, areaid);
#endif


public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	process_LeaveDynamicArea(playerid, areaid);

	#if defined btn_OnPlayerLeaveDynamicArea
		return btn_OnPlayerLeaveDynamicArea(playerid, areaid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea btn_OnPlayerLeaveDynamicArea
#if defined btn_OnPlayerLeaveDynamicArea
	forward btn_OnPlayerLeaveDynamicArea(playerid, areaid);
#endif

process_LeaveDynamicArea(playerid, areaid)
{
	sif_dp:SIF_DEBUG_LEVEL_CALLBACKS:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea]")<playerid>;
	if(!IsPlayerInAnyVehicle(playerid) && Iter_Count(btn_CurrentlyNearIndex[playerid]) > 0)
	{
		sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] player is valid")<playerid>;
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
			sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] area is valid")<playerid>;
			if(Iter_Contains(btn_Index, data[1]))
			{
				sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] in index")<playerid>;
				HideActionText(playerid);
				CallLocalFunction("OnPlayerLeaveButtonArea", "dd", playerid, data[1]);

				foreach(new i : btn_CurrentlyNearIndex[playerid])
				{
					sif_dp:SIF_DEBUG_LEVEL_LOOPS:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] looping player list")<playerid>;
					// ^ Add when debug supports format strings
					if(btn_CurrentlyNear[playerid][i] == data[1])
					{
						sif_dp:SIF_DEBUG_LEVEL_CALLBACKS_DEEP:BUTTON_DEBUG("[OnPlayerLeaveDynamicArea] removing from player list")<playerid>;
						Iter_Remove(btn_CurrentlyNearIndex[playerid], i);
						break;
					}
				}
			}
		}
	}
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

	Interface Functions

==============================================================================*/


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
stock SetButtonLabel(buttonid, text[], colour = 0xFFFF00FF, Float:range = BTN_DEFAULT_STREAMDIST)
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
		range, _, _, 1,
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

// btn_CurrentlyPressing
stock GetPlayerPressingButton(playerid)
{
	sif_dp:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetPlayerPressingButton]")<playerid>;
	if(!(0 <= playerid < MAX_PLAYERS))
		return -1;

	return btn_CurrentlyPressing[playerid];
}

stock GetPlayerButtonID(playerid)
{
	sif_dp:SIF_DEBUG_LEVEL_INTERFACE:BUTTON_DEBUG("[GetPlayerButtonID]")<playerid>;

	if(!IsPlayerConnected(playerid))
		return INVALID_BUTTON_ID;

	if(Iter_Count(btn_CurrentlyNearIndex[playerid]) == 0)
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

	foreach(new i : btn_CurrentlyNearIndex[playerid])
	{
		curid = btn_CurrentlyNear[playerid][i];

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

	if(Iter_Count(btn_CurrentlyNearIndex[playerid]) == 0)
		return 0;

	// Validate whether or not the player is actually inside the areas.
	// Caused by a bug that hasn't been found yet, this is the quick workaround.
	if(validate)
	{
		foreach(new i : btn_CurrentlyNearIndex[playerid])
		{
			if(!IsPlayerInDynamicArea(playerid, btn_Data[btn_CurrentlyNear[playerid][i]][btn_area]))
			{
				printf("ERROR: Player %d incorrectly flagged as inside button %d area, removing.", playerid, btn_CurrentlyNear[playerid][i]);
				Iter_SafeRemove(btn_CurrentlyNearIndex[playerid], i, i);
				continue;
			}

			list[size++] = btn_CurrentlyNear[playerid][i];
		}
	}
	else
	{
		foreach(new i : btn_CurrentlyNearIndex[playerid])
			list[size++] = btn_CurrentlyNear[playerid][i];
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

	Testing

==============================================================================*/


#if defined RUN_TESTS
	#include <SIF\testing/Button.pwn>
#endif
