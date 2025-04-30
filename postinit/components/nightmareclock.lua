local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local PHASE_NAMES =
{
    "calm",
    "warn",
    "wild",
    "dawn",
}

AddComponentPostInit("nightmareclock", function(self)
    if not TheWorld.ismastersim then
        return
    end
    local OnLockNightmarePhase = self.inst:GetEventCallbacks("ms_locknightmarephase", TheWorld, "scripts/components/nightmareclock.lua")

    function self:GetLockNightmarePhase()
        local _lockedphase = GlassicAPI.UpvalueUtil.GetUpvalue(OnLockNightmarePhase, "_lockedphase")
        return _lockedphase and PHASE_NAMES[_lockedphase] or nil
    end
end)
