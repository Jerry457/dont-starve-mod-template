local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
    ActionHandler(ACTIONS.SPIRITUALISM, "dolongaction"),
    ActionHandler(ACTIONS.GRAVE_RELOCATION, "dolongaction"),
    ActionHandler(ACTIONS.PRESENT, "give"),
}

local states = {
    State{
        name = "player_prayonly",
        tags = { "doing", "busy", "nodangle", "keep_pocket_rummage", "slowaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("player_prayonly_loop")
            inst.AnimState:PushAnimation("player_prayonly_pst")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
end

AddStategraphPostInit("wilson", function(sg)
end)
