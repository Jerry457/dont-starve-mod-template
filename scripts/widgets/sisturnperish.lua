local Widget = require("widgets/widget")
local Image = require("widgets/image")

local wendy_spellbook_atlas = "images/wendy_spellbook_bg.xml"

local state_texs = {
    EVIL = "shadow",
    BLOSSOM = "blossom",
    PETALS = "normal",
}

local SisturnPerish =  Class(Widget, function(self, owner, num)
    Widget._ctor(self, "SisturnPerish")
    self.owner = owner
    self.num = num

    local state = self.owner.player_classified.sisturnstate:value()
    local percent = self.owner.player_classified.sisturnperish:value()

    self:SetState(state)
    self:SetSisturnPerish(percent)

    self.inst:ListenForEvent("sisturnperishchange", function(_, data)
        self:SetState(data.state)
        self:SetSisturnPerish(data.percent)
    end, self.owner)
end)

function SisturnPerish:SetSisturnPerish(percent)
    if self.fill then
        local w, h = self.fill:GetSize()
        self.fill:SetScissor(-w / 2, -h / 2, w, h * percent)
    end
end

function SisturnPerish:SetState(state)
    local state_tex = state_texs[state]
    if state_tex then
        local fill_tex = state_tex .. "_" .. self.num .. ".tex"
        local bg_tex = state_tex .. "_" .. self.num .. "_0.tex"
        if not self.bg then
            self.bg = self:AddChild(Image(wendy_spellbook_atlas, bg_tex))
            -- self.bg:SetBlendMode(BLENDMODE.Disabled)
            self.bg:SetTint(1, 1, 1, 0.5)
            self.fill = self:AddChild(Image(wendy_spellbook_atlas, fill_tex))
            -- self.fill:SetBlendMode(BLENDMODE.Disabled)
            self.fill:SetTint(1, 1, 1, 0.65)
        else
            self.fill:SetTexture(wendy_spellbook_atlas, fill_tex)
            self.bg:SetTexture(wendy_spellbook_atlas, bg_tex)
        end
        self:Show()
    else
        self:Hide()
    end
end

return SisturnPerish
