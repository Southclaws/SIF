/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/Craft/Description
	{
		A small module to add a combination functionality to inventories
		enabling players to combine two items into one new item.
	}

	SIF/Craft/Dependencies
	{
		SIF/Item
		SIF/Inventory
		Streamer Plugin
		YSI\y_hooks
		YSI\y_timers
	}

	SIF/Craft/Credits
	{
		SA:MP Team						- Amazing mod!
		SA:MP Community					- Inspiration and support
		Incognito						- Very useful streamer plugin
		Y_Less							- YSI framework
		Patrik356b						- Discussing the idea and testing it
	}

	SIF/Craft/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/Craft/Core
		native -

		native DefineItemCombo(ItemType:item1, ItemType:item2, ItemType:result, returnitem1, returnitem2)
		{
			Description:
				Adds a new combination "recipe" to the index.

			Parameters:
				<item1> (int, ItemType)
					One of the two item types required for the combination.

				<item2> (int, ItemType)
					The other item type.

				<result> (int, ItemType)
					The type of the resulting item from the combination.

			Returns:
				-1
					If the item combination index is full.
		}
	}

	SIF/Craft/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
		GetItemComboResult(ItemType:item1, ItemType:item, &retitem1, &retitem)
		{
			Description:
				Returns the result of two items combined. Returns
				INVALID_ITEM_TYPE if there is no combination.
		}
	}

	SIF/Craft/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SIF/Inventory/OnPlayerViewInventoryOpt
		{
			Reason:
				To add a "Combine" option to the player's inventory options.
		}

		SIF/Inventory/OnPlayerSelectInventoryOpt
		{
			Reason:
				To give functionality to the "Combine" option.
		}
		SAMP/hook OnDialogResponse
		{
			Reason:
				To handle a dialog created by the module for displaying a list of
				a player's items to combine the selected one with.
		}

	}

==============================================================================*/


/*==============================================================================

	Setup

==============================================================================*/


#include <YSI\y_hooks>


#define CFT_MAX_COMBO (16)
#define DIALOG_COMBINE_ITEM (9004)


enum E_CRAFT_COMBO_DATA
{
ItemType:	cft_item1,
ItemType:	cft_item2,
ItemType:	cft_result,
			cft_retItem1,
			cft_retItem2
}


static 
ItemType:	cft_Data[CFT_MAX_COMBO][E_CRAFT_COMBO_DATA],
Iterator:	cft_Index<CFT_MAX_COMBO>;

static
			cft_SelectedInvSlot[MAX_PLAYERS],
			cft_InventoryOptionID[MAX_PLAYERS];


forward ItemType:GetItemComboResult(ItemType:item1, ItemType:item2, &retitem1, &retitem);


/*==============================================================================

	Core Functions

==============================================================================*/


