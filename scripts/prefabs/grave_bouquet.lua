local assets =
{
    Asset("ANIM", "anim/grave_bouquet.zip"),
}

local function common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("Fx")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("grave_bouquet")
    inst.AnimState:SetBuild("grave_bouquet")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetFinalOffset(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function evil()
    local inst = common()
    inst.AnimState:OverrideSymbol("flower", "grave_bouquet", "flower_evil")
    return inst
end

return Prefab("grave_bouquet", common, assets),
    Prefab("grave_bouquet_evil", evil, assets)
