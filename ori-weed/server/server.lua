local QBCore = exports['qb-core']:GetCoreObject()

-- Callback to check for seeds
QBCore.Functions.CreateCallback('weed:checkForSeeds', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local seedCount = Player.Functions.GetItemByName('weed_seed')

    if seedCount and seedCount.amount > 0 then
        cb(true)
    else
        cb(false)
    end
end)

-- Server-side plant seed handling
RegisterNetEvent('weed:plantSeed', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Check if player has seeds and remove one
    if Player.Functions.RemoveItem('weed_seed', 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weed_seed'], "remove")
        TriggerClientEvent('weed:growWeed', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have any weed seeds!', 'error')
    end
end)

-- Handle weed collection
RegisterNetEvent('weed:collectWeed', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Give the player the harvested weed
    Player.Functions.AddItem('weed_ogkush', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weed_ogkush'], "add")
end)
-- Handle weed selling to NPC
RegisterNetEvent('weed:sellWeedNPC', function(sellPrice)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local weedCount = Player.Functions.GetItemByName('weed_ogkush')

    if weedCount and weedCount.amount > 0 then
        Player.Functions.RemoveItem('weed_ogkush', 1)
        Player.Functions.AddMoney('cash', sellPrice)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You have no weed to sell!', 'error')
    end
end)