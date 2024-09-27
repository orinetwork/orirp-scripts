local QBCore = exports['qb-core']:GetCoreObject()

local rockModels = {
    "prop_rock_1_c",
    "prop_rock_1_d",
    "prop_rock_1_a"
}

local spawnCoords = vector3(2933.169190, 2803.687988, 41.597046)
local spawnRadius = 10.0
local processingCoords = vector3(1102.11, -2002.29, 29.66)
local processingRadius = 5.0
local rocks = {}

-- Function to spawn a rock at a random position within the radius
local function SpawnRock()
    local model = rockModels[math.random(#rockModels)]
    local rockPos
    local attempts = 0

    while attempts < 15 do  -- Limit to 15 attempts to find a valid spot
        local xOffset = math.random(-spawnRadius, spawnRadius)
        local yOffset = math.random(-spawnRadius, spawnRadius)
        local x = spawnCoords.x + xOffset
        local y = spawnCoords.y + yOffset
        local z = spawnCoords.z + 10.0  -- Initial Z height for the search

        -- Create a rock and place it
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        rockPos = vector3(x, y, z)
        local rock = CreateObjectNoOffset(model, rockPos.x, rockPos.y, rockPos.z, false, false, false)
        
        -- Attempt to place it on the ground properly
        PlaceObjectOnGroundProperly(rock)
        FreezeEntityPosition(rock, true)
        local groundZ = GetEntityCoords(rock).z

        if groundZ >= spawnCoords.z - 2.0 and groundZ <= spawnCoords.z + 2.0 then
            -- Successfully placed
            table.insert(rocks, rock)

            -- Create a target zone for the rock
            exports['qb-target']:AddCircleZone('mine_rock_' .. rock, rockPos, 1.5, {
                name = 'mine_rock_' .. rock,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = "client",
                        event = "custom:mining",
                        icon = "fas fa-hammer",
                        label = "Mine Rock",
                        rockEntity = rock
                    }
                },
                distance = 2.5
            })

            break
        else
            -- Failed placement, delete the rock and retry
            DeleteEntity(rock)
        end

        attempts = attempts + 1
    end

    if attempts >= 15 then
        print("No suitable ground position found for rock after 15 attempts.")
    end
end

-- Event to mine the rock with jackhammer emote
RegisterNetEvent('custom:mining', function(data)
    local playerPed = PlayerPedId()
    local rockEntity = data.rockEntity

    if rockEntity then
        -- Start jackhammer emote
        RequestAnimDict("amb@world_human_const_drill@male@drill@base")
        while not HasAnimDictLoaded("amb@world_human_const_drill@male@drill@base") do
            Wait(1)
        end
        TaskPlayAnim(playerPed, "amb@world_human_const_drill@male@drill@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)

        -- Show progress bar for mining
        QBCore.Functions.Progressbar("mining_rock", "Mining Rock...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- On complete
            -- Stop jackhammer emote
            ClearPedTasksImmediately(playerPed)

            -- Add paydirt to player's inventory
            TriggerServerEvent("qb-inventory:server:AddItem", "paydirt", 1)
            TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["paydirt"], "add")

            -- Remove the rock and its target zone
            DeleteEntity(rockEntity)
            exports['qb-target']:RemoveZone('mine_rock_' .. rockEntity)

            -- Spawn a new rock
            SpawnRock()
        end, function() -- On cancel
            -- Stop jackhammer emote
            ClearPedTasksImmediately(playerPed)

            -- Notify the player that mining was canceled
            QBCore.Functions.Notify("Mining canceled", "error")
        end)
    end
end)

-- Function to process paydirt continuously
local function ProcessPaydirt()
    local playerPed = PlayerPedId()
    local hasPaydirt = QBCore.Functions.HasItem("paydirt")

    if not hasPaydirt then
        QBCore.Functions.Notify("You don't have any Paydirt to process", "error")
        return
    end

    QBCore.Functions.Progressbar("process_paydirt", "Processing Paydirt...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- On complete
        -- Remove 1 paydirt and give a random amount of a random item
        TriggerServerEvent("qb-inventory:server:RemoveItem", "paydirt", 1)

        local items = {"diamond", "gold", "ruby", "emerald"}
        local item = items[math.random(#items)]
        local amount = math.random(1, 5)

        TriggerServerEvent("qb-inventory:server:AddItem", item, amount)
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items[item], "add")

        QBCore.Functions.Notify("You received " .. amount .. " " .. item .. "(s).")

        -- Continue processing if player has more paydirt
        ProcessPaydirt()
    end, function() -- On cancel
        QBCore.Functions.Notify("Processing canceled", "error")
    end)
end

-- Processing Paydirt at the processing location
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - processingCoords)

        if dist < processingRadius then
            QBCore.Functions.DrawText3D(processingCoords.x, processingCoords.y, processingCoords.z, "Press [E] to process Paydirt")

            if IsControlJustReleased(0, 38) then  -- 38 is the key code for "E"
                ProcessPaydirt()  -- Start the paydirt processing loop
            end
        end

        Wait(0)
    end
end)

-- Initial rock spawning
CreateThread(function()
    for i = 1, 10 do
        SpawnRock()
    end
end)
