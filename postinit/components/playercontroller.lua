GLOBAL.setfenv(1, GLOBAL)

local PlayerController = require("components/playercontroller")
-- fuck klei
local _RemoteMakeRecipeAtPoint = PlayerController.RemoteMakeRecipeAtPoint
function PlayerController:RemoteMakeRecipeAtPoint(recipe, ...)
    local _BufferedAction_ctor = BufferedAction._ctor
    BufferedAction._ctor = function(self, doer, target, action, invobject, pos, recipe_name, distance, ...)
        if action == ACTIONS.BUILD then
            distance = recipe.build_distance
        end
        _BufferedAction_ctor(self, doer, target, action, invobject, pos, recipe_name, distance, ...)
    end

    _RemoteMakeRecipeAtPoint(self, recipe, ...)

    BufferedAction._ctor = _BufferedAction_ctor
end
