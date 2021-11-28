FX.Events = FX.Events or {}
FX.Events.Total = 1
FX.Events.Active = {}

function FX.Events.Trigger(event, args, callback)
    local id = event .. ':' .. FX.Events.Total
    if not FX.Events.Active[id] then
        FX.Events.Active[id] = callback
        TriggerServerEvent("fxevents:listenEvent", id, event, args)
    end

    FX.Events.Total = FX.Events.Total + 1
end

RegisterNetEvent("fxevents:listenEvent")
AddEventHandler("fxevents:listenEvent", function(id, data)    
    if FX.Events.Active[id] then
        FX.Events.Active[id](data)
        FX.Events.Active[id] = nil
    end
end)