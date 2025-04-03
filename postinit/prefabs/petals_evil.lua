local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("petals_evil", function(inst)
    inst:AddTag("petal")

    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("upgrader")
    inst.components.upgrader.upgradetype = UPGRADETYPES.GRAVESTONE
end)
