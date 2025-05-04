local assets =
{
    Asset("ANIM", "anim/possessed_ghostflower_" .."blue" .. ".zip"),
    Asset("ANIM", "anim/possessed_ghostflower_" .."green" .. ".zip"),
    Asset("ANIM", "anim/possessed_ghostflower_" .."orange" .. ".zip"),
    Asset("ANIM", "anim/possessed_ghostflower_" .."purple" .. ".zip"),
    Asset("ANIM", "anim/possessed_ghostflower_" .."red" .. ".zip"),
    Asset("ANIM", "anim/possessed_ghostflower_" .."yellow" .. ".zip"),
}

local colors = {
    "blue",
    "green",
    "orange",
    "purple",
    "red",
    "yellow",
}

local function DoFx(inst)
    if not inst.inlimbo then
        local fx = SpawnPrefab("ghostflower_spirit"..tostring(math.random(2)).."_fx")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst:DoTaskInTime(3 + math.random() * 6, DoFx) -- the min delay needs to be greater than the grow animation + it's delay
    end
end

local function DoGrow(inst)
    inst:Show()
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function DelayedGrow(inst)
    inst:Hide()
    inst:DoTaskInTime(0.25 + math.random() * 0.25, DoGrow)
end

local function ToGround(inst)
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:DoTaskInTime(3 + math.random() * 6, DoFx)
end

local function OnDeploy(inst, pt, deployer)
    local x, y, z = pt:Get()

    local grave = SpawnSaveRecord(inst.grave_data)
    grave.Transform:SetPosition(x, y, z)
    SpawnPrefab("attune_out_fx").Transform:SetPosition(x, y, z)
    grave.SoundEmitter:PlaySound("meta5/wendy/tombstone_place")

    WS_UTIL.RemoveOneItem(inst)
end

local function SetColor(inst, color)
    inst.color = color or colors[math.random(#colors)]
    inst.AnimState:SetBuild("possessed_ghostflower_" .. inst.color)
    inst.components.inventoryitem:ChangeImageName("possessed_ghostflower_" .. inst.color)
end

local function OnSave(inst, data)
    data.color = inst.color
    data.grave_data = inst.grave_data
end

local function OnLoad(inst, data)
    if data then
        SetColor(inst, data.color)
        inst.grave_data = data.grave_data
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst:SetPrefabNameOverride("possessed_ghostflower")

    inst:AddTag("possessed_ghostflower")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetBank("ghostflower")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM)

    inst:ListenForEvent("ondropped", ToGround)

    inst.DelayedGrow = DelayedGrow

    inst.SetColor = SetColor
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    SetColor(inst)
    ToGround(inst)

    return inst
end

-- NOTES(DiogoW): This used to be TheCamera:GetDownVec()*.5, probably legacy code from DS,
-- since TheCamera:GetDownVec() would always return the values below.
local MOUND_POSITION_OFFSET = { 0.35355339059327, 0, 0.35355339059327 }

local function CreateMoundPlacer()
    local mound = CreateEntity()

    --[[Non-networked entity]]
    mound.entity:SetCanSleep(false)
    mound.persists = false

    mound.entity:AddTransform()
    mound.entity:AddAnimState()

    mound:AddTag("CLASSIFIED")
    mound:AddTag("NOCLICK")
    mound:AddTag("placer")

    mound.AnimState:SetBank("gravestone")
    mound.AnimState:SetBuild("gravestones")
    mound.AnimState:PlayAnimation("gravedirt")

    mound.Transform:SetPosition(unpack(MOUND_POSITION_OFFSET))

    return mound
end

local function possessed_ghostflower_gravestone_placer_postinit_fn(inst)
    inst.AnimState:Hide("flower")

    inst._mound = CreateMoundPlacer()
    inst._mound.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(inst._mound)
end

return Prefab("possessed_ghostflower_mound", fn, assets),
    Prefab("possessed_ghostflower_gravestone", fn, assets),
    MakePlacer("possessed_ghostflower_mound_placer", "gravestone", "gravestones", "gravedirt"),
    MakePlacer("possessed_ghostflower_gravestone_placer", "gravestone", "gravestones", "grave1", nil, nil, nil, nil, nil, nil, possessed_ghostflower_gravestone_placer_postinit_fn)
