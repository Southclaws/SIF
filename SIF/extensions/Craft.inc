/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.4.0
	Module Version: 2.1.0


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

		native DefineItemCraftSet(ItemType:result, {ItemType, _}:...)
		{
			Description:
				Adds a new combination "recipe" to the index.

			Parameters:
				<result> (int, ItemType)
					The resulting itemtype that will be produced by completing
					this crafting combination. This can also be set to
					INVALID_ITEM_TYPE if you want to merely trigger a callback
					by a player crafting something and execute code.

				<variable arguments>

					<itemtype> (int, ItemType)
						One ingredient of the crafting recipe.

					<keepitem> (boolean)
						When true, the item won't be deleted after crafting.

			Returns:
				-1
					If the item combination index is full.

				Prints an error if the variable arguments are invalid.
		}
	}

	SIF/Inventory/Events
	{
		Events called by player actions done by using features from this script.

		native -
		native - SIF/Inventory/Callbacks
		native -

		native OnPlayerCraft(playerid, craftset)
		{
			Called:
				When a player completes a crafting combination but before any
				items are destroyed or created. Can be used to cancel the
				action. Note: this is never called if the resulting item won't
				fit into the target location.

			Parameters:
				<playerid> (int, playerid)
					The player who completed the crafting combination.

				<craftset> (int, craftset ID)
					The craftset the player completed. Can be used to get data.

			Returns:
				1
					To cancel the action. Prevents ingredients from being used
					and the result item from being created.
		}

		native OnPlayerCrafted(playerid, craftset, result)
		{
			Called:
				After a player completed a crafting combination and all changes
				to their inventory or container have been committed. Note: this
				is never called if the resulting item won't fit into the target
				location.

			Parameters:
				<playerid> (int, playerid)
					The player who completed the crafting combination.

				<craftset> (int, craftset ID)
					The craftset the player completed. Can be used to get data.

				<result> (int, itemid)
					The ID handle of the resulting item of the combination.

			Returns:
				-
		}
	}

	SIF/Craft/Internal Functions
	{
		Internal events called by player actions done by using features from
		this script.
	
	}

	SIF/Craft/Interface Functions
	{
		Functions to get or set data values in this script without editing
		the data directly. These include automatic ID validation checks.

		native -
		native - SIF/Craft/Interface
		native -

		native GetCraftSetIngredients(craftset, ItemType:output[CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data])
		{
			Description:
				Returns a list (of the structure e_craft_item_data) containing
				itemtypes for the specified crafting set.

			Parameters:
				-

			Returns:
				-1
					If the specified craftset is invalid.
		}

		native ItemType:GetCraftSetItemType(craftset, index)
		{
			Description:
				Returns an item type for a specific index in a craftset.

			Parameters:
				-

			Returns:
				-
		}

		native GetCraftSetItemKeep(craftset, index)
		{
			Description:
				Returns an item keep state for a specific index in a craftset.

			Parameters:
				-

			Returns:
				-
		}

		native GetCraftSetItemCount(craftset)
		{
			Description:
				Returns the amount of ingredients in a craftset.

			Parameters:
				-

			Returns:
				-
		}

		native ItemType:GetCraftSetResult(craftset)
		{
			Description:
				Returns the itemtype the specified craftset produces.

			Parameters:
				-

			Returns:
				-
		}

		native GetCraftSetTotal()
		{
			Description:
				Returns the total amount of craftsets.

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerSelectedCraftItems(playerid, output[CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data])
		{
			Description:
				Returns a list (of the structure e_selected_item_data)
				containing the items that a player has selected to combine. This
				only returns data while the player is still combining and has
				not produced the result item yet. It works in OnPlayerCraft and
				OnPlayerCrafted but outside of these callbacks it's not useful.

			Parameters:
				-

			Returns:
				-
		}

		native ItemType:GetPlayerSelectedCraftItemType(playerid, index)
		{
			Description:
				Returns an item type for a specific index in a player's selected
				craft items. Like GetPlayerSelectedCraftItems, this is only
				really useful inside OnPlayerCraft and OnPlayerCrafted.

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerSelectedCraftItemID(playerid, index)
		{
			Description:
				Returns an item ID for a specific index in a player's selected
				craft items. Like GetPlayerSelectedCraftItems, this is only
				really useful inside OnPlayerCraft and OnPlayerCrafted.

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerSelectedCraftItemCount(playerid)
		{
			Description:
				Returns the amount of items a player has selected to craft. Like
				GetPlayerSelectedCraftItems, this is only really useful inside
				OnPlayerCraft and OnPlayerCrafted.

			Parameters:
				-

			Returns:
				-
		}

		native GetPlayerCraftEnvironment(playerid)
		{
			Description:
				Returns the environment a player is crafting in. This will
				either be none, an inventory or a container. Like
				GetPlayerSelectedCraftItems, this is only really useful inside
				OnPlayerCraft and OnPlayerCrafted.

			Parameters:
				-

			Returns:
				CRAFT_ENVIRONMENT_NONE
					If the player isn't currently crafting anything.

				CRAFT_ENVIRONMENT_INVENTORY
					If the player is crafting in their inventory.

				CRAFT_ENVIRONMENT_CONTAINER
					If the player is crafting inside a container.
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
				To give functionality to the "Combine" inventory option.
		}

		SIF/Container/OnPlayerViewInventoryOpt
		{
			Reason:
				To add a "Combine" option to the player's container options.
		}

		SIF/Container/OnPlayerSelectInventoryOpt
		{
			Reason:
				To give functionality to the "Combine" container option.
		}
	}

==============================================================================*/


#if defined _SIF_CRAFT_INCLUDED
	#endinput
#endif

#include <YSI_4\y_hooks>

#define _SIF_CRAFT_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


#if !defined CFT_MAX_CRAFT_SET
	#define CFT_MAX_CRAFT_SET (64)
#endif

#if !defined CFT_MAX_CRAFT_SET_ITEMS
	#define CFT_MAX_CRAFT_SET_ITEMS (8)
#endif


enum
{
	CRAFT_ENVIRONMENT_NONE,
	CRAFT_ENVIRONMENT_INVENTORY,
	CRAFT_ENVIRONMENT_CONTAINER
}

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


static 
			cft_Ingredients[CFT_MAX_CRAFT_SET][CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data],
			cft_ItemCount[CFT_MAX_CRAFT_SET],
ItemType:	cft_Result[CFT_MAX_CRAFT_SET],
			cft_Total;

static
			cft_SelectedItems[MAX_PLAYERS][CFT_MAX_CRAFT_SET_ITEMS][e_selected_item_data],
			cft_SelectedItemCount[MAX_PLAYERS],
			cft_SelectedSlot[MAX_PLAYERS],
			cft_SelectionEnvironment[MAX_PLAYERS],
			cft_MenuOptionID[MAX_PLAYERS];


forward OnPlayerCraft(playerid, craftset);
forward OnPlayerCrafted(playerid, craftset, result);


static CRAFT_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	CRAFT_DEBUG = sif_debug_register_handler("SIF/extensions/Craft");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CRAFT_DEBUG("[OnScriptInit]");
}

hook OnPlayerConnect(playerid)
{
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:CRAFT_DEBUG("[OnPlayerConnect]");
	// TODO: Zero player data
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

	for(new i, j = 1; j < args; i++)
	{
		cft_Ingredients[cft_Total][i][cft_itemType] = ItemType:getarg(j++);
		cft_Ingredients[cft_Total][i][cft_keepItem] = bool:getarg(j++);
		cft_ItemCount[cft_Total]++;
	}

	_btn_SortCraftSet(cft_Ingredients[cft_Total], 0, cft_ItemCount[cft_Total]);

	return cft_Total++;
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

	return 1;
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

	return 1;
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

	return 1;
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

	return 1;
}

hook OnPlayerCloseInventory(playerid)
{
	_cft_ClearCraftList(playerid);

	return 1;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	_cft_ClearCraftList(playerid);

	return 1;
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


/*==============================================================================

	Interface

==============================================================================*/


// cft_Total
stock IsValidCraftSet(craftset)
{
	if(!(0 <= craftset < cft_Total))
		return 0;

	return 1;
}

// cft_Ingredients
stock GetCraftSetIngredients(craftset, ItemType:output[CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data])
{
	if(!(0 <= craftset < cft_Total))
		return 0;

	output = cft_Ingredients[craftset];

	return 1;
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
