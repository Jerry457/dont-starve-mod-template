GLOBAL.setfenv(1, GLOBAL)

local skilltree_defs = require("prefabs/skilltree_defs")


local skillTreeIconsAtlasLookup = GlassicAPI.UpvalueUtil.GetUpvalue(GetSkilltreeIconAtlas, "skillTreeIconsAtlasLookup")
skillTreeIconsAtlasLookup["wendy_lunar_2.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_shadow_2.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_smallghost_2.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_smallghost_3.tex"] = "images/wendy_skillicons.xml"

skillTreeIconsAtlasLookup["mystical_observation.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_poetry.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["abigail_gardening_notes.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["mourningflower_1.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["mourningflower_2.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["mourningflower_3.tex"] = "images/wendy_skillicons.xml"

skillTreeIconsAtlasLookup["wendy_avenging_ghost.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_gravestone_1.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_makegravemounds.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_ghostflower_butterfly.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_ghostflower_hat.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_ghostflower_grave.tex"] = "images/wendy_skillicons.xml"
skillTreeIconsAtlasLookup["wendy_ghostcommand_3.tex"] = "images/wendy_skillicons.xml"

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

local function debug_enable()
    return true
end

package.loaded["prefabs/skilltree_wendy"] = function(SkillTreeFns, ...)
    local skills_data = BuildSkillsData(SkillTreeFns, ...)

    local wendy_smallghost_2 = skills_data.SKILLS["wendy_smallghost_2"]
    wendy_smallghost_2.onactivate = function(inst, fromload)
        inst:AddTag(UPGRADETYPES.GRAVESTONE.."_upgradeuser")
        inst:AddTag("gravedigger_user")
        inst:AddTag("wendy_smallghost_2")

    end

    wendy_smallghost_2.ondeactivate = function(inst, fromload)
        inst:RemoveTag(UPGRADETYPES.GRAVESTONE.."_upgradeuser")
        inst:RemoveTag("gravedigger_user")
        inst:RemoveTag("wendy_smallghost_2")
    end

    skills_data.SKILLS["wendy_shadow_lock_3"] = MakeSisturnLock({ pos = { -13, 40 } })
    skills_data.SKILLS["wendy_lunar_lock_3"] = MakeSisturnLock({ pos = { -13, 78 } })

    skills_data.SKILLS["wendy_shadow_1"] = nil
    skills_data.SKILLS["wendy_shadow_2"].locks = {"wendy_shadow_lock_1", "wendy_shadow_lock_2", "wendy_shadow_lock_3"}

    skills_data.SKILLS["wendy_shadow_2"].onactivate = function(inst, fromload)
        inst:AddTag("player_shadow_aligned")

        local addresists = function(pref)
            local damagetyperesist = pref.components.damagetyperesist
            if damagetyperesist then
                damagetyperesist:AddResist("shadow_aligned", pref, TUNING.SKILLS.WENDY.ALLEGIANCE_SHADOW_RESIST, "allegiance_shadow")
            end
            local damagetypebonus = pref.components.damagetypebonus
            if damagetypebonus then
                damagetypebonus:AddBonus("lunar_aligned", pref, TUNING.SKILLS.WENDY.ALLEGIANCE_VS_LUNAR_BONUS, "allegiance_shadow")
            end
        end

        addresists(inst)
        if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
            inst.components.ghostlybond.ghost:AddTag("shadow_aligned")
            addresists(inst.components.ghostlybond.ghost)
            inst.components.ghostlybond.ghost.components.planardefense:SetBaseDefense(TUNING.SKILLS.WENDY.GHOST_PLANARDEFENSE)
        end
    end

    skills_data.SKILLS["wendy_shadow_2"].ondeactivate = function(inst, fromload)
        inst:RemoveTag("player_shadow_aligned")

        local removeresist = function(pref)
            local damagetyperesist = pref.components.damagetyperesist
            if damagetyperesist then
                damagetyperesist:RemoveResist("shadow_aligned", pref, "allegiance_shadow")
            end
            local damagetypebonus = pref.components.damagetypebonus
            if damagetypebonus then
                damagetypebonus:RemoveBonus("lunar_aligned", pref, "allegiance_shadow")
            end
        end
        removeresist(inst)
        if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
            inst.components.ghostlybond.ghost:RemoveTag("shadow_aligned")
            removeresist(inst.components.ghostlybond.ghost)
            inst.components.ghostlybond.ghost.components.planardefense:SetBaseDefense(0)
        end
    end

    skills_data.SKILLS["wendy_lunar_1"] = nil
    skills_data.SKILLS["wendy_lunar_2"].locks = {"wendy_lunar_lock_1", "wendy_lunar_lock_2", "wendy_lunar_lock_3"}

    skills_data.SKILLS["wendy_lunar_2"].onactivate = function(inst, fromload)
        inst:AddTag("player_lunar_aligned")

        local addresists = function(pref)
            local damagetyperesist = pref.components.damagetyperesist
            if damagetyperesist then
                damagetyperesist:AddResist("lunar_aligned", pref, TUNING.SKILLS.WENDY.ALLEGIANCE_LUNAR_RESIST, "allegiance_lunar")
            end
            local damagetypebonus = pref.components.damagetypebonus
            if damagetypebonus then
                damagetypebonus:AddBonus("shadow_aligned", pref, TUNING.SKILLS.WENDY.ALLEGIANCE_VS_SHADOW_BONUS, "allegiance_lunar")
            end
        end

        addresists(inst)
        if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
            inst.components.ghostlybond.ghost:AddTag("lunar_aligned")
            addresists(inst.components.ghostlybond.ghost)
            inst.components.ghostlybond.ghost.components.planardefense:SetBaseDefense(TUNING.SKILLS.WENDY.GHOST_PLANARDEFENSE)
        end
    end

    skills_data.SKILLS["wendy_lunar_2"].ondeactivate = function(inst, fromload)
        inst:RemoveTag("player_lunar_aligned")

        local removeresist = function(pref)
            local damagetyperesist = pref.components.damagetyperesist
            if damagetyperesist then
                damagetyperesist:RemoveResist("lunar_aligned", pref, "allegiance_lunar")
            end
            local damagetypebonus = pref.components.damagetypebonus
            if damagetypebonus then
                damagetypebonus:RemoveBonus("shadow_aligned", pref, "allegiance_lunar")
            end
        end
        removeresist(inst)
        if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
            inst.components.ghostlybond.ghost:RemoveTag("lunar_aligned")
            removeresist(inst.components.ghostlybond.ghost)
            inst.components.ghostlybond.ghost.components.planardefense:SetBaseDefense(0)
        end
    end

    skills_data.SKILLS["wendy_lunar_lock_1"].lock_open = debug_enable
    skills_data.SKILLS["wendy_lunar_lock_2"].lock_open = debug_enable

    skills_data.SKILLS["wendy_shadow_lock_1"].lock_open = debug_enable
    skills_data.SKILLS["wendy_shadow_lock_2"].lock_open = debug_enable

    return skills_data
end

local BuildAllData = GlassicAPI.UpvalueUtil.GetUpvalue(skilltree_defs.DEBUG_REBUILD, "BuildAllData")
BuildAllData()
