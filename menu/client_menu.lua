ESX           = nil

-- Menu state
local showMenu = false

-- Keybind Lookup table
local keybindControls = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18, ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182, ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173, ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local MAX_MENU_ITEMS = 7

-- Main thread
Citizen.CreateThread(function()
    local keyBind = "F3"
    while true do
        Citizen.Wait(0)
        if IsControlPressed(1, keybindControls[keyBind]) and GetLastInputMethod(2) and showMenu then
            showMenu = false
            SetNuiFocus(false, false)
        end
        if IsControlPressed(1, keybindControls[keyBind]) and GetLastInputMethod(2) then
            showMenu = true
            local enabledMenus = {}
            for _, menuConfig in ipairs(rootMenuConfig) do
                if menuConfig:enableMenu() then
                    local dataElements = {}
                    local hasSubMenus = false
                    if menuConfig.subMenus ~= nil and #menuConfig.subMenus > 0 then
                        hasSubMenus = true
                        local previousMenu = dataElements
                        local currentElement = {}
                        for i = 1, #menuConfig.subMenus do
                            -- if newSubMenus[menuConfig.subMenus[i]] ~= nil and newSubMenus[menuConfig.subMenus[i]].enableMenu ~= nil and not newSubMenus[menuConfig.subMenus[i]]:enableMenu() then
                            --     goto continue
                            -- end
                            currentElement[#currentElement+1] = newSubMenus[menuConfig.subMenus[i]]
                            currentElement[#currentElement].id = menuConfig.subMenus[i]
                            currentElement[#currentElement].enableMenu = nil

                            if i % MAX_MENU_ITEMS == 0 and i < (#menuConfig.subMenus - 1) then
                                previousMenu[MAX_MENU_ITEMS + 1] = {
                                    id = "_more",
                                    title = "More",
                                    icon = "#more",
                                    items = currentElement
                                }
                                previousMenu = currentElement
                                currentElement = {}
                            end
                            --::continue::
                        end
                        if #currentElement > 0 then
                            previousMenu[MAX_MENU_ITEMS + 1] = {
                                id = "_more",
                                title = "More",
                                icon = "#more",
                                items = currentElement
                            }
                        end
                        dataElements = dataElements[MAX_MENU_ITEMS + 1].items

                    end
                    enabledMenus[#enabledMenus+1] = {
                        id = menuConfig.id,
                        title = menuConfig.displayName,
                        functionName = menuConfig.functionName,
                        icon = menuConfig.icon,
                    }
                    if hasSubMenus then
                        enabledMenus[#enabledMenus].items = dataElements
                    end
                end
            end
            SendNUIMessage({
                state = "show",
                resourceName = GetCurrentResourceName(),
                data = enabledMenus,
                menuKeyBind = keyBind
            })
            SetCursorLocation(0.5, 0.5)
            SetNuiFocus(true, true)

            -- Play sound
            PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)


            while showMenu == true do Citizen.Wait(100) end
            Citizen.Wait(100)
            while IsControlPressed(1, keybindControls[keyBind]) and GetLastInputMethod(2) do Citizen.Wait(100) end
        end
    end
end)
-- Callback function for closing menu
RegisterNUICallback('closemenu', function(data, cb)
    -- Clear focus and destroy UI
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    -- Play sound
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    -- Send ACK to callback function
    cb('ok')
end)

RegisterCommand('hidemenu', function(playerId, args, rawCommand)
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })
end)

-- Callback function for when a slice is clicked, execute command
RegisterNUICallback('triggerAction', function(data, cb)
    -- Clear focus and destroy UI
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    -- Play sound
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
    commands = {
        'e sitchair'
    }
    -- Run command
    for k,v in pairs(commands) do
    if data.action == v then
    ExecuteCommand(data.action)
    else
    TriggerEvent(data.action, data.parameters)
    end
end

    -- Send ACK to callback function
    cb('ok')
end)

RegisterNetEvent("menu:menuexit")
AddEventHandler("menu:menuexit", function()
    showMenu = false
    SetNuiFocus(false, false)
end)
--
RegisterNetEvent("showbank")
AddEventHandler("showbank", function()
    TriggerServerEvent('showbank')
end)

RegisterNetEvent("showcash")
AddEventHandler("showcash", function()
    TriggerServerEvent('showcash')
end)

RegisterNetEvent("showdirty")
AddEventHandler("showdirty", function()
    TriggerServerEvent('showdirty')
end)

RegisterNetEvent("showjob")
AddEventHandler("showjob", function()
    TriggerServerEvent('showjob')
end)

RegisterNetEvent("showsociety")
AddEventHandler("showsociety", function()
    TriggerServerEvent('showsociety')
end)

RegisterNetEvent('esx_policejob:usecuff')
AddEventHandler('esx_policejob:usecuff', function()
	local target, distance = ESX.Game.GetClosestPlayer()
	playerheading = GetEntityHeading(GetPlayerPed(-1))
	playerlocation = GetEntityForwardVector(PlayerPedId())
	playerCoords = GetEntityCoords(GetPlayerPed(-1))
	local target_id = GetPlayerServerId(target)
	if target ~= -1 and distance <= 3.0 then
	TriggerServerEvent('esx_policejob:requestarrest', target_id, playerheading, playerCoords, playerlocation)
	else
		TriggerEvent('notification', 'No Players Nearby', 2)
	end
end)

RegisterNetEvent('police:checkInventory')
AddEventHandler('police:checkInventory', function()
	local target, distance = ESX.Game.GetClosestPlayer()
	if target ~= -1 and distance <= 3.0 then
        OpenBodySearchMenu(target)
	else
		TriggerEvent('notification', 'No Players Nearby', 2)
	end
end)

RegisterNetEvent('escortPlayer')
AddEventHandler('escortPlayer', function()
	local target, distance = ESX.Game.GetClosestPlayer()
	if target ~= -1 and distance <= 3.0 then
		TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(target))
	else
		TriggerEvent('notification', 'No Players Nearby', 2)
	end
end)

RegisterNetEvent('police:uncuffMenu')
AddEventHandler('police:uncuffMenu', function()
	local target, distance = ESX.Game.GetClosestPlayer()
	playerheading = GetEntityHeading(GetPlayerPed(-1))
	playerlocation = GetEntityForwardVector(PlayerPedId())
	playerCoords = GetEntityCoords(GetPlayerPed(-1))
	local target_id = GetPlayerServerId(target)
	if target ~= -1 and distance <= 3.0 then
		TriggerServerEvent('esx_policejob:requestrelease', target_id, playerheading, playerCoords, playerlocation)
	else
		TriggerEvent('notification', 'No Players Nearby', 2)
	end
end)

function OpenBodySearchMenu(player)
	TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(player), GetPlayerName(player))
