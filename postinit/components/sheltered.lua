GLOBAL.setfenv(1, GLOBAL)

local Sheltered = require("components/sheltered")

local MUST_TAGS = { "gravestone_shade" }

local _SetSheltered = Sheltered.SetSheltered
function Sheltered:SetSheltered(issheltered, level, ...)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local _announcecooldown = self.announcecooldown
    if not issheltered or level < 2 then
        local gravestone_shade = TheSim:FindEntities(x, y, z, 6, MUST_TAGS)
        if #gravestone_shade > 0 then
            self.announcecooldown = 10
            issheltered = true
            level = 2
        end
    end
    _SetSheltered(self, issheltered, level, ...)
    self.announcecooldown = _announcecooldown
end
