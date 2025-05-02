local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("blossom", function(inst)
    inst:AddTag("flower")

    if not TheWorld.ismastersim then
        return
    end
end)
