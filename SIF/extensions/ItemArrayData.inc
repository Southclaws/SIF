/*==============================================================================

Southclaw's Interactivity Framework (SIF) (Formerly: Adventure API)

	SIF Version: 1.4.0
	Module Version: 1.4.0


	SIF/Overview
	{
		SIF is a collection of high-level include scripts to make the
		development of interactive features easy for the developer while
		maintaining quality front-end gameplay for players.
	}

	SIF/ItemArrayData/Description
	{
		Extends items to have an array of data instead of just one cell.
		Includes functions for setting, appending and getting array data.
	}

	SIF/ItemArrayData/Dependencies
	{
		SIF/Item
	}

	SIF/ItemArrayData/Credits
	{
	}

	SIF/ItemArrayData/Constants
	{
		These can be altered by defining their values before the include line.

		ITM_ARR_MAX_ARRAY_DATA
			Maximum size an item type's array can be.

		ITM_ARR_REPLACE_ITEM_EXTRADATA
			If this is true, this extension will replace instances of
			GetItemExtraData and SetItemExtraData with GetItemArrayDataAtCell
			and SetItemArrayDataAtCell.
	}

	SIF/ItemArrayData/Core Functions
	{
		The functions that control the core features of this script.

		native -
		native - SIF/ItemArrayData/Core
		native -

		native SetItemTypeMaxArrayData(ItemType:itemtype, size)
		{
			Description:
				Sets an item types max array data size.

			Parameters:
				<itemtype> (int, ItemType)
					The item type to set the size for. Must be valid.

				<size> (int)
					Size in 32 bit cells to set the size to. Must be less than
					ITM_ARR_MAX_ARRAY_DATA.

			Returns:
				0
					If the item type is invalid.

				-1
					If the size exceeds ITM_ARR_MAX_ARRAY_DATA.

				1
					If successful.
		}

		native GetItemTypeArrayDataSize(ItemType:itemtype)
		{
			Description:
				Gets an item types max array data size.

			Parameters:
				<itemtype> (int, ItemType)
					The item type to get the size from. Must be valid.

			Returns:
				-1
					If the item type is invalid.

				(int)
					The max size for the item type's array data.
		}

		native SetItemArrayData(itemid, data[], length, call = 1)
		{
			Description:
				Sets an item's array data and length to input parameters.

			Parameters:
				<itemid> (int, itemid)
					Item ID handle to set data for. Must be a valid item.

				<data> (array)
					The data to set.

				<length> (int)
					Length of the data, must be equal to or less than the size
					of <data>.

				<call> (bool)
					Whether or not to call OnItemArrayDataChanged

			Returns:
				0
					If the item is invalid.

				-1
					If the length exceeds the item's type max.

				1
					On success.
		}

		native GetItemArrayData(itemid, data[])
		{
			Description:
				Returns the array data associated with an item.

			Parameters:
				<itemid> (int, itemid)
					The item to return the data from.

				<data> (array)
					The array to store the returned data in.

			Returns:
				0
					If the item is invalid.

				1
					On success.
		}

		native SetItemArrayDataAtCell(itemid, data, cell, autoadjustsize = 0, call = 1)
		{
			Description:
				Sets item array data in a specific cell.

			Parameters:
				<itemid> (int, itemid)
					The item to set the data for.

				<data> (int)
					The data to set.

				<cell> (int)
					The cell in the array to set. Must be less than the item's
					array length and item type's array size max.

				<autoadjustsize> (bool)
					Automatically adjust the length of array data for new data.

				<call> (bool)
					Whether or not to call OnItemArrayDataChanged

			Returns:
				0
					If the item is invalid.

				-1
					If <cell> exceeds item type's max.

				-2
					If <cell> exceeds item's array length.

				1
					On success.
		}

		native GetItemArrayDataAtCell(itemid, cell)
		{
			Description:
				Returns a single cell of array data at the specified position.

			Parameters:
				<itemid> (int, itemid)
					The item to get the data from.

				<cell> (int)
					The cell to get the data from. Must be less than the item's
					array length and the item type's array size max.

			Returns:
				0
					If the item is invalid.

				-1
					If <cell> exceeds item type's max.

				-2
					If <cell> exceeds item's array length.

				1
					On success.
		}

		native SetItemArrayDataSize(itemid, size)
		{
			Description:
				Sets the array data length of an item.

			Parameters:
				-

			Returns:
				0
					If the item is invalid.

				1
					On success.
		}

		native GetItemArrayDataSize(itemid)
		{
			Description:
				Returns the array data length of an item.

			Parameters:
				-

			Returns:
				0
					If the item is invalid.

				(int)
					The item's array data length.
		}

		native GetItemTypeArrayDataMax(ItemType:itemtype)
		{
			Description:
				Returns an item type's max array data size.

			Parameters:
				-

			Returns:
				0
					If the item type is invalid.

				(int)
					Item type's array data max size.
		}

		native AppendItemArray(itemid, data[], length)
		{
			Description:
				Appends some data on to an item's array data.

			Parameters:
				<itemid> (int, itemid)
					The item ID to append data to.

				<data> (array)
					Data to append.

				<length> (int)
					Length of the data. The length added to the existing item
					array data length must not exceed the item type's array data
					max.

			Returns:
				0
					If the item is invalid.

				-1
					If the length added to the item's array data length exceeds
					the item type's array data max size.

				1
					On success.
		}

		native AppendItemArrayCell(itemid, data)
		{
			Description:
				Appends a single cell of data to an item's array data.

			Parameters:
				<itemid> (int, itemid)
					The item to append data to.

				<data> (int)
					A single cell of data to append.

			Returns:
				0
					If the item is invalid.

				-1
					If the item's array data length plus one exceeds the item
					type's array data max size.

				1
					On success.
		}

		native SetItemArrayDataLength(itemid, length)
		{
			Description:
				Sets an item's array data length. Length must be less than the
				item type's array data max size.

			Parameters:
				-

			Returns:
				-
		}

		native RemoveItemArrayData(itemid)
		{
			Description:
				Makes data inaccessible and overwritable by setting the item's
				array data length to 0. Doesn't actually reset any of the data
				but any future use of the append functions will start at cell 0.

			Parameters:
				-

			Returns:
				-
		}

		native SetItemNoResetArrayData(itemid, bool:toggle)
		{
			Description:
				Forces an item to not reset it's array data when created.

			Parameters:
				-

			Returns:
				-
		}
	}

	SIF/ItemArrayData/Events
	{
		Events called by features from this script.

		native -
		native - SIF/Button/Callbacks
		native -

		native OnItemArrayDataChanged(itemid)
		{
			Called:
				When the array data of an item is updated.

			Parameters:
				<itemid> (int, itemid)
					The ID of the item that had it's array data changed.

			Returns:
				-
		}
	}

	SIF/ItemArrayData/Hooks
	{
		Hooked functions or callbacks, either SA:MP natives or from other
		scripts or plugins.

		SIF/Item/OnItemCreate
		{
			Reason:
				To reset item array data variables to avoid data leaking between
				items after being destroyed.
		}
	}

==============================================================================*/


