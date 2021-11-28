FX.Vehicle = FX.Vehicle or {}
FX.Vehicle.ClientVehicles = {}

FX.Vehicle.GetProperties = function(vehicle)
    local Properties = {}
    local r, g, b = GetVehicleTyreSmokeColor(vehicle)
    Properties["ColorPrimary"], Properties["ColorSecondary"] = GetVehicleColours(vehicle)
    Properties["PearlescentColor"], Properties["WheelColor"] = GetVehicleExtraColours(vehicle)
    Properties["Dirty"] = GetVehicleDirtLevel(vehicle)
    Properties["Fuel"] = GetVehicleFuelLevel(vehicle)
    Properties["Livery"] = GetVehicleLivery(vehicle)
    Properties["Plate"] = GetVehicleNumberPlateText(vehicle)
    Properties["PlateIndex"] = GetVehicleNumberPlateTextIndex(vehicle)
    Properties["OilLevel"] = GetVehicleOilLevel(vehicle)
    Properties["WheelType"] = GetVehicleWheelType(vehicle)
    Properties["Clutch"] = GetVehicleClutch(vehicle)
    Properties["BodyHealth"] = GetVehicleBodyHealth(vehicle)
    Properties["EngineHealth"] = GetVehicleEngineHealth(vehicle)
    Properties["WindowTint"] = GetVehicleWindowTint(vehicle)
    Properties["ModKit"] = GetVehicleModKit(vehicle)
    Properties["DashboardColor"] = GetVehicleDashboardColour(vehicle)
    Properties["TyreSmokeColor"] = table.pack(GetVehicleTyreSmokeColor(vehicle))
    Properties["NeonColor"] = table.pack(GetVehicleNeonLightsColour(vehicle))
    Properties["Mods"] = {}
    Properties["Extras"] = {}
    Properties["NeonsEnabled"] = {}

    for i=0,50 do 
        Properties["Mods"][i] = GetVehicleMod(vehicle, i)
    end

	for i=0, 12 do
		if DoesExtraExist(vehicle, i) then
			Properties["Extras"][i] = IsVehicleExtraTurnedOn(vehicle, i) == 1
		end
    end
    
    for i=0,3 do 
        if IsVehicleNeonLightEnabled(vehicle,i) then
            table.insert(Properties["NeonsEnabled"], i)
        end
    end

    return Properties
end

FX.Vehicle.SetProperties = function(vehicle, Properties)
    if DoesEntityExist(vehicle) then

        if Properties["ColorPrimary"] and Properties["ColorSecondary"] then
            SetVehicleColours(vehicle, Properties["ColorPrimary"], Properties["ColorSecondary"])
        end

        if Properties["PearlescentColor"] and Properties["WheelColor"] then
            SetVehicleExtraColours(vehicle, Properties["PearlescentColor"], Properties["WheelColor"])
        end

        if Properties["Dirty"] then
            SetVehicleDirtLevel(vehicle, Properties["Dirty"])
        end

        if Properties["Fuel"] then
            SetVehicleFuelLevel(vehicle, Properties["Fuel"])
        end

        if Properties["Livery"] then
            SetVehicleLivery(vehicle, Properties["Livery"])
        end

        if Properties["Plate"] then
            SetVehicleNumberPlateText(vehicle, Properties["Plate"])
        end

        if Properties["PlateIndex"] then
            SetVehicleNumberPlateTextIndex(vehicle, Properties["PlateIndex"])
        end

        if Properties["OilLevel"] then
            SetVehicleOilLevel(vehicle, Properties["OilLevel"])
        end

        if Properties["WheelType"] then
            SetVehicleWheelType(vehicle, Properties["WheelType"])
        end

        if Properties["Clutch"] then
            SetVehicleClutch(vehicle, Properties["Clutch"])
        end

        if Properties["BodyHealth"] then
            SetVehicleBodyHealth(vehicle, Properties["BodyHealth"])
        end

        if Properties["EngineHealth"] then
            SetVehicleEngineHealth(vehicle, Properties["EngineHealth"])
        end

        if Properties["WindowTint"] then
            SetVehicleWindowTint(vehicle, Properties["WindowTint"])
        end

        if Properties["ModKit"] then
            SetVehicleModKit(vehicle, Properties["ModKit"])
        end

        if Properties["DashboardColor"] then
            SetVehicleDashboardColour(vehicle, Properties["DashboardColor"])
        end

        if Properties["TyreSmokeColor"][1] and Properties["TyreSmokeColor"][2] and Properties["TyreSmokeColor"][3] then
            SetVehicleTyreSmokeColor(vehicle,Properties["TyreSmokeColor"][1], Properties["TyreSmokeColor"][2], Properties["TyreSmokeColor"][3])
        end

        if Properties["NeonColor"][1] and Properties["NeonColor"][2] and Properties["NeonColor"][3] then
            SetVehicleNeonLightsColour(vehicle,Properties["NeonColor"][1], Properties["NeonColor"][2], Properties["NeonColor"][3])
        end

        if Properties["Mods"] then
            for k,v in pairs(Properties["Mods"]) do
                if k == 18 then
                    ToggleVehicleMod(vehicle,  k, v)
                elseif k == 20 then
                    ToggleVehicleMod(vehicle, k, true)
                elseif k == 22 then
                    ToggleVehicleMod(vehicle,  k, v)
                else
                    SetVehicleMod(vehicle, k, v, false)
                end
            end
        end

        return true
    end

    return false
