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

AddClassPostConstruct("widgets/pethealthbadge", function(self)
	self.underNumbernew = self:AddChild(Widget("underNumbernew"))
	if self.bufficon then
		self.bufficon:Kill()
		self.bufficon = self.underNumbernew:AddChild(UIAnim())
		self.bufficon:GetAnimState():SetBank("status_abigail")
		self.bufficon:GetAnimState():SetBuild("status_abigail")
		self.bufficon:GetAnimState():PlayAnimation("buff_none")
		self.bufficon:GetAnimState():AnimateWhilePaused(false)
		self.bufficon:SetClickable(false)
	end
	if self.bufficon2 then
		self.bufficon2:Kill()
		self.bufficon2 = self.underNumbernew:AddChild(UIAnim())
		self.bufficon2:GetAnimState():SetBank("status_abigail")
		self.bufficon2:GetAnimState():SetBuild("status_abigail")
		self.bufficon2:GetAnimState():PlayAnimation("buff_none")
		self.bufficon2:GetAnimState():AnimateWhilePaused(false)
		self.bufficon2:SetClickable(false)
		self.bufficon2:SetScale(-1,1,1)
	end
	self.inst:DoTaskInTime(0.1,function()
		self.underNumbernew:MoveToFront()
	end)
end)
