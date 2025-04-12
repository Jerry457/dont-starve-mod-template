local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
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
                inst:PerformBufferedAction()
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

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
end

AddStategraphPostInit("wilson", function(sg)
end)