#if defined _SIF_ITEMARRAYDATA_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include <SIF\Debug.pwn>
#endif

#if !defined _SIF_CORE_INCLUDED
	#include <SIF\Core.pwn>
#endif

#include <YSI\y_hooks>

#define _SIF_ITEMARRAYDATA_INCLUDED


/*==============================================================================

	Setup

==============================================================================*/


#if !defined ITM_ARR_MAX_ARRAY_DATA
	#define ITM_ARR_MAX_ARRAY_DATA			(256)
#endif

#if !defined ITM_ARR_REPLACE_ITEM_EXTRADATA
	#define ITM_ARR_REPLACE_ITEM_EXTRADATA	(1)
#endif

#if !defined ITM_ARR_ARRAY_SIZE_PROTECT
	#define ITM_ARR_ARRAY_SIZE_PROTECT		(true)
#endif

/*
	If true, this script will wrap calls of the default extra data functions
	with single-cell array equivalents.
*/
#if ITM_ARR_REPLACE_ITEM_EXTRADATA == 1
	#define SetItemExtraData(%0,%1) SetItemArrayDataAtCell(%0,%1,0,1)
	#define GetItemExtraData(%0) GetItemArrayDataAtCell(%0,0)
#endif



static
	itm_arr_ItemTypeArrayMax[ITM_MAX_TYPES],
	itm_arr_Data[ITM_MAX][ITM_ARR_MAX_ARRAY_DATA],
	itm_arr_Length[ITM_MAX],
	itm_arr_NoResetOnCreate[ITM_MAX];

