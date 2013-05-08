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


#define CFT_MAX_COMBO (64)
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
			cft_Data[CFT_MAX_COMBO][E_CRAFT_COMBO_DATA],
Iterator:	cft_Index<CFT_MAX_COMBO>;

static
			cft_ListType[MAX_PLAYERS],
			cft_SelectedInvSlot[MAX_PLAYERS],
			cft_InventoryOptionID[MAX_PLAYERS];


/*==============================================================================

	Core Functions

==============================================================================*/


stock DefineItemCombo(ItemType:item1, ItemType:item2, ItemType:result, returnitem1 = 0, returnitem2 = 0)
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

		DisplayCombineInventory(playerid, 0);
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

public OnPlayerViewContainerOpt(playerid, containerid)
{
	cft_InventoryOptionID[playerid] = AddContainerOption(playerid, "Combine");

	return CallLocalFunction("cft_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt cft_OnPlayerViewContainerOpt
forward OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	if(option == cft_InventoryOptionID[playerid])
	{
		cft_SelectedInvSlot[playerid] = GetPlayerContainerSlot(playerid);

		DisplayCombineInventory(playerid, 1);
	}

	return CallLocalFunction("cft_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt cft_OnPlayerSelectContainerOpt
forward OnPlayerSelectContainerOpt(playerid, containerid, option);

DisplayCombineInventory(playerid, listtype)
{
	new
		list[INV_MAX_SLOTS * (ITM_MAX_NAME + 1)],
		tmp[ITM_MAX_NAME];
	
	cft_ListType[playerid] = listtype;

	if(listtype == 0)
	{
		for(new i; i < INV_MAX_SLOTS; i++)
		{
			if(!IsValidItem(GetInventorySlotItem(playerid, i)))
				strcat(list, "<Empty>\n");

			else
			{
				GetItemName(GetInventorySlotItem(playerid, i), tmp);
				strcat(list, tmp);
				strcat(list, "\n");
			}
		}
	}
	else
	{
		new containerid = GetPlayerCurrentContainer(playerid);

		for(new i, j = GetContainerSize(containerid); i < j; i++)
		{
			if(!IsValidItem(GetContainerSlotItem(containerid, i)))
				strcat(list, "<Empty>\n");

			else
			{
				GetItemName(GetContainerSlotItem(containerid, i), tmp);
				strcat(list, tmp);
				strcat(list, "\n");
			}
		}
	}

	ShowPlayerDialog(playerid, DIALOG_COMBINE_ITEM, DIALOG_STYLE_LIST, "Combine", list, "Combine", "Close");
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

		if(cft_ListType[playerid] == 0)
		{
			// If the player picks the same inventory item as the one he is trying to combine
			// Or if they pick an empty slot, re-render the dialog.
			// You can't combine something with itself or nothing, that's like dividing by zero!

			if(listitem == GetPlayerSelectedInventorySlot(playerid) || !IsInventorySlotUsed(playerid, listitem))
			{
				DisplayCombineInventory(playerid, 0);
				return 1;
			}

			// Get the item combination result, AKA the item that the two items will create.

			new
				retitem1,
				retitem2,
				result,
				ItemType:itemtype,
				itemslot1,
				itemslot2;

			result = GetItemComboResult(
				GetItemType(GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid))),
				GetItemType(GetInventorySlotItem(playerid, listitem)));

			if(result == -1)
			{
				DisplayCombineInventory(playerid, 0);
				return 0;
			}

			if(cft_Data[result][cft_result] == GetItemType(GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid))))
			{
				new
					itemid1,
					itemid2,
					exdata1,
					exdata2;

				itemid1 = GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid)),
				itemid2 = GetInventorySlotItem(playerid, listitem);
				exdata1 = GetItemExtraData(itemid1),
				exdata2 = GetItemExtraData(itemid2);

				SetItemExtraData(itemid1, exdata1 + exdata2);

				DestroyItem(itemid2);
				RemoveItemFromInventory(playerid, listitem);
				DisplayPlayerInventory(playerid);

				return 1;
			}

			itemtype = cft_Data[result][cft_result];
			retitem1 = cft_Data[result][cft_retItem1];
			retitem2 = cft_Data[result][cft_retItem2];

			if(!IsValidItemType(itemtype))
			{
				DisplayCombineInventory(playerid, 0);
				return 0;
			}

			if(retitem1 && retitem2)
			{
				if(GetInventoryFreeSlots(playerid) < 1)
				{
					ShowMsgBox(playerid, "Not enough free space", 3000);
					DisplayCombineInventory(playerid, 0);
					return 0;
				}
			}

			if(GetItemTypeSize(itemtype) != ITEM_SIZE_SMALL)
			{
				ShowMsgBox(playerid, "Result item is too large", 3000);
				DisplayCombineInventory(playerid, 0);
				return 0;
			}

			if(GetItemType(GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid))) != cft_Data[result][cft_item1])
			{
				itemslot1 = GetPlayerSelectedInventorySlot(playerid);
				itemslot2 = listitem;
			}
			else
			{
				itemslot1 = listitem;
				itemslot2 = GetPlayerSelectedInventorySlot(playerid);
			}

			if(itemslot1 > itemslot2)
			{
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
			}
			else
			{
				if(!retitem2)
				{
					DestroyItem(GetInventorySlotItem(playerid, itemslot2));
					RemoveItemFromInventory(playerid, itemslot2);
				}

				if(!retitem1)
				{
					DestroyItem(GetInventorySlotItem(playerid, itemslot1));
					RemoveItemFromInventory(playerid, itemslot1);
				}
			}

			AddItemToInventory(playerid, CreateItem(itemtype, 0.0, 0.0, 0.0));

			DisplayPlayerInventory(playerid);
		}
		else
		{
			new
				containerid = GetPlayerCurrentContainer(playerid);

			if(listitem == GetPlayerContainerSlot(playerid) || !IsContainerSlotUsed(containerid, listitem))
			{
				DisplayCombineInventory(playerid, 1);
				return 1;
			}

			new
				retitem1,
				retitem2,
				result,
				ItemType:itemtype,
				itemslot1,
				itemslot2;

			result = GetItemComboResult(
				GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))),
				GetItemType(GetContainerSlotItem(containerid, listitem)));

			if(result == -1)
			{
				DisplayCombineInventory(playerid, 1);
				return 0;
			}

			if(cft_Data[result][cft_result] == GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))))
			{
				SetItemExtraData(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid)),
					GetItemExtraData(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) + 
					GetItemExtraData(GetContainerSlotItem(containerid, listitem)));

				DestroyItem(GetContainerSlotItem(containerid, listitem));
				RemoveItemFromContainer(containerid, listitem);

				return 1;
			}

			itemtype = cft_Data[result][cft_result];
			retitem1 = cft_Data[result][cft_retItem1];
			retitem2 = cft_Data[result][cft_retItem2];

			if(!IsValidItemType(itemtype))
			{
				DisplayCombineInventory(playerid, 1);
				return 0;
			}

			if(retitem1 && retitem2)
			{
				if(GetContainerFreeSlots(playerid) < 1)
				{
					ShowMsgBox(playerid, "Not enough free space", 3000);
					DisplayCombineInventory(playerid, 1);
					return 0;
				}
			}

			if(!WillItemTypeFitInContainer(containerid, itemtype))
			{
				ShowMsgBox(playerid, "Result item won't fit", 3000);
				DisplayCombineInventory(playerid, 1);
				return 0;
			}

			if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) != cft_Data[result][cft_item1])
			{
				itemslot1 = GetPlayerContainerSlot(playerid);
				itemslot2 = listitem;
			}
			else
			{
				itemslot1 = listitem;
				itemslot2 = GetPlayerContainerSlot(playerid);
			}

			if(itemslot1 > itemslot2)
			{
				if(!retitem1)
				{
					new tmp = GetContainerSlotItem(containerid, itemslot1);
					RemoveItemFromContainer(containerid, itemslot1);
					DestroyItem(tmp);
				}

				if(!retitem2)
				{
					new tmp = GetContainerSlotItem(containerid, itemslot2);
					RemoveItemFromContainer(containerid, itemslot2);
					DestroyItem(tmp);
				}
			}
			else
			{
				if(!retitem2)
				{
					new tmp = GetContainerSlotItem(containerid, itemslot2);
					RemoveItemFromContainer(containerid, itemslot2);
					DestroyItem(tmp);
				}
				if(!retitem1)
				{
					new tmp = GetContainerSlotItem(containerid, itemslot1);
					RemoveItemFromContainer(containerid, itemslot1);
					DestroyItem(tmp);
				}
			}

			AddItemToContainer(containerid, CreateItem(itemtype, 0.0, 0.0, 0.0));

			DisplayContainerInventory(playerid, containerid);
		}
	}

	return 1;
}

GetItemComboResult(ItemType:item1, ItemType:item2)
{
	// Loop through all "recipe" item combinations
	// If a match is found, return that combo result.
	foreach(new i : cft_Index)
	{
		if(cft_Data[i][cft_item1] == item1 && cft_Data[i][cft_item2] == item2)
		{
			return i;
		}

		if(cft_Data[i][cft_item2] == item1 && cft_Data[i][cft_item1] == item2)
		{
			return i;
		}
	}

	return -1;
}
