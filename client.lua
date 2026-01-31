-- Menu state
local SEM_InteractionMenuOpen = false
local SEM_MenuOptions = {}
local SEM_CurrentIndex = 1

local lastNavTime = 0
local navDelay = 150

local highlightSound = "NAV_UP_DOWN"
local selectSound = "SELECT"
local soundSet = "HUD_FRONTEND_DEFAULT_SOUNDSET"

local function TriggerRumble(duration)
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end
    if GamepadIsConnected() then
        GamepadSetVibration(0.5,0.5,duration or 150)
    end
end

-- Open menu
function SEM_OpenMenu(options)
    SEM_MenuOptions = options
    SEM_CurrentIndex = 1
    SEM_InteractionMenuOpen = true
    SendNUIMessage({ action="openMenu", options=SEM_MenuOptions, highlight=SEM_CurrentIndex })
    SetNuiFocus(true,true)
end

-- Close menu
function SEM_CloseMenu()
    SEM_InteractionMenuOpen = false
    SEM_MenuOptions = {}
    SEM_CurrentIndex = 1
    SendNUIMessage({ action="closeMenu" })
    SetNuiFocus(false,false)
end

function SEM_SelectNextOption()
    if #SEM_MenuOptions==0 then return end
    SEM_CurrentIndex = SEM_CurrentIndex + 1
    if SEM_CurrentIndex>#SEM_MenuOptions then SEM_CurrentIndex=1 end
    SEM_HighlightOption(SEM_CurrentIndex)
end

function SEM_SelectPreviousOption()
    if #SEM_MenuOptions==0 then return end
    SEM_CurrentIndex = SEM_CurrentIndex - 1
    if SEM_CurrentIndex<1 then SEM_CurrentIndex=#SEM_MenuOptions end
    SEM_HighlightOption(SEM_CurrentIndex)
end

function SEM_SelectCurrentOption()
    local option = SEM_MenuOptions[SEM_CurrentIndex]
    if option and option.action then
        PlaySoundFrontend(-1, selectSound, soundSet, 1)
        TriggerRumble(150)
        option.action()
    end
end

function SEM_HighlightOption(index)
    SEM_CurrentIndex = index
    SendNUIMessage({ action="highlight", index=SEM_CurrentIndex })
    PlaySoundFrontend(-1, highlightSound, soundSet, 1)
end

-- Controller / keyboard input
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if SEM_InteractionMenuOpen then
            local currentTime = GetGameTimer()
            local stickY = GetDisabledControlNormal(0,1)
            if stickY<-0.5 and (currentTime-lastNavTime)>navDelay then SEM_SelectNextOption() lastNavTime=currentTime end
            if stickY>0.5 and (currentTime-lastNavTime)>navDelay then SEM_SelectPreviousOption() lastNavTime=currentTime end

            if IsControlJustPressed(0,172) then SEM_SelectPreviousOption() end
            if IsControlJustPressed(0,173) then SEM_SelectNextOption() end

            if IsControlJustPressed(0,176) then SEM_SelectCurrentOption() end
            if IsControlJustPressed(0,177) then SEM_CloseMenu() end

            if IsControlJustPressed(0,38) then SEM_SelectCurrentOption() end
            if IsControlJustPressed(0,177) then SEM_CloseMenu() end
        end
    end
end)

-- NUI Callbacks
RegisterNUICallback("selectOption", function(data, cb)
    SEM_CurrentIndex = data.index
    SEM_SelectCurrentOption()
    cb("ok")
end)

RegisterNUICallback("closeMenu", function(data, cb)
    SEM_CloseMenu()
    cb("ok")
end)

RegisterNUICallback("highlightOption", function(data, cb)
    SEM_HighlightOption(data.index)
    cb("ok")
end)
