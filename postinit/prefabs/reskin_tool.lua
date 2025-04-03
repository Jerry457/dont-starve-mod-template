local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("reskin_tool", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _can_cast_fn = inst.components.spellcaster.can_cast_fn
    inst.components.spellcaster.can_cast_fn = function(doer, target, pos, ...)
        if target:HasTag("reskin_tool_target") then
            return true
        end
        return _can_cast_fn(doer, target, pos, ...)
    end
end)
