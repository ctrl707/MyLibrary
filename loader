--[[
    DivaUI Loader
    Author: ctrl707
    
    Usage:
    local DivaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ctrl707/MyLibrary/main/loader.lua"))()
]]

local URL = "https://raw.githubusercontent.com/ctrl707/MyLibrary/main/init.lua"

local success, result = pcall(function()
    return loadstring(game:HttpGet(URL))()
end)

if not success then
    warn("[DivaUI] ❌ Failed to load library!")
    warn("[DivaUI] Error: " .. tostring(result))
    error("[DivaUI] Loading failed. Check your internet / executor / HttpGet permissions.")
end

print("[NovaUI] ✅ Library loaded successfully! Version: " .. (result.Version or "?"))
return result
