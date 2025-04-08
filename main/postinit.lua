local files = {
    "postinit/entityscript.lua",
    "postinit/loottables.lua",
    "postinit/map.lua",
    "postinit/components/decoratedgrave_ghostmanager.lua",
    "postinit/components/pethealthbar.lua",
    "postinit/components/skilltreeupdater.lua",
    "postinit/prefabs/abigail.lua",
    "postinit/prefabs/elixir_container.lua",
    "postinit/prefabs/flower_evil.lua",
    "postinit/prefabs/ghost.lua",
    "postinit/prefabs/ghostflower.lua",
    "postinit/prefabs/graveguard_ghost.lua",
    "postinit/prefabs/gravestone.lua",
    "postinit/prefabs/moon_tree_blossom.lua",
    "postinit/prefabs/mound.lua",
    "postinit/prefabs/petals.lua",
    "postinit/prefabs/petals_evil.lua",
    "postinit/prefabs/reskin_tool.lua",
    "postinit/prefabs/skeleton.lua",
    "postinit/prefabs/skilltree_wendy.lua",
    "postinit/prefabs/smallghost.lua",
    "postinit/prefabs/wendy.lua",
    "postinit/prefabs/wendy_recipe_gravestone.lua",
    "postinit/stategraphs/SGabigail.lua",
    "postinit/stategraphs/SGcommon.lua",
    "postinit/stategraphs/SGwilson.lua",
    "postinit/stategraphs/SGwilson_client.lua",
    "postinit/widgets/pethealthbadge.lua"
}

for _, file in ipairs(files) do
    modimport(file)
end
