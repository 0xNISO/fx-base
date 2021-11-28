FX.Functions = FX.Functions or {}

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        for k,v in pairs(FX.Shared.Resources) do
            local state = GetResourceState(v)
            if state == 'starting' or state == 'started' then
                StopResource(v)
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        Wait(1500)
        for k,v in pairs(FX.Shared.Resources) do
            local state = GetResourceState(v)
            if state == 'stopped' or state == 'stopping' then
                StartResource(v)
            end
            Wait(150)
		end

		for k,v in pairs(FX.Shared.NonRestartResources) do
            local state = GetResourceState(v)
            if state == 'stopped' or state == 'stopping' then
                StartResource(v)
            end
            Wait(150)
		end
		
    end
end)