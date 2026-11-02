
-- Roblox Mobile VR Arm Controller V2
-- Original UI + Fixed R15 Motor6D + Mobile Joystick

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ==========================================
-- XÓA GUI CŨ
-- ==========================================

local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("MobileVRGui") then
    playerGui.MobileVRGui:Destroy()
end

-- ==========================================
-- GUI BAN ĐẦU
-- ==========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileVRGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

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

-- Khung giao diện chứa Joystick
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

-- ==========================================
-- BIẾN ĐIỀU KHIỂN
-- ==========================================

local enabled = false
local isInteracting = false

local leftX, leftY = 0, 0
local rightX, rightY = 0, 0

-- Góc điều khiển
local MAX_PITCH = math.rad(100)
local MAX_YAW = math.rad(120)

-- R15
local character
local leftShoulder
local rightShoulder

-- ==========================================
-- RESET ĐIỀU KHIỂN
-- ==========================================

local function resetControls()
    leftX, leftY = 0, 0
    rightX, rightY = 0, 0
    isInteracting = false
end

-- ==========================================
-- NÚT VR
-- ==========================================

toggleBtn.Activated:Connect(function()
    enabled = not enabled
    mainFrame.Visible = enabled

    if not enabled then
        resetControls()
    end

    toggleBtn.BackgroundColor3 = enabled
        and Color3.fromRGB(0, 170, 255)
        or Color3.fromRGB(80, 80, 80)
end)

-- ==========================================
-- JOYSTICK
-- ==========================================

local function createSuperJoystick(name, posX, onUpdate)

    local outer = Instance.new("Frame")
    outer.Name = name
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
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0.5, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    knob.Parent = outer

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local activeInput = nil
    local activeType = nil

    local function resetJoystick()
        activeInput = nil
        activeType = nil

        knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        onUpdate(0, 0)

        isInteracting = false
    end

    -- Bắt đầu kéo
    outer.InputBegan:Connect(function(input)

        if not enabled then return end

        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

            if activeInput then return end

            activeInput = input
            activeType = input.UserInputType
            isInteracting = true
        end
    end)

    -- Theo dõi kéo joystick
    UserInputService.InputChanged:Connect(function(input)

        if not enabled or not activeInput then return end

        local validInput = false

        if activeType == Enum.UserInputType.Touch then
            validInput = input == activeInput

        elseif activeType == Enum.UserInputType.MouseButton1 then
            validInput =
                input.UserInputType == Enum.UserInputType.MouseMovement
        end

        if not validInput then return end

        local pos = input.Position
        local outerPos = outer.AbsolutePosition
        local outerSize = outer.AbsoluteSize

        local center = outerPos + outerSize / 2

        local delta = Vector2.new(pos.X, pos.Y) - center

        local radius = 45

        if delta.Magnitude > radius then
            delta = delta.Unit * radius
        end

        -- Di chuyển nút joystick
        knob.Position = UDim2.new(
            0.5, delta.X,
            0.5, delta.Y
        )

        -- Giá trị -1 đến 1
        onUpdate(
            delta.X / radius,
            delta.Y / radius
        )
    end)

    -- Thả joystick
    UserInputService.InputEnded:Connect(function(input)

        if input == activeInput then
            resetJoystick()
        end
    end)

    -- Reset nếu ẩn menu
    mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()

        if not mainFrame.Visible then
            resetJoystick()
        end
    end)
end

-- ==========================================
-- JOYSTICK TAY TRÁI
-- ==========================================

createSuperJoystick("Tay Trái (Left)", 35, function(x, y)

    leftY = x * MAX_YAW
    leftX = -y * MAX_PITCH

end)

-- ==========================================
-- JOYSTICK TAY PHẢI
-- ==========================================

createSuperJoystick("Tay Phải (Right)", 215, function(x, y)

    rightY = x * MAX_YAW
    rightX = -y * MAX_PITCH

end)

-- ==========================================
-- R15 CHARACTER
-- ==========================================

local function setupCharacter(char)

    character = char

    -- Tìm UpperTorso
    local torso = char:WaitForChild("UpperTorso")

    -- Motor6D nằm trong UpperTorso
    leftShoulder = torso:WaitForChild("LeftShoulder")
    rightShoulder = torso:WaitForChild("RightShoulder")

    -- Reset góc tay
    resetControls()

    print("R15 Arm Controller: Character Ready")
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- ==========================================
-- ĐIỀU KHIỂN TAY R15
-- ==========================================

RunService.PreSimulation:Connect(function()

    if not character or not character.Parent then
        return
    end

    if not enabled then
        return
    end

    -- TAY TRÁI
    if leftShoulder and leftShoulder.Parent then

        leftShoulder.Transform = CFrame.Angles(
            leftX,
            leftY,
            0
        )
    end

    -- TAY PHẢI
    if rightShoulder and rightShoulder.Parent then

        rightShoulder.Transform = CFrame.Angles(
            rightX,
            rightY,
            0
        )
    end

end)

-- ==========================================
-- HOÀN TẤT
-- ==========================================

print("Mobile VR R15 Arm Controller V2 Loaded!")
