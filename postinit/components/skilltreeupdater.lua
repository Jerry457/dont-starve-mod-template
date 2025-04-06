GLOBAL.setfenv(1, GLOBAL)

local SkillTreeUpdater = require("components/skilltreeupdater")

function HookSkillTreeUpdaterIsActivated(original_skill, replace_skill, fn, ...)
    local _IsActivated = SkillTreeUpdater.IsActivated
    SkillTreeUpdater.IsActivated = function(self, skill, ...)
        skill = (skill == original_skill) and replace_skill or skill
        return _IsActivated(self, skill, ...)
    end
    local ret = {fn(...)}
    SkillTreeUpdater.IsActivated = _IsActivated
    return unpack(ret)
end