static
	ITEM_ARRAY_DATA = -1;


forward OnItemArrayDataChanged(itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	ITEM_ARRAY_DATA = sif_debug_register_handler("SIF/ItemArrayData");
}

public OnItemCreate(itemid)
{
	if(!itm_arr_NoResetOnCreate[itemid])
	{
		for(new i; i < itm_arr_ItemTypeArrayMax[GetItemType(itemid)]; i++)
			itm_arr_Data[itemid][i] = 0;

		itm_arr_Length[itemid] = 0;
	}
	else
	{
		itm_arr_NoResetOnCreate[itemid] = 0;
	}


	#if defined itmarr_OnItemCreate
		return itmarr_OnItemCreate(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate itmarr_OnItemCreate
#if defined itmarr_OnItemCreate
	forward itmarr_OnItemCreate(itemid);
#endif


/*==============================================================================

	Core Functions

==============================================================================*/


stock SetItemTypeMaxArrayData(ItemType:itemtype, size)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemTypeMaxArrayData] %d %d", _:itemtype, size);
	if(!IsValidItemType(itemtype))
		return 0;

	if(size > ITM_ARR_MAX_ARRAY_DATA)
		return -1;

	itm_arr_ItemTypeArrayMax[itemtype] = size;

	return 1;
}

stock GetItemTypeArrayDataSize(ItemType:itemtype)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[GetItemTypeArrayDataSize] %d", _:itemtype);
	if(!IsValidItemType(itemtype))
		return -1;

	return itm_arr_ItemTypeArrayMax[itemtype];
}

stock SetItemArrayData(itemid, data[], length, call = 1)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayData] %d %d", itemid, length);
	if(!IsValidItem(itemid))
		return 0;

	if(length > itm_arr_ItemTypeArrayMax[GetItemType(itemid)])
	{
		printf("ERROR: [SetItemArrayData] data length %d exceeds item type data size of %d.", length, itm_arr_ItemTypeArrayMax[GetItemType(itemid)]);
		return -1;
	}

	itm_arr_Length[itemid] = 0;

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[SetItemArrayData] Setting item array data");
	for(new i; i < length; i++)
	{
		sif_d:SIF_DEBUG_LEVEL_LOOPS:ITEM_ARRAY_DATA("[SetItemArrayData] Data at %04d: %d", i, data[i]);
		itm_arr_Data[itemid][itm_arr_Length[itemid]++] = data[i];
	}

	if(call)
		CallLocalFunction("OnItemArrayDataChanged", "d", itemid);

	return 1;
}

stock GetItemArrayData(itemid, data[])
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[GetItemArrayData] %d", itemid);
	if(!IsValidItem(itemid))
		return 0;

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[GetItemArrayData] Data length to return: %d", itm_arr_Length[itemid]);
	for(new i; i < itm_arr_Length[itemid]; i++)
	{
		sif_d:SIF_DEBUG_LEVEL_LOOPS:ITEM_ARRAY_DATA("[GetItemArrayData] Data at %04d: %d", i, itm_arr_Data[itemid][i]);
		data[i] = itm_arr_Data[itemid][i];
	}

	return 1;
}

