GLOBAL.setfenv(1, GLOBAL)

local SkillTreeData = require("skilltreedata")

local _GetPointsForSkillXP = SkillTreeData.GetPointsForSkillXP
function SkillTreeData:GetPointsForSkillXP(skillxp)
    return 999
end
