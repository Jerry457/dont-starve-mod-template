local AddStategraphEvent = AddStategraphEvent
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local events = {
    EventHandler("flicker", function(inst)
        if not (inst.components.health:IsDead() or inst.sg:HasStateTag("dissipate")) and not inst.sg:HasStateTag("nointerrupt") and not inst.sg:HasStateTag("swoop") and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("idle_abigail_flicker")
        end
    end),
}

local states = {
    State{
        name = "idle_abigail_flicker",
        tags = { "idle", "canrotate", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_abigail_flicker")
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
    }
}

for _, state in ipairs(states) do
    AddStategraphState("abigail", state)
end

for _, event in ipairs(events) do
    AddStategraphEvent("abigail", event)
end

AddStategraphPostInit("abigail", function(sg)
end)
