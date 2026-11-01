
-- Boss Fight Pro
-- Client-side menu for Roblox
-- The damage multiplier is a preview only.
-- Actual boss damage must be handled by the game server.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old menu if script is run again
local oldGui = playerGui:FindFirstChild("BossProMenu")
if oldGui then
    oldGui:Destroy()
end

if _G.BossFightProCleanup then
    _G.BossFightProCleanup()
end

local connections = {}
local function track(connection)
    table.insert(connections, connection)
    return connection
end

local flying = false
local godMode = false
local speedBoost = false
local oneHit = false
local autoAttack = false
local slimeBoost = false

local normalSpeed = 16
local boostSpeed = 50
local flySpeed = 55

local character, humanoid, root
local flyVelocity
local flyGyro

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
    normalSpeed = humanoid.WalkSpeed

    if speedBoost then
        humanoid.WalkSpeed = boostSpeed
    end
end

updateCharacter()

local gui = Instance.new("ScreenGui")
gui.Name = "BossProMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(245, 355)
frame.Position = UDim2.new(0.5, -122, 0.5, -177)
frame.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "BOSS FIGHT PRO"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(34, 30)
minimize.Position = UDim2.new(1, -40, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(60, 65, 85)
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 20
minimize.Parent = frame
Instance.new("UICorner", minimize).CornerRadius =
    UDim.new(0, 8)

local floating = Instance.new("TextButton")
floating.Name = "OpenButton"
floating.Size = UDim2.fromOffset(52, 52)
floating.Position = UDim2.new(0.8, 0, 0.15, 0)
floating.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
floating.Text = "⚙"
floating.TextColor3 = Color3.new(1, 1, 1)
floating.TextSize = 27
floating.Font = Enum.Font.GothamBold
floating.Active = true
floating.Draggable = true
floating.Visible = false
floating.Parent = gui
Instance.new("UICorner", floating).CornerRadius =
    UDim.new(1, 0)

local function setMenuVisible(visible)
    frame.Visible = visible
    floating.Visible = not visible
end

minimize.MouseButton1Click:Connect(function()
    setMenuVisible(false)
end)

floating.MouseButton1Click:Connect(function()
    setMenuVisible(true)
end)

local function createToggle(label, y, getState, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 36)
    button.Position = UDim2.fromOffset(10, y)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.Parent = frame

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    local function refresh()
        local enabled = getState()
        button.Text = label .. (enabled and " : ON" or " : OFF")
        button.BackgroundColor3 = enabled
            and Color3.fromRGB(0, 145, 100)
            or Color3.fromRGB(55, 60, 78)
    end

    button.MouseButton1Click:Connect(function()
        callback(not getState())
        refresh()
    end)

    refresh()
    return button
end

local function stopFly()
    flying = false

    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end

    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function startFly()
    if not root or not humanoid then
        return
    end

    stopFly()
    flying = true

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyGyro.P = 10000
    flyGyro.Parent = root

    humanoid.PlatformStand = true
end

local function applySpeed()
    if humanoid then
        humanoid.WalkSpeed =
            speedBoost and boostSpeed or normalSpeed
    end
end

local function getSlimeDamage()
    local petField = workspace:FindFirstChild("PetField")
    if not petField then
        return nil
    end

    local playerFolder =
        petField:FindFirstChild(tostring(player.UserId))

    if not playerFolder then
        return nil
    end

    local slime =
        playerFolder:FindFirstChild("CosmicPumpkinKingSlime")

    if not slime then
        return nil
    end

    local baseDamage = slime:GetAttribute("Damage")
    if type(baseDamage) ~= "number" then
        return nil
    end

    return baseDamage * (slimeBoost and 1000 or 1)
end

createToggle("Fly + God Mode", 48, function()
    return flying
end, function(state)
    godMode = state

    if state then
        startFly()
    else
        stopFly()
    end
end)

createToggle("Speed Boost", 91, function()
    return speedBoost
end, function(state)
    speedBoost = state
    applySpeed()
end)

createToggle("1-Hit Boss (Local Test)", 134, function()
    return oneHit
end, function(state)
    oneHit = state
end)

createToggle("Auto Attack (Local)", 177, function()
    return autoAttack
end, function(state)
    autoAttack = state
end)

createToggle("Slime Damage x1000 Preview", 220, function()
    return slimeBoost
end, function(state)
    slimeBoost = state

    local damage = getSlimeDamage()
    print("[Boss Pro] Slime preview damage:", damage)
end)

local damageLabel = Instance.new("TextLabel")
damageLabel.Size = UDim2.new(1, -20, 0, 42)
damageLabel.Position = UDim2.fromOffset(10, 268)
damageLabel.BackgroundTransparency = 1
damageLabel.TextColor3 = Color3.fromRGB(210, 220, 240)
damageLabel.TextWrapped = true
damageLabel.Font = Enum.Font.Gotham
damageLabel.TextSize = 12
damageLabel.Parent = frame

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 30)
footer.Position = UDim2.fromOffset(10, 315)
footer.BackgroundTransparency = 1
footer.Text = "⚙ Minimize to keep the floating button"
footer.TextColor3 = Color3.fromRGB(150, 165, 190)
footer.TextSize = 11
footer.Font = Enum.Font.Gotham
footer.Parent = frame

local elapsed = 0

track(RunService.Heartbeat:Connect(function(dt)
    elapsed += dt

    if flying and root and humanoid then
        local camera = workspace.CurrentCamera
        if camera and flyVelocity and flyGyro then
            local direction = humanoid.MoveDirection
            local vertical = 0

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vertical = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vertical = -1
            end

            flyVelocity.Velocity =
                direction * flySpeed +
                Vector3.new(0, vertical * flySpeed, 0)

            flyGyro.CFrame = camera.CFrame
        end
    end

    if godMode and humanoid then
        -- Client-side health display only.
        -- The server controls real damage.
        if humanoid.Health > 0 then
            humanoid.Health =
                math.max(humanoid.Health, humanoid.MaxHealth)
        end
    end

    if elapsed >= 0.5 then
        elapsed = 0

        local damage = getSlimeDamage()
        if damage then
            damageLabel.Text =
                "Cosmic Slime Damage Preview: " ..
                tostring(damage)
        else
            damageLabel.Text =
                "Cosmic Slime: Not found in PetField"
        end

        -- No unverified boss-damage remote calls.
        -- Server-side combat must implement real damage.
    end
end))

track(player.CharacterAdded:Connect(function()
    stopFly()
    updateCharacter()
    applySpeed()
end))

_G.BossFightProCleanup = function()
    stopFly()

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    gui:Destroy()
end

print("[Boss Pro] Menu loaded successfully")
