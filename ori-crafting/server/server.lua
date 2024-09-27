-- server.lua
local QBCore = exports['qb-core']:GetCoreObject()

local craftingRecipes = {
    ["diamond_ring"] = { requiredItems = { ["diamond"] = 1, ["gold"] = 1 }, rewardItem = "diamond_ring" }
}

-- Event to handle crafting
RegisterServerEvent('crafting:craftItem')
AddEventHandler('crafting:craftItem', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local recipe = craftingRecipes[item]

    if recipe then
        local hasItems = true

        -- Check if player has required items
        for requiredItem, quantity in pairs(recipe.requiredItems) do
            local itemCount = Player.Functions.GetItemByName(requiredItem)

            if not itemCount or itemCount.amount < quantity then
                hasItems = false
                TriggerClientEvent('QBCore:Notify', src, "You don't have enough " .. requiredItem, 'error')
                break
            end
        end

        -- If player has items, remove them and give the crafted item
        if hasItems then
            for requiredItem, quantity in pairs(recipe.requiredItems) do
                Player.Functions.RemoveItem(requiredItem, quantity)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[requiredItem], "remove")
            end

            Player.Functions.AddItem(recipe.rewardItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[recipe.rewardItem], "add")
            TriggerClientEvent('QBCore:Notify', src, "You crafted a " .. recipe.rewardItem, 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Invalid crafting item.", 'error')
    end
end)
