local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)
AddPrefabPostInit("smallghost", function(inst)
    if not TheWorld.ismastersim then
        return
    end
end)
