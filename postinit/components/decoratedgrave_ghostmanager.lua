local DecoratedGrave_GhostManager = require("components/decoratedgrave_ghostmanager")

local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("decoratedgrave_ghostmanager", function(cmp)
    local _OnUpdate = cmp.OnUpdate
    function cmp:OnUpdate(...)
        return HookSkillTreeUpdaterIsActivated("wendy_gravestone_1", "wendy_smallghost_2", _OnUpdate, self, ...)
    end
end)
