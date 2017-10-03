/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

Extends items to have an array of data instead of just one cell. Includes
functions for setting, appending and getting array data.

## Hooks

- OnItemCreate: To reset per-item array data variables.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_ITEMARRAYDATA_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include "debug.inc"
#endif

#if !defined _SIF_CORE_INCLUDED
	#include "core.inc"
#endif

#include <YSI\y_hooks>

#define _SIF_ITEMARRAYDATA_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

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


// Functions


forward SetItemTypeMaxArrayData(ItemType:itemtype, size, bool:protect = false);
/*
# Description:
-
*/

forward GetItemTypeArrayDataSize(ItemType:itemtype);
/*
# Description:
-
*/

forward SetItemArrayData(itemid, data[], length, call = 1, bool:force = false);
/*
# Description:
-
*/

forward GetItemArrayData(itemid, data[]);
/*
# Description:
-
*/

forward SetItemArrayDataAtCell(itemid, data, cell, autoadjustsize = 0, call = 1, bool:force = false);
/*
# Description:
-
*/

forward GetItemArrayDataAtCell(itemid, cell);
/*
# Description:
-
*/

forward SetItemArrayDataSize(itemid, size, bool:force = false);
/*
# Description:
-
*/

forward GetItemArrayDataSize(itemid);
/*
# Description:
-
*/

forward GetItemTypeArrayDataMax(ItemType:itemtype);
/*
# Description:
-
*/

forward AppendItemArray(itemid, data[], length);
/*
# Description:
-
*/

forward AppendItemArrayCell(itemid, data);
/*
# Description:
-
*/

forward SetItemArrayDataLength(itemid, length, bool:force = false);
/*
# Description:
-
*/

forward RemoveItemArrayData(itemid);
/*
# Description:
-
*/

forward SetItemNoResetArrayData(itemid, bool:toggle);
/*
# Description:
-
*/


// Events


forward OnItemArrayDataChanged(itemid);
/*
# Called:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
	itm_arr_ItemTypeArrayMax[ITM_MAX_TYPES],
	bool:itm_arr_ItemTypeArrayProtect[ITM_MAX_TYPES],
	itm_arr_Data[ITM_MAX][ITM_ARR_MAX_ARRAY_DATA],
	itm_arr_Length[ITM_MAX],
	itm_arr_NoResetOnCreate[ITM_MAX];

static
	ITEM_ARRAY_DATA = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	ITEM_ARRAY_DATA = sif_debug_register_handler("SIF/ItemArrayData");
}

hook OnItemCreate(itemid)
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

	return 1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock SetItemTypeMaxArrayData(ItemType:itemtype, size, bool:protect = false)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemTypeMaxArrayData] %d %d %d", _:itemtype, size, protect);
	if(!IsValidItemType(itemtype))
		return 0;

	if(size > ITM_ARR_MAX_ARRAY_DATA)
		return -1;

	itm_arr_ItemTypeArrayMax[itemtype] = size;
	itm_arr_ItemTypeArrayProtect[itemtype] = protect;

	return 1;
}

stock GetItemTypeArrayDataSize(ItemType:itemtype)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[GetItemTypeArrayDataSize] %d", _:itemtype);
	if(!IsValidItemType(itemtype))
		return -1;

	return itm_arr_ItemTypeArrayMax[itemtype];
}

stock SetItemArrayData(itemid, data[], length, call = 1, bool:force = false)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayData] %d %d", itemid, length);
	if(!IsValidItem(itemid))
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(length > itm_arr_ItemTypeArrayMax[itemtype])
	{
		printf("ERROR: [SetItemArrayData] data length %d exceeds item type %d data size of %d.", length, _:GetItemType(itemid), itm_arr_ItemTypeArrayMax[GetItemType(itemid)]);
		return -1;
	}

	if(itm_arr_ItemTypeArrayProtect[itemtype] && !force)
	{
		printf("ERROR: [SetItemArrayData] itemtype (%d) uses data protection and force parameter is false.", _:itemtype);
		return -2;
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

stock SetItemArrayDataAtCell(itemid, data, cell, autoadjustsize = 0, call = 1, bool:force = false)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayDataAtCell] %d %d", itemid, cell);
	if(!IsValidItem(itemid))
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(cell >= itm_arr_ItemTypeArrayMax[itemtype])
		return -1;

	if(itm_arr_ItemTypeArrayProtect[itemtype] && !force)
	{
		printf("ERROR: [SetItemArrayDataAtCell] itemtype (%d) uses data protection and force parameter is false.", _:itemtype);
		return -2;
	}

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

stock SetItemArrayDataSize(itemid, size, bool:force = false)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayDataSize] %d %d", itemid, size);
	if(!IsValidItem(itemid))
		return 0;

	if(itm_arr_ItemTypeArrayProtect[GetItemType(itemid)] && !force)
	{
		printf("ERROR: [SetItemArrayDataSize] itemtype (%d) uses data protection and force parameter is false.", _:GetItemType(itemid));
		return -2;
	}

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

stock SetItemArrayDataLength(itemid, length, bool:force = false)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_ARRAY_DATA("[SetItemArrayDataLength] %d %d", itemid, length);
	if(!IsValidItem(itemid))
		return 0;

	if(itm_arr_ItemTypeArrayProtect[GetItemType(itemid)] && !force)
	{
		printf("ERROR: [SetItemArrayDataLength] itemtype (%d) uses data protection and force parameter is false.", _:GetItemType(itemid));
		return -2;
	}

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
