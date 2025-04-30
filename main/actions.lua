local AddAction = AddAction
local AddComponentAction = AddComponentAction
local AddStategraphActionHandler = AddStategraphActionHandler
GLOBAL.setfenv(1, GLOBAL)

local HIGH_ACTION_PRIORITY = 10

if not rawget(_G, "HotReloading") then
    local ACTIONS = {
        SPIRITUALISM = Action({priority = 1, distance = 1.5, rmb = true}),
        GRAVE_RELOCATION = Action({priority = 1, distance = 16, rmb = true}),
        PRESENT = Action({priority = 1}),
        REGAIN_GLORY = Action({priority = 1, rmb = true}),
        USE_GHOSTLYELIXIR = Action({priority = 1, rmb = true}),
        BEGIN_AGAIN = Action({priority = 1, rmb = true}),
        CONFIDE = Action({priority = 1, distance = 1.5, rmb = true}),
        HONOR_THE_MEMORY = Action({priority = 1, rmb = true, distance = 20}),
        PYROPHASIC_TRANSITUS = Action({priority = 1, rmb = true, distance = 20}),
        WAX_REPLENISHMENT = Action({priority = 1, rmb = true, distance = 20}),
        GAZE_SHADOW = Action({priority = 1, mount_valid=true, canforce=true, }),
    }

    for name, action in pairs(ACTIONS) do
        action.id = name
        action.str = STRINGS.ACTIONS[name] or name
        AddAction(action)
    end
end

-- local ExtraDeployDist = ACTIONS.DEPLOY.extra_arrive_dist
-- ACTIONS.DEPLOY.extra_arrive_dist = function(doer, dest, bufferedaction, ...)
--     local invobject = bufferedaction and bufferedaction.invobject or nil
--     if invobject and invobject:HasTag("possessed_ghostflower") then
--         return 16 - ACTIONS.DEPLOY.distance or 0
--     end
--     return ExtraDeployDist and ExtraDeployDist(doer, dest, bufferedaction, ...) or 0
-- end

ACTIONS.UPGRADE.distance = 1.5

ACTIONS.SPIRITUALISM.fn = function(act)
    local doer, target = act.doer, act.target
    if doer and target then
        return doer.components.spiritualism:Summon(target)
    end
    return false
end

ACTIONS.HONOR_THE_MEMORY.fn = function(act)
    if act.target and not act.target:HasTag("honor_the_memory") then
        SpawnPrefab("attune_out_fx").Transform:SetPosition(act.target.Transform:GetWorldPosition())
        act.target:AddTag("honor_the_memory")
    end
    return true
end

ACTIONS.PYROPHASIC_TRANSITUS.fn = function(act)
    local target, invobject = act.target, act.invobject
    if target and target.SetState then
        local map = {
            petals = "petals",
            petals_evil = "evil",
            moon_tree_blossom = "moon",
        }
        target:SetState(map[invobject.prefab])
        WS_UTIL.RemoveOneItem(invobject)
    end
    return true
end

ACTIONS.WAX_REPLENISHMENT.fn = function(act)
    local target, invobject = act.target, act.invobject
    if target and target.WaxReplenishment then
        target:WaxReplenishment()
        WS_UTIL.RemoveOneItem(invobject)
    end
    return true
end

ACTIONS.GRAVE_RELOCATION.fn = function(act)
    local doer, target, invobject = act.doer, act.target, act.invobject
    if invobject and invobject.components.grave_relocation_item then
        invobject.components.grave_relocation_item:Relocation(doer, target, invobject)
        return true
    end
end

ACTIONS.USE_GHOSTLYELIXIR.fn = function(act)
    if act.invobject and act.invobject.components.ghostlyelixir then
        return act.invobject.components.ghostlyelixir:Apply(act.doer, act.doer)
    end
end

ACTIONS.GRAVE_RELOCATION.strfn = function(act)
    local target = act.target
    local str = "GENERIC"
    if target then
        if target:HasTag("skeleton") then
            return "ENCOFFIN"
        elseif target.prefab == "mound" then
            return "REINTERMENT"
        -- elseif target.prefab == "gravestone" then
        --     return "GENERIC"
        end
    end

    return str
end

ACTIONS.PRESENT.fn = function(act)
    local doer, target, invobject = act.doer, act.target, act.invobject
    if target and target.AcceptTest then
        return target:AcceptTest(invobject)
    end
end

ACTIONS.REGAIN_GLORY.fn = function(act)
    if act.target and act.target.components.regainglory then
        local success, message = act.target.components.regainglory:Regrow(act.doer)
        if success then
            WS_UTIL.RemoveOneItem(act.invobject)
        end
        return success, message
    else
        return false, "INVALID"
    end
end

ACTIONS.BEGIN_AGAIN.fn = function(act)
    if act.doer.components.begin_again then
        local success, message = act.doer.components.begin_again:ApplyElixirBuff()
        if success then
            WS_UTIL.RemoveOneItem(act.invobject)
        end
        return success, message
    end
end

ACTIONS.CONFIDE.fn = function(act)
    local doer, target, invobject = act.doer, act.target, act.invobject
    if doer then
        if doer.components.talker then
            doer.components.talker:Say(GetString(doer, "ANNOUNCE_CONFIDE"), false, true)
        end
        if invobject and invobject.components.stackable then
            local stacksize = invobject.components.stackable:StackSize()
            local num = math.floor(stacksize / 2)
            if num > 0 then
                invobject.components.stackable:Get(num * 2):Remove()
                local mourningflower = SpawnPrefab("mourningflower")
                mourningflower.components.stackable:SetStackSize(num)
                doer.components.inventory:GiveItem(mourningflower)
            end
        end
    end
    return true
