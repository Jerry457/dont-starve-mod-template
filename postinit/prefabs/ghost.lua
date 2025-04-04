local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local ghosts = {
    "ghost",
    "graveguard_ghost",
}

local must_have_tags = { "moon_tree_blossom_lantern" }
for _, ghost in ipairs(ghosts) do
    AddPrefabPostInit(ghost, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        -- local _auratestfn = inst.components.aura.auratestfn
        -- inst.components.aura.auratestfn = function(inst, ...)
        --     local x, y, z = inst.Transform:GetWorldPosition()
        --     local moon_tree_blossom_lanterns = TheSim:FindEntities(x, y, z, 12, must_have_tags)
        --     return #moon_tree_blossom_lanterns <= 0 and _auratestfn(inst, ...)
        -- end
    end)
end
