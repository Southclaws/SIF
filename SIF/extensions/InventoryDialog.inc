/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.4.0
	Module Version: 1.3.2


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/InventoryDialog/Description
	{
		An extension for SIF/Inventory that uses SA:MP dialog menus for player
		interaction with their inventory items.
	}

	SIF/InventoryDialog/Dependencies
	{
		SIF/Inventory
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/InventoryDialog/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
	}

	SIF/InventoryDialog/Constants
	{
		DIALOG_INVENTORY_LIST
			-

		DIALOG_INVENTORY_OPTIONS		
			-
	}

	SIF/InventoryDialog/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/InventoryDialog/Core
		native -

		native DisplayPlayerInventory(playerid)
		{
			Description:
				Displays a dialog to the player listing his inventory contents.

			Parameters:
				-

			Returns:
				0
					If OnPlayerOpenInventory has returned true and cancelled
					displaying the dialog to the player.
		}

		native ClosePlayerInventory(playerid)
		{
			Description:
				Closes the player inventory screen if it is displayed. If the
				player isn't viewing his inventory, the function does nothing to
				avoid closing a dialog unintentionally.

			Parameters:
				-

			Returns:
				0
					If the player wasn't viewing his inventory.
		}
	}

	SIF/InventoryDialog/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/InventoryDialog/Callbacks
		native -

		native OnPlayerOpenInventory(playerid);
		{
			Called:
				When a player presses H to open his inventory.

			Parameters:
				<playerid> (int)
					The player who opened their inventory.

			Returns:
				1
					To cancel displaying the inventory to the player.
		}

		native OnPlayerCloseInventory(playerid);
		{
			Called:
				When a player exits the inventory dialog.

			Parameters:
				<playerid> (int)
					The player who closed their inventory.

			Returns:
				1
					To disable the player from closing their inventory.
		}

		native OnPlayerSelectExtraItem(playerid, item)
		{
			Called:
				When a player selects an extra menu item (not an actual
				inventory item, but a menu item added with AddInventoryListItem)

			Parameters:
				<playerid> (int)
					The player who chose the menu item.

				<item> (int)
					The menu row starting from 0 (however, the actual listitem
					value would be above INV_MAX_SLOTS)

			Returns:
				(none)

		}

		native OnPlayerViewInventoryOpt(playerid);
		{
			Called:
				When a player opens the options menu for an item in his
				inventory. This callback can be used to add extra options.

			Parameters:
				<playerid>
					The player who opened the options menu.

			Returns:
				(none)
		}

		native OnPlayerRemoveFromInventory(playerid, slotid);
		{
			Called:
				When a player removes an item from his inventory either by
				equipping it or dropping it.

			Parameters:
				<playerid> (int)
					The player who removed an item from his inventory.

				<slotid> (int)
					The inventory slot which he removed the item from.

			Returns:
				1
					To cancel the action and disallow the player from removing
					the item from his inventory.
		}

		native OnPlayerRemovedFromInventory(playerid, slotid);
		{
			Called:
				After a player has removed an item from his inventory and the
				inventory index is updated with the item removed.

			Parameters:
				<playerid> (int)
					The player who removed an item from his inventory.

				<slotid> (int)
					The inventory slot which he removed the item from.

			Returns:
				(none)
		}

		native OnPlayerSelectInventoryOption(playerid, option);
		{
			Called:
				When a player selects an additional option from the item options
				menu. Note that this is only called when extra options are
				selected and not for the default Equip, Use and Drop options.

			Parameters:
				<playerid> (int)
					The player who selected an option in his inventory options.

				<option> (int)
					The option selected starting from 0, not the dialog
					listitem value. (it's listitem + number of default options)

			Returns:
				(none)
		}	}

	SIF/InventoryDialog/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/InventoryDialog/Interface
		native -

		native GetPlayerSelectedInventorySlot(playerid)
		{
			Description:
				Returns the inventory slot that the player is currently
				interacting with. The value this function returns will reset to
				-1 once the player exits his inventory menu.

			Parameters:
				-

			Returns:
				-1
					If the player has exited his inventory.
		}

		native AddInventoryListItem(playerid, itemname[])
		{
			Description:
				Only works properly when used in OnPlayerOpenInventory, this
				function adds a new menu row under the inventory items. When
				a newly added row is selected, the callback
				OnPlayerSelectExtraItem is called.

			Parameters:
				<playerid> (int)
					The player to add the new menu item to.

				<itemname> (string)
					The text to display in the new menu row. Does not require a
					newline '\n' character.

			Returns:
		}

		native AddInventoryOption(playerid, option[])
		{
			Description:
				Only works properly when used in OnPlayerViewInventoryOpt.
				This function adds an option to the inventory item options list.
				The inventory options are addressed from 0, not the number of
				default options.

			Parameters:
				<option> (string)
					The option name, note that a new line character is not
					required as the function adds these automatically.

			Returns:
				0
					If the options string can't fit the specified option.
		}

		native GetInventoryListItems(playerid)
		{
			Description:
				Returns the extra inventory list items as a string.

			Parameters:
				-

			Returns:
				A string containing the list items separated by '\n'
		}

		native GetInventoryOptions(playerid)
		{
			Description:
				Returns the extra inventory options as a string.

			Parameters:
				-

			Returns:
				A string containing the inventory options separated by '\n'
		}

		native GetInventoryListItemCount(playerid)
		{
			Description:
				Returns the number of extrainventory list items.

			Parameters:
				-

			Returns:
				-
		}

		native GetInventoryOptionCount(playerid)
		{
			Description:
				Returns the number of extra inventory options.

			Parameters:
				-

			Returns:
				-
		}


		native IsPlayerViewingInventory(playerid)
		{
			Description:
				Checks if a player is viewing his inventory menu.

			Parameters:
				-

			Returns:
				-
		}

	}

	SIF/InventoryDialog/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		DisplayPlayerInventoryOptions(playerid, slotid)
		{
			Description:
				Displays the options menu and calls OnPlayerViewInventoryOpt
				in order to add any additional options.
		}
	}

	SIF/InventoryDialog/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		YSI/OnScriptInit
		{
			Reason:
				Zero initialised array cells.
		}
	}

