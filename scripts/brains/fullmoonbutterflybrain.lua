require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/findflower"
local BrainCommon = require("brains/braincommon")

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 10
local POLLINATE_FLOWER_DIST = 10
local SEE_FLOWER_DIST = 30
local MAX_WANDER_DIST = 20

local FLOWER_TAGS = { "petal", "tree" }

local function NearestFlowerPos(inst)
    FindEntity(inst, SEE_FLOWER_DIST, function(inst)
        if inst.components.perishable and inst.components.perishable:IsPerishing() then
            return false
        end
        return inst.prefab == "moon_tree_blossom" or inst.prefab == "moon_tree"
    end, FLOWER_TAGS)

    local flower = GetClosestInstWithTag(FLOWER_TAGS, inst, SEE_FLOWER_DIST)
    if flower and
       flower:IsValid() then
        return Vector3(flower.Transform:GetWorldPosition() )
    end
end

local function GetHomePos(inst)
    return inst.components.knownlocations:GetLocation("home")
end

local RUN_AWAY_PARAMS =
{
    tags = {"scarytoprey"},
    fn = function(guy)
        return not (guy.components.skilltreeupdater
                and guy.components.skilltreeupdater:IsActivated("wormwood_bugs"))
    end,
}

local ButterflyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function ButterflyBrain:OnStart()
    local root =
        PriorityNode(
        {
			BrainCommon.PanicTrigger(self.inst),
            RunAway(self.inst, RUN_AWAY_PARAMS, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
            Wander(self.inst, GetHomePos, MAX_WANDER_DIST)
        },1)

    self.bt = BT(self.inst, root)
end

function ButterflyBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition(), true)
end

return ButterflyBrain
