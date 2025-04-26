local AddClassPostConstruct = AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

local PetHealthBadge = require("widgets/pethealthbadge")
local UIAnim = require("widgets/uianim")
local Widget = require("widgets/widget")

AddClassPostConstruct("widgets/pethealthbadge", function(self)
    self.underNumbernew = self:AddChild(Widget("underNumbernew"))

    if self.bufficon then
        self.bufficon:Kill()
    end
    self.bufficon = self.underNumbernew:AddChild(UIAnim())
    self.bufficon:GetAnimState():SetBank("status_abigail")
    self.bufficon:GetAnimState():SetBuild("status_abigail")
    self.bufficon:GetAnimState():PlayAnimation("buff_none")
    self.bufficon:GetAnimState():AnimateWhilePaused(false)
    self.bufficon:SetClickable(false)

    if self.bufficon2 then
        self.bufficon2:Kill()
    end
    self.bufficon2 = self.underNumbernew:AddChild(UIAnim())
    self.bufficon2:GetAnimState():SetBank("status_abigail")
    self.bufficon2:GetAnimState():SetBuild("status_abigail")
    self.bufficon2:GetAnimState():PlayAnimation("buff_none")
    self.bufficon2:GetAnimState():AnimateWhilePaused(false)
    self.bufficon2:SetClickable(false)
    self.bufficon2:SetScale(-1,1,1)

    self.default_symbol_build3 = "status_abigail"
    self.bufficon3 = self.underNumbernew:AddChild(UIAnim())
    self.bufficon3:GetAnimState():SetBank("status_abigail")
    self.bufficon3:GetAnimState():SetBuild("status_abigail")
    self.bufficon3:GetAnimState():PlayAnimation("buff_none")
    self.bufficon3:GetAnimState():AnimateWhilePaused(false)
    self.bufficon3:SetClickable(false)
    self.bufficon3:SetRotation(90)
    -- self.bufficon3:SetScale(1, -1, 1)
    self.buffsymbol3 = 0

    self.default_symbol_build4 = "status_abigail"
    self.bufficon4 = self.underNumbernew:AddChild(UIAnim())
    self.bufficon4:GetAnimState():SetBank("status_abigail")
    self.bufficon4:GetAnimState():SetBuild("status_abigail")
    self.bufficon4:GetAnimState():PlayAnimation("buff_none")
    self.bufficon4:GetAnimState():AnimateWhilePaused(false)
    self.bufficon4:SetClickable(false)
    -- self.bufficon4:SetRotation(-90)
    self.bufficon4:SetScale(-1, 1, 1)
    self.buffsymbol4 = 0

    self.inst:DoTaskInTime(0.1,function()
        self.underNumbernew:MoveToFront()
    end)
end)

function PetHealthBadge:ShowBuff3(symbol)
    if symbol == 0 then
        if self.buffsymbol3 ~= 0 then
            self.bufficon3:GetAnimState():PlayAnimation("buff_deactivate")
            self.bufficon3:GetAnimState():PushAnimation("buff_none", false)
        end
    elseif symbol ~= self.buffsymbol3 then
        self.bufficon3:GetAnimState():OverrideSymbol("buff_icon", self.OVERRIDE_SYMBOL_BUILD[symbol] or self.default_symbol_build3, symbol)

        self.bufficon3:GetAnimState():PlayAnimation("buff_activate")
        self.bufficon3:GetAnimState():PushAnimation("buff_idle", false)
    end

    self.buffsymbol3 = symbol
end

function PetHealthBadge:ShowBuff4(symbol)
    if symbol == 0 then
        if self.buffsymbol4 ~= 0 then
            self.bufficon4:GetAnimState():PlayAnimation("buff_deactivate")
            self.bufficon4:GetAnimState():PushAnimation("buff_none", false)
        end
    elseif symbol ~= self.buffsymbol4 then
        self.bufficon4:GetAnimState():OverrideSymbol("buff_icon", self.OVERRIDE_SYMBOL_BUILD[symbol] or self.default_symbol_build4, symbol)

        self.bufficon4:GetAnimState():PlayAnimation("buff_activate")
        self.bufficon4:GetAnimState():PushAnimation("buff_idle", false)
    end

    self.buffsymbol4 = symbol
end

local _SetValues = PetHealthBadge.SetValues
function PetHealthBadge:SetValues(...)
    local pethealthbar = self.owner.components.pethealthbar
    local symbol3 = pethealthbar:GetSymbol3()
    local symbol4 = pethealthbar:GetSymbol4()

    self:ShowBuff3(symbol3)
    self:ShowBuff4(symbol4)

    return _SetValues(self, ...)
end
