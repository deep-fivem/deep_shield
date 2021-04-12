local shieldActive = false
local shieldEntity = nil
local wait = false
local passed = false

-- ANIM
local animDict = "combat@gestures@gang@pistol_1h@beckon"
local animName = "0"

local prop = "prop_ballistic_shield"
local pistol = GetHashKey("weapon_combatpistol")
local taser = GetHashKey("weapon_stungun")

ESX              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterCommand("ammo", function(source)
    ESX.ShowNotification("pistol ammo: "..GetAmmoInPedWeapon(GetPlayerPed(source), GetHashKey("WEAPON_PISTOL")))
end, false)

RegisterNetEvent("shield:toggle")
AddEventHandler("shield:toggle", function()
    if not wait and shieldActive then
        DisableShield()
    elseif not wait and not shieldActive then
        EnableShield()
    end
    --print('toggle')
end)

--RegisterCommand("shield", function(source, args, rawCommand)
--    print('command entered')
--    TriggerEvent("shield:toggle")
--end, false)

function EnableShield()
    if not wait then
        wait = true
        local ped = GetPlayerPed(-1)
        local pedPos = GetEntityCoords(ped, false)
        local hasPistol = HasPedGotWeapon(ped, pistol, false)
        local hasTaser = HasPedGotWeapon(ped, taser, false)


        if hasPistol or hasTaser then
            if hasPistol and not hasTaser then
                --print('has pistol')
                SetCurrentPedWeapon(ped, pistol, true)
            elseif hasTaser and not hasPistol then
                --print('has taser')
                SetCurrentPedWeapon(ped, taser, true)
            elseif hasTaser and hasPistol then
                --print('has both')
                SetCurrentPedWeapon(ped, pistol, true)
            end

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
            
            SetEnableHandcuffs(ped, true)

            passed = false
            shieldActive = true
        elseif not hasPistol or not hasTaser then
            ESX.ShowNotification("Nincs nálad pisztoly vagy sokkoló!")
            passed = true
        elseif HasPedGotWeapon(ped, pistol, 0) and GetAmmoInPedWeapon(ped, pistol) < 200 then
            AddAmmoToPed(ped, pistol, 550)
            ESX.ShowNotification("Kaptál ammo-t mivel kevés volt nálad.")
            passed = true
        end
    end
    if shieldActive or passed and wait == true then
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
        end

        local ped = GetPlayerPed(-1)

        ClearPedTasksImmediately(ped)
        SetWeaponAnimationOverride(ped, GetHashKey("Default"))
        SetEnableHandcuffs(ped, false)

        --shieldEntity = nil
        shieldActive = false
    end
    if not shieldActive and wait == true then
        wait = false
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if shieldActive then
            local ped = GetPlayerPed(-1)
            
            if not IsEntityPlayingAnim(ped, animDict, animName, 1) then
                RequestAnimDict(animDict)

                while not HasAnimDictLoaded(animDict) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end

            if IsPedDeadOrDying(ped) or IsPedDiving(ped) or IsPedFalling(ped) or IsPedGettingIntoAVehicle(ped) or not IsPedOnFoot(ped) or IsPedDucking(ped) or IsPedGettingUp(ped) or IsPedInWrithe(ped) then
                DisableShield()
            end

            --TODO
            local closest_vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped))
            if closest_vehicle then
                if GetIsVehicleEngineRunning(closest_vehicle) or IsVehicleEngineStarting(closest_vehicle) then
                    -- if vehicle moved then disableshield
                end
            end
            
            SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))

            if not (GetSelectedPedWeapon(ped) == pistol or GetSelectedPedWeapon(ped == taser)) then
                DisableShield()    
            end
        end
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

--TODO:
-- optimization, if vehicle moves in front of the player disable shield, going over it for the last time
