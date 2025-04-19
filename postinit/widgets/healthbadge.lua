local AddClassPostConstruct = AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

local UIAnim = require("widgets/uianim")
local Widget = require("widgets/widget")

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
    self.inst:DoTaskInTime(0.1,function()
        self.underNumbernew:MoveToFront()
    end)
end)
