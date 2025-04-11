GLOBAL.setfenv(1, GLOBAL)


local Stunnable = require("components/stunnable")

function Stunnable:TakeDamage(damage)
    if GetTime() < self.valid_stun_time then return end

    self.damage[GetTime()] = (self.damage[GetTime()] or 0) + math.abs(damage)

    if self:GetDamageInPeriod() > self.stun_threshold then
        self:Stun()
    end
end
