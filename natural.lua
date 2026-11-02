
-- Mobile VR Arms Pro V3
-- Roblox Studio / R15 / LocalScript
-- Independent Left & Right Arm Controller

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ================= SETTINGS =================

local MAX_PITCH = math.rad(110)
local MAX_YAW = math.rad(100)
local MAX_ROLL = math.rad(90)

local enabled = false

local character
local leftShoulder
local rightShoulder

local leftPitch, leftYaw = 0, 0
local rightPitch, rightYaw = 0, 0

local leftRoll, rightRoll = 0, 0

-- ================= GUI =================

local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("MobileVRGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MobileVRGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Toggle
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(50,50)
toggle.Position = UDim2.new(0,20,0,120)
toggle.BackgroundColor3 = Color3.fromRGB(0,170,255)
toggle.Text = "🥽"
toggle.TextSize = 24
toggle.Parent = gui

Instance.new("UICorner",toggle).CornerRadius =
    UDim.new(1,0)

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(380,210)
panel.Position = UDim2.new(0.5,-190,1,-230)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
panel.BackgroundTransparency = 0.2
panel.Visible = false
panel.Parent = gui

Instance.new("UICorner",panel).CornerRadius =
    UDim.new(0,12)

-- Reset
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.fromOffset(65,28)
resetButton.Position = UDim2.new(0.5,-32,0,175)
resetButton.BackgroundColor3 = Color3.fromRGB(255,80,80)
resetButton.Text = "RESET"
resetButton.TextColor3 = Color3.new(1,1,1)
resetButton.TextSize = 12
resetButton.Parent = panel

Instance.new("UICorner",resetButton).CornerRadius =
    UDim.new(0,6)

-- ================= RESET =================

local function resetArms()
    leftPitch,leftYaw,leftRoll = 0,0,0
    rightPitch,rightYaw,rightRoll = 0,0,0
end

resetButton.Activated:Connect(resetArms)

toggle.Activated:Connect(function()
    enabled = not enabled
    panel.Visible = enabled

    toggle.BackgroundColor3 = enabled
        and Color3.fromRGB(0,170,255)
        or Color3.fromRGB(80,80,80)

    if not enabled then
        resetArms()
    end
end)

-- ================= JOYSTICK =================

local function createJoystick(name,posX,callback)

    local outer = Instance.new("Frame")
    outer.Size = UDim2.fromOffset(130,130)
    outer.Position = UDim2.new(0,posX,0,40)
    outer.BackgroundColor3 = Color3.fromRGB(45,45,45)
    outer.BackgroundTransparency = 0.35
    outer.Parent = panel

    Instance.new("UICorner",outer).CornerRadius =
        UDim.new(1,0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,20)
    label.Position = UDim2.new(0,0,0,-22)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 13
    label.Parent = outer

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(50,50)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.fromScale(0.5,0.5)
    knob.BackgroundColor3 = Color3.fromRGB(0,200,255)
    knob.Parent = outer

    Instance.new("UICorner",knob).CornerRadius =
        UDim.new(1,0)

    local activeTouch
    local mouseActive = false

    local function reset()
        activeTouch = nil
        mouseActive = false
        knob.Position = UDim2.fromScale(0.5,0.5)
        callback(0,0)
    end

    outer.InputBegan:Connect(function(input)

        if not enabled then return end

        if input.UserInputType == Enum.UserInputType.Touch then
            if activeTouch then return end
            activeTouch = input

        elseif input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            mouseActive = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not enabled then return end

        local valid = false

        if activeTouch and input == activeTouch then
            valid = true
        elseif mouseActive and
            input.UserInputType ==
            Enum.UserInputType.MouseMovement then
            valid = true
        end

        if not valid then return end

        local center = outer.AbsolutePosition +
            outer.AbsoluteSize/2

        local delta = Vector2.new(
            input.Position.X,
            input.Position.Y
        ) - center

        local radius = 45

        if delta.Magnitude > radius then
            delta = delta.Unit * radius
        end

        knob.Position = UDim2.new(
            0.5,delta.X,
            0.5,delta.Y
        )

        callback(
            delta.X/radius,
            delta.Y/radius
        )
    end)

    UserInputService.InputEnded:Connect(function(input)

        if input == activeTouch or
            input.UserInputType ==
            Enum.UserInputType.MouseButton1
            and mouseActive then

            reset()
        end
    end)

    panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if not panel.Visible then
            reset()
        end
    end)
end

-- ================= LEFT ARM =================

createJoystick("LEFT ARM",25,function(x,y)

    leftYaw = x * MAX_YAW
    leftPitch = -y * MAX_PITCH

end)

-- ================= RIGHT ARM =================

createJoystick("RIGHT ARM",215,function(x,y)

    rightYaw = x * MAX_YAW
    rightPitch = -y * MAX_PITCH

end)

-- ================= CHARACTER =================

local function setupCharacter(char)

    character = char

    local torso = char:WaitForChild("UpperTorso")

    leftShoulder = torso:WaitForChild("LeftShoulder")
    rightShoulder = torso:WaitForChild("RightShoulder")

    resetArms()
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- ================= ARM CONTROLLER =================

RunService.PreSimulation:Connect(function()

    if not enabled then return end
    if not character or not character.Parent then return end

    if leftShoulder and leftShoulder.Parent then

        leftShoulder.Transform =
            CFrame.Angles(
                leftPitch,
                leftYaw,
                leftRoll
            )
    end

    if rightShoulder and rightShoulder.Parent then

        rightShoulder.Transform =
            CFrame.Angles(
                rightPitch,
                rightYaw,
                rightRoll
            )
    end
end)

print("Mobile VR Arms Pro V3 Loaded!")
