/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

Generates arrays of items that include array data from ItemArrayData. Useful for
storing BLOBs of items that include their array data too for "compressing" and
writing to files.

A basic example of using this module would be:

- Create an array of a player's inventory items when they quit.
- Serialise the item array of items and store to another array
- Store the serialised data in a binary file (using modio or fblockwrite).
- Load the array next time the player logs in.
- Use DeserialiseItems on the loaded data to extract items.
- Loop through the items and create them with their array data.
- Add the items to the player's inventory.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_ITEM_SERIALIZER_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include "debug.inc"
#endif

#if !defined _SIF_CORE_INCLUDED
	#include "core.inc"
#endif

#if !defined _SIF_ITEMARRAYDATA_INCLUDED
	#include "extensions/item-array-data.inc"
#endif

#if !defined _SIF_GEID_INCLUDED
	#include "geid.inc"
#endif

#include <YSI\y_hooks>

#define _SIF_ITEM_SERIALIZER_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


#if !defined ITEM_SERIALIZER_MAX_ITEMS
	#define ITEM_SERIALIZER_MAX_ITEMS	(256)
#endif

#define ITEM_SERIALIZER_RAW_SIZE		(2 + (ITEM_SERIALIZER_MAX_ITEMS * (11 + GEID_LEN + ITM_ARR_MAX_ARRAY_DATA)))


// Functions


forward SerialiseItems(items[], maxitems = sizeof(items));
/*
# Description:
-
*/

forward DeserialiseItems(list[], length = sizeof(list), store = true);
/*
# Description:
-
*/

forward ClearSerializer();
/*
# Description:
-
*/

forward GetSerialisedSize();
/*
# Description:
-
*/

forward GetStoredItemCount();
/*
# Description:
-
*/

forward ItemType:GetStoredItemType(index);
/*
# Description:
-
*/

forward GetStoredItemPos(index, &Float:x, &Float:y, &Float:z);
/*
# Description:
-
*/

forward GetStoredItemRot(index, &Float:x, &Float:y, &Float:z);
/*
# Description:
-
*/

forward GetStoredItemWorld(index);
/*
# Description:
-
*/

forward GetStoredItemInterior(index);
/*
# Description:
-
*/

forward GetStoredItemArrayData(index, output[]);
/*
# Description:
-
*/

forward GetStoredItemArrayDataSize(index);
/*
# Description:
-
*/

forward CreateItemFromStored(index);
/*
# Description:
-
*/

forward SetItemArrayDataFromStored(itemid, index);
/*
# Description:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
			// Locks the item data to block interspersing read/write ops.
bool:		itm_list_Lock,

			// Contains a simple list of item types for lookups.
			itm_list_Items[ITEM_SERIALIZER_MAX_ITEMS],

			// World position
Float:		itm_list_WorldX[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_WorldY[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_WorldZ[ITEM_SERIALIZER_MAX_ITEMS],

			// Rotation
Float:		itm_list_RotationX[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_RotationY[ITEM_SERIALIZER_MAX_ITEMS],
Float:		itm_list_RotationZ[ITEM_SERIALIZER_MAX_ITEMS],

			// World and Interior
			itm_list_VirtualWorld[ITEM_SERIALIZER_MAX_ITEMS],
			itm_list_Interior[ITEM_SERIALIZER_MAX_ITEMS],

			// Hit points
			itm_list_Hitpoints[ITEM_SERIALIZER_MAX_ITEMS],

			// GEID
			itm_list_GEID[ITEM_SERIALIZER_MAX_ITEMS][GEID_LEN],

			// Contains the item extra data for returning.
			itm_list_Array[ITEM_SERIALIZER_MAX_ITEMS][ITM_ARR_MAX_ARRAY_DATA],

			// Contains the item data array size
			itm_list_ArraySize[ITEM_SERIALIZER_MAX_ITEMS],

			// Contains the number of items in the list
			itm_list_Count,

			/*
				This is the "raw list" which follows this structure:
				The first two cells are the data size in cells and item count.
				Each block starts with the block size followed by the item data.
				The block size will be: 11 + GEID_LEN (14) + array data size

				data size in cells
				number of items
				item blocks
				[
					block size
					item type
					world x
					world y
					world z
					rotation x
					rotation y
					rotation z
					virtual world
					interior
					hitpoints
					geid[GEID_LEN]
					array data[...]
				]
				...
			*/

			// Size of the raw list
			itm_arr_Size;

			// Raw list is global for easy access.
new			itm_arr_Serialized[ITEM_SERIALIZER_RAW_SIZE];


