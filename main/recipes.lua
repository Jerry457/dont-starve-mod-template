local AddRecipePostInit = AddRecipePostInit
GLOBAL.setfenv(1, GLOBAL)

-- GlassicAPI.AddTech("GK_SMITH")  -- 科技
-- GlassicAPI.AddTech("GREED_POWER", true)  -- 临时科技
-- GlassicAPI.AddPrototyperTrees("GOBLINKILLER_SMITH", {GK_SMITH = 1})  -- 科技站

-- GlassicAPI.AddRecipe("goblinkiller_backpack_2",
--     {
--         Ingredient("goblinkiller_backpack_1", 1),
--         Ingredient("pigskin", 4),
--         Ingredient("silk", 6),
--         Ingredient("rope", 2)
--     },
--     TECH.NONE,
--     { builder_tag = "goblinkiller" },
--     { "CHARACTER", "CONTAINERS" }
-- )

GlassicAPI.AddRecipe(
    "moon_tree_blossom_lantern",
    { Ingredient("moon_tree_blossom", 1) },
    TECH.NONE,
    {
        builder_skill="wendy_smallghost_2",
        build_mode = BUILDMODE.ANY_WHERE,
        placer="moon_tree_blossom_lantern_placer",
        min_spacing = 0.6,
        build_distance = 5,
        sg_state = "spawn_mutated_creature",
    }
)

AddRecipePostInit("graveurn", function(self)
    self.builder_skill = ""
    AllBuilderTaggedRecipes["graveurn"] = self.builder_tag or self.builder_skill
end)

AddRecipePostInit("wendy_gravestone", function(self)
    self.builder_skill = "wendy_smallghost_2"
    AllBuilderTaggedRecipes["wendy_gravestone"] = self.builder_tag or self.builder_skill
end)
