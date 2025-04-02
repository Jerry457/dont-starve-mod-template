local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("ghostflower", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("grave_relocation_item")
end)
