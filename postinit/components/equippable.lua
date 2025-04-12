GLOBAL.setfenv(1, GLOBAL)

local Equippable = require("components/equippable")

local _GetWalkSpeedMult = Equippable.GetWalkSpeedMult
function Equippable:GetWalkSpeedMult(...)
    local speed = _GetWalkSpeedMult(self, ...)

    local owner = self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner
    if speed < 1 and self.isequipped and owner and owner:HasTag("ghostlyelixir_speed") then
        speed = math.min(1, speed)
    end

    return speed
end
