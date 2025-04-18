local assets =
{
    Asset("ANIM", "anim/ghostflower_scatter_fx.zip"),
    Asset("ANIM", "anim/wendy_recall_ghostflower.zip"),
}

local function MakeSummonFX(bank, build, anim, is_mounted)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        if is_mounted then
            inst.Transform:SetSixFaced()
        else
            inst.Transform:SetFourFaced()
        end

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetFinalOffset(1)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return Prefab("ghostflower_scatter_fx", MakeSummonFX("ghostflower_scatter_fx", "ghostflower_scatter_fx", "ghostflower_scatter", false), assets)
    -- Prefab("ghostflower_scatter_fx_mount", MakeSummonFX("wendy_mount_recall_flower", nil, true), assets)
