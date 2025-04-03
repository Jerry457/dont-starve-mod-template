GLOBAL.setfenv(1, GLOBAL)

local SkillTreeUpdater = require("components/skilltreeupdater")

local skill_map = {
    wendy_smallghost_2 = "",
    wendy_smallghost_3 = "wendy_smallghost_1",

    wendy_gravestone_1 = "wendy_smallghost_2",
}

local _IsActivated = SkillTreeUpdater.IsActivated
function SkillTreeUpdater:IsActivated(skill, ...)
    skill = skill_map[skill] or skill
    return _IsActivated(self, skill, ...)
end