end

ACTIONS.GAZE_SHADOW.fn = function(act)
    local target, invobject = act.target, act.invobject
    if target and invobject then
        target:GazingShadow()
        WS_UTIL.RemoveOneItem(invobject)
        return true
    end
end

local DEPLOY_strfn = ACTIONS.DEPLOY.strfn
ACTIONS.DEPLOY.strfn = function(act, ...)
    if act.invobject then
        if act.invobject.prefab == "possessed_ghostflower_mound" then
            return "REINTERMENT"
        elseif act.invobject.prefab == "possessed_ghostflower_gravestone" then
            return "RELOCATION"
        end
    end
    return DEPLOY_strfn(act, ...)
end

local UPGRADE_strfn = ACTIONS.UPGRADE.strfn
ACTIONS.UPGRADE.strfn = function(act, ...)
    if act.invobject and act.invobject:HasTag(UPGRADETYPES.GRAVESTONE .. "_upgrader") then
        return "CONDOLENCE_BOUQUET"
    end
    return UPGRADE_strfn(act, ...)
end

AddComponentAction("SCENE", "gravediggable", function(inst, doer, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil
    if right and skilltreeupdater and skilltreeupdater:IsActivated("wendy_smallghost_1") then
        table.insert(actions, ACTIONS.SPIRITUALISM)
    end
end)

AddComponentAction("SCENE", "knownlocations", function(inst, doer, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil
    if right and skilltreeupdater:IsActivated("wendy_smallghost_2") and inst and inst:HasTag("moon_tree_blossom_lantern") and not inst:HasTag("honor_the_memory") then
        if TheWorld.Map:IsOceanAtPoint(inst.Transform:GetWorldPosition()) then
            table.insert(actions, ACTIONS.HONOR_THE_MEMORY)
        end
    end
end)

AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil
    if right and skilltreeupdater then
        if skilltreeupdater:IsActivated("wendy_ghostflower_butterfly") and inst:HasTag("ghostflower") and target and target:HasTag("active_sisturn") then
            table.insert(actions, ACTIONS.CONFIDE)
        elseif skilltreeupdater:IsActivated("wendy_smallghost_2") and target and target:HasTag("moon_tree_blossom_lantern") then
            if inst:HasTag("petal") then
                table.insert(actions, ACTIONS.PYROPHASIC_TRANSITUS)
            elseif inst:HasTag("ghostflower") then
                table.insert(actions, ACTIONS.WAX_REPLENISHMENT)
            end
        elseif skilltreeupdater:IsActivated("wendy_avenging_ghost") and inst.prefab == "nightmare_timepiece"
            and TheWorld:HasTag("cave")
            and target and target:HasTag("nightlight") and not target:HasTag("gazing_shadow") then
            table.insert(actions, ACTIONS.GAZE_SHADOW)
        end
    end
end)

AddComponentAction("USEITEM", "grave_relocation_item", function(inst, doer, target, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil

    if right and skilltreeupdater and skilltreeupdater:IsActivated("wendy_smallghost_2") then
        if target:HasTag("grave_relocation") and not target:HasTag("has_gravestone") then
            table.insert(actions, ACTIONS.GRAVE_RELOCATION)
        end
    end
end)

AddComponentAction("USEITEM", "graveguard_ghost_item", function(inst, doer, target, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil

    if right and skilltreeupdater and skilltreeupdater:IsActivated("wendy_smallghost_2") then
        if target:HasTag("graveghost") then
            table.insert(actions, ACTIONS.PRESENT)
        end
    end
end)

AddComponentAction("USEITEM", "mourningflower", function(inst, doer, target, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil
    if right and target and target:HasTag("regainglory") and skilltreeupdater and skilltreeupdater:IsActivated("wendy_ghostflower_butterfly") then
        table.insert(actions, ACTIONS.REGAIN_GLORY)
    end
end)

AddComponentAction("USEITEM", "ghostlyelixir", function(inst, doer, target, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil
    if right and skilltreeupdater and skilltreeupdater:IsActivated("wendy_ghostflower_hat") and target and target:HasTag("mourningflower") and right then
        table.insert(actions, ACTIONS.USE_GHOSTLYELIXIR)
    end
end)

AddComponentAction("INVENTORY", "mourningflower", function(inst, doer, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil
    if skilltreeupdater and skilltreeupdater:IsActivated("wendy_ghostflower_grave") then
        table.insert(actions, ACTIONS.BEGIN_AGAIN)
    end
end)

local COMPONENT_ACTIONS = GlassicAPI.UpvalueUtil.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
local SCENE = COMPONENT_ACTIONS.SCENE
local USEITEM = COMPONENT_ACTIONS.USEITEM
local POINT = COMPONENT_ACTIONS.POINT
local EQUIPPED = COMPONENT_ACTIONS.EQUIPPED
local INVENTORY = COMPONENT_ACTIONS.INVENTORY

local _SCENE_attunable = SCENE.attunable
SCENE.attunable = function(inst, ...)
    if inst.prefab == "sisturn" then
        return
    end
    return _SCENE_attunable(inst, ...)
end

local _SCENE_ghostgestalter = SCENE.ghostgestalter
SCENE.ghostgestalter = function(...)
    return HookSkillTreeUpdaterIsActivated("wendy_lunar_3", "", _SCENE_ghostgestalter, ...)
end
