GLOBAL.setfenv(1, GLOBAL)

local SkillTreeUpdater = require("components/skilltreeupdater")
local SkillTreeBuilder = require("widgets/redux/skilltreebuilder")
local skill_map = {
    wendy_smallghost_2 = "",
    wendy_smallghost_3 = "wendy_smallghost_1",

    wendy_gravestone_1 = "wendy_smallghost_2",
}

local _IsActivated = SkillTreeUpdater.IsActivated
local function IsActivated(self, skill, ...)
    local skill = skill_map[skill]
    return _IsActivated(self, skill, ...)
end
SkillTreeUpdater.IsActivated = IsActivated

local _RefreshTree = SkillTreeBuilder.RefreshTree
function SkillTreeBuilder:RefreshTree(...)
    SkillTreeUpdater.IsActivated = _IsActivated
    _RefreshTree(self, ...)
    SkillTreeUpdater.IsActivated = _IsActivated
end
