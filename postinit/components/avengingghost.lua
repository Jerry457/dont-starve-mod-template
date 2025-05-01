GLOBAL.setfenv(1, GLOBAL)

local AvengingGhost = require("components/avengingghost")
function AvengingGhost:ShouldAvenge()
    return false
end