==============================================================================*/


#if defined _SIF_INVENTORY_DIALOG_INCLUDED
	#endinput
#endif

#include <YSI_4\y_hooks>
#include <YSI_4\y_dialog>

#define _SIF_INVENTORY_DIALOG_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


static
		inv_ItemListTotal			[MAX_PLAYERS],
		inv_SelectedSlot			[MAX_PLAYERS],
		inv_ViewingInventory		[MAX_PLAYERS],
		inv_ExtraItemList			[MAX_PLAYERS][128],
		inv_ExtraItemCount			[MAX_PLAYERS],
		inv_OptionsList				[MAX_PLAYERS][128],
		inv_OptionsCount			[MAX_PLAYERS];


forward OnPlayerOpenInventory(playerid);
forward OnPlayerCloseInventory(playerid);
forward OnPlayerSelectExtraItem(playerid, item);
forward OnPlayerRemoveFromInventory(playerid, slotid); // TODO
forward OnPlayerRemovedFromInventory(playerid, slotid); // TODO
forward OnPlayerViewInventoryOpt(playerid);
forward OnPlayerSelectInventoryOpt(playerid, option);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			inv_SelectedSlot[i] = -1;
		}
	}
}

hook OnPlayerConnect(playerid)
{
	for(new j; j < INV_MAX_SLOTS; j++)
	{
		inv_SelectedSlot[playerid] = -1;
	}

	return;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock DisplayPlayerInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new
		title[18],
		list[(INV_MAX_SLOTS * (ITM_MAX_NAME + ITM_MAX_TEXT + 1)) + 32],
		itemid,
		tmp[5 + ITM_MAX_NAME + ITM_MAX_TEXT + 1];

	inv_ItemListTotal[playerid] = 0;

	for(new i; i < GetPlayerInventorySize(playerid); i++)
	{
		itemid = GetInventorySlotItem(playerid, i);

		if(!IsValidItem(itemid))
			break;

		GetItemName(itemid, tmp);

		format(list, sizeof(list), "%s[%02d]%s\n", list, GetItemTypeSize(GetItemType(itemid)), tmp);
		inv_ItemListTotal[playerid]++;
	}

	for(new i; i < GetInventoryFreeSlots(playerid); i++)
	{
		strcat(list, "<Empty>\n");
		inv_ItemListTotal[playerid]++;
	}

	inv_ExtraItemList[playerid][0] = EOS;
	inv_ExtraItemCount[playerid] = 0;

	if(CallLocalFunction("OnPlayerOpenInventory", "d", playerid))
		return 0;

	if(!isnull(inv_ExtraItemList[playerid]))
		strcat(list, inv_ExtraItemList[playerid]);

	format(title, sizeof(title), "Inventory (%d/%d)", GetPlayerInventorySize(playerid) - GetInventoryFreeSlots(playerid), GetPlayerInventorySize(playerid));

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			if(listitem >= inv_ItemListTotal[playerid])
			{
				CallLocalFunction("OnPlayerSelectExtraItem", "dd", playerid, listitem - inv_ItemListTotal[playerid]);
				inv_ViewingInventory[playerid] = false;
				return 1;
			}

			if(!IsValidItem(GetInventorySlotItem(playerid, listitem)))
			{
				DisplayPlayerInventory(playerid);
			}
			else
			{
				inv_SelectedSlot[playerid] = listitem;
				DisplayPlayerInventoryOptions(playerid, listitem);
			}
		}
		else
		{
			ClosePlayerInventory(playerid, true);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, title, list, "Options", "Close");

	inv_ViewingInventory[playerid] = true;

	return 1;
}

