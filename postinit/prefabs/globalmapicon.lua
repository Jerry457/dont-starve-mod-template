local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("globalmapicon", function(inst)
    if not TheWorld.ismastersim then
        return
    end

end)
