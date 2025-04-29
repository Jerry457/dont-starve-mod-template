require "behaviours/wander"

local WANDER_TIMES = {minwalktime=1, randwalktime=0.25, minwaittime=0.0, randwaittime=0.0}

local function getdirectionFn(inst)
	local r = math.random() * 2 - 1
	return (inst.Transform:GetRotation() + r*r*r * 40) * DEGREES
end

local function ShouldMove(inst)
    if inst.honor_the_memory then
        return TheWorld.Map:IsOceanAtPoint(inst.Transform:GetWorldPosition())
    end
end

local MoonTreeBlossomLanternBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MoonTreeBlossomLanternBrain:OnStart()
    local root = PriorityNode(
    {
		WhileNode(function() return ShouldMove(self.inst) end, "ShouldMove",
            Wander(self.inst, function()
                if self.inst.honor_the_memory then
                    return self.inst.components.knownlocations:GetLocation("home")
                end
            end, TUNING.MINIBOATLANTERN_WANDER_DIST, WANDER_TIMES, getdirectionFn)
        ),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return MoonTreeBlossomLanternBrain
