local AddStategraphEvent = AddStategraphEvent
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local events = {
    -- EventHandler("flicker", function(inst)
    --     if not (inst.components.health:IsDead() or inst.sg:HasStateTag("dissipate")) and not inst.sg:HasStateTag("nointerrupt") and not inst.sg:HasStateTag("swoop") and not inst.sg:HasStateTag("busy") then
    --         inst.sg:GoToState("idle_abigail_flicker")
    --     end
    -- end),
}

local states = {
    State{
        name = "idle_abigail_flicker",
        tags = { "idle", "canrotate", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_abigail_normal_flicker")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
            EventHandler("startaura", function(inst)
                if not inst:HasTag("gestalt") then
                    inst.sg:GoToState("attack_start")
                end
            end),
        },
    },
}

for _, state in ipairs(states) do
    AddStategraphState("abigail", state)
end

for _, event in ipairs(events) do
    AddStategraphEvent("abigail", event)
end

local function getidleanim(inst)
    if not inst.components.timer:TimerExists("flicker_cooldown")
        and inst:HasTag("player_damagescale")
        and math.random() < 0.2
        and inst.components.combat.target == nil
        and inst.is_defensive
    then
        inst.components.timer:StartTimer("flicker_cooldown", math.random() * 20  + 10)

        if inst:HasTag("gestalt") then
            return "idle_abigail_gestalt_flicker"
        elseif inst:HasTag("shadow_abigail") then
            return "idle_abigail_shadow_flicker"
        else
            return "idle_abigail_normal_flicker"
        end
    end

    return (inst._is_transparent and "abigail_escape_loop")
        or (inst.components.aura.applying and "attack_loop")
        or (inst.is_defensive and math.random() < 0.1 and "idle_custom")
        or "idle"
end

AddStategraphPostInit("abigail", function(sg)
    GlassicAPI.UpvalueUtil.SetUpvalue(sg.states["idle"].onenter, "getidleanim", getidleanim)

    local _abigail_attack_start_onenter = sg.states["abigail_attack_start"].onenter
    sg.states["abigail_attack_start"].onenter = function(inst, pos)
        if pos and inst.shadow_command_attack then
            inst.Transform:SetPosition(pos:Get())
        end
        _abigail_attack_start_onenter(inst, pos)
        inst.fade_toggle:set(true)
        inst.components.health:SetInvincible(true)
    end

    local _abigail_attack_end_onexit = sg.states["abigail_attack_end"].onexit
    sg.states["abigail_attack_end"].onexit = function(inst, ...)
        _abigail_attack_end_onexit(inst, ...)
        inst.fade_toggle:set(false)
        inst.components.health:SetInvincible(false)
    end

    local _gestalt_attack_onenter = sg.states["gestalt_attack"].onenter
    sg.states["gestalt_attack"].onenter = function(inst, pos, ...)
        _gestalt_attack_onenter(inst, pos,...)
        if pos then
            inst.fade_toggle:set(true)
            inst.components.health:SetInvincible(true)
        end
    end

    local _gestalt_pst_attack_onexit = sg.states["gestalt_pst_attack"].onexit
    sg.states["gestalt_pst_attack"].onexit = function(inst, ...)
        if _gestalt_pst_attack_onexit then
            _gestalt_pst_attack_onexit(inst, ...)
        end
        inst.fade_toggle:set(false)
        inst.components.health:SetInvincible(false)
    end

    local _gestalt_loop_attack_onenter = sg.states["gestalt_loop_attack"].onenter
    sg.states["gestalt_loop_attack"].onenter = function(inst, ...)
        HookDebuff(inst, _gestalt_loop_attack_onenter, "ghostlyelixir_attack_buff", inst, ...)
    end

    local _gestalt_loop_homing_attack_onenter = sg.states["gestalt_loop_homing_attack"].onenter
    sg.states["gestalt_loop_homing_attack"].onenter = function(inst, ...)
        HookDebuff(inst, _gestalt_loop_homing_attack_onenter, "ghostlyelixir_attack_buff", inst, ...)
    end
end)
