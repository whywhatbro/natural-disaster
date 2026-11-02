-- Roblox Mobile VR Arm Controller (Fixed Arm Motion & Camera Lock)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("MobileVRGui") then
    CoreGui.MobileVRGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileVRGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- Nút mở menu VR
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

-- Khung giao diện chính chứa Joystick
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

-- Chức năng Khóa xoay màn hình khi chạm vào bảng điều khiển (Giống như chạm vào bảng UI thông thường)
local isInteracting = false

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isInteracting = true
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isInteracting = false
    end
end)

-- Chặn camera xoay khi đang chạm vào bảng UI
RunService.RenderStepped:Connect(function()
    if isInteracting and mainFrame.Visible then
        -- Ngăn game bắt sự kiện vuốt màn hình để xoay camera
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

-- Biến lưu góc tay
local leftPitch, leftYaw = 0, 0
local rightPitch, rightYaw = 0, 0

-- Hàm tạo Joystick siêu nhạy
local function createSuperJoystick(name, posX, onUpdate)
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

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 50, 0, 50)
    knob.Position = UDim2.new(0.5, -25, 0.5, -25)
    knob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    knob.Parent = outer
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local activeInput = nil
    
    outer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            activeInput = input
            isInteracting = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == activeInput then
            activeInput = nil
            knob.Position = UDim2.new(0.5, -25, 0.5, -25)
            onUpdate(0, 0)
            isInteracting = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if activeInput then
            local pos = activeInput.Position
            local outerPos = outer.AbsolutePosition
            local center = outerPos + Vector2.new(65, 65)
            local delta = Vector2.new(pos.X, pos.Y) - center
            
            local radius = 45
            if delta.Magnitude > radius then
                delta = delta.Unit * radius
            end
            
            knob.Position = UDim2.new(0.5, delta.X - 25, 0.5, delta.Y - 25)
            onUpdate(delta.X / radius, delta.Y / radius)
        end
    end)
end

-- Khởi tạo 2 Joystick cho Tay Trái và Tay Phải
createSuperJoystick("Tay Trái (Left)", 35, function(x, y)
    leftYaw = x * 1.5
    leftPitch = -y * 1.5
end)

createSuperJoystick("Tay Trải (Right)", 215, function(x, y)
    rightYaw = x * 1.5
    rightPitch = -y * 1.5
end)

-- Vòng lặp ép buộc chuyển động khớp tay R15 (Chống ghi đè Animation & Ép tay di chuyển)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- Dừng các animation tay của game để không tranh chấp khớp nối
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation and (string.find(string.lower(track.Animation.AnimationId), "arm") or string.find(string.lower(track.Animation.AnimationId), "tool")) then
                    track:Stop(0)
                end
            end
        end
    end

    -- Ép buộc góc xoay trực tiếp vào khớp vai R15 (LeftUpperArm & RightUpperArm)
    local leftUpperArm = char:FindFirstChild("LeftUpperArm")
    local rightUpperArm = char:FindFirstChild("RightUpperArm")
    
    if leftUpperArm and leftUpperArm:FindFirstChild("LeftShoulder") then
        local lShoulder = leftUpperArm.LeftShoulder
        lShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(leftPitch, leftYaw, 0)
        lShoulder.C1 = CFrame.new(0, 0.5, 0)
    end
    
    if rightUpperArm and rightUpperArm:FindFirstChild("RightShoulder") then
        local rShoulder = rightUpperArm.RightShoulder
        rShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(rightPitch, rightYaw, 0)
        rShoulder.C1 = CFrame.new(0, 0.5, 0)
    end
end)

print("VR Mobile R15 (Camera Lock & Force Arm Motion) đã hoạt động!")
