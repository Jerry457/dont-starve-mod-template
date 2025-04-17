
env.SG_COMMON = env.SG_COMMON or {}

local SG_COMMON = SG_COMMON
local AddStategraphActionHandler = AddStategraphActionHandler
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
    ActionHandler(ACTIONS.SPIRITUALISM, "player_prayonly"),
    ActionHandler(ACTIONS.GRAVE_RELOCATION, "wendy_recall_ghostflower"),
    ActionHandler(ACTIONS.PRESENT, "give"),
    ActionHandler(ACTIONS.REGAIN_GLORY, "give"),
    ActionHandler(ACTIONS.BEGIN_AGAIN, "give"),
    ActionHandler(ACTIONS.USE_GHOSTLYELIXIR, "applyelixir_mourningflower"),
}

local states = {

}

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
    AddStategraphActionHandler("wilson_client", actionhandler)
end

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
    AddStategraphState("wilson_client", state)
end

local function SGwilson(sg)
    local _deploy_actionhandler_deststate = sg.actionhandlers[ACTIONS.DEPLOY].deststate
    sg.actionhandlers[ACTIONS.DEPLOY].deststate = function(inst, act, ...)
        if act.invobject and act.invobject:HasTag("possessed_ghostflower") then
            return "wendy_recall_ghostflower"
        end
        return _deploy_actionhandler_deststate(inst, act, ...)
    end

    local _upgrade_actionhandler_deststate = sg.actionhandlers[ACTIONS.UPGRADE].deststate
    sg.actionhandlers[ACTIONS.UPGRADE].deststate = function(inst, act, ...)
        if act.invobject and act.invobject:HasTag(UPGRADETYPES.GRAVESTONE .. "_upgrader") then
            return "player_pray"
        end
        return _upgrade_actionhandler_deststate(inst, act, ...)
    end
end

AddStategraphPostInit("wilson", SGwilson)
AddStategraphPostInit("wilson_client", SGwilson)
