require("stategraphs/commonstates")

local actionhandlers =
{
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
	EventHandler("floater_stopfloating", function(inst)
		inst.sg:GoToState("idle")
    end),
    EventHandler("onturnoff", function(inst)
        inst.sg:GoToState("idle")
    end),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
        end,
    },
}

CommonStates.AddWalkStates(states, nil, {
    startwalk = function(inst)
        return inst:GetIdleAnim()
    end,
    walk = function(inst)
        return inst:GetIdleAnim()
    end,
    stopwalk= function(inst)
        return inst:GetIdleAnim()
    end,
})

return StateGraph("moon_tree_blossom_lantern", states, events, "idle", actionhandlers)
