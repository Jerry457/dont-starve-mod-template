local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

AddSimPostInit(function()
    local potion_tunings = GlassicAPI.UpvalueUtil.GetUpvalue(Prefabs["ghostlyelixir_slowregen"].fn, "potion_tunings")
    potion_tunings.ghostlyelixir_fastregen.skill_modifier_long_duration = true

end)
