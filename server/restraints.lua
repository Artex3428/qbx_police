local ox_inventory = exports.ox_inventory

local cuffItems = {
    cuffs = 'cuffs',
    zipties = 'zipties'
}

local uncuffItems = {
    cuffs = 'handcuffkey',
    zipties = 'tools'
}

local function setHandcuffedState(target, state)
    local player = exports.qbx_core:GetPlayer(target)
    if not player then return false end

    player.Functions.SetMetaData('ishandcuffed', state)
    Player(target).state.invBusy = state

    return true
end

local function cuffCheck(src, target, cuffType)
    target = tonumber(target)

    if not target or target == src then
        return false
    end

    local itemName = cuffItems[cuffType]

    if not itemName then
        return false
    end

    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)

    if GetVehiclePedIsIn(ped, false) ~= 0
        or GetVehiclePedIsIn(targetPed, false) ~= 0
        or #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 5.0
        or ox_inventory:GetItemCount(src, itemName) == 0
    then
        return false
    end

    local playerState = Player(src).state
    local targetState = Player(target).state

    if playerState.handsUp
        or playerState.gettingCuffed
        or playerState.isCuffed
        or playerState.isCuffing
    then
        return false
    end

    if targetState.gettingCuffed
        or targetState.isCuffing
        or targetState.isCuffed
    then
        return false
    end

    -- Zip ties require the victim to surrender.
    if cuffType == 'zipties' and not targetState.handsUp then
        return false
    end

    return true, itemName
end

local function uncuffCheck(src, target, cuffType)
    target = tonumber(target)

    if not target or target == src then
        return false
    end

    local requiredItem = uncuffItems[cuffType]

    if not requiredItem then
        return false
    end

    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)

    if GetVehiclePedIsIn(ped, false) ~= 0
        or GetVehiclePedIsIn(targetPed, false) ~= 0
        or #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 5.0
        or ox_inventory:GetItemCount(src, requiredItem) == 0
    then
        return false
    end

    local playerState = Player(src).state
    local targetState = Player(target).state

    if playerState.handsUp
        or playerState.gettingCuffed
        or playerState.isCuffed
        or playerState.isCuffing
        or not targetState.isCuffed
    then
        return false
    end

    return true
end

RegisterNetEvent('police:syncAgressiveCuff', function(target, angle, cuffType, slot, heading)
    local src = source

    local valid, itemName = cuffCheck(src, target, cuffType)
    if not valid then return end

    local escaped = lib.callback.await(
        'police:syncAgressiveCuff',
        target,
        angle,
        cuffType,
        heading
    )

    if escaped then return end

    if not ox_inventory:RemoveItem(src, itemName, 1, nil, slot) then
        TriggerClientEvent('police:uncuffPed', target)
        return
    end

    Player(target).state.handsUp = false

    setHandcuffedState(target, true)
end)

RegisterNetEvent('police:syncNormalCuff', function(target, angle, cuffType, slot)
    local src = source

    local valid, itemName = cuffCheck(src, target, cuffType)
    if not valid then return end

    if not ox_inventory:RemoveItem(src, itemName, 1, nil, slot) then
        return
    end

    setHandcuffedState(target, true)

    TriggerClientEvent(
        'police:syncNormalCuff',
        target,
        angle,
        cuffType
    )
end)

RegisterNetEvent('police:uncuffPed', function(target, cuffType)
    local src = source

    if not uncuffCheck(src, target, cuffType) then
        return
    end

    local targetState = Player(target).state
    local playerCuffType = targetState.cuffType or 'cuffs'

    if playerCuffType ~= cuffType then
        return
    end

    setHandcuffedState(target, false)

    targetState:set('isEscorted', false, true)

    TriggerClientEvent('police:uncuffPed', target)

    Wait(500)

    -- Real handcuffs are returned.
    if cuffType == 'cuffs' then
        ox_inventory:AddItem(src, 'cuffs', 1)
    end

    -- Zip ties are CUT and destroyed.
end)