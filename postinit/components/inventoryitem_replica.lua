GLOBAL.setfenv(1, GLOBAL)

local InventoryItem = require("components/inventoryitem_replica")

local _GetWalkSpeedMult = InventoryItem.GetWalkSpeedMult
function InventoryItem:GetWalkSpeedMult(...)
    local speed = _GetWalkSpeedMult(self, ...)

    local owner = self.owner
    if speed < 1 and owner and owner:HasTag("ghostlyelixir_speed") then
        speed = math.min(1, speed)
    end

    return speed
end
