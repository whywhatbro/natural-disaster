-- Roblox Mobile VR Arm Controller for R15
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

-- Nút Bật/Tắt Menu VR
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.Text = "🥽"
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = screenGui

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleBtn

-- Khung điều khiển chính (Ẩn/Hiện)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 200)
mainFrame.Position = UDim2.new(0.5, -180, 1, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0, 12)
cornerFrame.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Biến điều khiển góc tay (Left & Right Arm Angles)
local leftArmAngleX, leftArmAngleY = 0, 0
local rightArmAngleX, rightArmAngleY = 0, 0

-- Hàm tạo Joystick ảo trên màn hình điện thoại
local function createVirtualJoystick(name, posX, callback)
    local stickBg = Instance.new("Frame")
    stickBg.Size = UDim2.new(0, 120, 0, 120)
    stickBg.Position = UDim2.new(0, posX, 0, 40)
    stickBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    stickBg.BackgroundTransparency = 0.5
    stickBg.Parent = mainFrame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = stickBg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, -25)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Parent = stickBg

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 50, 0, 50)
    knob.Position = UDim2.new(0.5, -25, 0.5, -25)
    knob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    knob.Text = ""
    knob.Parent = stickBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local touchId = nil
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            touchId = input
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == touchId then
            dragging = false
            touchId = nil
            knob.Position = UDim2.new(0.5, -25, 0.5, -25)
            callback(0, 0)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local pos = input.Position
            local bgPos = stickBg.AbsolutePosition
            local center = bgPos + Vector2.new(60, 60)
            local delta = Vector2.new(pos.X, pos.Y) - center
            
            -- Giới hạn bán kính joystick
            local distance = delta.Magnitude
            if distance > 45 then
                delta = delta.Unit * 45
            end
            
            knob.Position = UDim2.new(0.5, delta.X - 25, 0.5, delta.Y - 25)
            
            -- Trả về giá trị -1 đến 1
            callback(delta.X / 45, delta.Y / 45)
        end
    end)
end

-- Tạo Joystick điều khiển Tay Trái và Tay Phải
createVirtualJoystick("Tay Trái (Left Arm)", 30, function(x, y)
    leftArmAngleY = x * 2
    leftArmAngleX = -y * 2
end)

createVirtualJoystick("Tay Phải (Right Arm)", 210, function(x, y)
    rightArmAngleY = x * 2
    rightArmAngleX = -y * 2
end)

-- Vòng lặp cập nhật chuyển động khớp vai R15 (Motor6D / CFrame)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    local leftUpperArm = char:FindFirstChild("LeftUpperArm")
    local rightUpperArm = char:FindFirstChild("RightUpperArm")
    
    if leftUpperArm and leftUpperArm:FindFirstChild("LeftShoulder") then
        local shoulder = leftUpperArm.LeftShoulder
        shoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(leftArmAngleX, leftArmAngleY, 0)
    end
    
    if rightUpperArm and rightUpperArm:FindFirstChild("RightShoulder") then
        local shoulder = rightUpperArm.RightShoulder
        shoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(rightArmAngleX, rightArmAngleY, 0)
    end
end)

print("Script VR Mobile R15 đã khởi động thành công!")
