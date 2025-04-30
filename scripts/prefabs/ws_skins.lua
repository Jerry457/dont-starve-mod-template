local prefabs = {
    CreatePrefabSkin("moon_tree_blossom_lantern1", {
        base_prefab = "moon_tree_blossom_lantern",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/moon_tree_blossom_lantern1.zip"),
        },
        init_fn = function(inst)
            inst.AnimState:OverrideSymbol("moontree", "moon_tree_blossom_lantern1", "moontree")
            GlassicAPI.BasicInitFn(inst)
        end,
        skins = { normal_skin = "moon_tree_blossom_lantern" },
        skin_tags = { "moon_tree_blossom_lantern" },
        release_group = 87,
    }),
    CreatePrefabSkin("moon_tree_blossom_lantern2", {
        base_prefab = "moon_tree_blossom_lantern",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/moon_tree_blossom_lantern2.zip"),
        },
        init_fn = function(inst)
            inst.AnimState:OverrideSymbol("moontree", "moon_tree_blossom_lantern2", "moontree")
            GlassicAPI.BasicInitFn(inst)
        end,
        skins = { normal_skin = "moon_tree_blossom_lantern" },
        skin_tags = { "moon_tree_blossom_lantern" },
        release_group = 87,
    }),
}

return unpack(prefabs)
