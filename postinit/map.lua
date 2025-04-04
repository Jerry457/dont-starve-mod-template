local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

AddSimPostInit(function()
    local _CanDeployRecipeAtPoint = Map.CanDeployRecipeAtPoint
    Map.CanDeployRecipeAtPoint = function(self, pt, recipe, rot, ...)
        if BUILDMODE.ANY_WHERE == recipe.build_mode then
            local x, y, z = pt:Get()
            local is_valid_ground = self:IsPassableAtPointWithPlatformRadiusBias(x, y, z, true, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)

            return is_valid_ground
            and (recipe.testfn == nil or recipe.testfn(pt, rot))
            and self:IsDeployPointClear(pt, nil, recipe.min_spacing or 3.2)
        end

        return _CanDeployRecipeAtPoint(self, pt, recipe, rot, ...)
    end
end)
