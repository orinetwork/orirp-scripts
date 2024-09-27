exports ['qb-target']:AddTargetModel(GetAllVehicleModels(), {
    options = { 
        {
            label = "Lockpick Vehicle",
            icon = "fas fa-car-side",
            action = function(entity)
                TriggerEvent('startLockpick', entity)
            end
            canInteract = function(entity)
                return IsVehicleLocked(entity)
            end
        }
    },
    distance = 2.0
})

-- Register the lockpicking event
RegisterNetEvent('startLockpick')
AddEventHandler('startLockpick', function(vehicle)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local lockpicks = QBCore.Functions.GetPlayerData().items['lockpick']

    -- Check if player has a lockpick
    if lockpicks and lockpicks > 0 then
        -- Initiate lockpicking minigame
        StartLockpickingMinigame(vehicle)
    else
        QBCore.Functions.Notify('You don\'t have a lockpick!', "error")
    end
end)

function StartLockpickingMinigame(vehicle)
    local attempts = 0
    local maxAttempts = 3
    local success = true

    -- Notify the player
    QBCore.Functions.Notify('Lockpicking started. Press SPACE when the arrow reaches the green zone.', 'info')

    -- Start the minigame loop 

    while attempts < maxAttempts do
        local passed = PerformLockpickAttempt()

        if passed then
            attempts = attempts + 1
            QBCore.Functions.Notify('Success! Keep going...', 'success')
        else
            success = false
            QBCore.Functions.Notify("You failed!", 'error')
            break
        end

        Citizen.Wait(1000) -- Short delay between attempts
    end

    -- Final outcome 
    if success and attempts == maxAttempts then
        -- Remove one lockpick from inventory
        TriggerServerEvent('removeLockpick')

        -- Unlock the vehicle
        SetVehicleDoorsLocked(vehicle, 1)
        QBCore.Functions.Notify('Vehicle unlocked!', 'success')
    else
        -- Failed, remove one lockpick from inventory
        TriggerServerEvent("removeLockpick")
        QBCore.Functions.Notify("You broke the lockpick!", 'error')
    end
end

-- Function to simulate the lockpicking attempt minigame
function PerformLockpickAttempt()
    local minigameTime = 5000 -- Time for one attempt
    local success = false

    -- Create a minigame UI (e.g., a bar with green and red zones)
    local greenZoneStart = 0.4
    local greenZoneEnd = 0.6

    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        local pressedSpace = false

        while GetGameTimer() - startTime < minigameTime do
            -- Simulate the arrow moving
            local arrowPos = (GetGameTimer() - startTime) / minigameTime

            -- Check for spacebar press
            if IsControlJustPressed(0, 22) then -- SPACE key (control 22)
                pressedSpace = true
                break
            end

            Citizen.Wait(0)
        end

        if pressedSpace and arrowPos >= greenZoneStart and arrowPos <= greenZoneEnd then
            success = true
        end
    end)

    Citizen.Wait(minigameTime)
    return success
end

-- Server-side event to remove the lockpick item
RegisterNetEvent('removeLockpick')
AddEventHandler('removeLockpick', function()
    local player = QBCore.Functions.GetPlayer(source)
    player.Functions.RemoveItem('lockpick', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['lockpick'], 'remove')
end)

-- Helper function to check if a vehicle is locked
function IsVehicleLocked(vehicle)
    local lockStatus = GetVehicleDoorLockStatus(vehicle)
    return lockStatus == 2 -- Locked status
end