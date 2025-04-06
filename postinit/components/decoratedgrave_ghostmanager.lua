local DecoratedGrave_GhostManager = require("components/decoratedgrave_ghostmanager")

local OnUpdate = DecoratedGrave_GhostManager.OnUpdate
function DecoratedGrave_GhostManager:OnUpdate(...)
    return HookSkillTreeUpdaterIsActivated("wendy_gravestone_1", "wendy_smallghost_2", OnUpdate, self, ...)
end
