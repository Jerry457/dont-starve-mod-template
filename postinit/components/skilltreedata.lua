GLOBAL.setfenv(1, GLOBAL)

local SkillTreeData = require("skilltreedata")

local _GetPointsForSkillXP = SkillTreeData.GetPointsForSkillXP
function SkillTreeData:GetPointsForSkillXP(skillxp, ...)
    if IS_DEV then
        return 999
    end
    return _GetPointsForSkillXP(self, skillxp, ...)
end
