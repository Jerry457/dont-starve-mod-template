GLOBAL.setfenv(1, GLOBAL)

local Burnable = require("components/burnable")

local MUST_TAGS = { "gravestone_shade" }

local StartWildfire = Burnable.StartWildfire
function Burnable:StartWildfire(...)
    if FindClosestEntity(self.inst, 6, nil, MUST_TAGS) then
        return
    end

    return StartWildfire(self, ...)
end
