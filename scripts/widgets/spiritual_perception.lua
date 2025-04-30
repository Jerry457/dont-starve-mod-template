

local Widget = require("widgets/widget")
local UIAnim = require("widgets/uianim")

local function OnSkillChange(self)
    if self.owner.components.skilltreeupdater and self.owner.components.skilltreeupdater:IsActivated("wendy_avenging_ghost") then
        self:Show()
    else
        self:Hide()
    end
end

local function OnMoonPhaseChanged(self)
    local symbol = "moon_" .. TheWorld.state.moonphase
    print("moon phase changed to " .. symbol)
    local animation
    if TheWorld.state.moonphase == "full" then
        animation = "moon_full"
    elseif TheWorld.state.moonphase == "new" then
        animation = "moon_new"
    elseif TheWorld.state.iswaxingmoon then
        symbol = symbol .. "_waxing"
        animation = "moon_waxing"
    else
        symbol = symbol .. "_waning"
        animation = "moon_waning"
    end
    self.spiritual_perception:GetAnimState():OverrideSymbol("moon_phase", "spiritual_perception_moon_phase", symbol)
    self.spiritual_perception:GetAnimState():PlayAnimation(animation, true)
end

local SpiritualPerception =  Class(Widget, function(self, owner)
    Widget._ctor(self, "SpiritualPerception")
    self.owner = owner

    self.spiritual_perception = self:AddChild(UIAnim())
    self.spiritual_perception:GetAnimState():SetBank("spiritual_perception")
    self.spiritual_perception:GetAnimState():SetBuild("spiritual_perception")

    self._OnSkillChange = function()
        OnSkillChange(self)
    end
    self._OnMoonPhaseChanged = function()
        OnMoonPhaseChanged(self)
    end
    self.inst:ListenForEvent("onactivateskill_client", self._OnSkillChange, owner)
    self.inst:ListenForEvent("ondeactivateskill_client", self._OnSkillChange, owner)
    self.inst:WatchWorldState("moonphase", self._OnMoonPhaseChanged)

    self.inst:DoTaskInTime(0, function ()
        self._OnSkillChange()
        self._OnMoonPhaseChanged()
    end)
end)


return SpiritualPerception
