local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("moon_tree_blossom", function(inst)
    inst:AddTag("petal")
    inst:AddTag("flower")

    if not TheWorld.ismastersim then
        return
    end
end)
