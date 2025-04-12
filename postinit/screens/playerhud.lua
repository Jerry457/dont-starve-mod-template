GLOBAL.setfenv(1, GLOBAL)

local PlayerHud = require("screens/playerhud")

local function OnSisturnPerishChange(self, percent)
    local w, h = 338, 333
    -- local w, h = self.controls.spellwheel.bg:GetBoundingBoxSize()
    self.controls.spellwheel.bg:SetScissor(-w / 2, -h / 2, w, h * percent)
end

local _OpenSpellWheel = PlayerHud.OpenSpellWheel
function PlayerHud:OpenSpellWheel(invobject, items, radius, focus_radius, bgdata, ...)
    _OpenSpellWheel(self, invobject, items, radius, focus_radius, bgdata, ...)

    if self.controls.spellwheel.bg then
        if self.owner.player_classified then
            OnSisturnPerishChange(self, self.owner.player_classified.sisturnperish:value())
        end
        self.controls.spellwheel.bg.inst:ListenForEvent("sisturnperishchange", function(_, data)
            OnSisturnPerishChange(self, data.percent)
        end, self.owner)
    end
end
