local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("gravestone", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.mound:AddTag("has_gravestone")
    inst:AddTag("grave_relocation")
end)