static ITEM_SERIALIZER_DEBUG = -1;


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	ITEM_SERIALIZER_DEBUG = sif_debug_register_handler("SIF/ItemSerializer");
	sif_d:SIF_DEBUG_LEVEL_CALLBACKS:ITEM_SERIALIZER_DEBUG("[OnScriptInit]");
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock SerialiseItems(items[], maxitems = sizeof(items))
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[SerialiseItems] maxitems:%d", maxitems);
	if(itm_list_Lock)
	{
		printf("[SerialiseItems] ERROR: serialiser is locked, DeserialiseItems operation not finished with ClearSerializer");
		return 1;
	}

	itm_arr_Size = 0;
	itm_list_Count = 0;

	itm_arr_Serialized[itm_arr_Size++] = 0;
	itm_arr_Serialized[itm_arr_Size++] = maxitems;

	for(new i; i < maxitems; i++)
	{
		itm_list_Items[i] = _:GetItemType(items[i]);
		GetItemPos(items[i], itm_list_WorldX[i], itm_list_WorldY[i], itm_list_WorldZ[i]);
		GetItemRot(items[i], itm_list_RotationX[i], itm_list_RotationY[i], itm_list_RotationZ[i]);
		itm_list_VirtualWorld[i] = GetItemWorld(items[i]);
		itm_list_Interior[i] = GetItemInterior(items[i]);
		itm_list_ArraySize[i] = GetItemArrayDataSize(items[i]);
		GetItemArrayData(items[i], itm_list_Array[i]);
		GetItemGEID(items[i], itm_list_GEID[i]);

		itm_arr_Serialized[itm_arr_Size++] = 11 + GEID_LEN + itm_list_ArraySize[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_Items[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_WorldX[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_WorldY[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_WorldZ[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_RotationX[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_RotationY[i];
		itm_arr_Serialized[itm_arr_Size++] = _:itm_list_RotationZ[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_VirtualWorld[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_Interior[i];
		itm_arr_Serialized[itm_arr_Size++] = itm_list_Hitpoints[i];

		memcpy(itm_arr_Serialized, itm_list_GEID[i], itm_arr_Size * 4, GEID_LEN * 4);
		itm_arr_Size += GEID_LEN;

		if(itm_list_ArraySize[i] > 0)
		{
			sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[SerialiseItems] calling item array data memcpy(%d, %d, %d, %d)", itm_arr_Serialized, itm_list_Array[i], itm_arr_Size * 4, itm_list_ArraySize[i] * 4);
			memcpy(itm_arr_Serialized, itm_list_Array[i], itm_arr_Size * 4, itm_list_ArraySize[i] * 4);
			itm_arr_Size += itm_list_ArraySize[i];
		}

		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[SerialiseItems] %d/%d (raw:%d) itemtype:%d(%s) arrsize: %d, arr[0]: %d", i, maxitems, itm_arr_Size, itm_list_Items[i], itm_list_GEID[i], itm_list_ArraySize[i], itm_list_Array[i][0]);

		itm_list_Count++;
	}

	if(itm_list_Count != maxitems)
	{
		printf("[SerialiseItems] ERROR: itm_list_Count != maxitems (%d != %d)", itm_list_Count, maxitems);
		return 1;
	}

	itm_arr_Serialized[0] = itm_arr_Size;

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[SerialiseItems] first two cells: %d %d", itm_arr_Serialized[0], itm_arr_Serialized[1]);

	return 0;
}

stock DeserialiseItems(list[], length = sizeof(list), store = true)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[DeserialiseItems] length:%d store:%d", length, store);
	if(itm_list_Lock)
	{
		printf("[SerialiseItems] ERROR: serialiser is locked, DeserialiseItems operation not finished with ClearSerializer");
		return 1;
	}

	itm_list_Lock = true;

	if(store)
		memcpy(itm_arr_Serialized, list, 0, length * 4);

	new expected_item_count = list[1];

	itm_arr_Size = 2;
	itm_list_Count = 0;

	if(length != list[0])
	{
		printf("[DeserialiseItems] ERROR: size in first cell (%d) does not match size passed in (%d)", list[0], length);
		return 1;
	}

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[DeserialiseItems] first two cells: %d (data size) %d (item count)", list[0], list[1]);

	while(itm_list_Count < expected_item_count)
	{
		itm_list_ArraySize[itm_list_Count]		= list[itm_arr_Size++] - (11 + GEID_LEN);
		itm_list_Items[itm_list_Count]			= list[itm_arr_Size++];
		itm_list_WorldX[itm_list_Count]			= Float:list[itm_arr_Size++];
		itm_list_WorldY[itm_list_Count]			= Float:list[itm_arr_Size++];
		itm_list_WorldZ[itm_list_Count]			= Float:list[itm_arr_Size++];
		itm_list_RotationX[itm_list_Count]		= Float:list[itm_arr_Size++];
		itm_list_RotationY[itm_list_Count]		= Float:list[itm_arr_Size++];
		itm_list_RotationZ[itm_list_Count]		= Float:list[itm_arr_Size++];
		itm_list_VirtualWorld[itm_list_Count]	= list[itm_arr_Size++];
		itm_list_Interior[itm_list_Count]		= list[itm_arr_Size++];
		itm_list_Hitpoints[itm_list_Count]		= list[itm_arr_Size++];

		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[DeserialiseItems] calling item geid memcpy(%d, %d, %d, %d, %d)", itm_list_GEID[itm_list_Count], list[itm_arr_Size], 0, GEID_LEN * 4, GEID_LEN * 4);
		memcpy(itm_list_GEID[itm_list_Count], list[itm_arr_Size], 0, GEID_LEN * 4, GEID_LEN * 4);
		itm_arr_Size += GEID_LEN;

		if(itm_list_ArraySize[itm_list_Count] > 0)
		{
			sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[DeserialiseItems] calling item array data memcpy(%d, %d, %d, %d)", itm_list_Array[itm_list_Count], list[itm_arr_Size], 0, itm_list_ArraySize[itm_list_Count] * 4);
			memcpy(itm_list_Array[itm_list_Count], list[itm_arr_Size], 0, itm_list_ArraySize[itm_list_Count] * 4);
			itm_arr_Size += itm_list_ArraySize[itm_list_Count];
		}

		sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[DeserialiseItems] %d/%d (raw:%d/%d) itemtype:%d(%s) arrsize: %d, arr[0]: %d", itm_list_Count, list[1], itm_arr_Size, length, itm_list_Items[itm_list_Count], itm_list_GEID[itm_list_Count], itm_list_ArraySize[itm_list_Count], itm_list_Array[itm_list_Count][0]);
		itm_list_Count++;
	}

	if(itm_arr_Size != list[0])
	{
		printf("[DeserialiseItems] ERROR: itm_arr_Size != list[0] (%d != %d)", itm_arr_Size, list[0]);
		return 1;
	}

	return 0;
}

stock ClearSerializer()
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[ClearSerializer]");
	itm_list_Count = 0;
	itm_list_Lock = false;
}

stock GetSerialisedSize()
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetSerialisedSize] -> %d", itm_arr_Size);
	return itm_arr_Size;
}

stock GetStoredItemCount()
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemCount] -> %d", itm_list_Count);
	return itm_list_Count;
}

stock ItemType:GetStoredItemType(index)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemType] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemType] ERROR: index (%d) out of bounds 0..%d", index, itm_list_Count);
		return INVALID_ITEM_TYPE;
	}

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[GetStoredItemType] -> %d", _:itm_list_Items[index]);
	return ItemType:itm_list_Items[index];
}

