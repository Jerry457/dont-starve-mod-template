local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)


AddComponentPostInit("clock", function(self)
    if not TheWorld.ismastersim then
        return
    end
    local OnSetMoonPhase = self.inst:GetEventCallbacks("ms_setmoonphase", TheWorld, "scripts/components/clock.lua")
    local MOON_PHASE_CYCLES = GlassicAPI.UpvalueUtil.GetUpvalue(OnSetMoonPhase, "OnSetMoonPhase.GetMoonPhase.MOON_PHASE_CYCLES")
    local function GetMoonPhase()
        local _mooomphasecycle = GlassicAPI.UpvalueUtil.GetUpvalue(OnSetMoonPhase, "OnSetMoonPhase.GetMoonPhase._mooomphasecycle")
        local waxing = _mooomphasecycle <= #MOON_PHASE_CYCLES / 2
        return MOON_PHASE_CYCLES[_mooomphasecycle], waxing
    end
    GlassicAPI.UpvalueUtil.SetUpvalue(OnSetMoonPhase, "OnSetMoonPhase.GetMoonPhase", GetMoonPhase)
end)
