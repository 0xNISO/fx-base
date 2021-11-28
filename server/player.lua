FX.Player = FX.Player or {}
FX.Players = {}
FX.DiscordData = {}

FX.Player.SelectC1aracter = function(source, index)
    local src = source
    local steam = GetPlayerIdentifiers(source)[1]
    local result = FX.Database.Execute(true, "SELECT * FROM `characters` WHERE `steam` = '" .. steam .. "' AND `index`='" .. index .. "'")
    local admin = FX.Database.Execute(true, "SELECT * FROM `admins` WHERE `steam` = '" .. steam .. "'")

    result[1].rank = admin[1] and admin[1]['rank'] or 'user'

    if result[1] then
        local user FX.Player.CreateCharacterObject(src, result[1])
        user.UpdateClient()
        user.Save()
        return user["PlayerData"]["location"]
    end
    return false
end

FX.Player.CreateCharacterObject = function(source, result)
    local src = source
    local self = {}
    local data = result

    -- General
    self["PlayerData"] = {}
    self["PlayerData"]["source"] = src
    self["PlayerData"]["name"] = GetPlayerName(src)
    self["PlayerData"]["cid"] = data["cid"]

    -- Player Discord
    self["PlayerData"]["discord"] = FX.Player.DiscordInfo(src)
    -- Verify player steam
    self["PlayerData"]["steam"] = data["steam"] ~= nil and data["steam"] or GetPlayerIdentifiers(src)[1]
    -- Charcter ID
    self["PlayerData"]["index"] = data["index"]
    -- Player Rank
    self["PlayerData"]["rank"] = data['rank'] ~= nil and data['rank'] or 'user'
    -- Last Locations
    self["PlayerData"]["location"] = data["location"] and json.decode(data["location"]) or FX.Shared.SpawnLocation
    -- Player Character
    self["PlayerData"]['character'] = data['character'] and json.decode(data['character']) or {}
    self["PlayerData"]['character']['dob'] = self["PlayerData"]['character']['dob'] and self["PlayerData"]['character']['dob'] or "None"
    self["PlayerData"]['character']['story'] = self["PlayerData"]['character']['story'] and self["PlayerData"]['character']['story'] or "None"
    self["PlayerData"]['character']['gender'] = self["PlayerData"]['character']['gender'] and self["PlayerData"]['character']['gender'] or "None"
    self["PlayerData"]['character']['lastname'] = self["PlayerData"]['character']['lastname'] and self["PlayerData"]['character']['lastname'] or "None"
    self["PlayerData"]['character']['firstname'] = self["PlayerData"]['character']['firstname'] and self["PlayerData"]['character']['firstname'] or "None"

    -- Player Accounts (cash, bank)
    self["PlayerData"]["accounts"] = data["accounts"] and json.decode(data['accounts']) or {}
    for k,v in pairs(FX.Shared.Accounts) do
        if not self["PlayerData"]["accounts"][k] then
            self["PlayerData"]["accounts"][k] = v
        end
    end
    -- Player Metadata
    self["PlayerData"]["metadata"] = data["metadata"] and json.decode(data["metadata"]) or {}
    for k,v in pairs(FX.Shared.MetaData) do
        if not self["PlayerData"]["metadata"][k] then
            self["PlayerData"]["metadata"][k] = v
        end
    end

    -- Player Job
    self["PlayerData"]['job'] = data['job'] and json.decode(data['job']) or {}
    self["PlayerData"]['job']["name"] = FX.Shared.Jobs[self["PlayerData"]['job']["name"]] ~= nil and self["PlayerData"]['job']["name"] or 'unemployed'
    self["PlayerData"]['job']["label"] = FX.Shared.Jobs[self["PlayerData"]['job']["name"]].label
    self["PlayerData"]['job']["grade"] = FX.Shared.Jobs[self["PlayerData"]['job']["name"]]['grades'][self["PlayerData"]['job']["grade"]] ~= nil and self["PlayerData"]['job']["grade"] or 1
    self["PlayerData"]['job']["duty"] = self["PlayerData"]['job']["duty"] ~= nil and self["PlayerData"]['job']["duty"] or true

    if not FX.Shared.Jobs[self["PlayerData"]['job']['name']] then
        self["PlayerData"]['job'] = { ["name"] = 'unemployed', ["label"] = 'Unemployed', ["grade"] = 'unemployed', ["duty"] = true }
    end

    -- Saves
    self.SetMetaData = function(type, value)
        if FX.Shared.MetaData[type] and type(FX.Shared.MetaData[type]) == type(value) then
            self["PlayerData"]["metadata"][type] = value
            self.UpdateClient()
            return true
        end
        return false
    end
    
    self.RemoveAccount = function(account, money)
        if self["PlayerData"]["accounts"][account] and type(money) == 'number' then
            self["PlayerData"]["accounts"][account] = self["PlayerData"]['accounts'][account] - money
            self.UpdateClient()
            return true
        end
        return false
    end
    self.AddAccount = function(account, money)
        if self["PlayerData"]['accounts'][account] and type(money) == 'number' then
            self["PlayerData"]['accounts'][account] = self["PlayerData"]['accounts'][account] + money
            self.UpdateClient()
            return true
        end

        return false
    end

    self.SetAccount = function(account, money)
        if self["PlayerData"]['accounts'][account] and type(money) == 'number' then
            self.UpdateClient()
            self["PlayerData"]['accounts'][account] = money
            return true
        end

        return false
    end
    
    self.SetCharacterData = function(index, val)
        if self["PlayerData"]['character'][index] then
            self["PlayerData"]['character'][index] = val
            self.UpdateClient()
            return true
        end

        return false
    end

    self.SetRank = function(rank)
        for i=1,#FX.Shared.Ranks do 
            if FX.Shared.Ranks[i] == rank then
                self["PlayerData"]['rank'] = rank
                FX.Player.SetPlayerRank(self["PlayerData"]['source'], self["PlayerData"]['rank'])
                self.UpdateClient()
                return true
            end
        end

        return false
    end

    self.HasRank = function(rank)
        for i=1,#FX.Shared.Ranks do 
            if FX.Shared.Ranks[i] == rank then
                return true
            end

            if FX.Shared.Ranks[i] == self["PlayerData"]['rank'] then
                return false
            end
        end

        return false
    end

    self.SetJob = function(job,grade)
        if FX.Shared.Jobs[job] and FX.Shared.Jobs[job]['grades'][grade] then
            self["PlayerData"]['job'] = {}
            self["PlayerData"]['job']["name"] = job
            self["PlayerData"]['job']["label"] = FX.Shared.Jobs[job]["label"]
            self["PlayerData"]['job']["grade"] = FX.Shared.Jobs[job]['grades'][grade]
            self["PlayerData"]['job']["duty"] = true 
            self.UpdateClient()
            return true
        end

        return false
    end

    self.SetDuty = function(duty)
        if duty == true or duty == false then
            self["PlayerData"]['job']['duty'] = duty
            self.UpdateClient()
            return true
        end

        return false
    end

    self.Save = function()
        FX.SavePlayer(self["PlayerData"]['source'])
    end

    self.UpdateClient = function()
        TriggerClientEvent('fxbase:updateClient', self["PlayerData"]['source'], self["PlayerData"])
    end

    FX.DiscordData[src] = self['PlayerData']['discord']
    FX.Commands.Refresh(self['PlayerData']['source'])
    FX.Players[self['PlayerData']['source']] = self
    TriggerClientEvent("fxbase:networkDiscord", -1, FX.DiscordData)
    return FX.Players[self['PlayerData']['source']]
