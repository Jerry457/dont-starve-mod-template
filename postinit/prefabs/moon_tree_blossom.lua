local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function SetNewAnim(inst, i)
    inst.new_anim = i
    inst.AnimState:SetBank("moon_tree_blossom_new")
    inst.AnimState:SetBuild("moon_tree_blossom_new")
    inst.AnimState:PlayAnimation("idle" .. i)
end

AddPrefabPostInit("moon_tree_blossom", function(inst)
    inst:AddTag("petal")
    inst:AddTag("flower")

    if not TheWorld.ismastersim then
        return
    end

    inst.SetNewAnim = SetNewAnim

    local _OnLoad = inst.OnLoad
    function inst:OnLoad(data, ...)
        if _OnLoad then
            _OnLoad(self, data, ...)
        end
        if data and data.new_anim then
            inst:SetNewAnim(data.new_anim)
        end
    end

    local _OnSave = inst.OnSave
    function inst:OnSave(data, ...)
        local refs
        if _OnSave then
            refs = _OnSave(inst, data, ...)
        end
        data.new_anim = inst.new_anim

        return refs
    end
end)
