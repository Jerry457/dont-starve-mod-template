local AddIngredientValues = AddIngredientValues
GLOBAL.setfenv(1, GLOBAL)

local preparedfoods = require("preparedfoods")
preparedfoods.butterflymuffin.test = function(cooker, names, tags)
    return (names.butterflywings or names.moonbutterflywings or names.fullmoonbutterflywings)
        and not tags.meat
        and tags.veggie and tags.veggie >= 0.5
end

AddIngredientValues({"fullmoonbutterflywings"}, {decoration=2})
