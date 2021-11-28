FX.Player = FX.Player or {}
FX.LocalPlayer = {}
FX.DiscordData = {}

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    while true do
        if NetworkIsSessionStarted() then
            TriggerEvent("fxbase:playerSessionStarted")
            TriggerServerEvent("fxbase:playerSessionStarted")
            break
        end
    end
end)

RegisterNetEvent("fxbase:updateClient")
AddEventHandler("fxbase:updateClient", function(data)
    FX.LocalPlayer = data
end)

RegisterNetEvent('fxbase:firstSpawn')
AddEventHandler("fxbase:firstSpawn", function(spawn)
    Citizen.CreateThread(function()
        SetTimecycleModifier('default')
        TransitionToBlurred(500)        
        DoScreenFadeOut(500)

        while IsScreenFadingOut() do
            Citizen.Wait(0)
        end

        RequestModel('mp_m_freemode_01')

        while not HasModelLoaded('mp_m_freemode_01') do
            RequestModel('mp_m_freemode_01')
            Wait(0)
        end

        SetPlayerModel(PlayerId(), 'mp_m_freemode_01')
        SetModelAsNoLongerNeeded('mp_m_freemode_01')
        SetPedDefaultComponentVariation(PlayerPedId())

        TriggerEvent("fxbase:initialSpawnModelLoaded")
        TriggerServerEvent("fxbase:initialSpawnModelLoaded")

        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)

        local ped = PlayerPedId()

        SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)

        SetEntityVisible(ped, true)
        FreezeEntityPosition(PlayerPedId(), false)

        NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, 100, true, true, false)
        ClearPedTasksImmediately(ped)
        RemoveAllPedWeapons(ped)
        ClearPlayerWantedLevel(PlayerId())

        local startedCollision = GetGameTimer()

        while not HasCollisionLoadedAroundEntity(ped) do
            if GetGameTimer() - startedCollision > 8000 then break end
            Citizen.Wait(0)
        end

        Citizen.Wait(500)
        
        while IsScreenFadingIn() do
            Citizen.Wait(0)
        end

        TransitionFromBlurred(500)

        TriggerEvent("fxbase:playerSpawned")

        DestroyAllCams(true)
        RenderScriptCams(false, true, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)

        DoScreenFadeIn(500)
        FX.Player.PlayerLoop()
    end)
end)

FX.Player.PlayerLoop = function()
    SetNuiFocus(false, false)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(15000)
            ped = PlayerPedId()
            coords = GetEntityCoords(ped)
            heading = GetEntityHeading(ped)
            TriggerServerEvent("fxbase:updatePlayerLocation", { x = coords.x, y = coords.y, z = coords.z, h = heading })
        end
    end)
end

RegisterNetEvent("fxbase:networkDiscord")
AddEventHandler("fxbase:networkDiscord", function(data)
    FX.DiscordData = data
end)

FX.GetPlayerName = function(source, discriminator)
    local src = source ~= source and source or PlayerId()

    if GetPlayerServerId(source) and FX.DiscordData[GetPlayerServerId(source)] then
        return discriminator == true and (FX.DiscordData[GetPlayerServerId(source)].user.username .. '#' .. FX.DiscordData[GetPlayerServerId(source)].user.discriminator) or (FX.DiscordData[GetPlayerServerId(source)].user.username)
    end
    return nil
end

exports("GetPlayerName", FX.GetPlayerName)
