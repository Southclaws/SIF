/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

A small module to add a combination functionality to inventories enabling
players to combine two items into one new item.

## Hooks

- OnPlayerViewInventoryOpt: To add a "Combine" option to the player's inventory options.
- OnPlayerSelectInventoryOpt: To give functionality to the "Combine" inventory option.
- OnPlayerViewInventoryOpt: To add a "Combine" option to the player's container options.
- OnPlayerSelectInventoryOpt: To give functionality to the "Combine" container option.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_CRAFT_INCLUDED
	#endinput
#endif

#if !defined _SIF_GEID_INCLUDED
	#include "geid.pwn"
#endif

#if !defined _SIF_INVENTORY_INCLUDED
	#include "inventory.pwn"
#endif

#if !defined _SIF_CONTAINER_INCLUDED
	#include "container.pwn"
#endif

#if !defined _SIF_INVENTORY_DIALOG_INCLUDED
	#include "extensions/inventory-dialog.pwn"
#endif

#if !defined _SIF_CONTAINER_DIALOG_INCLUDED
	#include "extensions/container-dialog.pwn"
#endif

#include <YSI\y_hooks>

#define _SIF_CRAFT_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


#if !defined CFT_MAX_CRAFT_SET
	#define CFT_MAX_CRAFT_SET (64)
#endif

#if !defined CFT_MAX_CRAFT_SET_ITEMS
	#define CFT_MAX_CRAFT_SET_ITEMS (8)
#endif

enum e_craft_item_data
{
ItemType:	cft_itemType,
bool:		cft_keepItem
}

enum e_selected_item_data
{
ItemType:	cft_selectedItemType,
			cft_selectedItemID
}


// Functions


forward DefineItemCraftSet(ItemType:result, {ItemType, _}:...);
/*
# Description:
-
*/

forward IsValidCraftSet(craftset);
/*
# Description:
-
*/

forward GetCraftSetIngredients(craftset, output[CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data]);
/*
# Description:
-
*/

forward ItemType:GetCraftSetItemType(craftset, index);
/*
# Description:
-
*/

forward GetCraftSetItemKeep(craftset, index);
/*
# Description:
-
*/

forward GetCraftSetItemCount(craftset);
/*
# Description:
-
*/

forward ItemType:GetCraftSetResult(craftset);
/*
# Description:
-
*/

forward GetCraftSetTotal();
/*
# Description:
-
*/

forward GetPlayerSelectedCraftItems(playerid, output[CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data]);
/*
# Description:
-
*/

forward ItemType:GetPlayerSelectedCraftItemType(playerid, index);
/*
# Description:
-
*/

forward GetPlayerSelectedCraftItemID(playerid, index);
/*
# Description:
-
*/

forward GetPlayerSelectedCraftItemCount(playerid);
/*
# Description:
-
*/

forward GetPlayerCraftEnvironment(playerid);
/*
# Description:
-
*/

forward ItemTypeResultForCraftingSet(ItemType:itemtype);
/*
# Description:
-
*/


// Events


forward OnPlayerCraft(playerid, craftset);
/*
# Called:
-
*/

