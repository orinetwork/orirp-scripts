local oxmysql = exports.oxmysql

-- Player Connecting Event with Deferral
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local src = source
    deferrals.defer()

    local discordIdentifier
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(identifier, "discord:") then
            discordIdentifier = identifier:gsub("discord:", "")
            break
        end
    end

    if not discordIdentifier then
        deferrals.done("Discord must be connected to join this server.")
        return
    end

    -- Check if the player is banned
    MySQL.query('SELECT * FROM ori_bans WHERE `discord_id` = ?', {discordIdentifier}, function(result)
        if #result > 0 then
            local banInfo = result[1]
            local banReason = banInfo.reason
            local bannedBy = banInfo.banned_by
            deferrals.done(string.format(
                "You are banned from Ori Roleplay for the following reason: %s. Banned by: %s. If you feel this is a mistake, you can appeal this at comingsoon",
                banReason,
                bannedBy
            ))
        else
            deferrals.done()  -- Allow connection
        end
    end)
end)

-- Register the ban command
RegisterCommand("ban", function(source, args, rawCommand)
    local src = source
    local targetID = tonumber(args[1])
    local reason = table.concat(args, " ", 2)

    -- Check if the player running the command has permission
        if targetID and reason and GetPlayerName(targetID) then
            local targetName = GetPlayerName(targetID)
            local discordIdentifier

            for _, identifier in ipairs(GetPlayerIdentifiers(targetID)) do
                if string.find(identifier, "discord:") then
                    discordIdentifier = identifier:gsub("discord:", "")
                    break
                end
            end

            if not discordIdentifier then
                TriggerClientEvent('chat:addMessage', src, { args = { "System", "The player does not have Discord connected." } })
                return
            end

            local bannedBy = GetPlayerName(src)

            -- Correct SQL query as a string
            local query = "INSERT INTO ori_bans (discord_id, name, banned_by, reason) VALUES (?, ?, ?, ?)"
            local params = {discordIdentifier, targetName, bannedBy, reason}

            -- Execute the SQL query
            MySQL.insert(query, params, function(insertId)
                if insertId then
                    -- Kick the player with a ban message
                    DropPlayer(targetID, string.format(
                        "You have been banned from Ori Roleplay for %s by %s. If you feel like this is a mistake you can appeal this at https://discord.gg/comingsoon\nYou ban id is: %s",
                        reason,
                        bannedBy,
                        insertId
                    ))

                    TriggerClientEvent('chat:addMessage', src, { args = { "System", "Player has been successfully banned." } })
                else
                    TriggerClientEvent('chat:addMessage', src, { args = { "System", "Failed to ban the player. Please try again." } })
                end
            end)
        else
            TriggerClientEvent('chat:addMessage', src, { args = { "System", "Invalid player ID or reason." } })
        end
end, false)


RegisterCommand("kick", function(source, args, rawCommand)
    local src = source
    local targetID = tonumber(args[1])
    local reason = table.concat(args, " ", 2)

    -- Check if the player running the command has permission
        if targetID and reason and GetPlayerName(targetID) then
            local targetName = GetPlayerName(targetID)

            local kickedBy = GetPlayerName(src)

            -- Execute the SQL query
            DropPlayer(targetID, string.format(
                "You have been kicked from Ori Roleplay for %s by %s.",
                    reason,
                    kickedBy
                ))

            TriggerClientEvent('chat:addMessage', src, { args = { "System", "Player has been successfully kicked." } })
        else
            TriggerClientEvent('chat:addMessage', src, { args = { "System", "Invalid player ID or reason." } })
        end
end, false)

RegisterCommand("unban", function(source, args, rawCommand)
    local src = source
    local banID = tonumber(args[1])

    if not banID then
        TriggerClientEvent('chat:addMessage', src, { args = { "System", "Invalid ban ID."} })
        return
    end

    -- Check if the ban exists
    local checkQuery = "SELECT * FROM ori_bans WHERE ban_id = ?"
    local checkParams = {banID}

    MySQL.query(checkQuery, checkParams, function(result)
        if #result > 0 then
            -- Ban exists, proceed to delete it
            local deleteQuery = "DELETE FROM ori_bans WHERE ban_id = ?"
            local deleteParams = {banID}

            MySQL.update(deleteQuery, deleteParams, function(affectedRows)
                if affectedRows > 0 then
                    -- Successfully deleted the ban
                    TriggerClientEvent('chat:addMessage', src, { args = { "System", string.format("Ban with ID %d has been successfully removed.", banID) } })
                    print(string.format("Ban with ID %d has been removed by %s.", banID, GetPlayerName(src)))
                else
                    -- Failed to delete the ban
                    TriggerClientEvent('chat:addMessage', src, { args = { "System", "Failed to remove the ban. Please try again." } })
                end    
            end)
        else
            -- Ban ID does not exist
            TriggerClientEvent('chat:addMessage', src, { args = { "System", string.format("No ban found with ID %d.", banID) } })
        end
    end)
end, false)

RegisterServerEvent('ori:bringPlayer')
AddEventHandler('ori:bringPlayer', function(targetId, coords)
    TriggerClientEvent('ori:teleportPlayer', targetId, coords)
end)