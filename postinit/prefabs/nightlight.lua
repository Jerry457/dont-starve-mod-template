local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnRemove(inst)
    TheWorld:DoTaskInTime(0, TheWorld.PushEvent, "spiritualperceptionchange")
end

local NightMarePhaseFire = {
    look_wild = { build = "wild_fire", anim ="level4", sound="dontstarve/common/nightlight", soundintensity = 1.0},
    wild =      { build = "wild_fire", anim ="level3", sound="dontstarve/common/nightlight", soundintensity = 0.6},
    warn =      { build = "wild_fire", anim ="level2", sound="dontstarve/common/nightlight", soundintensity = 0.3},
    dawn =      { build = "calm_fire", anim ="level2", sound="dontstarve/common/nightlight", soundintensity = 0.3},
    calm =      { build = "calm_fire", anim ="level1", sound="dontstarve/common/nightlight", soundintensity = 0.1},
}

local function OnNightMarePhaseChange(inst, phase)
    if TheWorld.net.components.nightmareclock and TheWorld.net.components.nightmareclock:GetLockNightmarePhase() == "wild" then
        phase = "look_wild"
    end
    if not phase then
        return
    end

    if not inst.gazing_shadow_fire then
        inst.gazing_shadow_fire = SpawnPrefab("gazing_shadow_fire")
        inst:AddChild(inst.gazing_shadow_fire)
        inst.gazing_shadow_fire.entity:AddFollower()
        inst.gazing_shadow_fire.Follower:FollowSymbol(inst.GUID, "fire_marker")
    end
    local params = NightMarePhaseFire[phase]
    inst.gazing_shadow_fire.AnimState:OverrideSymbol("flames_wide", params.build, "flames_wide")
    inst.gazing_shadow_fire.AnimState:PlayAnimation(params.anim, true)

    inst.SoundEmitter:PlaySound("dontstarve/common/fireBurstLarge")
    inst.gazing_shadow_fire.SoundEmitter:KillSound("fire")
    inst.gazing_shadow_fire.SoundEmitter:PlaySound(params.sound, "fire")
    inst.gazing_shadow_fire.SoundEmitter:SetParameter("fire", "intensity", params.soundintensity)
end

local function ShowGlobalMapIcon(inst)
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon.MiniMapEntity:SetPriority(30)
    inst.icon:TrackEntity(inst)
    -- inst.MiniMapEntity:SetCanUseCache(false)
    -- inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.icon.MiniMapEntity:SetIcon("nightlight_link.tex")
end

local function GazingShadow(inst)
    inst:AddTag("gazing_shadow")
    TheWorld:PushEvent("spiritualperceptionchange")

    inst:ListenForEvent("ms_locknightmarephase", function(inst, phase)
        OnNightMarePhaseChange(inst, phase)
    end, TheWorld)
    inst:WatchWorldState("nightmarephase", OnNightMarePhaseChange)

    local phase = TheWorld.state.nightmarephase
    if TheWorld.net.components.nightmareclock and TheWorld.net.components.nightmareclock:GetLockNightmarePhase() == "wild" then
        phase = "look_wild"
    end
    OnNightMarePhaseChange(inst, phase)

    ShowGlobalMapIcon(inst)
end

AddPrefabPostInit("nightlight", function(inst)
    inst:AddTag("nightlight")

    inst:ListenForEvent("onremove", OnRemove)

    inst.GazingShadow = GazingShadow

    local _OnLoad = inst.OnLoad
    function inst:OnLoad(data, ...)
        if _OnLoad then
            _OnLoad(self, data, ...)
        end
        if data and data.gazing_shadow then
            inst:GazingShadow()
        end
    end

    local _OnSave = inst.OnSave
    function inst:OnSave(data, ...)
        local refs
        if _OnSave then
            refs = _OnSave(inst, data, ...)
        end

        data.gazing_shadow = inst:HasTag("gazing_shadow")

        return refs
    end
end)
