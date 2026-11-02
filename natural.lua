-- Mobile VR Arms - Local visual experiment
-- R15 avatar | Two touch joysticks | Toggle | Reset

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "MobileVRArms"
gui.ResetOnSpawn = false

local parent = game:GetService("CoreGui")
gui.Parent = parent

local active = false
local character, leftShoulder, rightShoulder
local leftValue = Vector2.zero
local rightValue = Vector2.zero
local originalLeft, originalRight

local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    local torso = character:WaitForChild("UpperTorso", 5)
    if not torso then return end

    leftShoulder = torso:FindFirstChild("LeftShoulder")
    rightShoulder = torso:FindFirstChild("RightShoulder")

    if leftShoulder and rightShoulder then
        originalLeft = leftShoulder.Transform
        originalRight = rightShoulder.Transform
    end
end

setupCharacter()

player.CharacterAdded:Connect(function()
    task.wait(1)
    setupCharacter()
end)

local function makeButton(name, position, size, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Text = name
    button.Parent = gui
    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 12)
    return button
end

local toggle = makeButton(
    "🥽 VR ON",
    UDim2.new(0, 15, 0, 120),
    UDim2.fromOffset(105, 45),
    Color3.fromRGB(40, 110, 190)
)

local reset = makeButton(
    "RESET",
    UDim2.new(0, 15, 0, 175),
    UDim2.fromOffset(105, 40),
    Color3.fromRGB(180, 75, 65)
)

local function makeJoystick(name, pos)
    local base = Instance.new("Frame")
    base.Name = name
    base.Size = UDim2.fromOffset(130, 130)
    base.Position = pos
    base.BackgroundColor3 = Color3.fromRGB(45,45,55)
    base.BackgroundTransparency = 0.2
    base.Parent = gui
    Instance.new("UICorner", base).CornerRadius =
        UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(48,48)
    knob.Position = UDim2.new(0.5,-24,0.5,-24)
    knob.BackgroundColor3 = Color3.fromRGB(80,170,255)
    knob.Parent = base
    Instance.new("UICorner", knob).CornerRadius =
        UDim.new(1,0)

    return base, knob
end

local leftBase, leftKnob = makeJoystick(
    "LeftJoystick",
    UDim2.new(0, 25, 1, -165)
)

local rightBase, rightKnob = makeJoystick(
    "RightJoystick",
    UDim2.new(1, -155, 1, -165)
)

local function connectJoystick(base, knob, side)
    local dragging = false
    local touchId

    local function update(position)
        local center = base.AbsolutePosition +
            base.AbsoluteSize / 2

        local delta = Vector2.new(
            position.X - center.X,
            position.Y - center.Y
        )

        local radius = 42
        if delta.Magnitude > radius then
            delta = delta.Unit * radius
        end

        knob.Position = UDim2.new(
            0.5, delta.X - 24,
            0.5, delta.Y - 24
        )

        local value = Vector2.new(
            delta.X / radius,
            delta.Y / radius
        )

        if side == "Left" then
            leftValue = value
        else
            rightValue = value
        end
    end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            touchId = input
            update(input.Position)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input == touchId then
            update(input.Position)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input == touchId then
            dragging = false
            touchId = nil
            knob.Position = UDim2.new(0.5,-24,0.5,-24)

            if side == "Left" then
                leftValue = Vector2.zero
            else
                rightValue = Vector2.zero
            end
        end
    end)
end

connectJoystick(leftBase, leftKnob, "Left")
connectJoystick(rightBase, rightKnob, "Right")

toggle.MouseButton1Click:Connect(function()
    active = not active
    toggle.Text = active and "🥽 VR ON" or "🥽 VR OFF"
end)

reset.MouseButton1Click:Connect(function()
    leftValue = Vector2.zero
    rightValue = Vector2.zero

    if leftShoulder and originalLeft then
        leftShoulder.Transform = originalLeft
    end

    if rightShoulder and originalRight then
        rightShoulder.Transform = originalRight
    end
end)

RunService:BindToRenderStep(
    "MobileVRArms",
    Enum.RenderPriority.Character.Value + 1,
    function()
        if not active or not character then return end
        if not leftShoulder or not rightShoulder then return end

        leftShoulder.Transform =
            CFrame.Angles(
                leftValue.Y * 1.2,
                0,
                -leftValue.X * 1.2
            )

        rightShoulder.Transform =
            CFrame.Angles(
                rightValue.Y * 1.2,
                0,
                -rightValue.X * 1.2
            )
    end
)

print("Mobile VR Arms loaded")
