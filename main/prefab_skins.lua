GLOBAL.setfenv(1, GLOBAL)

-- goblinkiller_toothpick_clear_fn = function(inst) basic_clear_fn(inst, "goblinkiller_toothpick") end

local function resetflower(inst)
    for i = 1, inst.components.container:GetNumSlots() do
        local item = inst.components.container.slots[i]
        if item then
            local skin_build = inst:GetSkinBuild()
            if item.prefab == "petals_evil" then
                if skin_build ~= nil then
                    inst.AnimState:OverrideItemSkinSymbol("flowers_0" .. i, skin_build, "flowers_evil", inst.GUID, "flowers_evil")
                else
                    inst.AnimState:OverrideSymbol("flowers_0" .. i, "sisturn", "flowers_evil")
                end
            elseif item.prefab == "moon_tree_blossom" then
                if skin_build ~= nil then
                    inst.AnimState:OverrideItemSkinSymbol("flowers_0" .. i, skin_build, "flowers_lunar", inst.GUID, "flowers_lunar")
                else
                    inst.AnimState:OverrideSymbol("flowers_0" .. i, "sisturn", "flowers_lunar")
                end
            else
                inst.AnimState:ClearOverrideSymbol("flowers_0" .. i)
            end
        end
    end
end

local _sisturn_init_fn = sisturn_init_fn
sisturn_init_fn = function(inst, ...)
    _sisturn_init_fn(inst, ...)
    if inst.components.container then
        resetflower(inst)
    end
end

local _sisturn_clear_fn = sisturn_clear_fn
sisturn_clear_fn = function(inst, ...)
    _sisturn_clear_fn(inst, ...)
    if inst.components.container then
        resetflower(inst)
    end
end

moon_tree_blossom_lantern_clear_fn = function(inst)
    inst.AnimState:ClearOverrideSymbol("moontree")
    basic_clear_fn(inst, "moon_tree_blossom_lantern")
end

GlassicAPI.SkinHandler.AddModSkins({
    moon_tree_blossom_lantern = {
        "moon_tree_blossom_lantern_wan",
        "moon_tree_blossom_lantern_wax",
    }
})
