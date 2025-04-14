local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local ICON_SCALE = .6
local SPELLBOOK_BG =
{
    bank = "ui_chest_3x3",
    build = "ui_chest_3x3",
    anim = "open",
    widget_scale = 1,
}

AddPrefabPostInit("abigail_flower", function(inst)
    -- inst.components.spellbook:SetBgData(SPELLBOOK_BG)
end)
