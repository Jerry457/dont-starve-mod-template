local AddCookerRecipe = AddCookerRecipe
local AddIngredientValues = AddIngredientValues
GLOBAL.setfenv(1, GLOBAL)

local skilltree_defs = require("prefabs/skilltree_defs")

local preparedfoods = require("preparedfoods")
preparedfoods.butterflymuffin.test = function(cooker, names, tags)
    return (names.butterflywings or names.moonbutterflywings or names.fullmoonbutterflywings)
        and not tags.meat
        and tags.veggie and tags.veggie >= 0.5
end

AddIngredientValues({"fullmoonbutterflywings"}, {decoration=2})


local function skill_has_kv(skill_data, k, v)
    if skill_data[k] then
        for _, _v in pairs(skill_data[k]) do
            if _v == v then
                return true
            end
        end
    end
    return false
end

local function sorted_skills(skilldef, skill, skills, has_skill)
    local skills = skills or {}
    local has_skill = has_skill or {}
    if not has_skill[skill] then
        table.insert(skills, skill)
        has_skill[skill] = true
    end

    if skill_has_kv(skilldef[skill], "tags", "lock") then
        for _skill in pairs(skilldef) do
            if skill_has_kv(skilldef[_skill], "locks", skill) then
                sorted_skills(skilldef, _skill, skills, has_skill)
            end
        end
    end
    if skilldef[skill].connects then
        for _, _skill in ipairs(skilldef[skill].connects) do
            sorted_skills(skilldef, _skill, skills, has_skill)
        end
    end

    return skills
end

local function is_allegiance_skill(skill_data)
    return skill_data.root and skill_data.tags and skill_data.tags["allegiance"]
end

local function unlock_branches(skilltreeupdater, branches)
    for _, branche in ipairs(branches) do
        for i = #branche, 1, -1 do
            skilltreeupdater:DeactivateSkill(branche[i])
        end
    end
end

local ws_foods = {
    lethean_cake = {  -- 忘川蛋糕
        test = function(cooker, names, tags)  -- 土豆土豆番茄, 填充物不能是数值冰肉蛋
            return names.forgetmelots and names.forgetmelots > 1
                and (names.berries or names.berries_cooked or names.berries_juicy or names.berries_juicy_cooked)
                and tags.sweetener and tags.sweetener < 2
        end,

        priority = 30,
        foodtype = FOODTYPE.GOODIES,  -- 零食

        hunger = 20,
        sanity = 30,
        health = -3,
        oneatenfn  = function(inst, eater)
            eater.SoundEmitter:PlaySound("wilson_rework/ui/unlock_gatedskill")

            local skilltreeupdater = eater and eater.components.skilltreeupdater
            if not skilltreeupdater then
                return
            end

            local branches = {}
            local skilldef = skilltree_defs.SKILLTREE_DEFS[eater.prefab]
            for skill, data in pairs(skilldef) do
                if data.root and skill_has_kv(data, "tags", "allegiance") then
                    table.insert(branches, sorted_skills(skilldef, skill))
                end
            end
            unlock_branches(skilltreeupdater, branches)
        end,

        -- floater = {nil, 0.1, {0.7, 0.6, 0.7}},  -- 飘浮
        perishtime = TUNING.TOTAL_DAY_TIME * 20,  --腐烂时间

        cooktime = .75,  -- 煮的时间
        potlevel = "high",  -- 在锅的位置
    },
    nightmare_lethean_cake = {  -- 梦魇忘川蛋糕
        test = function(cooker, names, tags)  -- 土豆土豆番茄, 填充物不能是数值冰肉蛋
            return names.forgetmelots and names.forgetmelots > 1
                and (names.nightmarefuel)
                and tags.sweetener and tags.sweetener < 2
        end,

        priority = 30,
        foodtype = FOODTYPE.GOODIES,  -- 零食

        hunger = 20,
        sanity = 0.0000000000000001,
        health = -3,
        oneatenfn = function(inst, eater)
            eater.SoundEmitter:PlaySound("meta4/shadow_merm/buff_pst")
            eater:DoTaskInTime(1,function()
                eater.SoundEmitter:PlaySound("wilson_rework/ui/unlock_gatedskill")
            end)

            local skilltreeupdater = eater and eater.components.skilltreeupdater
            if not skilltreeupdater then
                return
            end

            if not skilltreeupdater:HasActivatedSkill() then
                return
            end

            if eater and eater.components.sanity then
                eater.components.sanity:DoDelta(150)
            end

            local branches = {}
            local skilldef = skilltree_defs.SKILLTREE_DEFS[eater.prefab]
            for skill, data in pairs(skilldef) do
                if data.root then
                    table.insert(branches, sorted_skills(skilldef, skill))
                end
            end
            unlock_branches(skilltreeupdater, branches)
        end,

        -- floater = {nil, 0.1, {0.7, 0.6, 0.7}},  -- 飘浮
        perishtime = TUNING.TOTAL_DAY_TIME * 20,  --腐烂时间

        cooktime = .75,  -- 煮的时间
        potlevel = "high",  -- 在锅的位置
    },
}

for name, data in pairs(ws_foods) do
    data.name = name
    data.weight = data.weight or 1
    data.priority = data.priority or 0

    data.overridebuild = data.overridebuild or name
    data.cookbook_tex = "cookbook_" .. name .. ".tex"
    data.cookbook_atlas = "images/ws_cookbook.xml"

    AddCookerRecipe("cookpot", data)
    AddCookerRecipe("portablecookpot", data)
    AddCookerRecipe("archive_cookpot", data)

    preparedfoods[name] = data
end

GenerateSpicedFoods(ws_foods)  -- 香料
local spicedfoods = require("spicedfoods")
for _, recipe in pairs(spicedfoods) do
    if ws_foods[recipe.basename] then
        AddCookerRecipe("portablespicer", recipe)
    end
end