stock DefineItemCombo(ItemType:item1, ItemType:item2, ItemType:result, returnitem1, returnitem2)
{
	new id = Iter_Free(cft_Index);
	if(id == -1)
		return -1;

	cft_Data[id][cft_item1] = item1;
	cft_Data[id][cft_item2] = item2;
	cft_Data[id][cft_result] = result;
	cft_Data[id][cft_retItem1] = returnitem1;
	cft_Data[id][cft_retItem2] = returnitem2;

	Iter_Add(cft_Index, id);

	return id;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


public OnPlayerViewInventoryOpt(playerid)
{
	cft_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Combine");

	return CallLocalFunction("cft_OnPlayerViewInventoryOpt", "d", playerid);
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt cft_OnPlayerViewInventoryOpt
forward OnPlayerViewInventoryOpt(playerid);

public OnPlayerSelectInventoryOpt(playerid, option)
{
	if(option == cft_InventoryOptionID[playerid])
	{
		cft_SelectedInvSlot[playerid] = GetPlayerSelectedInventorySlot(playerid);

		DisplayCombineInventory(playerid);
	}

	return CallLocalFunction("cft_OnPlayerSelectInventoryOpt", "dd", playerid, option);
}
#if defined _ALS_OnPlayerSelectInventoryOpt
	#undef OnPlayerSelectInventoryOpt
#else
	#define _ALS_OnPlayerSelectInventoryOpt
#endif
#define OnPlayerSelectInventoryOpt cft_OnPlayerSelectInventoryOpt
forward OnPlayerSelectInventoryOpt(playerid, option);

DisplayCombineInventory(playerid)
{
	new
		list[INV_MAX_SLOTS * (ITM_MAX_NAME + 1)],
		tmp[ITM_MAX_NAME];
	
	for(new i; i < INV_MAX_SLOTS; i++)
	{
		if(!IsValidItem(GetInventorySlotItem(playerid, i)))
			strcat(list, "<Empty>\n");

		else
		{
			GetItemTypeName(GetItemType(GetInventorySlotItem(playerid, i)), tmp);
			strcat(list, tmp);
			strcat(list, "\n");
		}
	}

	ShowPlayerDialog(playerid, DIALOG_COMBINE_ITEM, DIALOG_STYLE_LIST, "Inventory", list, "Combine", "Close");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_COMBINE_ITEM)
	{
		if(!response)
		{
			DisplayPlayerInventory(playerid);
			return 1;
		}

		// If the player picks the same inventory item as the one he is trying to combine
		// Or if he picks an empty slot, re-render the dialog.
		// You can't combine something with itself or nothing, that's like dividing by zero!

		if(listitem == GetPlayerSelectedInventorySlot(playerid) || !IsInventorySlotUsed(playerid, listitem))
		{
			DisplayCombineInventory(playerid);
			return 1;
		}

		// Get the item combination result, AKA the item that the two items will create.

		new
			retitem1,
			retitem2,
			ItemType:result,
			itemslot1,
			itemslot2;

		result = GetItemComboResult(
			GetItemType(GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid))),
			GetItemType(GetInventorySlotItem(playerid, listitem)), retitem1, retitem2);

		if(retitem1 && retitem2)
		{
			if(GetInventoryFreeSlots(playerid) < 3)
			{
				ShowMsgBox(playerid, "Not enough inventory space", 3000);
				return 0;
			}
		}

		// The above function returns an invalid item if there is no combination
		// If it's valid then delete the original items and add the new one to the inventory.

		if(IsValidItemType(result))
		{
			new newitem = CreateItem(result, 0.0, 0.0, 0.0);

			// Remove from the highest slot first
			// Because the remove code shifts other inventory items up by 1 slot.

			if(GetPlayerSelectedInventorySlot(playerid) > listitem)
			{
				itemslot1 = GetPlayerSelectedInventorySlot(playerid);
				itemslot2 = listitem;
			}
			else
			{
				itemslot1 = listitem;
				itemslot2 = GetPlayerSelectedInventorySlot(playerid);
			}

			if(!retitem1)
			{
				DestroyItem(GetInventorySlotItem(playerid, itemslot1));
				RemoveItemFromInventory(playerid, itemslot1);
			}

			if(!retitem2)
			{
				DestroyItem(GetInventorySlotItem(playerid, itemslot2));
				RemoveItemFromInventory(playerid, itemslot2);
			}

			AddItemToInventory(playerid, newitem);

			DisplayPlayerInventory(playerid);
		}

		// If it's not valid, re-render the dialog.

		else DisplayCombineInventory(playerid);
	}

	return 1;
}

ItemType:GetItemComboResult(ItemType:item1, ItemType:item2, &retitem1 = 0, &retitem = 0)
{
	// Loop through all "recipe" item combinations
	// If a match is found, return that combo result.
	foreach(new i : cft_Index)
	{
		if(cft_Data[i][cft_item1] == item1 && cft_Data[i][cft_item2] == item2)
			return cft_Data[i][cft_result];

		if(cft_Data[i][cft_item2] == item1 && cft_Data[i][cft_item1] == item2)
			return cft_Data[i][cft_result];
	}

	// If no match is found, return an invalid item type.

	return INVALID_ITEM_TYPE;
}
