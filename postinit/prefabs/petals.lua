local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("petals", function(inst)
    inst:AddTag("petal")

    if not TheWorld.ismastersim then
        return
    end
end)
