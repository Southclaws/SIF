#define FILTERSCRIPT

#include <a_samp>
#include <SIF\Item.pwn>
#include <SIF\extensions/ItemArrayData>
#include <SIF\extensions/ItemList>
#include <YSI_4\y_hooks>
#include <modio>


static
ItemType:	item_Journal,
ItemType:	item_Gun;

static
			journal1;

static
			gItemList[ITM_LST_MAX_LIST_SIZE];


public OnFilterScriptInit()
{
	item_Journal = DefineItemType("Journal", 2894, ITEM_SIZE_SMALL);
	item_Gun = DefineItemType("Gun", 0, ITEM_SIZE_SMALL);

	SetItemTypeMaxArrayData(item_Journal, 256);
	SetItemTypeMaxArrayData(item_Gun, 4);

	journal1 = CreateItem(item_Journal, 0.0, 0.0, 2.0);

	// Setting data

	new
		data[256],
		ret;

	data = "Hello world. This is a journal item.";

	// SetItemArrayData
	ret = SetItemArrayData(journal1, data, strlen(data));
	printf("ret: %d - Set array data to '%s'", ret, data);

	// GetItemArrayData
	new data2[256];
	GetItemArrayData(journal1, data2);
	printf("ret: %d - got: '%s'", ret, data2);

	// SetItemArrayDataAtCell
	ret = SetItemArrayDataAtCell(journal1, 'r', 3);
	printf("ret: %d - Setting 'r' at 3", ret);

	// AppendItemArray
	ret = AppendItemArray(journal1, "More text added", 15);
	printf("ret: %d - appending 'More text added' to data", ret);

	// AppendItemArrayCell
	ret = AppendItemArrayCell(journal1, '!');
	printf("ret: %d - appending '!' to data", ret);

	// Get one last time to see if it's all right
	ret = GetItemArrayData(journal1, data2);
	printf("ret: %d - got: '%s'", ret, data2);

	// GetItemArrayDataAtCell
	printf("data at cell %d: %d ('%c')", 5, GetItemArrayDataAtCell(journal1, 5), GetItemArrayDataAtCell(journal1, 5));

	// GetItemArrayDataSize
	printf("data size: %d", GetItemArrayDataSize(journal1));

	// GetItemTypeArrayDataSize
	printf("data max for itemtype: %d", GetItemTypeArrayDataSize(item_Journal));


	defer makelist();

	return 1;
}

timer makelist[1000]()
{
	print("\n\n\nItem list test\n\n\n");

	new
		// The list of item IDs
		items[4],
		// Some random array data for items
		gundata[4],
		journaldata[12];

	gundata[0] = 49;
	gundata[1] = 1;
	gundata[2] = 7827;
	gundata[3] = 100;

	journaldata = "hello world";

	// Create valid items
	items[0] = CreateItem(item_Gun);
	items[1] = CreateItem(item_Gun);
	items[2] = CreateItem(item_Journal);
	items[3] = CreateItem(item_Gun);

	// Assign array data to the items
	SetItemArrayData(items[0], gundata, 4);
	SetItemArrayData(items[1], gundata, 4);
	SetItemArrayData(items[2], journaldata, 12);
	SetItemArrayData(items[3], gundata, 4);

	// Create an itemlist using the item IDs
	new itemlist = CreateItemList(items, 4);

	// Print out the raw item list contents
	for(new i, j = GetItemListSize(itemlist); i < j; i++)
	{
		printf("[%03d] :: %d", i, GetItemListElement(itemlist, i));
	}

	// Return the raw list from the itemlist
	new listsize;

	// A global must be used due to the huge size of item lists
	listsize = GetItemList(itemlist, gItemList);

	// Write the raw item list to a file
	modio_push("items.dat", !"LIST", listsize, gItemList);

	// Free the itemlist from memory as it's not needed any more
	DestroyItemList(itemlist);

	defer readfile();
}

timer readfile[1000]()
{
	new
		// Stores the raw list of items and their array data
		array[ITM_LST_OF_ITEMS(4)],
		length;

	// Load the raw item list from the file
	length = modio_read("items.dat", !"LIST", array);

	printf("Loaded array of size %d", length);

	// Extract/decode the list into itemtypes and array data
	new
		itemlist,
		ItemType:itemtype,
		itemarraydata[ITM_ARR_MAX_ARRAY_DATA],
		itemarraydatasize;

	itemlist = ExtractItemList(array);

	// Loop through each item
	for(new i; i < GetItemListItemCount(itemlist); i++)
	{
		// Get the item type and array data from the list
		itemtype = GetItemListItem(itemlist, i);
		itemarraydatasize = GetItemListItemArrayData(itemlist, i, itemarraydata);

		// Print stuff out
		printf("[item %d]", i);
		printf("\tItem type: %d, arraydata size: %d", _:itemtype, itemarraydatasize);

		for(new j; j < GetItemListItemArrayDataSize(itemlist, i); j++)
			printf("\tItem data: [%d]: %d", j, itemarraydata[j]);

		// Create the item and assign the array data
		SetItemArrayData(CreateItem(itemtype), itemarraydata, itemarraydatasize);
	}

	// Free the itemlist from memory as it's not needed any more
	DestroyItemList(itemlist);
}
