GLOBAL.setfenv(1, GLOBAL)

local SisturnPerish = require("widgets/sisturnperish")
local PlayerHud = require("screens/playerhud")

local _OpenSpellWheel = PlayerHud.OpenSpellWheel
function PlayerHud:OpenSpellWheel(invobject, items, radius, focus_radius, bgdata, ...)
    _OpenSpellWheel(self, invobject, items, radius, focus_radius, bgdata, ...)

    if not self.controls.spellwheel.bg then
        local bg = self.controls.spellwheel:AddChild(SisturnPerish(self.owner, #items))
        bg:MoveToBack()
        -- bg:SetScale(bgdata.widget_scale)
        self.controls.spellwheel.bg = bg
    end
end
