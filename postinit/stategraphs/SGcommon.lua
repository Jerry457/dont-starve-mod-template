
env.SG_COMMON = env.SG_COMMON or {}

local SG_COMMON = SG_COMMON
local AddStategraphActionHandler = AddStategraphActionHandler
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
    ActionHandler(ACTIONS.SPIRITUALISM, "dolongaction"),
    ActionHandler(ACTIONS.GRAVE_RELOCATION, "dolongaction"),
    ActionHandler(ACTIONS.PRESENT, "give"),
}

local states = {
    State{
        name = "player_pray",
        tags = { "doing", "busy", "player_pray" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("player_pray_pre")
            inst.AnimState:PushAnimation("player_pray_loop", false)
            inst.AnimState:PushAnimation("player_pray_pst", false)
        end,

        timeline =
        {
            TimeEvent(50 * FRAMES, function(inst)
                if TheWorld.ismastersim then
                    inst:PerformBufferedAction()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
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
    local _upgrade_actionhandler_deststate = sg.actionhandlers[ACTIONS.UPGRADE].deststate
    sg.actionhandlers[ACTIONS.UPGRADE].deststate = function(inst, act, ...)
        if act.invobject:HasTag(UPGRADETYPES.GRAVESTONE .. "_upgrader") then
            return "player_pray"
        end
        return _upgrade_actionhandler_deststate(inst, act, ...)
    end
end

AddStategraphPostInit("wilson", SGwilson)
AddStategraphPostInit("wilson_client", SGwilson)
