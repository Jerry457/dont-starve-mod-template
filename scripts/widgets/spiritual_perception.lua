

local Widget = require("widgets/widget")
local UIAnim = require("widgets/uianim")

local function OnMoonPhaseChange(self, data)
    local style = data and data.style
    local symbol = "moon_" .. TheWorld.state.moonphase
    local animation
    local fx_animation
    if data then
        self.alter = style == "alter_active" or style == "glassed_alter_active"
    end
    if self.alter then
        animation = "alter"
        fx_animation = "waxing"
    elseif TheWorld.state.moonphase == "full" then
        animation = "moon_full"
        fx_animation = "waxing"
    elseif TheWorld.state.moonphase == "new" then
        animation = "moon_new"
        fx_animation = "waning"
    elseif TheWorld.state.iswaxingmoon then
        symbol = symbol .. "_waxing"
        animation = "moon_waxing"
        fx_animation = "waxing"
    else
        symbol = symbol .. "_waning"
        animation = "moon_waning"
        fx_animation = "waning"
    end
    self:PlayerChangeFx(fx_animation)
    self.inst:DoTaskInTime(15 * FRAMES, function()
        self.spiritual_perception:GetAnimState():OverrideSymbol("moon_phase", "spiritual_perception_moon_phase", symbol)
        self.spiritual_perception:GetAnimState():PlayAnimation(animation, true)
    end)
    self.animation_data = nil
end

local function force_nightmare_wild_anim(inst)
    if math.random(0, 1) <= 0.5 then
        inst.AnimState:PlayAnimation("force_nightmare_wild_idle")
    else
        inst.AnimState:PlayAnimation("force_nightmare_wild_taunt")
    end
end

local function OnNightMarePhaseChange(self)
    if self.lisented then
        self.lisented = false
        self.spiritual_perception.inst:RemoveEventCallback("animover", force_nightmare_wild_anim)
    end

    local animation = "nightmare_" .. TheWorld.state.nightmarephase:gsub("nightmare", "nightmare_")
    local loop = true
    if self.owner.player_classified.locknightmarephase:value() == "wild_repaired" then
        animation = "force_nightmare_wild_idle"
        loop = false
    elseif self.owner.player_classified.locknightmarephase:value() == "wild" then
        animation = "force_nightmare_wild_broken"
    end

    self:PlayerChangeFx("nightmare")
    self.inst:DoTaskInTime(15 * FRAMES, function()
        if animation == "force_nightmare_wild_idle" then
            self.lisented = true
            self.spiritual_perception.inst:ListenForEvent("animover", force_nightmare_wild_anim)
        end
        self.spiritual_perception:GetAnimState():PlayAnimation(animation, loop)
    end)
end

local function OnSpiritualPerceptionShowChange(self, show)
    if show then
        self:Show()
    end

    if self.owner.player_classified then
        if TheWorld:HasTag("cave") then
            OnNightMarePhaseChange(self)
        else
            OnMoonPhaseChange(self, {style = self.alter and "alter_active" or nil})
        end
    end

    self.inst:DoTaskInTime(13 * FRAMES, function()
        if show then
            self.spiritual_perception:Show()
        else
            self.spiritual_perception:Hide()
            self:Hide()
        end
    end)
end

local SpiritualPerception =  Class(Widget, function(self, owner)
    Widget._ctor(self, "SpiritualPerception")
    self.owner = owner

    self.spiritual_perception = self:AddChild(UIAnim())
    self.spiritual_perception:GetAnimState():SetBank("spiritual_perception")
    self.spiritual_perception:GetAnimState():SetBuild("spiritual_perception")

    self.change_fx = self:AddChild(UIAnim())
    self.change_fx:GetAnimState():SetBank("spiritual_perception")
    self.change_fx:GetAnimState():SetBuild("spiritual_perception")

    self._OnNightMarePhaseChange = function()
        OnNightMarePhaseChange(self)
    end
    self._OnMoonPhaseChange = function(src, data)
        OnMoonPhaseChange(self, data)
    end

    if TheWorld:HasTag("cave") then
        self.inst:ListenForEvent("locknightmarephasechange", self._OnNightMarePhaseChange, owner)
        self.inst:WatchWorldState("nightmarephase", self._OnNightMarePhaseChange)
    else
        self.inst:WatchWorldState("moonphase", self._OnMoonPhaseChange)
        self.inst:ListenForEvent("moonphasestylechanged", self._OnMoonPhaseChange, TheWorld)
    end

    self._OnSpiritualPerceptionShowChange = function(_, show)
        self.alter = false
        OnSpiritualPerceptionShowChange(self, show)
    end
    self.inst:ListenForEvent("spiritualperceptionshowchange", self._OnSpiritualPerceptionShowChange, owner)

    self.spiritual_perception:Hide()
    self:Hide()
end)

function SpiritualPerception:PlayerChangeFx(animation)
    self.change_fx:GetAnimState():PlayAnimation(animation)
end

return SpiritualPerception
