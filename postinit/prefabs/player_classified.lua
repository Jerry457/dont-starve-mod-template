local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnSisturnperishChange(parent, data)
    parent.player_classified.sisturnperish:set(data.percent)
    parent.player_classified.sisturnstate:set(data.state)
end

local function OnMourningFlowerPercentChange(parent, data)
    parent.player_classified.mourningflowerpercent:set(data.percent)
    parent.player_classified.mourningflowerlight:set(data.light)
end

local function OnSisturnPerishDirty(inst)
    if inst._parent then
        inst._parent:PushEvent("sisturnperishchange", { percent = inst.sisturnperish:value(), state = inst.sisturnstate:value() })
    end
end

local function OnMourningFlowerPercentDirty(inst)
    if inst._parent then
        inst._parent:PushEvent("mourningflowerpercentchange", {
            percent = inst.mourningflowerpercent:value(),
            light = inst.mourningflowerlight:value()
        })
    end
end

local function OnLockNightmarePhaseChange(inst, phase)
    phase = phase and phase or ""
    local atrium_gate = TheSim:FindFirstEntityWithTag("stargate")
    if phase ~= "" and atrium_gate and atrium_gate.components.charliecutscene and atrium_gate.components.charliecutscene:IsGateRepaired() then
        phase = phase .. "_repaired"
    end
    inst.locknightmarephase:set_local(phase)
    inst.locknightmarephase:set(phase)
end

local function OnLockNightmarePhaseDirty(inst)
    inst._parent:PushEvent("locknightmarephasechange", inst.locknightmarephase:value())
end

local function OnSpiritualPerceptionChange(player)
    local skilltreeupdater = player.components.skilltreeupdater
    local watcher = TheWorld:HasTag("cave") and TheSim:FindFirstEntityWithTag("gazing_shadow") or TheSim:FindFirstEntityWithTag("moondial")
    local shown = watcher ~= nil and skilltreeupdater ~= nil and skilltreeupdater:IsActivated("wendy_avenging_ghost")
    player.player_classified.spiritualperception:set(shown)
end

local function OnSpiritualPerceptionDirty(inst)
    inst._parent:PushEvent("spiritualperceptionshowchange", inst.spiritualperception:value())
end

local function RegisterNetListeners(inst)
    if TheWorld.ismastersim then
        inst._parent = inst.entity:GetParent()
        inst:ListenForEvent("sisturnperishchange", OnSisturnperishChange, inst._parent)
        inst:ListenForEvent("mourningflowerpercentchange", OnMourningFlowerPercentChange, inst._parent)
        inst:ListenForEvent("ms_locknightmarephase", function(src, phase)
            OnLockNightmarePhaseChange(inst, phase)
        end, TheWorld)
        if TheWorld.net.components.nightmareclock then
            OnLockNightmarePhaseChange(inst, TheWorld.net.components.nightmareclock:GetLockNightmarePhase())
        end
        inst:ListenForEvent("spiritualperceptionchange", function(src, ent)
            OnSpiritualPerceptionChange(inst._parent)
        end, TheWorld)
        inst:ListenForEvent("onactivateskill_server", OnSpiritualPerceptionChange, inst._parent)
        inst:ListenForEvent("ondeactivateskill_server", OnSpiritualPerceptionChange, inst._parent)
        OnSpiritualPerceptionChange(inst._parent)

    else
        inst:ListenForEvent("sisturnperishdirty", OnSisturnPerishDirty)
        inst:ListenForEvent("mourningflowerpercentdirty", OnMourningFlowerPercentDirty)
    end

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("locknightmarephasedirty", OnLockNightmarePhaseDirty)
        inst:ListenForEvent("spiritualperceptiondirty", OnSpiritualPerceptionDirty)
    end
end

AddPrefabPostInit("player_classified", function(inst)
    inst.sisturnstate = net_string(inst.GUID, "sisturn.state", "sisturnperishdirty")
    inst.sisturnperish = net_float(inst.GUID, "sisturn.perish", "sisturnperishdirty")
    inst.locknightmarephase = net_string(inst.GUID, "lock.nightmarephase", "locknightmarephasedirty")
    inst.spiritualperception = net_bool(inst.GUID, "spiritual.perception", "spiritualperceptiondirty")

    inst.mourningflowerpercent = net_float(inst.GUID, "mourningflower.perish", "mourningflowerpercentdirty")
    inst.mourningflowerlight = net_bool(inst.GUID, "mourningflower.light", "mourningflowerpercentdirty")

    inst.spiritualperception:set(false)
    inst.locknightmarephase:set("")
    inst.sisturnstate:set("NORMAL")
    inst.sisturnperish:set(0)
    inst.mourningflowerpercent:set(0)
    inst.mourningflowerlight:set(true)

    inst:DoTaskInTime(0, RegisterNetListeners)
end)
