GLOBAL.setfenv(1, GLOBAL)

local Hauntable = require("components/hauntable")

local weed_transform = {
    probability = 1,
    produce = "weed_forgetmelots",
    modifier = "WEED_FORGETMELOTS",
}

local transform_when_haunt = {
    petals_evil = {
        probability = 0.25,
        modifier = function()
            return TheWorld.state.isfullmoon and "EVIL_BLOSSOM" or "EVIL_FORGETMELOTS"
        end,
        produce = function()
            return TheWorld.state.isfullmoon and "blossom" or "forgetmelots"
        end
    },
    weed_firenettle = weed_transform,
    weed_tillweed = weed_transform,
    weed_ivy = weed_transform,
    weed_forgetmelots = weed_transform,
}

local function DoChangePrefab(inst, newprefab, haunter, nofx)
    local x, y, z = inst.Transform:GetWorldPosition()
    if not nofx then
        SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
    end
    local new = SpawnPrefab(type(newprefab) == "table" and newprefab[math.random(#newprefab)] or newprefab)
    if new ~= nil then
        new.Transform:SetPosition(x, y, z)
        if new.components.stackable ~= nil and inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
            new.components.stackable:SetStackSize(math.min(new.components.stackable.maxsize, inst.components.stackable:StackSize()))
        end
        if new.components.inventoryitem ~= nil and inst.components.inventoryitem ~= nil then
            new.components.inventoryitem:InheritMoisture(inst.components.inventoryitem:GetMoisture(), inst.components.inventoryitem:IsWet())
        end
        if new.components.perishable ~= nil and inst.components.perishable ~= nil then
            new.components.perishable:SetPercent(inst.components.perishable:GetPercent())
        end
        if new.components.fueled ~= nil and inst.components.fueled ~= nil then
            new.components.fueled:SetPercent(inst.components.fueled:GetPercent())
        end
        if new.components.finiteuses ~= nil and inst.components.finiteuses ~= nil then
            new.components.finiteuses:SetPercent(inst.components.finiteuses:GetPercent())
        end
        local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
        inst:PushEvent("detachchild")
        if home ~= nil and home.components.childspawner ~= nil then
            home.components.childspawner:TakeOwnership(new)
        end
        new:PushEvent("spawnedfromhaunt", { haunter = haunter, oldPrefab = inst })
        inst:PushEvent("despawnedfromhaunt", { haunter = haunter, newPrefab = new })
        inst.persists = false
        inst.entity:Hide()
        inst:DoTaskInTime(0, inst.Remove)
    end
    return new
end

local function LinkPlayerSay(inst, modifier)
    if not inst._playerlink then
        return
    end
    inst._playerlink.components.talker:Say(GetString(inst._playerlink, "ANNOUNCE_ABIGAIL_HAUNT_TRANSFORM", modifier))
end

local _DoHaunt = Hauntable.DoHaunt
function Hauntable:DoHaunt(doer, ...)
    local _HAUNT_CHANCE_ALWAYS = TUNING.HAUNT_CHANCE_ALWAYS
    local _HAUNT_CHANCE_OFTEN = TUNING.HAUNT_CHANCE_OFTEN
    local _HAUNT_CHANCE_HALF = TUNING.HAUNT_CHANCE_HALF
    local _HAUNT_CHANCE_OCCASIONAL = TUNING.HAUNT_CHANCE_OCCASIONAL
    local _HAUNT_CHANCE_RARE = TUNING.HAUNT_CHANCE_RARE
    local _HAUNT_CHANCE_VERYRARE = TUNING.HAUNT_CHANCE_VERYRARE
    local _HAUNT_CHANCE_SUPERRARE = TUNING.HAUNT_CHANCE_SUPERRARE

    if doer and doer.prefab == "abigail" and (not doer:HasTag("shadow_abigail") and not doer:HasTag("gestalt")) then
        TUNING.HAUNT_CHANCE_ALWAYS = 1
        TUNING.HAUNT_CHANCE_OFTEN = 1
        TUNING.HAUNT_CHANCE_HALF = 1
        TUNING.HAUNT_CHANCE_OCCASIONAL = 1
        TUNING.HAUNT_CHANCE_RARE = 0.25
        TUNING.HAUNT_CHANCE_VERYRARE = .005
        TUNING.HAUNT_CHANCE_SUPERRARE = 0.1

        local data = transform_when_haunt[self.inst.prefab]
        if data and math.random() <= data.probability then
            if self.inst.prefab == "weed_forgetmelots" then
                if self.inst.components.growable:GetStage() == 4 then
                    self.inst.components.growable:SetStage(3)
                    LinkPlayerSay(doer, "WEED_FORGETMELOTS_BOLTING")
                end
            else
                local produce = DoChangePrefab(self.inst, FunctionOrValue(data.produce), doer)
                if self.inst.components.growable and produce.components.growable then
                    local num_stage = self.inst.components.growable:GetStage()
                    produce.mature = self.inst.mature
                    produce.components.growable:SetStage(num_stage)
                end

                LinkPlayerSay(doer, FunctionOrValue(data.modifier))
            end
        end
    end

    _DoHaunt(self, doer, ...)

    TUNING.HAUNT_CHANCE_ALWAYS = _HAUNT_CHANCE_ALWAYS
    TUNING.HAUNT_CHANCE_OFTEN = _HAUNT_CHANCE_OFTEN
    TUNING.HAUNT_CHANCE_HALF = _HAUNT_CHANCE_HALF
    TUNING.HAUNT_CHANCE_OCCASIONAL = _HAUNT_CHANCE_OCCASIONAL
    TUNING.HAUNT_CHANCE_RARE = _HAUNT_CHANCE_RARE
    TUNING.HAUNT_CHANCE_VERYRARE = _HAUNT_CHANCE_VERYRARE
    TUNING.HAUNT_CHANCE_SUPERRARE = _HAUNT_CHANCE_SUPERRARE
end
