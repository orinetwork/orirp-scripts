local QBCore = exports['qb-core']:GetCoreObject()
local craftingActive = false
local craftingStations = {
    ["darnell_bros"] = { coords = vector3(717.5, -964.9, 30.4) } -- Darnell Bros location
}

-- Function to check if player is near a crafting station
function isNearCraftingStation()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, station in pairs(craftingStations) do
        local distance = #(playerCoords - station.coords)
        if distance < 2.0 then
            return true
        end
    end
    return false
end

-- Open crafting UI
function openCraftingMenu()
    if isNearCraftingStation() then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openCraftingMenu"
        })
        craftingActive = true
    else
        print("No")
    end
end

-- Close crafting UI
RegisterNUICallback("closeCraftingMenu", function(data)
    SetNUIFocus(false, false)
    craftingActive = false
end)

-- Request crafting item from server
RegisterNUICallback("craftItem", function(data)
    local item = data.item
    TriggerServerEvent('crafting:craftItem', item)
end)

-- Check for key press to open crafting table
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 38) then -- "E" key
            if not craftingActive then
                openCraftingMenu()
            else
                SetNuiFocus(false, false)
                craftingActive = false
            end
        end
    end
end)

