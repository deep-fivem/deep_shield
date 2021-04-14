local shieldActive = false
local shieldEntity = nil
local weapon = nil
local wait = false
local passed = false
ESX              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("shield:toggle")
AddEventHandler("shield:toggle", function()
    if not wait and shieldActive then
        DisableShield()
    elseif not wait and not shieldActive then
        EnableShield()
    end
end)

function EnableShield()
    if not wait and not shieldActive then
        wait = true
        local ped = GetPlayerPed(-1)
        local pedPos = GetEntityCoords(ped, false)
        
        for k,v in pairs(Config.Weapons) do
            if GetSelectedPedWeapon(PlayerPedId()) == Config.Weapons[k] then
                weapon = Config.Weapons[k]
            end
        end

        if weapon then
            if Config.AddAmmo then
                if GetAmmoInPedWeapon(ped, weapon) < Config.AmmoTreshold then
                    AddAmmoToPed(ped, weapon, Config.Ammo)
                    ESX.ShowNotification(Config.Locales.ammo_added)
                end
            end
            Shield()
        else
            ESX.ShowNotification(Config.Locales.equip_pistol)
            wait = false
        end
    end
end

function DisableShield()
    if not wait and shieldActive then
        wait = true

        while DoesEntityExist(shieldEntity) do
            DetachEntity(shieldEntity, true, false)
            DeleteEntity(shieldEntity)
            SetEntityAsNoLongerNeeded(shieldEntity)
        end

        local ped = GetPlayerPed(-1)

        ClearPedTasksImmediately(ped)
        SetWeaponAnimationOverride(ped, GetHashKey("Default"))
        SetEnableHandcuffs(ped, false)

        shieldActive = false
    end
    if not shieldActive and wait == true then
        wait = false
    end
end

function Shield()
    if wait and not shieldActive then
        local ped = GetPlayerPed(-1)
        local pedPos = GetEntityCoords(ped, false)

        SetCurrentPedWeapon(ped, weapon, true)

        RequestAnimDict(Config.animDict)
        while not HasAnimDictLoaded(Config.animDict) do
            Citizen.Wait(100)
        end

        TaskPlayAnim(ped, Config.animDict, Config.animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

        RequestModel(GetHashKey(Config.prop))
        while not HasModelLoaded(GetHashKey(Config.prop)) do
            Citizen.Wait(100)
        end

        local shield = CreateObject(GetHashKey(Config.prop), pedPos.x, pedPos.y, pedPos.z, 1, 1, 1)
        shieldEntity = shield

        AttachEntityToEntity(shieldEntity, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
        SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))
        
        SetEnableHandcuffs(ped, true)
        
        shieldActive = true
    end
    if shieldActive and wait == true then
        wait = false
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if shieldActive then
            local ped = GetPlayerPed(-1)
            
            if not IsEntityPlayingAnim(ped, Config.animDict, Config.animName, 1) then
                RequestAnimDict(Config.animDict)

                while not HasAnimDictLoaded(Config.animDict) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, Config.animDict, Config.animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end

            if IsPedDeadOrDying(ped) or IsPedGoingIntoCover(ped) or IsPedDiving(ped) or IsPedGettingIntoAVehicle(ped) or not IsPedOnFoot(ped) or IsPedGettingUp(ped) then
                DisableShield()
            end
            
            SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))

            if not (GetSelectedPedWeapon(ped) == weapon) then
                DisableShield()
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(300)
        if IsPedFalling(ped) then
            DisableShield()
        end
    end
end)

if Config.DeleteEntityOnResourceRestart then
    AddEventHandler('onResourceStop', function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
            return
        end
        print('shield stopped ....')
        DisableShield()
        print('shieldEntity deleted')
    end)
end
