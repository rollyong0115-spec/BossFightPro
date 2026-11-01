
-- Boss Fight Pro GitHub Loader

local URL =
    "https://raw.githubusercontent.com/rollyong0115-spec/BossFightPro/main/BossFightPro.lua"

local success, err = pcall(function()
    local source = game:HttpGet(URL)
    local run = loadstring(source)

    if not run then
        error("Failed to compile BossFightPro.lua")
    end

    run()
end)

if not success then
    warn("[Boss Pro Loader] " .. tostring(err))
end
