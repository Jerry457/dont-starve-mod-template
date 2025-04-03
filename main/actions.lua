local AddAction = AddAction
local AddComponentAction = AddComponentAction
local AddStategraphActionHandler = AddStategraphActionHandler
GLOBAL.setfenv(1, GLOBAL)

local HIGH_ACTION_PRIORITY = 10

if not rawget(_G, "HotReloading") then
    local ACTIONS = {
        SUMMON_SMALLGHOST = Action({priority = 1, rmb = true}),
        GRAVE_RELOCATION = Action({priority = 1, rmb = true}),
    }

    for name, action in pairs(ACTIONS) do
        action.id = name
        action.str = STRINGS.ACTIONS[name] or name
        AddAction(action)
    end
end

ACTIONS.SUMMON_SMALLGHOST.fn = function(act)
    local doer, target = act.doer, act.target
    if doer and target then
        return doer.components.smallghost_summoner:Summon(target)
    end
    return false
end

ACTIONS.GRAVE_RELOCATION.fn = function(act)
    local doer, target, invobject = act.doer, act.target, act.invobject
    if invobject and invobject.components.grave_relocation_item then
        invobject.components.grave_relocation_item:Relocation(doer, target)
        return true
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

local _strfn = ACTIONS.DEPLOY.strfn
ACTIONS.DEPLOY.strfn = function(act, ...)
    if act.invobject then
        if act.invobject.prefab == "possessed_ghostflower_mound" then
            return "REINTERMENT"
        elseif act.invobject.prefab == "possessed_ghostflower_gravestone" then
            return "RELOCATION"
        end
    end
    return _strfn(act, ...)
end

AddComponentAction("SCENE", "gravediggable", function(inst, doer, actions, right)
    local skilltreeupdater = (doer and doer.components.skilltreeupdater) or nil

    if right and skilltreeupdater and skilltreeupdater:IsActivated("wendy_smallghost_1") then
        table.insert(actions, ACTIONS.SUMMON_SMALLGHOST)
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

local COMPONENT_ACTIONS = GlassicAPI.UpvalueUtil.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
local SCENE = COMPONENT_ACTIONS.SCENE
local USEITEM = COMPONENT_ACTIONS.USEITEM
local POINT = COMPONENT_ACTIONS.POINT
local EQUIPPED = COMPONENT_ACTIONS.EQUIPPED
local INVENTORY = COMPONENT_ACTIONS.INVENTORY