end

FX.Player.SetPlayerRank = function(source, rank)
    local src = source
    local user = FX.GetPlayer(src)
    local steam = GetPlayerIdentifiers(src)[1]
    local admin = FX.Database.Execute(true, "SELECT * FROM `admins` WHERE `steam` = '" .. steam .. "'")

    if admin[1] then
        FX.Database.Execute(true, "UPDATE `admins` SET `rank`='" .. rank .. "' WHERE `steam` = '" .. steam .. "'")
    else
        FX.Database.Execute(true, "INSERT INTO `admins` (`steam`, `rank`) VALUES ('" .. steam .. "', '" .. rank .. "')")
    end
end

FX.Player.IsBanned = function(source)
	local banned = false
    local reason = ""
    local query = "SELECT * FROM `bans` WHERE "
    local identifiers = GetPlayerIdentifiers(source)

    for k,v in pairs(identifiers) do
        query = query .. "`identifiers` LIKE '%" .. v .. "%'"

        if k ~= #identifiers then
            query = query .. " OR "
        end
    end


    FX.Database.Execute(true, query, function(result)
        if result[1] ~= nil then 
            if os.time() < result[1].expire then
                banned,reason, time, id = true, result[1].reason, os.date("*t", tonumber(result[1].expire)), result[1].id
			else
				FX.Database.Execute(true, "DELETE FROM `bans` WHERE `id` = "..result[1].id)
			end
		end
    end)
    
	return banned,reason, time, id
end

