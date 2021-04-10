ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('shield', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent("shield:toggle", source)
	xPlayer.showNotification('SCRIPT BY DEEP!')
end)
