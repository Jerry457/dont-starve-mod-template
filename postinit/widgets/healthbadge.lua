local AddClassPostConstruct = AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

local UIAnim = require("widgets/uianim")
local Widget = require("widgets/widget")

local HealthBadge = require("widgets/healthbadge")

AddClassPostConstruct("widgets/healthbadge", function(self)
    self.underNumbernew = self:AddChild(Widget("underNumbernew"))
    if self.bufficon then
        self.bufficon:Kill()
        self.bufficon = self.underNumbernew:AddChild(UIAnim())
        self.bufficon:GetAnimState():SetBank("status_abigail")
        self.bufficon:GetAnimState():SetBuild("status_abigail")
        self.bufficon:GetAnimState():PlayAnimation("buff_none")
        self.bufficon:GetAnimState():AnimateWhilePaused(false)
        self.bufficon:SetClickable(false)
        self.bufficon:SetScale(-1,1,1)
    end

    self.mourningflower = self.underNumbernew:AddChild(UIAnim())
    self.mourningflower:GetAnimState():SetBank("mourningflower_ui")
    self.mourningflower:GetAnimState():SetBuild("mourningflower_ui")
    self.mourningflower:GetAnimState():PlayAnimation("idle_full")
    self.mourningflower:GetAnimState():AnimateWhilePaused(false)
    self.mourningflower:SetPosition(-25, 25, 0)
    self.mourningflower:SetClickable(false)
    self.mourningflower:Hide()

    self.inst:ListenForEvent("mourningflowerpercentchange", function(owner, data)
        self:SetMourningFlower(data.percent, data.light)
    end, self.owner)

    self.inst:DoTaskInTime(0.1,function()
        self.underNumbernew:MoveToFront()
    end)
end)

function HealthBadge:SetMourningFlower(percent, light)
    if percent > 0 then
        self.mourningflower:Show()
    else
        self.mourningflower:Hide()
    end

    if light then
        self.mourningflower:GetAnimState():OverrideSymbol("mourningflower", "mourningflower_ui", "mourningflower_light")
    else
        self.mourningflower:GetAnimState():ClearOverrideSymbol("mourningflower")
    end
end