forward OnPlayerCrafted(playerid, craftset, result);
/*
# Called:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


enum
{
	CRAFT_ENVIRONMENT_NONE,
	CRAFT_ENVIRONMENT_INVENTORY,
	CRAFT_ENVIRONMENT_CONTAINER
}


static 
			cft_Ingredients[CFT_MAX_CRAFT_SET][CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data],
			cft_ItemCount[CFT_MAX_CRAFT_SET],
ItemType:	cft_Result[CFT_MAX_CRAFT_SET],
			cft_Total,
			cft_ItemTypeResultFor[ITM_MAX_TYPES] = {-1, ...};

static
			cft_SelectedItems[MAX_PLAYERS][CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data],
			cft_SelectedItemCount[MAX_PLAYERS],
			cft_SelectedSlot[MAX_PLAYERS],
			cft_SelectionEnvironment[MAX_PLAYERS],
			cft_MenuOptionID[MAX_PLAYERS];


static CRAFT_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	CRAFT_DEBUG = sif_debug_register_handler("SIF/extensions/Craft");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CRAFT_DEBUG("[OnScriptInit]");
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock DefineItemCraftSet(ItemType:result, {ItemType, _}:...)
{
	if(cft_Total >= CFT_MAX_CRAFT_SET)
		return -1;

	new
		args = numargs();

	if(!(args & 1))
	{
		printf("ERROR: DefineItemCraftSet (for result item %d) has invalid parameter structure. Should be: result, (item, keep) * n", _:result);
		return -1;
	}

	cft_Result[cft_Total] = result;
	cft_ItemTypeResultFor[result] = cft_Total;

	for(new i, j = 1; j < args; i++)
	{
		cft_Ingredients[cft_Total][i][cft_itemType] = ItemType:getarg(j++);
		cft_Ingredients[cft_Total][i][cft_keepItem] = bool:getarg(j++);
		cft_ItemCount[cft_Total]++;
	}

	_btn_SortCraftSet(cft_Ingredients[cft_Total], 0, cft_ItemCount[cft_Total]);

	return cft_Total++;
}

// cft_Total
stock IsValidCraftSet(craftset)
{
	if(!(0 <= craftset < cft_Total))
		return 0;

	return 1;
}

// cft_Ingredients
stock GetCraftSetIngredients(craftset, output[CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data])
{
	if(!(0 <= craftset < cft_Total))
		return 0;

	for(new i; i < cft_ItemCount[craftset]; i++)
	{
		output[i][cft_itemType] = cft_Ingredients[craftset][i][cft_itemType];
		output[i][cft_keepItem] = cft_Ingredients[craftset][i][cft_keepItem];
	}

	return cft_ItemCount[craftset];
}

// cft_Ingredients/cft_itemType
stock ItemType:GetCraftSetItemType(craftset, index)
{
	if(!(0 <= craftset < cft_Total))
		return INVALID_ITEM_TYPE;

	if(!(0 <= index < cft_ItemCount[craftset]))
		return INVALID_ITEM_TYPE;

	return cft_Ingredients[craftset][index][cft_itemType];
}

// cft_Ingredients/cft_keepItem
stock GetCraftSetItemKeep(craftset, index)
{
	if(!(0 <= craftset < cft_Total))
		return 0;

	if(!(0 <= index < cft_ItemCount[craftset]))
		return 0;

	return cft_Ingredients[craftset][index][cft_keepItem];
}

// cft_ItemCount
stock GetCraftSetItemCount(craftset)
{
	if(!(0 <= craftset < cft_Total))
		return 0;

	return cft_ItemCount[craftset];
}

// cft_Result
stock ItemType:GetCraftSetResult(craftset)
{
	if(!(0 <= craftset < cft_Total))
		return INVALID_ITEM_TYPE;

	return cft_Result[craftset];
}

// cft_Total
stock GetCraftSetTotal()
	return cft_Total;

// cft_SelectedItems
stock GetPlayerSelectedCraftItems(playerid, output[CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	output = cft_SelectedItems[playerid];

	return 1;
}

// cft_SelectedItems/cft_selectedItemType
stock ItemType:GetPlayerSelectedCraftItemType(playerid, index)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_TYPE;

	if(!(0 <= index < cft_ItemCount[playerid]))
		return INVALID_ITEM_TYPE;

	return cft_SelectedItems[playerid][index][cft_selectedItemType];
}

// cft_SelectedItems/cft_selectedItemID
stock GetPlayerSelectedCraftItemID(playerid, index)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

	if(!(0 <= index < cft_ItemCount[playerid]))
		return INVALID_ITEM_ID;

	return cft_SelectedItems[playerid][index][cft_selectedItemID];
}

// cft_SelectedItemCount
stock GetPlayerSelectedCraftItemCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return cft_SelectedItemCount[playerid];
}

// cft_SelectionEnvironment
stock GetPlayerCraftEnvironment(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return cft_SelectionEnvironment[playerid];
}

// cft_ItemTypeResultFor
stock ItemTypeResultForCraftingSet(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return cft_ItemTypeResultFor[itemtype];
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerViewInvOpt(playerid)
{
	if(cft_SelectedItemCount[playerid] == 0)
	{
		cft_MenuOptionID[playerid] = AddInventoryOption(playerid, "Combine...");
	}
	else
	{
		new
			string[128], // TODO: Improve option length
			itemname[ITM_MAX_NAME];

		string = "Combine with ";

		for(new i; i < cft_SelectedItemCount[playerid]; i++)
		{
			GetItemTypeName(cft_SelectedItems[playerid][i][cft_selectedItemType], itemname);

			if(i == 0)
				format(string, sizeof(string), "%s%s", string, itemname);

			else

				format(string, sizeof(string), "%s+%s", string, itemname);
		}
		cft_MenuOptionID[playerid] = AddInventoryOption(playerid, string);
	}

	return 0;
}

hook OnPlayerSelectInvOpt(playerid, option)
{
	if(option == cft_MenuOptionID[playerid])
	{
		// Get selected item ID, store it.
		// make the item yellow.
		// If there are more than 1 items selected, perform craft table check.
		_cft_AddItemToCraftList(playerid, cft_SelectedSlot[playerid] = GetInventorySlotItem(playerid, GetPlayerSelectedInventorySlot(playerid)));
		cft_SelectionEnvironment[playerid] = CRAFT_ENVIRONMENT_INVENTORY;

		DisplayPlayerInventory(playerid);
	}

	return 0;
}

hook OnPlayerViewCntOpt(playerid, containerid)
{
	if(cft_SelectedItemCount[playerid] == 0)
	{
		cft_MenuOptionID[playerid] = AddContainerOption(playerid, "Combine...");
	}
	else
	{
		new
			string[128], // TODO: Improve option length
			itemname[ITM_MAX_NAME];

		string = "Combine with ";

		for(new i; i < cft_SelectedItemCount[playerid]; i++)
		{
			GetItemTypeName(cft_SelectedItems[playerid][i][cft_selectedItemType], itemname);

			if(i == 0)
				format(string, sizeof(string), "%s%s", string, itemname);

			else

				format(string, sizeof(string), "%s+%s", string, itemname);
		}
		cft_MenuOptionID[playerid] = AddContainerOption(playerid, string);
	}

	return 0;
}

hook OnPlayerSelectCntOpt(playerid, containerid, option)
{
	if(option == cft_MenuOptionID[playerid])
	{
		// Get selected item ID, store it.
		// make the item yellow.
		// If there are more than 1 items selected, perform craft table check.
		_cft_AddItemToCraftList(playerid, cft_SelectedSlot[playerid] = GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid)));
		cft_SelectionEnvironment[playerid] = CRAFT_ENVIRONMENT_CONTAINER;

		DisplayContainerInventory(playerid, containerid);
	}

	return 0;
}

hook OnPlayerCloseInventory(playerid)
{
	_cft_ClearCraftList(playerid);

	return 0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	_cft_ClearCraftList(playerid);

	return 0;
}

_cft_AddItemToCraftList(playerid, itemid)
{
	new itemname[ITM_MAX_NAME];
	GetItemTypeName(GetItemType(itemid), itemname);
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_AddItemToCraftList] %d added %d (type %d, %s)", playerid, itemid, _:GetItemType(itemid), itemname);

	cft_SelectedItems[playerid][cft_SelectedItemCount[playerid]][cft_selectedItemType] = GetItemType(itemid);
	cft_SelectedItems[playerid][cft_SelectedItemCount[playerid]][cft_selectedItemID] = itemid;
	cft_SelectedItemCount[playerid]++;

	if(cft_SelectedItemCount[playerid] >= 2)
	{
		new craftset = _cft_FindCraftset(cft_SelectedItems[playerid], cft_SelectedItemCount[playerid]);

		if(craftset != -1)
			_cft_CraftSelected(playerid, craftset);

		else
			SendClientMessage(playerid, -1, "That combination doesn't seem to work... Try adding more items or close the menu to cancel.");
	}

	return 1;
}

_cft_ClearCraftList(playerid)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_ClearCraftList] Clearing craft list for %d", playerid);

	cft_SelectionEnvironment[playerid] = CRAFT_ENVIRONMENT_NONE;
	cft_SelectedItemCount[playerid] = 0;
}

_cft_CraftSelected(playerid, craftset)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_CraftSelected] %d crafting set %d", playerid, craftset);

	new
		resultslots = GetItemTypeSize(cft_Result[craftset]),
		totalslots,
		freeslots;

	for(new i; i < cft_ItemCount[craftset]; i++)
	{
		if(!cft_Ingredients[craftset][i][cft_keepItem])
			resultslots -= GetItemTypeSize(cft_Ingredients[craftset][i][cft_itemType]);
	}

	if(cft_SelectionEnvironment[playerid] == CRAFT_ENVIRONMENT_INVENTORY)
	{
		freeslots = GetInventoryFreeSlots(playerid);
		totalslots = GetPlayerInventorySize(playerid);

		if(freeslots + resultslots > totalslots)
			return 0;

		if(CallLocalFunction("OnPlayerCraft", "dd", playerid, craftset))
			return 0;

		for(new i; i < cft_SelectedItemCount[playerid]; i++)
		{
			sif_d:SIF_DEBUG_LEVEL_LOOPS:CRAFT_DEBUG("[_cft_CraftSelected] Looping ingredient item %d (%d)", cft_SelectedItems[playerid][i][cft_selectedItemID], _:GetItemType(cft_SelectedItems[playerid][i][cft_selectedItemID]));
			if(!cft_Ingredients[craftset][i][cft_keepItem])
			{
				sif_d:SIF_DEBUG_LEVEL_LOOPS:CRAFT_DEBUG("[_cft_CraftSelected] Destroying ingredient item %d (%d)", cft_SelectedItems[playerid][i][cft_selectedItemID], _:GetItemType(cft_SelectedItems[playerid][i][cft_selectedItemID]));
				RemoveItemFromInventory(playerid, GetItemPlayerInventorySlot(cft_SelectedItems[playerid][i][cft_selectedItemID]), 0);
				DestroyItem(cft_SelectedItems[playerid][i][cft_selectedItemID]);
			}
		}

		new itemid = CreateItem(cft_Result[craftset]);
		sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_CraftSelected] Created result item %d (%d)", itemid, _:cft_Result[craftset]);

		AddItemToInventory(playerid, itemid, false);
		sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_CraftSelected] Added result item %d to player %d", itemid, playerid);

		CallLocalFunction("OnPlayerCrafted", "ddd", playerid, craftset, itemid);
	}
	else
	{
		new containerid = GetPlayerCurrentContainer(playerid);

		if(!IsValidContainer(containerid))
			return 0;

		freeslots = GetContainerFreeSlots(containerid);
		totalslots = GetContainerSize(containerid);

		if(freeslots + resultslots > totalslots)
			return 0;

		if(CallLocalFunction("OnPlayerCraft", "dd", playerid, craftset))
			return 0;

		for(new i; i < cft_SelectedItemCount[playerid]; i++)
		{
			sif_d:SIF_DEBUG_LEVEL_LOOPS:CRAFT_DEBUG("[_cft_CraftSelected] Looping ingredient item %d (%d)", cft_SelectedItems[playerid][i][cft_selectedItemID], _:GetItemType(cft_SelectedItems[playerid][i][cft_selectedItemID]));
			if(!cft_Ingredients[craftset][i][cft_keepItem])
			{
				sif_d:SIF_DEBUG_LEVEL_LOOPS:CRAFT_DEBUG("[_cft_CraftSelected] Destroying ingredient item %d (%d)", cft_SelectedItems[playerid][i][cft_selectedItemID], _:GetItemType(cft_SelectedItems[playerid][i][cft_selectedItemID]));
				RemoveItemFromContainer(containerid, GetItemContainerSlot(cft_SelectedItems[playerid][i][cft_selectedItemID]), .call = 0);
				DestroyItem(cft_SelectedItems[playerid][i][cft_selectedItemID]);
			}
		}

		new itemid = CreateItem(cft_Result[craftset]);
		sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_CraftSelected] Created result item %d (%d)", itemid, _:cft_Result[craftset]);

		AddItemToContainer(containerid, itemid);
		sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_CraftSelected] Added result item %d to container %d", itemid, containerid);

		CallLocalFunction("OnPlayerCrafted", "ddd", playerid, craftset, itemid);
	}

	new
		str[8 + ITM_MAX_NAME],
		itemname[ITM_MAX_NAME];

	GetItemTypeName(cft_Result[craftset], itemname);
	format(str, sizeof(str), "Crafted %s", itemname);
	ShowActionText(playerid, str, 3000);

	_cft_ClearCraftList(playerid);

	return 1;
}

_cft_FindCraftset(list[CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data], size)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_FindCraftset]");

	_btn_SortSelectedItems(list, 0, size);

	for(new i; i < cft_Total; i++)
	{
		if(cft_ItemCount[i] != size)
			continue;

		if(_cft_CompareListToCraftSet(list, i))
			return i;
	}

	return -1;
}

_cft_CompareListToCraftSet(list[][e_selected_item_data], craftset)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_cft_CompareListToCraftSet] craftset %d", craftset);

	for(new i; i < cft_ItemCount[craftset]; i++)
	{
		sif_d:SIF_DEBUG_LEVEL_LOOPS:CRAFT_DEBUG("[_cft_CompareListToCraftSet] Item type in %d/%d craftset: %d, player selected: %d", i, cft_ItemCount[craftset], _:cft_Ingredients[craftset][i][cft_itemType], _:list[i][cft_selectedItemType]);

		if(cft_Ingredients[craftset][i][cft_itemType] != list[i][cft_selectedItemType])
			return 0;
	}

	return 1;
}

_btn_SortCraftSet(array[CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data], left, right)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_btn_SortCraftSet]");

	new
		tmp_left = left,
		tmp_right = right,
		ItemType:pivot = array[(left + right) / 2][cft_itemType],
		ItemType:itemtype,
		bool:keepitem;

	while(tmp_left <= tmp_right)
	{
		while(array[tmp_left][cft_itemType] > pivot)
			tmp_left++;

		while(array[tmp_right][cft_itemType] < pivot)
			tmp_right--;

		if(tmp_left <= tmp_right)
		{
			itemtype = array[tmp_left][cft_itemType];
			array[tmp_left][cft_itemType] = array[tmp_right][cft_itemType];
			array[tmp_right][cft_itemType] = itemtype;

			keepitem = array[tmp_left][cft_keepItem];
			array[tmp_left][cft_keepItem] = array[tmp_right][cft_keepItem];
			array[tmp_right][cft_keepItem] = keepitem;

			tmp_left++;
			tmp_right--;
		}
	}

	if(left < tmp_right)
		_btn_SortCraftSet(array, left, tmp_right);

	if(tmp_left < right)
		_btn_SortCraftSet(array, tmp_left, right);
}

_btn_SortSelectedItems(array[CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data], left, right)
{
	sif_d:SIF_DEBUG_LEVEL_INTERNAL:CRAFT_DEBUG("[_btn_SortSelectedItems]");

	new
		tmp_left = left,
		tmp_right = right,
		ItemType:pivot = array[(left + right) / 2][cft_selectedItemType],
		ItemType:itemtype,
		itemid;

	while(tmp_left <= tmp_right)
	{
		while(array[tmp_left][cft_selectedItemType] > pivot)
			tmp_left++;

		while(array[tmp_right][cft_selectedItemType] < pivot)
			tmp_right--;

		if(tmp_left <= tmp_right)
		{
			itemtype = array[tmp_left][cft_selectedItemType];
			array[tmp_left][cft_selectedItemType] = array[tmp_right][cft_selectedItemType];
			array[tmp_right][cft_selectedItemType] = itemtype;

			itemid = array[tmp_left][cft_selectedItemID];
			array[tmp_left][cft_selectedItemID] = array[tmp_right][cft_selectedItemID];
			array[tmp_right][cft_selectedItemID] = itemid;

			tmp_left++;
			tmp_right--;
		}
	}

	if(left < tmp_right)
		_btn_SortSelectedItems(array, left, tmp_right);

	if(tmp_left < right)
		_btn_SortSelectedItems(array, tmp_left, right);
}
