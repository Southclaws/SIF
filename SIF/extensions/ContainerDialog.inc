/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.3.0
	Module Version: 1.1.1


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/ContainerDialog/Description
	{
		An extension script for SIF/Container that adds SA:MP dialogs for player
		interaction with containers. Also allows containers and inventories to
		work together.
	}

	SIF/ContainerDialog/Dependencies
	{
		SIF/Container
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/ContainerDialog/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/ContainerDialog/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/ContainerDialog/Core
		native -

		native DisplayContainerInventory(playerid, containerid)
		{
			Description:
				Displays the contents of a container with a SA:MP dialog.

			Parameters:
				-

			Returns:
				-
		}

		native ClosePlayerContainer(playerid)
		{
			Description:
				Closes a container dialog for a player. It's important that this
				function is used rather than just a dialog close function as
				this clears the current dialog ID from the player.

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/ContainerDialog/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/ContainerDialog/Callbacks
		native -

		native OnPlayerOpenContainer(playerid, containerid);
		{
			Called:
				When a container dialog is displayed for a player.

			Parameters:
				-

			Returns:
				1
					To cancel the dialog being shown.
		}

		native OnPlayerCloseContainer(playerid, containerid);
		{
			Called:
				When a container dialog menu is closed for a player.

			Parameters:
				-

			Returns:
				1
					To cancel and keep the dialog open.
		}

		native OnPlayerViewContainerOpt(playerid, containerid);
		{
			Called:
				When a player opens the options for an item in a container.

			Parameters:
				-

			Returns:
				-
		}

		native OnPlayerSelectContainerOpt(playerid, containerid, option);
		{
			Called:
				When a player selects an option for an item in a container.

			Parameters:
				-

			Returns:
				-
		}

		native OnMoveItemToContainer(playerid, itemid, containerid);
		{
			Called:
				When a player moves an item from their inventory to a container
				using the inventory options dialog.

			Parameters:
				-

			Returns:
				-
		}

		native OnMoveItemToInventory(playerid, itemid, containerid);
		{
			Called:
				When a player moves an item from a container to their inventory
				using the container options dialog.

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/ContainerDialog/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/ContainerDialog/Interface
		native -

		native GetPlayerCurrentContainer(playerid)
		{
			Description:
				Returns the container that <playerid> is currently viewing.

			Parameters:
				-

			Returns:
				(int, containerid)
		}

		native GetPlayerContainerSlot(playerid)
		{
			Description:
				Returns the slot that a player selected in the container dialog.

			Parameters:
				-

			Returns:
				-1
					If the specified player is invalid.
		}

		native AddContainerOption(playerid, option[])
		{
			Description:
				Adds an option to a player's container dialog option list.

			Parameters:
				-

			Returns:
				0
					If the input string won't fit in the options string.
		}
	}

	SIF/ContainerDialog/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		DisplayContainerOptions(playerid, slotid)
		{
			Description:
				-
		}
	}

	SIF/ContainerDialog/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SAMP/OnDialogResponse
		{
			Reason:
				-
		}
	}

==============================================================================*/


#if defined _SIF_CONTAINER_DIALOG_INCLUDED
	#endinput
#endif

#include <YSI\y_hooks>

#define _SIF_CONTAINER_DIALOG_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


#if !defined DIALOG_CONTAINER_LIST
	#define DIALOG_CONTAINER_LIST		(9002)
#endif

#if !defined DIALOG_CONTAINER_OPTIONS
	#define DIALOG_CONTAINER_OPTIONS	(9003)
#endif


static
			cnt_CurrentContainer		[MAX_PLAYERS],
			cnt_SelectedSlot			[MAX_PLAYERS],
			cnt_OptionsList				[MAX_PLAYERS][128],
			cnt_OptionsCount			[MAX_PLAYERS],
			cnt_InventoryContainerItem	[MAX_PLAYERS],
			cnt_InventoryOptionID		[MAX_PLAYERS];


forward OnPlayerOpenContainer(playerid, containerid);
forward OnPlayerCloseContainer(playerid, containerid);
forward OnPlayerViewContainerOpt(playerid, containerid);
forward OnPlayerSelectContainerOpt(playerid, containerid, option);
forward OnMoveItemToContainer(playerid, itemid, containerid);
forward OnMoveItemToInventory(playerid, itemid, containerid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		_ContDialog_ResetPlayerVars(i);
	}
}

hook OnPlayerConnect(playerid)
{
	_ContDialog_ResetPlayerVars(playerid);
}

_ContDialog_ResetPlayerVars(playerid)
{
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
	cnt_SelectedSlot[playerid] = -1;
	cnt_OptionsList[playerid][0] = EOS;
	cnt_OptionsCount[playerid] = 0;
	cnt_InventoryContainerItem[playerid] = INVALID_ITEM_ID;
	cnt_InventoryOptionID[playerid] = 0;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock DisplayContainerInventory(playerid, containerid)
{
	if(!IsValidContainer(containerid))
		return 0;

	new
		list[CNT_MAX_SLOTS * (ITM_MAX_NAME + 1)],
		tmp[ITM_MAX_NAME];

	for(new i; i < cnt_Data[containerid][cnt_size]; i++)
	{
		if(!IsValidItem(cnt_Items[containerid][i])) strcat(list, "<Empty>\n");
		else
		{
			GetItemName(cnt_Items[containerid][i], tmp);
			strcat(list, tmp);
			strcat(list, "\n");
		}
	}

	strcat(list, "My Inventory >");

	cnt_CurrentContainer[playerid] = containerid;

	if(CallLocalFunction("OnPlayerOpenContainer", "dd", playerid, containerid))
		return 0;

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			if(!IsValidContainer(cnt_CurrentContainer[playerid]))
				return 0;

			if(listitem == cnt_Data[cnt_CurrentContainer[playerid]][cnt_size])
			{
				DisplayPlayerInventory(playerid);
			}
			else
			{
				if(!IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][listitem]))
				{
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
				else
				{
					cnt_SelectedSlot[playerid] = listitem;
					DisplayContainerOptions(playerid, listitem);
				}
			}
		}
		else
		{
			ClosePlayerContainer(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, cnt_Data[containerid][cnt_name], list, "Options", "Close");

	SelectTextDraw(playerid, 0xFFFF00FF);

	return 1;
}

