FX.Events = FX.Events or {}
FX.Events.Active = {}

function FX.Events.Create(event, callback)
    FX.Events.Active[event] = callback
end

RegisterServerEvent("fxevents:listenEvent")
AddEventHandler("fxevents:listenEvent", function(id, event, args)    
    local src = source
    local id = id
    if FX.Events.Active[event] then
        local data = FX.Events.Active[event](src, args)
        TriggerClientEvent("fxevents:listenEvent", src, id, data)
    else
        print("Warning: '" .. event .. "' event doesn't exist")
    end
end)