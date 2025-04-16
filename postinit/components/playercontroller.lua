GLOBAL.setfenv(1, GLOBAL)

local PlayerController = require("components/playercontroller")
-- fuck klei
local _RemoteMakeRecipeAtPoint = PlayerController.RemoteMakeRecipeAtPoint
function PlayerController:RemoteMakeRecipeAtPoint(...)
    local _BufferedAction_ctor = BufferedAction._ctor
    BufferedAction._ctor = function(self, doer, target, action, invobject, pos, recipe, distance, ...)
        if action == ACTIONS.BUILD then
            distance = recipe.build_distance
        end
        _BufferedAction_ctor(self, doer, target, action, invobject, pos, recipe, distance, ...)
    end

    _RemoteMakeRecipeAtPoint(self, ...)

    BufferedAction._ctor = _BufferedAction_ctor
end