stock ClosePlayerContainer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(cnt_CurrentContainer[playerid] == INVALID_CONTAINER_ID)
		return 0;

	Dialog_Hide(playerid);
	CancelSelectTextDraw(playerid);
	CallLocalFunction("OnPlayerCloseContainer", "dd", playerid, cnt_CurrentContainer[playerid]);
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;

	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayContainerOptions(playerid, slotid)
{
	new
		tmp[ITM_MAX_NAME];

	GetItemName(cnt_Items[cnt_CurrentContainer[playerid]][slotid], tmp);

	if(GetItemTypeSize(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][slotid])) == ITEM_SIZE_SMALL)
		cnt_OptionsList[playerid] = "Equip\nMove to inventory\n";

	else
		cnt_OptionsList[playerid] = "Equip\n";

	cnt_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewContainerOpt", "dd", playerid, cnt_CurrentContainer[playerid]);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(!response)
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			return 1;
		}

		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID && GetPlayerWeapon(playerid) == 0)
				{
					new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

					RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
					GiveWorldItemToPlayer(playerid, id);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
				else
				{
					ShowActionText(playerid, "You are already holding something", 3000, 200);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
			}
			case 1:
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]])) != ITEM_SIZE_SMALL)
				{
					CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, cnt_CurrentContainer[playerid], 0);
					return 1;
				}

				new itemid = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

				if(IsPlayerInventoryFull(playerid) || !IsValidItem(itemid))
				{
					ShowActionText(playerid, "Inventory full", 3000, 100);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
					return 0;
				}

				if(CallLocalFunction("OnMoveItemToInventory", "ddd", playerid, itemid, cnt_CurrentContainer[playerid]))
					return 0;

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid, 0);
				AddItemToInventory(playerid, itemid);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);

				return 1;
			}
			default:
			{
				if(GetItemTypeSize(GetItemType(cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]])) == ITEM_SIZE_SMALL)
					CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, cnt_CurrentContainer[playerid], listitem - 2);

				else
					CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, cnt_CurrentContainer[playerid], listitem - 1);
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, tmp, cnt_OptionsList[playerid], "Accept", "Back");

	return 1;
}

hook OnButtonPress(playerid, buttonid)
{
	new containerid = GetButtonContainer(buttonid);

	if(IsValidContainer(containerid))
	{
		DisplayContainerInventory(playerid, containerid);
	}
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(IsValidContainer(cnt_CurrentContainer[playerid]))
		{
			ClosePlayerContainer(playerid);
		}
	}

	return 1;
}

hook OnPlayerViewInvOpt(playerid)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		new str[8 + CNT_MAX_NAME];
		str = "Move to ";
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		cnt_InventoryOptionID[playerid] = AddInventoryOption(playerid, str);
	}
}

hook OnPlayerSelectInvOpt(playerid, option)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		if(option == cnt_InventoryOptionID[playerid])
		{
			new
				slot,
				itemid;

			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][cnt_Data[cnt_CurrentContainer[playerid]][cnt_size]-1]) || !IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return 0;
			}

			if(CallLocalFunction("OnMoveItemToContainer", "ddd", playerid, itemid, cnt_CurrentContainer[playerid]))
				return 0;

			RemoveItemFromInventory(playerid, slot, 0);
			AddItemToContainer(cnt_CurrentContainer[playerid], itemid, playerid);
			DisplayPlayerInventory(playerid);

			return 1;
		}
	}

	return 1;
}

hook OnPlayerOpenInventory(playerid)
{
	if(IsValidContainer(cnt_CurrentContainer[playerid]))
	{
		new str[CNT_MAX_NAME + 2];
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		strcat(str, " >");
		cnt_InventoryContainerItem[playerid] = AddInventoryListItem(playerid, str);
	}
}

hook OnPlayerSelectExtraItem(playerid, item)
{
	if(IsValidContainer(cnt_CurrentContainer[playerid]))
	{
		if(item == cnt_InventoryContainerItem[playerid])
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
		}
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetPlayerCurrentContainer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_CONTAINER_ID;

	return cnt_CurrentContainer[playerid];
}

stock GetPlayerContainerSlot(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return cnt_SelectedSlot[playerid];
}

stock AddContainerOption(playerid, option[])
{
	if(strlen(cnt_OptionsList[playerid]) + strlen(option) > sizeof(cnt_OptionsList[]))
		return 0;

	strcat(cnt_OptionsList[playerid], option);
	strcat(cnt_OptionsList[playerid], "\n");

	return cnt_OptionsCount[playerid]++;
}
