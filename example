--[[
    DivaUI — Example usage
    Test all components
]]

local DivaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ctrl707/MyLibrary/main/loader.lua"))()

local Window = DivaUI:CreateWindow({
    Name  = "DivaUI Test Hub",
    Theme = "Midnight",
    Size  = "Normal",
})

----------------------------------------
local Main = Window:CreateTab("Main")

Main:CreateSection("Welcome")
Main:CreateParagraph({
    Title   = "About",
    Content = "This is DivaUI — a modern Roblox UI library. Test all components below.",
})

Main:CreateDivider()

Main:CreateSection("Buttons")
Main:CreateButton({
    Name = "Show Notification",
    Callback = function()
        DivaUI:Notify({Title="Hello!", Content="It works!", Duration=3})
    end
})

Main:CreateButton({
    Name = "Print to console",
    Callback = function() print("Hello from DivaUI!") end
})

----------------------------------------
local Controls = Window:CreateTab("Controls")

Controls:CreateSection("Toggles & Sliders")

Controls:CreateToggle({
    Name    = "Auto Farm",
    Flag    = "autofarm",
    Default = false,
    Callback = function(v) print("AutoFarm:", v) end
})

Controls:CreateToggle({
    Name    = "ESP",
    Default = true,
    Callback = function(v) print("ESP:", v) end
})

Controls:CreateSlider({
    Name    = "Walk Speed",
    Min     = 16, Max = 200, Default = 50,
    Format  = "%d",
    Callback = function(v)
        local plr = game.Players.LocalPlayer
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.WalkSpeed = v
        end
    end
})

Controls:CreateSlider({
    Name    = "Jump Power",
    Min     = 0, Max = 300, Default = 50,
    Format  = "%d",
    Callback = function(v)
        local plr = game.Players.LocalPlayer
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.JumpPower = v
        end
    end
})

----------------------------------------
local Misc = Window:CreateTab("Misc")

Misc:CreateSection("Inputs")

Misc:CreateDropdown({
    Name    = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Default = "Head",
    Callback = function(v) print("Target:", v) end
})

Misc:CreateTextBox({
    Name        = "Username",
    Placeholder = "Type a username...",
    Callback    = function(text)
        print("Entered:", text)
    end
})

Misc:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color, name)
        print("Color:", name)
    end
})

Misc:CreateKeybind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Window.MainFrame.Visible = not Window.MainFrame.Visible
    end
})

----------------------------------------
DivaUI:Notify({
    Title    = "DivaUI Loaded!",
    Content  = "All components ready to test 🚀",
    Duration = 4,
})
