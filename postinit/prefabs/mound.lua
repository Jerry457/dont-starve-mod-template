local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("mound", function(inst)
    inst.entity:AddSoundEmitter()

    inst:AddTag("mound")
    inst:AddTag("grave_relocation")

    if not TheWorld.ismastersim then
        return
    end
end)
