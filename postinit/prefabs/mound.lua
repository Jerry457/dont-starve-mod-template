local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("mound", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddTag("grave_relocation")
end)
