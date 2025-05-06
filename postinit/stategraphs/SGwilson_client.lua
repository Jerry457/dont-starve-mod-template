local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
}

local TIMEOUT = 2

local states = {
    State{
        name = "player_pray_handonly",
        tags = { "doing", "busy", "player_pray_handonly" },
        server_states = { "player_pray_handonly" },

        onenter = function(inst)
            inst:PerformPreviewBufferedAction()
            inst.AnimState:SetDeltaTimeMultiplier(1.5)
            inst.AnimState:PlayAnimation("player_pray_handonly")
        end,

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

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
        name = "honor_the_memory_pre",
        tags = { "doing", "busy", "honor_the_memory" },
        server_states = { "honor_the_memory_pre" },

        onenter = function(inst)
            inst:PerformPreviewBufferedAction()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("player_prayonly_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("honor_the_memory_loop")
                end
            end),
        },
    },
    State{
        name = "honor_the_memory_loop",
        tags = { "doing", "busy", "honor_the_memory" },
        server_states = { "honor_the_memory_loop" },
        onenter = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(2)
            inst.AnimState:PushAnimation("player_prayonly_loop", false)
        end,
        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("honor_the_memory_pst")
                end
            end),
        },
    },
    State{
        name = "honor_the_memory_pst",
        tags = { "doing", "busy", "honor_the_memory" },
        server_states = { "honor_the_memory_pst" },
        onenter = function(inst)
            inst.AnimState:PushAnimation("player_prayonly_pst", false)
        end,
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
        name = "wendy_channel_no",
        tags = { "doing", "busy", "wendy_channel_no" },
        server_states = { "wendy_channel_no" },

        onenter = function(inst)
            inst:PerformPreviewBufferedAction()
            inst.components.locomotor:Stop()
            inst.AnimState:AddOverrideBuild("wendy_channel_no")
            inst.AnimState:SetSymbolBloom("flower_glow_green")
            inst.AnimState:PlayAnimation("wendy_channel_no")
        end,
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
        name = "player_prayonly_pre",
        tags = { "doing", "busy", "player_prayonly" },
        server_states = { "player_prayonly_pre" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("player_prayonly_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("player_prayonly_loop")
                end
            end),
        },
    },
    State{
        name = "player_prayonly_loop",
        tags = { "player_prayonly" },
        server_states = { "player_prayonly_loop" },
        onenter = function(inst)
            local bufferedaction = inst:GetBufferedAction()
            inst.sg.statemem.loop = bufferedaction and bufferedaction.action and bufferedaction.action == ACTIONS.CONFIDE
            inst:PerformPreviewBufferedAction()
            inst.AnimState:SetDeltaTimeMultiplier(2)
            inst.AnimState:PushAnimation("player_prayonly_loop", inst.sg.statemem.loop)
        end,
        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and not inst.sg.statemem.loop then
                    inst.sg:GoToState("player_prayonly_pst")
                end
            end),
        },
    },
    State{
        name = "player_prayonly_pst",
        tags = { "player_prayonly" },
        server_states = { "player_prayonly_pst" },
        onenter = function(inst)
            inst.AnimState:PushAnimation("player_prayonly_pst", false)
        end,
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
        name = "player_prayonly",
        tags = { "doing", "busy", "player_prayonly" },
        server_states = { "player_prayonly" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("player_prayonly_pre")
            inst.AnimState:PushAnimation("player_prayonly_loop", false)
            inst.AnimState:PushAnimation("player_prayonly_pst", false)

            inst:PerformPreviewBufferedAction()
        end,

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
        server_states = { "player_pray" },

        onenter = function(inst)
            local bufferedaction = inst:GetBufferedAction()
            if bufferedaction and bufferedaction.pos then
                inst:ForceFacePoint(bufferedaction.pos:GetPosition())
            end

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("player_pray_pre")
            inst.AnimState:PushAnimation("player_pray_loop", false)
            inst.AnimState:PushAnimation("player_pray_pst", false)

            inst:PerformPreviewBufferedAction()
        end,

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
        name = "wendy_recall_ghostflower",
        tags = { "doing", "busy", "wendy_recall_ghostflower" },
        server_states = { "wendy_recall_ghostflower" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:AddOverrideBuild("wendy_recall_ghostflower")
            -- inst.AnimState:PlayAnimation("wendy_recall_ghostflower_pre")
            inst.AnimState:PlayAnimation("wendy_recall_ghostflower")
            inst.AnimState:PushAnimation("wendy_recall_ghostflower_pst", false)
            inst:PerformPreviewBufferedAction()
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
    State{
        name = "applyelixir_mourningflower",
        tags = { "busy" },
        server_states = { "applyelixir_mourningflower" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_elixir_pre")
            inst.AnimState:PushAnimation("wendy_elixir_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.invobject ~= nil then
                local elixir_type = buffaction.invobject.elixir_buff_type
                inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs", "ghostly_elixirs_".. elixir_type .."_swap")
            end
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },
}

for _, state in ipairs(states) do
    AddStategraphState("wilson_client", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson_client", actionhandler)
end

AddStategraphPostInit("wilson_client", function(sg)
end)
