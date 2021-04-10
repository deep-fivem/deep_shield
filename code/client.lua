local shieldActive = false
local shieldEntity = nil
local wait = false

-- ANIM
local animDict = "combat@gestures@gang@pistol_1h@beckon"
local animName = "0"

local prop = "prop_ballistic_shield"
local pistol = GetHashKey("WEAPON_PISTOL")

ESX              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterCommand("ammo", function(source)
    ESX.ShowNotification("pistol ammo: "..GetAmmoInPedWeapon(GetPlayerPed(source), GetHashKey("WEAPON_PISTOL") ""))
end, false)

RegisterNetEvent("shield:toggle")
AddEventHandler("shield:toggle", function()
    if not wait and shieldActive then
        DisableShield()
    elseif not wait and not shieldActive then
        EnableShield()
    end
    print('toggle')
end)

RegisterCommand("shield", function(source, args, rawCommand)
    print('command entered')
    TriggerEvent("shield:toggle")
end, false)

function EnableShield()
    wait = true
    if not wait then
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

        elseif not HasPedGotWeapon(ped, pistol, 0) or not GetSelectedPedWeapon(ped) == pistol then
            ESX.ShowNotification("Nincs nálad pisztoly!")
        
        elseif HasPedGotWeapon(ped, pistol, 0) and (GetAmmoInPedWeapon(ped, pistol) < 200) then
            AddAmmoToPed(ped, pistol, 550)
            ESX.ShowNotification("Kaptál ammo-t mivel kevés volt nálad.")
        end
    end
    if shieldActive then
        wait = false
    end
end

function DisableShield()
    if not wait then
        wait = true

        while DoesEntityExist(shieldEntity) do
            DetachEntity(shieldEntity, true, false)
            DeleteEntity(shieldEntity)
            SetEntityAsNoLongerNeeded(shieldEntity)
            SetEntityRoutingBucket(shieldEntity, 355235)
        end
        
        local ped = GetPlayerPed(-1)

        ClearPedTasksImmediately(ped)
        SetWeaponAnimationOverride(ped, GetHashKey("Default"))
        SetEnableHandcuffs(ped, false)

        --shieldEntity = nil
        shieldActive = false
    end
    if not shieldActive then
        wait = false
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if not wait and shieldActive then
            local ped = GetPlayerPed(-1)
            
            --make sure anim is playing
            if not IsEntityPlayingAnim(ped, animDict, animName, 1) then
                RequestAnimDict(animDict)

                while not HasAnimDictLoaded(animDict) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end
            --should be useful is the player slips or something like that
            if HasEntityAnimFinished(ped, animDict, animName, 1) then
                print('HasEntityAnimFinished')
                DisableShield()
            end
            
            SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))

            -- if selected weapon is changed shield will be disabled
            if not (GetSelectedPedWeapon(ped) == pistol) then
                DisableShield()    
            end
        end
    end
end)

--disable on restart
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('shield stopped ....')
    DisableShield()
    print('shieldEntity deleted')
end)  
