local prefabs = {
    CreatePrefabSkin("moon_tree_blossom_lantern_wan", {
        base_prefab = "moon_tree_blossom_lantern",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/moon_tree_blossom_lantern_wan.zip"),
        },
        init_fn = function(inst)
            inst.AnimState:OverrideSymbol("moontree", "moon_tree_blossom_lantern_wan", "moontree")
            GlassicAPI.BasicInitFn(inst)
        end,
        skins = { normal_skin = "moon_tree_blossom_lantern" },
        skin_tags = { "moon_tree_blossom_lantern" },
        release_group = 87,
    }),
    CreatePrefabSkin("moon_tree_blossom_lantern_wax", {
        base_prefab = "moon_tree_blossom_lantern",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/moon_tree_blossom_lantern_wax.zip"),
        },
        init_fn = function(inst)
            inst.AnimState:OverrideSymbol("moontree", "moon_tree_blossom_lantern_wax", "moontree")
            GlassicAPI.BasicInitFn(inst)
        end,
        skins = { normal_skin = "moon_tree_blossom_lantern" },
        skin_tags = { "moon_tree_blossom_lantern" },
        release_group = 87,
    }),
}

return unpack(prefabs)
