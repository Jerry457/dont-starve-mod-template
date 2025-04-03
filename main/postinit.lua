local files = {
    "postinit/entityscript.lua",
    "postinit/loottables.lua",
    "postinit/components/skilltreeupdater.lua",
    "postinit/prefabs/flower_evil.lua",
    "postinit/prefabs/ghostflower.lua",
    "postinit/prefabs/gravestone.lua",
    "postinit/prefabs/mound.lua",
    "postinit/prefabs/petals_evil.lua",
    "postinit/prefabs/skeleton.lua",
    "postinit/prefabs/skilltree_wendy.lua",
    "postinit/prefabs/smallghost.lua",
    "postinit/prefabs/wendy.lua",
    "postinit/prefabs/wendy_recipe_gravestone.lua",
    "postinit/stategraphs/SGcommon.lua",
    "postinit/stategraphs/SGwilson.lua",
    "postinit/stategraphs/SGwilson_client.lua"
}

for _, file in ipairs(files) do
    modimport(file)
end
