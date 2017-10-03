#if defined _SIF_DISPENSER_INCLUDED
	#endinput
#endif

#include <YSI\y_hooks>

#define _SIF_DISPENSER_INCLUDED

#define MAX_DISPENSER			(64)
#define MAX_DISPENSER_TYPE		DispenserType:(8)
#define INVALID_DISPENSER_TYPE	DispenserType:(-1)
#define INVALID_DISPENSER_ID	(-1)


enum E_DISPENSER_DATA
{
DispenserType:	dsp_type,
				dsp_objId,
				dsp_buttonId,
				dsp_labelId,
				dsp_itemId,
Float:			dsp_posX,
Float:			dsp_posY,
Float:			dsp_posZ,
Float:			dsp_rotZ,
				dsp_world,
				dsp_interior
}

enum E_DISPENSER_TYPE_DATA
{
				dsp_name[32],
ItemType:		dsp_itemType,
				dsp_price
}


new
				dsp_Data[MAX_DISPENSER][E_DISPENSER_DATA],
       Iterator:dsp_Index<MAX_DISPENSER>;

new
				dsp_TypeData[MAX_DISPENSER_TYPE][E_DISPENSER_TYPE_DATA],
   Iterator:	dsp_TypeIndex<_:MAX_DISPENSER_TYPE>,
				dsp_ButtonDispenser[BTN_MAX],
				dsp_ItemDispenser[ITM_MAX];


forward OnPlayerUseDispenser(playerid, dispenserid);


stock CreateDispenser(Float:x, Float:y, Float:z, Float:rz, DispenserType:type, worldid = 0, interiorid = 0)
{
	new
		id = Iter_Free(dsp_Index),
		str[64];
	
	dsp_Data[id][dsp_type]		= type;

	dsp_Data[id][dsp_objId]		= CreateDynamicObject(
		2942, x, y, z, 0.0, 0.0, rz, worldid, interiorid);

	dsp_Data[id][dsp_buttonId]	= CreateButton(
		x, y, z + 0.5, "Press F to buy", worldid, interiorid);

	if(dsp_Data[id][dsp_buttonId] == INVALID_BUTTON_ID)
		return INVALID_DISPENSER_ID;

	dsp_ButtonDispenser[dsp_Data[id][dsp_buttonId]] = id;

	format(str, sizeof(str), ""#C_YELLOW"%s\n"#C_GREEN"$%d",
		dsp_TypeData[type][dsp_name],
		dsp_TypeData[type][dsp_price]);

	SetButtonLabel(dsp_Data[id][dsp_buttonId], str);

	dsp_Data[id][dsp_posX]		= x;
	dsp_Data[id][dsp_posY]		= y;
	dsp_Data[id][dsp_posZ]		= z;
	dsp_Data[id][dsp_rotZ]		= rz;
	dsp_Data[id][dsp_world]		= worldid;
	dsp_Data[id][dsp_interior]	= interiorid;

	Iter_Add(dsp_Index, id);
	
	return id;
}
stock DestroyDispenser(id)
{
	if(!Iter_Contains(dsp_Index, id))
		return 0;

	DestroyDynamicObject(dsp_Data[id][dsp_objId]);
	DestroyButton(dsp_Data[id][dsp_buttonId]);
	DestroyDynamic3DTextLabel(dsp_Data[id][dsp_labelId]);

	Iter_Remove(dsp_Index, id);
	return 1;
}

stock DispenserType:DefineDispenserType(name[], ItemType:type, price)
{
	new DispenserType:id = DispenserType:Iter_Free(dsp_TypeIndex);

	if(id == INVALID_DISPENSER_TYPE)
		return INVALID_DISPENSER_TYPE;
	
	format(dsp_TypeData[id][dsp_name], 32, name);
	dsp_TypeData[id][dsp_itemType] = type;
	dsp_TypeData[id][dsp_price] = price;
	
	Iter_Add(dsp_TypeIndex, _:id);
	
	return id;
}

hook OnButtonPress(playerid, buttonid)
{
	new dispenserid = dsp_ButtonDispenser[buttonid];

	if(Iter_Contains(dsp_Index, dispenserid))
	{
		if(GetPlayerMoney(playerid) < dsp_TypeData[ dsp_Data[dispenserid][dsp_type] ][dsp_price])
		{
			new str[128];

			format(str, sizeof(str), " >  You need another "#C_RED"$%d "#C_ORANGE"to buy that.",
				dsp_TypeData[ dsp_Data[dispenserid][dsp_type] ][dsp_price] - GetPlayerMoney(playerid));

			SendClientMessage(playerid, 0xFFFF00FF, str);

			return 0;
		}

		if(CallLocalFunction("OnPlayerUseDispenser", "dd", playerid, dispenserid))
			return 0;

		dsp_Data[dispenserid][dsp_itemId] = CreateItem(dsp_TypeData[ dsp_Data[dispenserid][dsp_type] ][dsp_itemType],
			dsp_Data[dispenserid][dsp_posX],
			dsp_Data[dispenserid][dsp_posY],
			dsp_Data[dispenserid][dsp_posZ] + 0.5,
			.rx = 30.0,
			.rz = dsp_Data[dispenserid][dsp_rotZ],
			.world = dsp_Data[dispenserid][dsp_world],
			.interior = dsp_Data[dispenserid][dsp_interior]);

		if(dsp_Data[dispenserid][dsp_itemId] != INVALID_ITEM_ID)
			dsp_ItemDispenser[dsp_Data[dispenserid][dsp_itemId]] = dispenserid;

		DestroyButton(buttonid);
		GivePlayerMoney(playerid, -dsp_TypeData[ dsp_Data[dispenserid][dsp_type] ][dsp_price]);

		return 1;
	}

	return 0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	new dispenserid = dsp_ItemDispenser[itemid];

	if(Iter_Contains(dsp_Index, dispenserid))
	{
		new str[64];

		dsp_Data[dispenserid][dsp_buttonId] = CreateButton(
			dsp_Data[dispenserid][dsp_posX],
			dsp_Data[dispenserid][dsp_posY],
			dsp_Data[dispenserid][dsp_posZ] + 0.5,
			"Press F to buy",
			dsp_Data[dispenserid][dsp_world],
			dsp_Data[dispenserid][dsp_interior]);

		format(str, sizeof(str), ""#C_YELLOW"%s\n"#C_GREEN"$%d",
			dsp_TypeData[dsp_Data[dispenserid][dsp_type]][dsp_name],
			dsp_TypeData[dsp_Data[dispenserid][dsp_type]][dsp_price]);

		SetButtonLabel(dsp_Data[dispenserid][dsp_buttonId], str);

		dsp_ItemDispenser[itemid] = INVALID_DISPENSER_ID;
		dsp_Data[dispenserid][dsp_itemId] = INVALID_ITEM_ID;
	}

	return 0;
}
