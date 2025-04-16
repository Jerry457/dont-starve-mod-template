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
