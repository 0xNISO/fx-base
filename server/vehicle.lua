FX.Vehicle = FX.Vehicle or {}

RegisterServerEvent("vehicles:getPlayerVehicles")
AddEventHandler("vehicles:getPlayerVehicles", function()
    FX.Vehicle.UpdateClientVehicles(source)
end)

RegisterServerEvent("vehicles:addVehicle")
AddEventHandler("vehicles:addVehicle", function(plate,properties)
    local src = source
    local user = FX.GetPlayer(src)

    exports['ghmattimysql']:execute("INSERT INTO `vehicles` (`steam`, `plate`, `properties`) VALUES ('" .. user["PlayerData"]["steam"] .. "', '" .. plate .. "', '" .. json.encode(properties) .. "')", {}, function(result)
        FX.Vehicle.UpdateClientVehicles(src)
    end)
end)

RegisterServerEvent("vehicles:removeVehicle")
AddEventHandler("vehicles:removeVehicle", function(plate)
    local src = source
    local user = FX.GetPlayer(src)

    exports['ghmattimysql']:execute("DELETE FROM `vehicles` WHERE `steam`='" .. user["PlayerData"]["steam"] .. "' AND `plate`='" .. plate .. "'", {}, function(result)
        FX.Vehicle.UpdateClientVehicles(src)
    end)
end)

RegisterServerEvent("vehicles:updateVehicle")
AddEventHandler("vehicles:updateVehicle", function(plate,properties)
    local src = source
    local user = FX.GetPlayer(src)

    exports['ghmattimysql']:execute("UPDATE `vehicles` SET `properties` = '" .. json.encode(properties) .. "' WHERE `steam`='" .. user["PlayerData"]["steam"] .. "' AND `plate`='" .. plate .. "'", {}, function(result)
        FX.Vehicle.UpdateClientVehicles(src)
    end)
end)

FX.Vehicle.UpdateClientVehicles = function(source)
    local src = source
    local user = FX.GetPlayer(src)

    exports['ghmattimysql']:execute("SELECT * FROM `vehicles` WHERE `steam`='" .. user["PlayerData"]["steam"] .. "'", {}, function(result)
        local vehicles = {}
        for k,v in ipairs(result) do
            local vehicle = {}
            vehicle.plate = result[k].plate ~= nil and result[k].plate or "none"
            vehicle.garage = result[k].garage ~= nil and result[k].garage or "A"
            vehicle.properties = result[k].properties ~= nil and json.decode(result[k].properties) or {}
            table.insert(vehicles, vehicle)
        end

        TriggerClientEvent("vehicles:getPlayerVehicles", src, vehicles)
    end)
end
