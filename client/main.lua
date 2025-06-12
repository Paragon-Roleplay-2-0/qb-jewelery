local QBCore = exports['qb-core']:GetCoreObject()
local firstAlarm = false
local smashing = false
local targetBusy = false

local function loadParticle()
    if not HasNamedPtfxAssetLoaded('scr_jewelheist') then
        RequestNamedPtfxAsset('scr_jewelheist')
    end
    while not HasNamedPtfxAssetLoaded('scr_jewelheist') do
        Wait(0)
    end
    SetPtfxAssetNextCall('scr_jewelheist')
end

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(3)
    end
end

local function validWeapon()
    local ped = PlayerPedId()
    local pedWeapon = GetSelectedPedWeapon(ped)

    for k, _ in pairs(Config.WhitelistedWeapons) do
        if pedWeapon == k then
            return true
        end
    end
    return false
end

local function smashVitrine(k)
    TriggerServerEvent('qb-jewellery:server:setBusy', k, true)
    if not firstAlarm then
        -- TriggerServerEvent('police:server:policeAlert', 'Suspicious Activity')
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = { 'police', 'lssd', 'sasp' },
            coords = data.coords,
            title = '10-90 - Vangelico Robbery',
            message = 'A ' .. data.sex .. ' is robbing Vangelico Jewelry at ' .. data.street,
            flash = 0,
            unique_id = data.unique_id,
            sound = 2,
            blip = {
                sprite = 617,
                scale = 1.0,
                colour = 1,
                flashes = false,
                text = '911 - Vangelico Jewelry Robbery',
                time = 5,
                radius = 50,
            }
        })
        firstAlarm = true
    end
    smashing = true

    local animDict = 'missheist_jewel'
    local animName = 'smash_case'

    local ped = PlayerPedId()
    local playerCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
    local pedWeapon = GetSelectedPedWeapon(ped)
    local random = math.random(1, 100)

    if random <= 80 and not QBCore.Functions.IsWearingGloves() then
        TriggerServerEvent('evidence:server:CreateFingerDrop', playerCoords)
    elseif random <= 5 and QBCore.Functions.IsWearingGloves() then
        TriggerServerEvent('evidence:server:CreateFingerDrop', playerCoords)
        QBCore.Functions.Notify(Lang:t('error.fingerprints'), 'error')
    end

    CreateThread(function()
        while smashing do
            loadAnimDict(animDict)
            lib.playAnim(ped, animDict, animName, 3.0, 3.0, -1, 2)
            Wait(500)
            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'breaking_vitrine_glass', 0.25)
            loadParticle()
            StartParticleFxLoopedAtCoord('scr_jewel_cab_smash', playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            Wait(2500)
        end
    end)

    QBCore.Functions.Progressbar('smash_vitrine', Lang:t('info.progressbar'), Config.WhitelistedWeapons[pedWeapon]['timeOut'], false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('qb-jewellery:server:setBusy', k, false)
        TriggerServerEvent('qb-jewellery:server:vitrineReward', k)
        TriggerServerEvent('qb-jewellery:server:setTimeout')
        -- TriggerServerEvent('police:server:policeAlert', 'Robbery in progress')
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = { 'police', 'lssd', 'sasp' },
            coords = data.coords,
            title = '10-90 - Vangelico Robbery',
            message = 'A ' .. data.sex .. ' is robbing Vangelico Jewelry at ' .. data.street,
            flash = 0,
            unique_id = data.unique_id,
            sound = 2,
            blip = {
                sprite = 617,
                scale = 1.0,
                colour = 1,
                flashes = false,
                text = '911 - Vangelico Jewelry Robbery',
                time = 5,
                radius = 50,
            }
        })
        smashing = false
        lib.playAnim(ped, animDict, 'exit', 3.0, 3.0, -1, 2)
        targetBusy = false
    end, function()
        smashing = false
        targetBusy = false
        TriggerServerEvent('qb-jewellery:server:setBusy', k, false)
    end)
