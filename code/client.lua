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
            if GetAmmoInPedWeapon(ped, weapon) < Config.AmmoTreshold then
                AddAmmoToPed(ped, weapon, Config.Ammo)
                ESX.ShowNotification("Kaptál ammo-t mivel kevés volt nálad.")
            end
            Shield()
        else
            ESX.ShowNotification("Legyen a kezedben bármilyen pisztoly vagy sokkoló!")
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

            --TODO
            --if not ESX.Game.GetClosestVehicle(GetEntityCoords(ped)) == -1 then
            --    local closest_vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped))
            --    local distance = #(GetEntityCoords(ped) - closest_vehicle)
            --    print(distance)
            --    if not (GetIsVehicleEngineRunning(closest_vehicle) or IsVehicleEngineStarting(closest_vehicle)) then
            --        -- if vehicle moved then disableshield
            --    end
            --end
            
            SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))

            if not (GetSelectedPedWeapon(ped) == weapon) then
                --SetCurrentPedWeapon(ped, weapon, true) did not work
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

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('shield stopped ....')
    DisableShield()
    print('shieldEntity deleted')
end)

--TODO:
-- if vehicle moves in front of the player disable shield, --going over it for the last time

--[[
    A scriptről

    Configolható

    Itemmel működik - sql mellékelt (esx 1.2 vagy nagyobb verzióhoz át kell írni a limit-et weight-re)

    Ad ammo-t. Konfigurálható, hogy mennyi ammotól adjon és mennyit.

    Konfigurálható, hogy milyen fegyverekkel lehet használni (Pisztoly ajánlott, esetleg bugolhat is nagyobb fegyverrel)

    Mikor használod a shield-et a kezedben kell lennie egy fegyvernek, ha nincs a script automatikusan a legutóbbi fegyvered veszi elő,
    vagy ha nincs legutóbbi értesít, hogy végy elő pisztolyt.

    Optimalizált
    - nem használatban - 0.1 ms
    - használatban - min 0.2 max 0.5 - átlag 0.3

    Ha shield használata közben elteszed a fegyvered, elveszi tőled a shield-et.
    Ha shield használata közben elesel, elveszi tőled a shield-et.
    Ha shield használata közben meghalsz, elveszi tőled a shield-et.
    Ha shield használata közben vízbe mész, elveszi tőled a shield-et.
    Ha shield használata közben q-t nyomsz, azaz fedezékbe mész, elveszi tőled a shield-et.
    Nem ülhetsz be autóba shield használata közben, mivel autóval használva bugos, ha megpróbálod elveszi tőled a shield-et.

    A shield elrakásának leggyorsabb módja a más fegyverre váltás (akár kéz).
]]
