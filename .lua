getgenv().Config = {
    Speed = 5,
    Distance = 500,
    Smoothness = 0.1,
    ResetTime = 1.5,
    Text = "Camlock"
}

local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = PlayersService.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local locking = false
local targetPlayer = nil

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Sui"
    screenGui.Parent = player:WaitForChild("PlayerGui") 

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 50)
    btn.Position = UDim2.new(0.5, -100, 0.8, 0)
    btn.Font = Enum.Font.GrenzeGotisch
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Draggable = true
    btn.Active = true
    btn.Parent = screenGui

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

local Button = createUI()

local function getClosestPlayerToMouse()
    local closest = nil
    local shortestDistance = getgenv().Config.Distance or math.huge
    local mousePos = mouse.Hit.Position

    for _, p in pairs(PlayersService:GetPlayers()) do
        if p == player or not p.Character then continue end
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (mousePos - root.Position).Magnitude
            if dist < shortestDistance then
                closest = p
                shortestDistance = dist
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local speed = getgenv().Config.Speed or 5
    local hue = (tick() % speed) / speed
    Button.TextColor3 = Color3.fromHSV(hue, 1, 1)

    if locking and targetPlayer and targetPlayer.Character then
        local targetPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            camera.CameraType = Enum.CameraType.Scriptable
            
            local targetRotation = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
            local smooth = getgenv().Config.Smoothness or 0.1
            camera.CFrame = camera.CFrame:Lerp(targetRotation, smooth)
        end
    else
        camera.CameraType = Enum.CameraType.Custom
    end
end)

Button.MouseButton1Click:Connect(function()
    locking = not locking 
    if locking then
        targetPlayer = getClosestPlayerToMouse()
        if targetPlayer then
            Button.Text = "Locking: " .. targetPlayer.Name
        else
            locking = false
            Button.Text = "No Target"
        end
    else
        local name = targetPlayer and targetPlayer.Name or "None"
        targetPlayer = nil
        Button.Text = "Unlocked: " .. name
        
        task.delay(getgenv().Config.ResetTime or 1.5, function()
            if not locking then
                Button.Text = getgenv().Config.Text or "Camlock"
            end
        end)
    end
end)
