local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function onpickedfn(inst, picker)
    if picker and picker.components.sanity then
        picker.components.sanity:DoDelta(-TUNING.SANITY_TINY)
    end
end

AddPrefabPostInit("flower_evil", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.pickable.onpickedfn = onpickedfn
end)
