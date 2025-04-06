local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local SkillTreeUpdater = require("components/skilltreeupdater")

AddPrefabPostInit("smallghost", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _on_begin_quest = inst.components.questowner.on_begin_quest
    inst.components.questowner.on_begin_quest = function(...)
        return HookSkillTreeUpdaterIsActivated("wendy_smallghost_2", "", _on_begin_quest, ...)
    end

    local _PickupToy = inst.PickupToy
    inst.PickupToy = function(...)
        return HookSkillTreeUpdaterIsActivated("wendy_smallghost_3", "wendy_smallghost_1", _PickupToy, ...)
    end
end)
