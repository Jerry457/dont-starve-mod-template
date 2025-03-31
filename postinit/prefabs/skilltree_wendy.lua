GLOBAL.setfenv(1, GLOBAL)

local skilltree_defs = require("prefabs/skilltree_defs")

-- Positions
local TILEGAP = 38
local TILE = 50
local POS_X_1 = -245 -- -211
local POS_Y_1 = 172

local X = -298
local Y = 288

local width = 255+249-50
local height = 142+10

local CURVE_BASE_H = 75
local A_BASE_H = -10 +TILE

local COL1= POS_X_1 + math.floor(width/11)
local COL2= POS_X_1 + math.floor(width/11) *2
local COL3= POS_X_1 + math.floor(width/11) *3
local COL4= POS_X_1 + math.floor(width/11) *4
local COL5= POS_X_1 + math.floor(width/11) *5

local COL6= POS_X_1 + math.floor(width/11) *7
local COL7= POS_X_1 + math.floor(width/11) *8
local COL8= POS_X_1 + math.floor(width/11) *9
local COL9= POS_X_1 + math.floor(width/11) *10
local COL10= POS_X_1 + math.floor(width/11) *11

local CURV1 = CURVE_BASE_H + 0
local CURV2 = CURVE_BASE_H + math.floor(TILE/1.5)
local CURV3 = CURVE_BASE_H + math.floor(TILE/1.5+TILE/3)
local CURV4 = CURVE_BASE_H + math.floor(TILE/1.5+TILE/3+TILE/4)
local CURV5 = CURVE_BASE_H + math.floor(TILE/1.5+TILE/3+TILE/4+TILE/5)

package.loaded["prefabs/skilltree_wendy"] = nil
local BuildSkillsData = require("prefabs/skilltree_wendy")

local WENDY_SKILL_STRINGS = STRINGS.SKILLTREE.WENDY

local function MakeSisturnLock(extra_data, group_name)
    local lock = {
        desc = STRINGS.SKILLTREE.SISTURN_LOCK_DESC,
        root = true,
        group = "wendy_alliegience",
        tags = {"allegiance", "lock", "wendy_alliegience"},
        lock_open = function(prefabname, activatedskills, readonly)
            return activatedskills and activatedskills["wendy_sisturn_3"] ~= nil
        end,
    }

    if extra_data then
        lock.pos = extra_data.pos
        lock.connects = extra_data.connects
        lock.group = extra_data.group or lock.group
    end

    return lock
end

package.loaded["prefabs/skilltree_wendy"] = function(SkillTreeFns, ...)
    local skills_data = BuildSkillsData(SkillTreeFns, ...)

    skills_data.SKILLS["wendy_shadow_lock_3"] = MakeSisturnLock({ pos = {COL5 + TILEGAP / 2 + 8, A_BASE_H} })
    skills_data.SKILLS["wendy_lunar_lock_3"] = MakeSisturnLock({ pos = {COL5 + TILEGAP / 2 + 8, A_BASE_H + TILEGAP} })

    skills_data.SKILLS["wendy_shadow_1"] = nil
    skills_data.SKILLS["wendy_shadow_2"].locks = {"wendy_shadow_lock_1", "wendy_shadow_lock_2", "wendy_shadow_lock_3"}

    skills_data.SKILLS["wendy_lunar_1"] = nil
    skills_data.SKILLS["wendy_lunar_2"].locks = {"wendy_lunar_lock_1", "wendy_lunar_lock_2", "wendy_lunar_lock_3"}

    return skills_data
end

local BuildAllData = GlassicAPI.UpvalueUtil.GetUpvalue(skilltree_defs.DEBUG_REBUILD, "BuildAllData")
BuildAllData()