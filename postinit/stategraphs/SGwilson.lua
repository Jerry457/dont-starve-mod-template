local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
}

local states = {
    State{
        name = "player_prayonly",
        tags = { "doing", "busy", "player_prayonly" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("player_prayonly_pre")
            inst.AnimState:PushAnimation("player_prayonly_loop", false)
            inst.AnimState:PushAnimation("player_prayonly_pst", false)
        end,

        timeline =
        {
            TimeEvent(100 * FRAMES, function(inst)
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
    },
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
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "wendy_recall_ghostflower",
        tags = { "doing", "busy", "wendy_recall_ghostflower" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:AddOverrideBuild("wendy_recall_ghostflower")
            -- inst.AnimState:PlayAnimation("wendy_recall_ghostflower_pre")
            inst.AnimState:PlayAnimation("wendy_recall_ghostflower")
            inst.AnimState:PushAnimation("wendy_recall_ghostflower_pst", false)
        end,

        timeline =
        {
            TimeEvent(25 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                -- if inst.components.rider:IsRiding() then
                --     inst.sg.statemem.fx = SpawnPrefab("ghostflower_scatter_fx_mount")
                -- else
                    inst.sg.statemem.fx = SpawnPrefab("ghostflower_scatter_fx")
                -- end
                inst.sg.statemem.fx.entity:SetParent(inst.entity)
            end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "applyelixir_mourningflower",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("wendy_elixir_pre")
            inst.AnimState:PushAnimation("wendy_elixir", false)
            inst.SoundEmitter:PlaySound("meta5/wendy/pour_elixir_f17")

            inst.sg.statemem.action = inst:GetBufferedAction()

            if inst.sg.statemem.action ~= nil then
                local invobject = inst.sg.statemem.action.invobject
                local elixir_type = invobject.elixir_buff_type

                inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs", "ghostly_elixirs_".. elixir_type .."_swap")
                inst.AnimState:OverrideSymbol("flower", "mourningflower", "flower")
            end

            inst.sg:SetTimeout(50 * FRAMES)
        end,

        timeline =
        {
            FrameEvent(4, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            FrameEvent(19, function(inst)
                if not inst:PerformBufferedAction() then
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
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
