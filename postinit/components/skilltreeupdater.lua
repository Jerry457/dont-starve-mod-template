GLOBAL.setfenv(1, GLOBAL)

local SkillTreeUpdater = require("components/skilltreeupdater")

function HookSkillTreeUpdaterIsActivated(original_skill, replace_skill, fn, ...)
    local _IsActivated = SkillTreeUpdater.IsActivated
    SkillTreeUpdater.IsActivated = function(self, skill, ...)
        if type(original_skill) == "table" then
            skill = original_skill[skill] or skill
        else
            skill = (skill == original_skill) and replace_skill or skill
        end
        return _IsActivated(self, skill, ...)
    end
    local ret = {fn(...)}
    SkillTreeUpdater.IsActivated = _IsActivated
    return unpack(ret)
end

function SkillTreeUpdater:HasActivatedSkill()
    return self.skilltree.activatedskills and self.skilltree.activatedskills[self.inst.prefab] and not IsTableEmpty(self.skilltree.activatedskills[self.inst.prefab])
end
