-- Roblox Mobile VR Arm Controller (Fixed & Animation Override)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("MobileVRGui") then
    CoreGui.MobileVRGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileVRGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- Nút nổi bật/tắt bảng VR trên màn hình
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 120)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.Text = "🥽"
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = screenGui

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleBtn

-- Khung giao diện chứa Joystick điều khiển
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 210)
mainFrame.Position = UDim2.new(0.5, -190, 1, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0, 12)
cornerFrame.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Biến lưu góc độ tay trái và tay phải
local leftPitch, leftYaw = 0, 0
local rightPitch, rightYaw = 0, 0

-- Hàm tạo Joystick cảm ứng mượt mà dành riêng cho Mobile
local function createJoystick(name, posX, onUpdate)
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(0, 130, 0, 130)
    outer.Position = UDim2.new(0, posX, 0, 45)
    outer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    outer.BackgroundTransparency = 0.4
    outer.Parent = mainFrame
    
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outer
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, -25)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Parent = outer

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 50, 0, 50)
    knob.Position = UDim2.new(0.5, -25, 0.5, -25)
    knob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    knob.Text = ""
    knob.Parent = outer
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local activeTouch = nil
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            activeTouch = input
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == activeTouch then
            activeTouch = nil
            knob.Position = UDim2.new(0.5, -25, 0.5, -25)
            onUpdate(0, 0)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == activeTouch and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local outerPos = outer.AbsolutePosition
            local center = outerPos + Vector2.new(65, 65)
            local currentPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentPos - center
            
            local radius = 45
            if delta.Magnitude > radius then
                delta = delta.Unit * radius
            end
            
            knob.Position = UDim2.new(0.5, delta.X - 25, 0.5, delta.Y - 25)
            onUpdate(delta.X / radius, delta.Y / radius)
        end
    end)
end

-- Khởi tạo Joystick cho Tay Trái và Tay Phải
createJoystick("Tay Trái (Left)", 35, function(x, y)
    leftYaw = x * 1.5
    leftPitch = -y * 1.5
end)

createJoystick("Tay Phải (Right)", 215, function(x, y)
    rightYaw = x * 1.5
    rightPitch = -y * 1.5
end)

-- Vòng lặp chiếm quyền khớp vai R15 (Bẻ khóa Animation hoàn toàn)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- Tắt Animator của game để không bị ghi đè cử động tay
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation and string.find(string.lower(track.Animation.AnimationId), "arm") then
                    track:Stop(0)
                end
            end
        end
    end

    local leftUpperArm = char:FindFirstChild("LeftUpperArm")
    local rightUpperArm = char:FindFirstChild("RightUpperArm")
    
    if leftUpperArm and leftUpperArm:FindFirstChild("LeftShoulder") then
        local lShoulder = leftUpperArm.LeftShoulder
        lShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(leftPitch, leftYaw, 0)
    end
    
    if rightUpperArm and rightUpperArm:FindFirstChild("RightShoulder") then
        local rShoulder = rightUpperArm.RightShoulder
        rShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(rightPitch, rightYaw, 0)
    end
end)

print("VR Mobile R15 (Animation Override Fixed) đã chạy!")
