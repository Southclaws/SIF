#include <YSI\y_hooks>
#include <YSI\y_testing>


hook OnScriptInit()
{
	new
		tests,
		fails,
		func[33];

	Testing_Run(tests, fails, func);

	printf("Test complete. Tests: %d, Fails: %d, Last func: '%s'.", tests, fails, func);

	return 1;
}


/*==============================================================================

	SIF/Button

==============================================================================*/


static
	gButton;


TestInit:Button_Core()
{
	sif_debug_level(sif_debug_handler_search("SIF/Button"), SIF_DEBUG_LEVEL_INTERFACE_DEEP);

	gButton = CreateButton(1.0, 2.0, 3.0, "Button", 4, 8, 2.5, 1, "Label", 0x1C1C1CFF, 12.5);

	// Button should be valid
	ASSERT(IsValidButton(gButton));
}

Test:Button_Core()
{
	new tmp;

	ASSERT(bool:IsValidDynamicArea(GetButtonArea(gButton)));
	tmp = CreateDynamicCircle(20.0, 20.0, 4.0);
	ASSERT(bool:SetButtonArea(gButton, tmp));
	ASSERT(GetButtonArea(gButton) == tmp);

	ASSERT(bool:SetButtonLabel(gButton, "New text", -1, 42.0));
	ASSERT(bool:DestroyButtonLabel(gButton));

	new Float:x, Float:y, Float:z;
	ASSERT(bool:GetButtonPos(gButton, x, y, z));
	ASSERT(x == 1.0 && y == 2.0 && z == 3.0);
	ASSERT(bool:SetButtonPos(gButton, 3.0, 5.0, 1.0));
	ASSERT(bool:GetButtonPos(gButton, x, y, z));
	ASSERT(x == 3.0 && y == 5.0 && z == 1.0);

	ASSERT(GetButtonSize(gButton) == 2.5);
	ASSERT(bool:SetButtonSize(gButton, 4.4));
	ASSERT(GetButtonSize(gButton) == 4.4);

	ASSERT(GetButtonWorld(gButton) == 4);
	ASSERT(bool:SetButtonWorld(gButton, 6));
	ASSERT(GetButtonWorld(gButton) == 6);

	ASSERT(GetButtonInterior(gButton) == 8);
	ASSERT(bool:SetButtonInterior(gButton, 10));
	ASSERT(GetButtonInterior(gButton) == 10);

	tmp = CreateButton(10.0, 0.0, 0.0, "Linked");
	ASSERT(bool:LinkTP(gButton, tmp));
	ASSERT(GetButtonLinkedID(gButton) == tmp);
	ASSERT(GetButtonLinkedID(tmp) == gButton);
	ASSERT(bool:UnLinkTP(gButton, tmp));
	ASSERT(GetButtonLinkedID(gButton) == INVALID_BUTTON_ID);
	ASSERT(GetButtonLinkedID(tmp) == INVALID_BUTTON_ID);

	new string[128];
	ASSERT(bool:GetButtonText(gButton, string));
	ASSERT(!strcmp(string, "Button"));
	ASSERT(bool:SetButtonText(gButton, "New Button Text Long String"));
	ASSERT(bool:GetButtonText(gButton, string));
	ASSERT(!strcmp(string, "New Button Text Long String"));

	ASSERT(bool:SetButtonExtraData(gButton, 50));
	ASSERT(GetButtonExtraData(gButton) == 50);
}

TestClose:Button_Core()
{
	DestroyButton(gButton);

	// Button should be invalid now that it's deleted
	ASSERT(!IsValidButton(gButton));
}
