GLOBAL.setfenv(1, GLOBAL)

local PlayerController = require("components/playercontroller")
-- fuck klei
function PlayerController:RemoteMakeRecipeAtPoint(recipe, pt, rot, skin)
    if not self.ismastersim then
        local skin_index = skin ~= nil and PREFAB_SKINS_IDS[recipe.name][skin] or nil
        if self.locomotor == nil then
            -- NOTES(JBK): Does not call locomotor component functions needed for pre_action_cb, manual call here.
            if ACTIONS.BUILD.pre_action_cb ~= nil then
                ACTIONS.BUILD.pre_action_cb(BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt, recipe.name, recipe.build_distance, nil, rot))
            end
            local platform, pos_x, pos_z = self:GetPlatformRelativePosition(pt.x, pt.z)
            SendRPCToServer(RPC.MakeRecipeAtPoint, recipe.rpc_id, pos_x, pos_z, rot, skin_index, platform, platform ~= nil)
        elseif self:CanLocomote() then
            self.locomotor:Stop()
            local act = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt, recipe.name, recipe.build_distance, nil, rot)
            act.preview_cb = function()
                SendRPCToServer(RPC.MakeRecipeAtPoint, recipe.rpc_id, act.pos.local_pt.x, act.pos.local_pt.z, rot, skin_index, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
            end
            self.locomotor:PreviewAction(act, true)
        end
    end
end