end

FX.Vehicle.Spawn = function(model, coords, heading, networked)
    if type(model) ~= 'number' then
        model = GetHashKey(model)
    end

    if coords == nil then
        coords = GetEntityCoords(PlayerPedId())
    end

    if heading == nil then
        heading = 100
    end

	RequestModel(model)

	while not HasModelLoaded(model) do
		Citizen.Wait(0)
    end

	local vehicle = CreateVehicle(model, coords.x or 0, coords.y or 0, coords.z or 0, heading, networked == nil and true or networked, false)

    if not networked then
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(vehicle), true)
    end

	SetEntityAsMissionEntity(vehicle, true, false)
	SetVehicleHasBeenOwnedByPlayer(vehicle, true)
	SetVehicleNeedsToBeHotwired(vehicle, false)
	SetModelAsNoLongerNeeded(model)

	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	while not HasCollisionLoadedAroundEntity(vehicle) do
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		Citizen.Wait(0)
    end

	SetVehRadioStation(vehicle, 'OFF')

	return vehicle
end

FX.Vehicle.Delete = function(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

FX.Vehicle.Get = function()
    local vehicles = {}
	for vehicle in FX.Functions.EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) do
		table.insert(vehicles, vehicle)
	end
	return vehicles
end

FX.Vehicle.GetClosest = function(coords, maxDistance)
	local vehicles = FX.Vehicle.Get()
	local closestDistance = -1
	local closestVehicle  = -1
    local coords = coords or GetEntityCoords(PlayerPedId())
    local maxDistance = maxDistance or 150

    for k,v in pairs(vehicles) do
        local vehicleCoords = GetEntityCoords(v)
		local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

		if (closestDistance == -1 or closestDistance > distance) and (distance <= maxDistance) then
			closestVehicle  = v
			closestDistance = distance
		end
    end
    
	return closestVehicle,closestDistance
end

FX.Vehicle.IsOwnedThisVehicle = function(plate)
    for k,v in pairs(FX.Vehicle.ClientVehicles) do
        print(v.plate)
        if v.plate == plate then
            return true
        end
    end

    return false
end

RegisterNetEvent("fxbase:firstSpawn")
AddEventHandler("FX:firstSpawn", function()
    TriggerServerEvent("vehicles:getPlayerVehicles")
end)

RegisterNetEvent("vehicles:getPlayerVehicles")
AddEventHandler("vehicles:getPlayerVehicles", function(vehicles)
    FX.Vehicle.ClientVehicles = vehicles
end)