end

RegisterNetEvent('police:forceEnter')
AddEventHandler('police:forceEnter', function()
local target, distance = ESX.Game.GetClosestPlayer()
if target ~= -1 and distance <= 3.0 then
    TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(target))
else
    TriggerEvent('notification', 'No Players Nearby', 2)
end
end)

RegisterNetEvent('unseatPlayer')
AddEventHandler('unseatPlayer', function()
local target, distance = ESX.Game.GetClosestPlayer()
if target ~= -1 and distance <= 3.0 then
    TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(target))
else
    TriggerEvent('notification', 'No Players Nearby', 2)
end
end)

RegisterNetEvent('anim:id')
AddEventHandler('anim:id', function()
    TriggerEvent("animation:PlayAnimation","id")
end)

RegisterNetEvent('anim:getup')
AddEventHandler('anim:getup', function()
TriggerEvent("animation:PlayAnimation","getup")
end)

RegisterNetEvent('anim:search')
AddEventHandler('anim:search', function()
    TriggerEvent("animation:PlayAnimation","search")
    Citizen.Wait(7000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('anim:boxing')
AddEventHandler('anim:boxing', function()
    TriggerEvent("animation:PlayAnimation","boxing")
    Citizen.Wait(4000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('anim:bark')
AddEventHandler('anim:bark', function()
    TriggerEvent("animation:PlayAnimation","bark")
    Citizen.Wait(6000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('anim:shower')
AddEventHandler('anim:shower', function()
    TriggerEvent("animation:PlayAnimation","shower")
    Citizen.Wait(7000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('anim:desk')
AddEventHandler('anim:desk', function()
    TriggerEvent("animation:PlayAnimation","cokecut")
    Citizen.Wait(7000)
    ClearPedTasks(PlayerPedId())
end)


RegisterNetEvent('anim:look')
AddEventHandler('anim:look', function()
    TriggerEvent("animation:PlayAnimation","searchground")
    Citizen.Wait(7000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('anim:taxi')
AddEventHandler('anim:taxi', function()
    TriggerEvent("animation:PlayAnimation","taxi")
    Citizen.Wait(2000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('FlipVehicle')
AddEventHandler('FlipVehicle', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = nil
    if IsPedInAnyVehicle(ped, false) then vehicle = GetVehiclePedIsIn(ped, false) else vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71) end
        if DoesEntityExist(vehicle) then
        exports['mythic_progbar']:Progress({
            name = "flipping_vehicle",
            duration = 5000,
            label = "Flipping Vehicle",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "random@mugging4",
                anim = "struggle_loop_b_thief",
                flags = 49,
            }
        }, function(status)

            local playerped = PlayerPedId()
            local coordA = GetEntityCoords(playerped, 1)
            local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
            local targetVehicle = getVehicleInDirection(coordA, coordB)
            SetVehicleOnGroundProperly(targetVehicle)
        end)
    else
        exports['mythic_notify']:SendAlert('error', 'There is no vehicle near-by', 7000)
    end
end)

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)    
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    
    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end