stock GetStoredItemPos(index, &Float:x, &Float:y, &Float:z)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemPos] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemPos] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	x = itm_list_WorldX[index];
	y = itm_list_WorldY[index];
	z = itm_list_WorldZ[index];
	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[GetStoredItemType] -> %f, %f, %f", x, y, z);

	return 1;
}

stock GetStoredItemRot(index, &Float:x, &Float:y, &Float:z)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemRot] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemRot] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	x = itm_list_RotationX[index];
	y = itm_list_RotationY[index];
	z = itm_list_RotationZ[index];
	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[GetStoredItemRot] -> %f, %f, %f", x, y, z);

	return 1;
}

stock GetStoredItemWorld(index)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemWorld] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemWorld] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[GetStoredItemWorld] -> %d", itm_list_VirtualWorld[index]);
	return itm_list_VirtualWorld[index];
}

stock GetStoredItemInterior(index)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemInterior] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemInterior] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[GetStoredItemInterior] -> %d", itm_list_Interior[index]);
	return itm_list_Interior[index];
}

stock GetStoredItemArrayData(index, output[])
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemArrayData] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemArrayData] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	memcpy(output, itm_list_Array[index], 0, itm_list_ArraySize[index] * 4, itm_arr_Size);

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[GetStoredItemArrayData] -> %d", itm_list_ArraySize[index]);
	return itm_list_ArraySize[index];
}

stock GetStoredItemArrayDataSize(index)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[GetStoredItemArrayDataSize] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[GetStoredItemArrayDataSize] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[GetStoredItemArrayDataSize] -> %d", itm_list_ArraySize[index]);
	return itm_list_ArraySize[index];
}

stock CreateItemFromStored(index)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[CreateItemFromStored] index:%d", index);
	if(!(0 <= index < itm_list_Count))
	{
		printf("[CreateItemFromStored] ERROR: index (%d) out of bounds", index);
		return 0;
	}

	new itemid = CreateItem(itm_list_Items[index]);
	SetItemArrayData(itemid, itm_list_Array[index], itm_list_ArraySize[index]);

	sif_d:SIF_DEBUG_LEVEL_CORE_DEEP:ITEM_SERIALIZER_DEBUG("[CreateItemFromStored] -> %d", itemid);
	return itemid;
}

stock SetItemArrayDataFromStored(itemid, index)
{
	sif_d:SIF_DEBUG_LEVEL_CORE:ITEM_SERIALIZER_DEBUG("[SetItemArrayDataFromStored] itemid:%d index:%d", itemid, index);
	return SetItemArrayData(itemid, itm_list_Array[index], itm_list_ArraySize[index]);
}
