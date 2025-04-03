local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnPicked(inst, picker)
    if picker and picker.components.sanity then
        picker.components.sanity:DoDelta(-TUNING.SANITY_TINY)
    end
end

AddPrefabPostInit("flower_evil", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.pickable.onpickedfn = OnPicked
end)
