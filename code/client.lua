--shieldActive_two szaar

--local shieldActive_two = false
local shieldActive = false
local shieldEntity = nil

-- ANIM
local animDict = "combat@gestures@gang@pistol_1h@beckon"
local animName = "0"

local prop = "prop_ballistic_shield"
local pistol = GetHashKey("WEAPON_PISTOL")

ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent("shield:toggle")
AddEventHandler("shield:toggle", function()
    print('toggle')
    if shieldActive or shieldActive_two then
        DisableShield()
    else
        EnableShield()
    end
end)

function EnableShield()
    local ped = GetPlayerPed(-1)
    local pedPos = GetEntityCoords(ped, false)
    local ammo = GetAmmoInPedWeapon(ped, pistol)
    print('ammo: '..ammo) --need test
    if HasPedGotWeapon(ped, pistol, 0) or GetSelectedPedWeapon(ped) == pistol then
        print('has pistol')
        shieldActive = true

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(100)
        end

        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

        RequestModel(GetHashKey(prop))
        while not HasModelLoaded(GetHashKey(prop)) do
            Citizen.Wait(100)
        end

        local shield = CreateObject(GetHashKey(prop), pedPos.x, pedPos.y, pedPos.z, 1, 1, 1)
        shieldEntity = shield

        AttachEntityToEntity(shieldEntity, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
        SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))
        SetCurrentPedWeapon(ped, pistol, true)
        SetEnableHandcuffs(ped, true)
    elseif not HasPedGotWeapon(ped, pistol, 0) or not GetSelectedPedWeapon(ped) == pistol
        print('does not has pistol')
    --[[
        shieldActive_two = true

        animDict = "combat@gestures@gang@pistol_1h@beckon"
        animName = "-90"

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(100)
        end

        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

        RequestModel(GetHashKey(prop))
        while not HasModelLoaded(GetHashKey(prop)) do
            Citizen.Wait(100)
        end

        local shield = CreateObject(GetHashKey(prop), pedPos.x, pedPos.y, pedPos.z, 1, 1, 1)
        shieldEntity = shield

        local others = {
            xPos = 0.0,
            yPos = -0.05,
            zPos = -0.10,
            xRot = -30.0,
            yRot = 180.0,
            zRot = 40.0,
            p9 = false,
            useSoftPinning = false,
            collision = true,
            isPed = false,
            vertexIndex = 0,
            fixedRot = true
        }

        AttachEntityToEntity(shieldEntity, ped, GetEntityBoneIndexByName(ped, "SKEL_R_Finger32"), others.xPos, others.yPos, others.zPos, others.xRot, others.yRot, others.zRot,others.p9, others.useSoftPinning, others.collision, others.isPed, others.vertexIndex, others.fixedRot)

        --SetWeaponAnimationOverride(ped, GetHashKey("Gang"))
        --SetCurrentPedWeapon(ped, pistol, true)
        --SetEnableHandcuffs(ped, true)
        ]]

        ESX.ShowNotification("Nincs nálad pisztoly!")

    elseif HasPedGotWeapon(ped, pistol, 0) and GetAmmoInPedWeapon(ped, pistol) == < 200
        AddAmmoToPed(ped, pistol, 550)
        ESX.ShowNotification("Kaptál ammo-t mivel kevés volt nálad.")
    end
end

function DisableShield()
    local ped = GetPlayerPed(-1)
    DetachEntity(shieldEntity, true, false)
    DeleteEntity(shieldEntity)
    SetEntityAsNoLongerNeeded(shieldEntity)
    ClearPedTasksImmediately(ped)
    SetWeaponAnimationOverride(ped, GetHashKey("Default"))

    SetEnableHandcuffs(ped, false)
    shieldActive = false
    --shieldActive_two = false
    shieldEntity = nil
    animDict = ""
    animName = ""
end

RegisterCommand("shield", function(source, args, rawCommand)
    print('command entered')
    TriggerEvent("shield:toggle")
end, false)

Citizen.CreateThread(function()
    while true do
        if shieldActive then
            local ped = GetPlayerPed(-1)
            if not IsEntityPlayingAnim(ped, animDict, animName, 1) then
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end
            SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))


            if not (GetSelectedPedWeapon(ped) == pistol) then
                DisableShield()    
            end

            RequestAnimDict(animDict)
            if not HasAnimDictLoaded(animDict) then
                Citizen.Wait(0)
            end

            --[[
            if not IsEntityAttached(shieldEntity) then
                RequestAnimDict(animDict)
                

                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

                RequestModel(GetHashKey(prop))
                while not HasModelLoaded(GetHashKey(prop)) do
                    Citizen.Wait(100)
                end

                AttachEntityToEntity(shieldEntity, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
                SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))
            end
            ]]

        end
        --[[
        if shieldActive_two then
            local ped = GetPlayerPed(-1)
            if not IsEntityPlayingAnim(ped, animDict, animName, 1) then
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end
            --SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))

            RequestAnimDict(animDict)
            if not HasAnimDictLoaded(animDict) then
                Citizen.Wait(0)
            end
        end
        ]]
        Citizen.Wait(100)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('shield stopped ....')
    DisableShield()
    print('shieldEntity deleted')
end)  

--notes
--[[

    nem kellett.
    volt collisionje.

  AttachEntityToEntityPhysically(entity1, entity2, boneIndex1, boneIndex2, xPos1, yPos1, zPos1, xPos2, yPos2, zPos2, xRot, yRot, zRot, breakForce, fixedRot, p15, collision, teleport, p18)

    if not DoesEntityHavePhysics(entity) then
        ActivatePhysics(entity)
    end

]]
