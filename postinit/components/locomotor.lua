GLOBAL.setfenv(1, GLOBAL)

local Locomotor = require("components/locomotor")

local _RecalculateExternalSpeedMultiplier = Locomotor.RecalculateExternalSpeedMultiplier
function Locomotor:RecalculateExternalSpeedMultiplier(sources)
    if self.inst:HasTag("ghostlyelixir_speed") then
        local m = 1
        for source, src_params in pairs(sources) do
            for k, v in pairs(src_params.multipliers) do
                m = m * math.max(1, v)
            end
        end
        return m
    end

    return _RecalculateExternalSpeedMultiplier(self, sources)
end