stock SetItemArrayDataAtCell(itemid, data, cell, autoadjustsize = 0, call = 1)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] %d %d", itemid, cell);
	if(!IsValidItem(itemid))
		return 0;

	if(cell >= itm_arr_ItemTypeArrayMax[GetItemType(itemid)])
		return -1;

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] Item and cell valid. Checking cell %d >= length %d", cell, itm_arr_Length[itemid]);
	if(cell >= itm_arr_Length[itemid])
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] cell > itm_arr_Length");
		if(autoadjustsize)
		{
			sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] Auto adjusting size to %d", cell +1);
			itm_arr_Length[itemid] = cell + 1;			
		}
		else
		{
			#if ITM_ARR_ARRAY_SIZE_PROTECT == false
				sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] (Un-protect) adjusting size to %d", cell +1);
				itm_arr_Length[itemid] = cell + 1;
			#else
				sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] cell out of item bounds, return -2.");
				return -2;
			#endif	
		}
	}

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] Setting cell %d data to %d", cell, data);
	itm_arr_Data[itemid][cell] = data;

	if(call)
		CallLocalFunction("OnItemArrayDataChanged", "d", itemid);

	return 1;
}

stock GetItemArrayDataAtCell(itemid, cell)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[GetItemArrayDataAtCell] %d %d", itemid, cell);
	if(!IsValidItem(itemid))
	{
		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[GetItemArrayDataAtCell] ERROR: Invalid item ID");
		return 0;
	}

	new ItemType:itemtype = GetItemType(itemid);

	if(cell >= itm_arr_ItemTypeArrayMax[itemtype])
	{
		printf("[GetItemArrayDataAtCell] ERROR: Cell %d exceeds item type (%d) max of %d.", cell, _:itemtype, itm_arr_ItemTypeArrayMax[itemtype]);
		return -1;
	}

	#if ITM_ARR_ARRAY_SIZE_PROTECT == true

		if(cell >= itm_arr_Length[itemid])
		{
			printf("[GetItemArrayDataAtCell] ERROR: Cell %d exceeds item (%d) length of %d.", cell, itemid, itm_arr_Length[itemid]);
			return -2;
		}

	#endif

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_ARRAY_DATA("[GetItemArrayDataAtCell] Returning %d", itm_arr_Data[itemid][cell]);
	return itm_arr_Data[itemid][cell];
}

stock SetItemArrayDataSize(itemid, size)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayDataSize] %d %d", itemid, size);
	if(!IsValidItem(itemid))
		return 0;

	itm_arr_Length[itemid] = size;

	return 1;
}

stock GetItemArrayDataSize(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[GetItemArrayDataSize] %d", itemid);
	if(!IsValidItem(itemid))
		return 0;

	return itm_arr_Length[itemid];
}

stock GetItemTypeArrayDataMax(ItemType:itemtype)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[GetItemTypeArrayDataMax] %d", _:itemtype);
	if(!IsValidItemType(itemtype))
		return 0;

	return itm_arr_ItemTypeArrayMax[itemtype];
}

stock AppendItemArray(itemid, data[], length)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[AppendItemArray] %d %d", itemid, length);
	if(!IsValidItem(itemid))
		return 0;

	if(itm_arr_Length[itemid] + length > itm_arr_ItemTypeArrayMax[GetItemType(itemid)])
		return -1;

	for(new i; i < length; i++)
		itm_arr_Data[itemid][itm_arr_Length[itemid]++] = data[i];

	return 1;
}

stock AppendItemArrayCell(itemid, data)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[AppendItemArrayCell] %d %d", itemid, data);
	if(!IsValidItem(itemid))
		return 0;

	if(itm_arr_Length[itemid] + 1 > itm_arr_ItemTypeArrayMax[GetItemType(itemid)])
		return -1;

	itm_arr_Data[itemid][itm_arr_Length[itemid]++] = data;

	return 1;
}

stock SetItemArrayDataLength(itemid, length)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayDataLength] %d %d", itemid, length);
	if(!IsValidItem(itemid))
		return 0;

	itm_arr_Length[itemid] = length;

	return 1;
}

stock RemoveItemArrayData(itemid)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[RemoveItemArrayData] %d", itemid);
	if(!IsValidItem(itemid))
		return 0;

	itm_arr_Length[itemid] = 0;

	return 1;
}

stock SetItemNoResetArrayData(itemid, bool:toggle)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemNoResetArrayData] %d %d", itemid, toggle);
	if(!IsValidItem(itemid))
		return 0;

	itm_arr_NoResetOnCreate[itemid] = toggle;

	return 1;
}