stock ClosePlayerInventory(playerid, call = false)
{
	if(!inv_ViewingInventory[playerid])
		return 0;

	if(call)
	{
		if(CallLocalFunction("OnPlayerCloseInventory", "d", playerid))
		{
			DisplayPlayerInventory(playerid);
			return 1;
		}
	}

	Dialog_Hide(playerid);
	inv_ViewingInventory[playerid] = false;

	return 1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayPlayerInventoryOptions(playerid, slotid)
{
	new
		name[ITM_MAX_NAME + ITM_MAX_TEXT];

	GetItemName(GetInventorySlotItem(playerid, slotid), name);
	inv_OptionsList[playerid] = "Equip\nUse\nDrop\n";
	inv_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewInventoryOpt", "d", playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(!response)
		{
			DisplayPlayerInventory(playerid);
			return 1;
		}

		switch(listitem)
		{
			case 0:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
				{
					new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					GiveWorldItemToPlayer(playerid, itemid, 1);
					DisplayPlayerInventory(playerid);
				}
				else
				{
					ShowActionText(playerid, "You are already holding something", 3000, 200);
					DisplayPlayerInventory(playerid);
				}
			}
			case 1:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
				{
					new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					GiveWorldItemToPlayer(playerid, itemid, 1);

					PlayerUseItem(playerid);

					ClosePlayerInventory(playerid, true);
				}
				else
				{
					ShowActionText(playerid, "You are already holding something", 3000, 200);
					DisplayPlayerInventory(playerid);
				}
			}
			case 2:
			{
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
				{
					new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					GiveWorldItemToPlayer(playerid, itemid, 1);

					PlayerDropItem(playerid);

					ClosePlayerInventory(playerid, true);
				}
				else
				{
					ShowActionText(playerid, "You are already holding something", 3000, 200);
					DisplayPlayerInventory(playerid);
				}
			}
			default:
			{
				CallLocalFunction("OnPlayerSelectInventoryOpt", "dd", playerid, listitem - 3);
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, name, inv_OptionsList[playerid], "Accept", "Back");

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetPlayerSelectedInventorySlot(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return inv_SelectedSlot[playerid];
}

stock AddInventoryListItem(playerid, itemname[])
{
	if(strlen(inv_ExtraItemList[playerid]) + strlen(itemname) > sizeof(inv_ExtraItemList[]))
		return 0;

	strcat(inv_ExtraItemList[playerid], itemname);
	strcat(inv_ExtraItemList[playerid], "\n");

	return inv_ExtraItemCount[playerid]++;
}

stock AddInventoryOption(playerid, option[])
{
	if(strlen(inv_OptionsList[playerid]) + strlen(option) > sizeof(inv_OptionsList[]))
		return 0;

	strcat(inv_OptionsList[playerid], option);
	strcat(inv_OptionsList[playerid], "\n");

	return inv_OptionsCount[playerid]++;
}

stock GetInventoryListItems(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ExtraItemList[playerid];
}

stock GetInventoryOptions(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_OptionsList[playerid];
}

stock GetInventoryListItemCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ExtraItemCount[playerid];
}

stock GetInventoryOptionCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_OptionsCount[playerid];
}

stock IsPlayerViewingInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ViewingInventory[playerid];
}