FX.Player.Ban = function(source, reason, time)
    time = tonumber(time) * 3600
    local time = tonumber(os.time() + tonumber(time)) < 2147483647 and tonumber(os.time() + tonumber(time)) or 2147483647
    local date = os.date("*t", time)

    FX.Database.Execute(false, "INSERT INTO `bans` (`identifiers`, `reason`, `expire`) VALUES ('" .. json.encode(GetPlayerIdentifiers(source)) .. "', '" .. reason .. "', '" .. time .. "')")
    DropPlayer(source, "\n[Banned] "..reason.."\n[Expires] "..date["day"].. "/" .. date["month"] .. "/" .. date["year"] .. " " .. date["hour"].. ":" .. date["min"])
end

FX.SavePlayer = function(source)
    local src = source
    local user = FX.GetPlayer(src)
    local PlayerData = user['PlayerData']

    FX.Database.Execute(true, "UPDATE `characters` SET `character`='" .. json.encode(PlayerData['character']) .. "', `accounts`='" .. json.encode(PlayerData['accounts']) .. "', `metadata`='" .. json.encode(PlayerData['metadata']) .. "', `job`='" .. json.encode(PlayerData['job']) .. "' WHERE `steam` = '" .. PlayerData['steam'] .. "' AND `index` = '" .. PlayerData['index'] .. "'")
    FX.Shared.ConsoleLog('Saved ' .. PlayerData['name'] .. ' (' .. PlayerData['source'] .. ')', 'Base')

    return true
end

FX.SavePlayers = function(source)
    for index,user in pairs(FX.GetPlayers()) do
        FX.SavePlayer(user.PlayerData['source'])
        Wait(150)
    end
end

FX.GetPlayer = function(source)
    return FX.Players[source]
end

FX.GetPlayers = function(source)
    return FX.Players
end

RegisterServerEvent("fxbase:updatePlayerLocation")
AddEventHandler("fxbase:updatePlayerLocation", function(coords)
    local src = source
    local user = FX.GetPlayer(src)

    if user then
        local PlayerData = user['PlayerData']
        FX.Database.Execute(true, "UPDATE `characters` SET `location`='" .. json.encode(coords) .. "' WHERE `steam` = '" .. PlayerData['steam'] .. "' AND `index` = '" .. PlayerData['index'] .. "'")
    end
end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()

    local src = source
    local error = nil
    local processing = true
    local steam = FX.Shared.GetIdentifier(src, 'steam')
    local discord = FX.Shared.GetIdentifier(src, 'discord')
    local banned, banReason, date, banID = FX.Player.IsBanned(src)

    CreateThread(function()
        while processing do            
            deferrals.update("Synchronization between you and Queue..")

            Wait(100)
        end
    end)

    if not steam then
        error = '\n[ERROR] Your steam is currently offline!'
    end

    if not discord then
        error = '\n[ERROR] Your discord is currently offline!'
    end
    
    if banned then
        error = "\n[Ban #" .. banID .. "] "..banReason.."\n[Expires] "..date["day"].. "/" .. date["month"] .. "/" .. date["year"] .. " " .. date["hour"].. ":" .. date["min"]
    end

    if error then
        processing = false
        setKickReason(error)
        deferrals.update(error)
        CancelEvent()
        return
    end

    Wait(2000)

   TriggerEvent("fxbase:connectQueue", src, playerName, setKickReason, deferrals)
   processing = false
end)

AddEventHandler('playerDropped', function(reason)
	local src = source
    local user = FX.GetPlayer(src)

    if user then
        FX.SavePlayer(src)
        FX.Players[src] = nil
    end
end)

CreateThread(function()
    while true do
        Wait(1000 * 60 * 2)
        FX.SavePlayers()
    end
end)


RegisterCommand('save', function(source)
    if source == 0 then
        FXs.SavePlayers()
    end
end)

FX.Player.DiscordInfo = function(source)
    local src = source
    local discord = FX.Shared.GetIdentifier(src, 'discord')
    local data = false

    if not discord then
        data = {}
    else
        PerformHttpRequest("https://discordapp.com/api/guilds/786545863786364958/members/"..string.sub(discord, 9), function(err, text, headers)
            if err == 200 then
                data = json.decode(text)
            else
                data = {}
            end
        end, "GET", "", {["Content-type"] = "application/json", ["Authorization"] = "Bot NzkxMTEyMzk0NjgzMTg3MjYw.X-Ka1Q.i4JDHdIEKUwyvUKMH646Q23Zx2o"})
    end

    while not data do
        Wait(1) 
    end

    return data
end

FX.GetPlayerName = function(source, discriminator)
    local src = source
    
    if FX.DiscordData[source] then
        return discriminator == true and (FX.DiscordData[source].user.username .. '#' .. FX.DiscordData[source].user.discriminator) or (FX.DiscordData[source].user.username)
    end

    return nil
end

exports('GetPlayerName', FX.GetPlayerName)