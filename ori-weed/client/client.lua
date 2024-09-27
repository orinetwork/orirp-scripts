local QBCore = exports['qb-core']:GetCoreObject()

local isPlanting = false
local isSelling = false
local plantCoords = vector3(-582.41, 24.44, 43.93)
local plantRadius = 3.0  -- Radius within which the player can plant the seed

-- Function to check if the player is within the planting area
local function IsPlayerInPlantingArea()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - plantCoords)
    return distance <= plantRadius
end

-- Function to handle the planting process
local function PlantWeedSeed()
    if isPlanting then
        QBCore.Functions.Notify('You are already planting a seed!', 'error')
        return
    end

    -- Ensure player has the seed
    QBCore.Functions.TriggerCallback('weed:checkForSeeds', function(hasSeed)
        if hasSeed then
            isPlanting = true

            -- Trigger server event to plant the seed
            TriggerServerEvent('weed:plantSeed', plantCoords)
            
            QBCore.Functions.Notify('Weed seed planted. Wait for it to grow.', 'success')
            isPlanting = false
        else
            QBCore.Functions.Notify('You don\'t have any weed seeds!', 'error')
        end
    end)
end

-- Monitor for player input (E key) when in the planting area
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPlayerInPlantingArea() then
            QBCore.Functions.DrawText3D(plantCoords.x, plantCoords.y, plantCoords.z, "[E] Plant Weed Seed")
            if IsControlJustReleased(0, 38) then -- 38 is the E key
                PlantWeedSeed()
            end
        end
    end
end)

RegisterNetEvent('weed:growWeed', function()
    QBCore.Functions.Notify('Weed is growing...', 'success')
    Citizen.Wait(Config.GrowTime * 1000)

    -- When the weed is ready to be cut, add a qb-target zone
    exports['qb-target']:AddCircleZone("weed_cutting_zone", plantCoords, 10.0, {
        name = "weed_cutting_zone",
        useZ = true,
    }, {
        options = {
            {
                type = "client",
                event = 'weed:cutWeed',
                icon = 'fas fa-scissors',
                label = 'Cut Weed Plant',
                canInteract = function()
                    return true
                end
            }
        },
        distance = 1.5
    })

    QBCore.Functions.Notify('Weed is ready to harvest. Interact with it to cut it.', 'success')
end)

-- Handle cutting the weed
RegisterNetEvent('weed:cutWeed', function()
    QBCore.Functions.Notify('You cut the weed plant.', 'success')

    -- Remove the qb-target zone after cutting
    exports['qb-target']:RemoveZone("weed_cutting_zone")

    -- Trigger server event to handle weed collection
    TriggerServerEvent('weed:collectWeed')
end)


-- Function to sell weed using radial menu and PCs
RegisterNetEvent('weed:sellWeed', function()
    if isSelling then
        QBCore.Functions.Notify('You are already selling weed!', 'error')
        return
    end

    isSelling = true
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local weedCount = QBCore.Functions.GetItemByName('weed')

    if not weedCount or weedCount.amount <= 0 then
        QBCore.Functions.Notify('You have no weed to sell!', 'error')
        isSelling = false
        return
    end

    QBCore.Functions.Notify('NPCs are approaching to buy weed...', 'success')

    -- Start NPC selling process
    Citizen.CreateThread(function()
        local npcCount = 0
        while npcCount < Config.MaxNPCs and weedCount.amount > 0 do
            Citizen.Wait(Config.NPCTimeInterval)
            local npc = createNPCNearby(playerCoords)

            if npc then
                TaskGoToEntity(npc, playerPed, -1, 2.0, 1.0, 1073741824, 0)
                Citizen.Wait(5000) -- Wait for NPC to reach the player.

                sellTonNPC(npc)
                npcCount = npcCount + 1

                weedCount = QBCore.Functions.GetItemByName('weed')
                if not weedCount or weedCount.amount < 0 then
                    QBCore.Functions.Notify('You have ran out of weed!', 'error')
                    break
                end
            end
        end

        isSelling = false
    end) 
end)

function createNPCNearby(playerCoords)
    local npcModel = Config.NPCModels[math.random(#Config.NPCModels)]
    local model = GetHashKey(npcModel)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(1)
    end

    local offsetX = math.random(-10, 10)
    local offsetY = math.random(-10, 10)
    local spawnCoords = vector3(playerCoords.x + offSet, playerCoords.y + offsetY, playerCoords.z)

    local npc = CreatePed(4, model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
    SetEntityAsMissionEntity(npc, true, true)
    return npc
end

function sellToNPC(npc)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local npcCoords = GetEntityCoords(npc)

    if #(playerCoords - npcCoords) < 2.0 then
        local sellPrice = math.random(Config.SellPriceMin, Config.SellPriceMax)
        TriggerServerEvent('weed:sellWeedNPC', sellPrice)

        QBCore.Functions.Notify('You sold weed to an NPC for $'..sellPrice, 'success')

        TaskWanderStandard(npc, 10.0, 10)
        SetPedAsNoLongerNeeded(npc)
    end
end
