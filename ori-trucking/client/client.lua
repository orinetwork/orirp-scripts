-- Cluckin Bell Factory coordinates
local cluckinBellFactory = vector3(-68.77, 6258.87, 31.09) -- Change this to your Cluckin Bell location
local cluckinBellPedModel = 'cs_bradcadaver' -- Ped model at Cluckin Bell
local deliveryPedModel = 's_m_m_trucker_01' -- Ped model at delivery locations
local truckModel = 'mule' -- Truck model
local playerJob = false -- Job status tracker
local jobVehicle = nil

-- Delivery locations
local deliveryLocations = {
    { name = "Grove Street 24/7", coords = vector3(-47.4, -1758.29, 29.42) },
    { name = "The Docks in Los Santos", coords = vector3(1210.76, -3230.59, 5.8) },
    { name = "Pacific Bank", coords = vector3(252.49, 225.51, 106.29) }
}

-- Function to spawn ped at the factory
local function spawnCluckinBellPed()
    RequestModel(cluckinBellPedModel)
    while not HasModelLoaded(cluckinBellPedModel) do
        Wait(10)
    end

    local ped = CreatePed(4, cluckinBellPedModel, cluckinBellFactory.x, cluckinBellFactory.y, cluckinBellFactory.z, 100.0, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "job:startTruckJob",
                icon = "fas fa-truck",
                label = "Start Truck Job",
            }
        },
        distance = 2.0
    })
end

-- Function to spawn job vehicle (Mule)
local function spawnJobVehicle()
    RequestModel(truckModel)
    while not HasModelLoaded(truckModel) do
        Wait(10)
    end

    local vehicle = CreateVehicle(truckModel, cluckinBellFactory.x + 5.0, cluckinBellFactory.y + 5.0, cluckinBellFactory.z, 100.0, true, false)
    jobVehicle = vehicle

    -- Give player keys to the spawned vehicle using QBCore's vehicle key system
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerServerEvent('QBCore:Server:SetVehicleOwned', plate)
    TriggerEvent('vehiclekeys:client:SetOwner', plate)

    QBCore.Functions.Notify("You have the keys to the truck.")
end

-- Function to choose a random delivery location
local function getRandomDeliveryLocation()
    local randomIndex = math.random(1, #deliveryLocations)
    return deliveryLocations[randomIndex]
end

-- Start the truck job
RegisterNetEvent('job:startTruckJob', function()
    if playerJob then
        QBCore.Functions.Notify("You're already on a job!", "error")
        return
    end

    playerJob = true
    spawnJobVehicle()

    -- Choose random location and set waypoint
    local deliveryLocation = getRandomDeliveryLocation()
    SetNewWaypoint(deliveryLocation.coords.x, deliveryLocation.coords.y)

    QBCore.Functions.Notify("Drive the truck to the " .. deliveryLocation.name)
end)

-- Function to complete delivery
local function completeDelivery(ped, deliveryLocation)
    if not playerJob then return end

    if DoesEntityExist(jobVehicle) then
        DeleteVehicle(jobVehicle)
    end

    -- Random payout between 1000 and 4000
    local payout = math.random(1000, 4000)
    TriggerServerEvent('QBCore:Server:AddMoney', 'cash', payout)

    QBCore.Functions.Notify("Delivery complete! You earned $" .. payout)

    -- Clean up the job
    playerJob = false
    RemoveBlip(ped.blip)
    DeleteEntity(ped)
end

-- Function to spawn delivery ped
local function spawnDeliveryPed(location)
    RequestModel(deliveryPedModel)
    while not HasModelLoaded(deliveryPedModel) do
        Wait(10)
    end

    local ped = CreatePed(4, deliveryPedModel, location.coords.x, location.coords.y, location.coords.z, 100.0, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "job:completeTruckJob",
                icon = "fas fa-clipboard-check",
                label = "Deliver Truck",
                action = function()
                    completeDelivery(ped, location)
                end
            }
        },
        distance = 2.0
    })
end

-- Complete job when delivery location is reached
RegisterNetEvent('job:completeTruckJob', function()
    if not playerJob then
        QBCore.Functions.Notify("You are not on a job!", "error")
        return
    end

    local deliveryLocation = getRandomDeliveryLocation()
    spawnDeliveryPed(deliveryLocation)
end)

-- Create a blip for Cluckin Bell Factory
local function createBlip()
    local blip = AddBlipForCoord(cluckinBellFactory.x, cluckinBellFactory.y, cluckinBellFactory.z)
    SetBlipSprite(blip, 477) -- Truck icon
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 5) -- Yellow color
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Cluckin Bell Factory")
    EndTextCommandSetBlipName(blip)
end

-- On resource start, spawn the Cluckin Bell ped and set blip
CreateThread(function()
    spawnCluckinBellPed()
    createBlip()
end)
