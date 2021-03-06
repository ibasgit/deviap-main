-- Copyright 2020- Teverse
-- This script is required when workshop is loaded.

local globals = require("devgit:workshop/library/globals.lua") -- globals; variables or instances that can be shared between files
local environmentPresets = require("devgit:workshop/library/environment/presets.lua") -- 3D environment presets (or defaults)
local camera = require("devgit:core/3d/camera.lua") -- 3D Camera for 3D Environment

local function init(dev)
    --[[
        @Description
            The initializer method that comes first when a new scene is open. 

        @Params
            Instance, workshop
        
        @Returns
            void, null, nil
    ]]--

    globals.dev = dev -- Set teverse.dev (previously workshop) instance as a global
    globals.user = core.networking.localClient -- Set & Streamline user instance as a global
    globals.developerMode = not globals.dev.localDevGit -- Set developmode boolean as a global

    local loadingScreen = core.construct("guiFrame", {
        parent = dev.interface,
        size = guiCoord(1, 0, 1, 0),
        backgroundColour = globals.defaultColours.background,
        zIndex = 1000
    })

    core.construct("guiTextBox", {
        parent = loadingScreen,
        size = guiCoord(0.5, 0, 0.5, 0),
        position = guiCoord(0.25, 0, 0.25, 0),
        textAlign = enums.align.middle,
        backgroundAlpha = 0,
        text = "Downloading the latest workshop...\nThis takes longer than a moment during beta."
    })

    -- Load stuff before initial load in
    require("devgit:workshop/library/ui/controllers/workshopInterface.lua")

    -- Loading is no longer needed by this phase, remove if still valid
    if loadingScreen then
    	loadingScreen:destroy()
    end

    -- Setup Basic Default Scene (3D viewport)
    environmentPresets.default()
end

return function(dev)
    --[[
        @Description
            The main method that comes when a new scene is opened. 

        @Params
            Instance, workshop
        
        @Returns
            function, method
    ]]--
    dev = core.dev
    local success, message = pcall(init, dev)

    -- If initialize phase fails, prompt to the error screen
    if (not success) then
        core.interface:destroyChildren()

        local errorScreen = core.construct("guiFrame", {
            parent = dev.interface,
            size = guiCoord(1, 0, 1, 0),
            backgroundColour = globals.defaultColours.background,
            backgroundAlpha = 0,
            zIndex = 10000
        })

        core.construct("guiTextBox", {
            parent = errorScreen,
            size = guiCoord(0.8, 0, 0.8, 0),
            position = guiCoord(0.1, 0, 0.1, 0),
            backgroundColour = globals.defaultColours.background,
            backgroundAlpha = 0,
            textColour = globals.defaultColours.red,
            textAlign = enums.align.topLeft,
            text = "Error loading Workshop\nIf this isn't your fault, please take a screenshot and report this as a bug. \n\n" .. message .." \n\nPlease press 'ENTER' on your keyboard to restart Teverse.",
            textWrap = true,
            textFont = "tevurl:fonts/firaCodeMedium.otf"
        })

        -- Bind the "return" key on the keyboard as temporary fast-reload keybind
        core.input:on("keyDown", function(key)
            if key == "KEY_RETURN" then
                core.apps:loadWorkshop()
            end
        end)
    end

    -- Bind the "f12" key on the keyboard as fast-reload keybind if initialize phase is successful
    core.input:on("keyDown", function(key)
        if key == "KEY_F12" then
            core.apps:loadWorkshop()
        end
    end)
end