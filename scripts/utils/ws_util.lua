WS_UTIL = {}

WS_UTIL.RemoveOneItem = function(item)
    if item.components.stackable then
        item.components.stackable:Get():Remove()
    else
        item:Remove()
    end
end
