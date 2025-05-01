local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("clock", function(self)
    if not TheWorld.ismastersim then
        return
    end
    local OnSetMoonPhase = self.inst:GetEventCallbacks("ms_setmoonphase", TheWorld, "scripts/components/clock.lua")
    local _GetMoonPhase, i = GlassicAPI.UpvalueUtil.GetUpvalue(OnSetMoonPhase, "GetMoonPhase")
    local MOON_PHASE_CYCLES = GlassicAPI.UpvalueUtil.GetUpvalue(_GetMoonPhase, "MOON_PHASE_CYCLES")
    local function GetMoonPhase()
        local _mooomphasecycle = GlassicAPI.UpvalueUtil.GetUpvalue(_GetMoonPhase, "_mooomphasecycle")
        local waxing = _mooomphasecycle <= #MOON_PHASE_CYCLES / 2
        return MOON_PHASE_CYCLES[_mooomphasecycle], waxing
    end
    debug.setupvalue(OnSetMoonPhase, i, GetMoonPhase)
end)
