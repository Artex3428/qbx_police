RegisterServerEvent('police:setPlayerEscort', function(target, state, setIntoVeh, setIntoSeat, exitVeh)
    local src = source
    target = tonumber(target)
    if not target or target == 0 then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local targetPed = GetPlayerPed(target)
    local targetCoords = GetEntityCoords(targetPed)
    if not playerCoords or not targetCoords or #(playerCoords-targetCoords) > 10 then return end

    if exitVeh then
        SetEntityCoords(targetPed, playerCoords.x, playerCoords.y, playerCoords.z)
    end

    target = Player(target)?.state

    if not target then return end
    target:set('isEscorted', state and src, true)

    if not setIntoVeh or not setIntoSeat then return end
    Wait(500)

    local veh = NetworkGetEntityFromNetworkId(setIntoVeh)
    if not DoesEntityExist(veh) then return end

    SetPedIntoVehicle(targetPed, veh, setIntoSeat)
end)