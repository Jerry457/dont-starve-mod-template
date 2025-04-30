local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("nightmareclock", function(self)
    if not TheWorld.ismastersim then
        return
    end
    local OnLockNightmarePhase = self.inst:GetEventCallbacks("ms_locknightmarephase", TheWorld, "scripts/components/nightmareclock.lua")

    function self:GetLockNightmarePhase()
        return GlassicAPI.UpvalueUtil.GetUpvalue(OnLockNightmarePhase, "_lockedphase")
    end
end)
