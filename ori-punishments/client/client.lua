local MenuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("Ori Roleplay", "Management Menu")
MenuPool:Add(mainMenu)

local menuVisible = false

-- Function to create the main menu
function CreateMainMenu(menu)
    -- Player Management submenu
    local playerManagement = MenuPool:AddSubMenu(menu, "Player Management", "Manage players on the server")
    local serverManagement = NativeUI.CreateItem("Server Management", "Manage server settings and features")
    
    menu:AddItem(serverManagement)
    
    serverManagement.Activated = function(sender, item)
        if item == serverManagement then
            Notify("Server Management: Coming Soon!")
        end
    end

    -- Initial population of player list
    AddPlayersToMenu(playerManagement)

    -- Update player list every 10 seconds
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10000) -- 10 seconds
            if menuVisible then
                UpdatePlayerList(playerManagement)
            end
        end
    end)
end

-- Function to add players to the Player Management menu
function AddPlayersToMenu(menu)
    Citizen.CreateThread(function()
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local playerName = GetPlayerName(GetPlayerFromServerId(playerId))
            local playerItem = NativeUI.CreateItem(playerName, "Select an action for this player")

            menu:AddItem(playerItem)

            playerItem.Activated = function(sender, item)
                if item == playerItem then
                    OpenPlayerActionsMenu(menu, playerId)
                end
            end
        end

        MenuPool:RefreshIndex()
    end)
end

-- Function to update the player list in the menu
function UpdatePlayerList(menu)
    menu:Clear() -- Clear the current list of players
    AddPlayersToMenu(menu) -- Repopulate the menu with the updated player list
    MenuPool:RefreshIndex() -- Refresh the menu to reflect changes
end

-- Function to create the Player Actions directly in the submenu
function OpenPlayerActionsMenu(menu, playerId)
    local kickOption = NativeUI.CreateItem("Kick Player", "Kick this player from the server")
    local banOption = NativeUI.CreateItem("Ban Player", "Ban this player from the server")
    local teleportOption = NativeUI.CreateItem("Teleport to Player", "Teleport to the selected player")
    local bringOption = NativeUI.CreateItem("Bring Player", "Teleport the selected player to you")
    menu:Clear()  -- Clear previous items in the menu
    menu:AddItem(kickOption)
    menu:AddItem(banOption)
    menu:AddItem(teleportOption)
    menu:AddItem(bringOption)

    kickOption.Activated = function(sender, item)
        if item == kickOption then
            local reason = GetUserInput("Enter reason for kick:", "", 100)
            if reason then
                ExecuteCommand("kick " .. playerId .. " " .. reason)
                Notify("Player kicked successfully.")
                mainMenu:Visible(false)  -- Close the menu after action
                menuVisible = false
            end
        end
    end

    banOption.Activated = function(sender, item)
        if item == banOption then
            local reason = GetUserInput("Enter reason for ban:", "", 100)
            if reason then
                ExecuteCommand("ban " .. playerId .. " " .. reason)
                Notify("Player banned successfully.")
                mainMenu:Visible(false)  -- Close the menu after action
                menuVisible = false
            end
        end
    end

    -- Teleport to player
    teleportOption.Activated = function(sender, item)
        if item == teleportOption then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
            local playerPed = PlayerPedId()
            local targetCoords = GetEntityCoords(targetPed)

            SetEntityCoords(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, true)
            Notify("You have been teleported to " .. GetPlayerName(GetPlayerFromServerId(playerId)) .. ".")
            mainMenu:Visible(false)  -- Close the menu after action
            menuVisible = false
        end
    end

    -- Bring player
    bringOption.Activated = function(sender, item)
        if item == bringOption then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            TriggerServerEvent('ori:bringPlayer', playerId, playerCoords) -- Trigger server event to bring the player
            Notify("Player has been brought to your location.")
            mainMenu:Visible(false)  -- Close the menu after action
            menuVisible = false
        end
    end

    MenuPool:RefreshIndex()
end

RegisterNetEvent('ori:teleportPlayer')
AddEventHandler('ori:teleportPlayer', function(targetId, coords)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    SetEntityCoords(targetPed, coords.x, coords.y, coords.z, false, false, false, true)
end)

-- Utility function to get player input
function GetUserInput(textEntry, inputText, maxLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", inputText, "", "", "", maxLength) 

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        return GetOnscreenKeyboardResult()
    else
        return nil
    end
end

-- Utility function to fetch players on the server
function GetPlayers()
    local players = {}
    for i = 0, 256 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))  -- Ensure to get the server ID
        end
    end
    return players
end

-- Utility function to send notifications
function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Disable mouse controls function
function DisableMouseControls()
    DisableAllControlActions(0)
    EnableControlAction(0, 1, true)  -- INPUT_NEXT_CAMERA
    EnableControlAction(0, 2, true)  -- INPUT_LOOK_LR
    EnableControlAction(0, 3, true)  -- INPUT_LOOK_UD
    EnableControlAction(0, 4, true)  -- INPUT_LOOK_UP
    EnableControlAction(0, 5, true)  -- INPUT_LOOK_DOWN
end

-- Enable mouse controls function
function EnableMouseControls()
    EnableAllControlActions(0)
end

-- Key press event handler
Citizen.CreateThread(function()
    CreateMainMenu(mainMenu)
    MenuPool:RefreshIndex()

    while true do
        Citizen.Wait(0)
        MenuPool:ProcessMenus()

        if IsControlJustPressed(0, 344) then -- 344 is the control code for F11
            menuVisible = not menuVisible
            mainMenu:Visible(menuVisible)

            if menuVisible then
                DisableMouseControls()  -- Disable mouse controls when menu is visible
            else
                EnableMouseControls()  -- Re-enable mouse controls when menu is hidden
            end
        end
    end
end)