end

-- Threads

CreateThread(function()
    local Dealer = AddBlipForCoord(Config.JewelleryLocation['coords']['x'], Config.JewelleryLocation['coords']['y'],
    Config.JewelleryLocation['coords']['z'])
    SetBlipSprite(Dealer, 617)
    SetBlipDisplay(Dealer, 4)
    SetBlipScale(Dealer, 0.7)
    SetBlipAsShortRange(Dealer, true)
    SetBlipColour(Dealer, 3)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Vangelico Jewelry')
    EndTextCommandSetBlipName(Dealer)
end)

CreateThread(function()
    if Config.UseTarget then
        for k, v in pairs(GlobalState.VitrineLocations) do
            if Config.Target == 'qb' then
                exports['qb-target']:AddBoxZone('jewelstore' .. k, v.coords, 1, 1, {
                    name = 'jewelstore' .. k,
                    heading = 40,
                    minZ = v.coords.z - 1,
                    maxZ = v.coords.z + 1,
                    debugPoly = false
                }, {
                    options = {
                        {
                            type = 'client',
                            icon = 'fa fa-hand',
                            label = Lang:t('general.target_label'),
                            action = function()
                                targetBusy = true
                                if validWeapon() then
                                    smashVitrine(k)
                                else
                                    targetBusy = false
                                    QBCore.Functions.Notify(Lang:t('error.wrong_weapon'), 'error')
                                end
                            end,
                            canInteract = function()
                                if GlobalState.VitrineLocations[k].isbusy or GlobalState.VitrineLocations[k].isOpened or targetBusy then
                                    return false
                                end
                                return true
                            end,
                        }
                    },
                    distance = 2.0
                })
            elseif Config.Target == 'ox' then
                local ox_target = exports.ox_target
                ox_target:addBoxZone({
                    name = 'jewelstore' .. k,
                    coords = v.coords,
                    size = vector3(1, 1, 1),
                    debug = false,
                    options = {
                        label = Lang:t('general.target_label'),
                        icon = 'fa-solid fa-hand',
                        distance = 2.0,
                        onSelect = function()
                            targetBusy = true
                            if validWeapon() then
                                smashVitrine(k)
                            else
                                targetBusy = false
                                QBCore.Functions.Notify(Lang:t('error.wrong_weapon'), 'error')
                            end
                        end,
                        canInteract = function()
                            if GlobalState.VitrineLocations[k].isbusy or GlobalState.VitrineLocations[k].isOpened or targetBusy then
                                return false
                            end
                            return true
                        end,
                    }
                })
            end
        end
    else
        for k, v in pairs(GlobalState.VitrineLocations) do
            local boxZone = BoxZone:Create(v.coords, 0.5, 1, {
                name = 'jewelstore' .. k,
                heading = v.coords.w,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
                debugPoly = true
            })
            boxZone:onPlayerInOut(function(isPointInside)
                if GlobalState.VitrineLocations[k].isBusy or GlobalState.VitrineLocations[k].isOpened then return end
                if isPointInside then
                    exports['qb-core']:DrawText(Lang:t('general.drawtextui_grab'), 'left')
                    while not smashing do
                        if IsControlJustPressed(0, 38) then
                            if not GlobalState.VitrineLocations[k].isBusy and not GlobalState.VitrineLocations[k].isOpened then
                                exports['qb-core']:KeyPressed()
                                if validWeapon() then
                                    smashVitrine(k)
                                else
                                    QBCore.Functions.Notify(Lang:t('error.wrong_weapon'), 'error')
                                end
                            else
                                exports['qb-core']:DrawText(Lang:t('general.drawtextui_broken'), 'left')
                            end
                        end
                        Wait(1)
                    end
                else
                    exports['qb-core']:HideText()
                end
            end)
        end
    end
end)