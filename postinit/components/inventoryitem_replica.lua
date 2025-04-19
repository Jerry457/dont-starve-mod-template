GLOBAL.setfenv(1, GLOBAL)

local InventoryItem = require("components/inventoryitem_replica")

local _GetWalkSpeedMult = InventoryItem.GetWalkSpeedMult
function InventoryItem:GetWalkSpeedMult(...)
    local speed_mult = _GetWalkSpeedMult(self, ...)

    local owner = self.owner
    if speed_mult < 1 and ThePlayer and self:IsGrandOwner(ThePlayer) and ThePlayer:HasTag("ghostlyelixir_speed") then
        speed_mult = math.min(1, speed_mult)
    end

    return speed_mult
end
