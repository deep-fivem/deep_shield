ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem(Config.itemName,
function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent("shield:toggle", source)
    xPlayer.showNotification('SCRIPT BY deep#4324!')
end)
