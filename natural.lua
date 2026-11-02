-- Natural Disaster Survival - Stable Pixel Art & Debris Selector
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("NDSPixelArtGui") then
    CoreGui.NDSPixelArtGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NDSPixelArtGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- Nút nổi mở bảng vẽ
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 150)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.Text = "🎨"
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = screenGui

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleBtn

-- Bảng chính 20x20
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 440)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0, 10)
cornerFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Pixel Art - Chọn Block Thật"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Parent = mainFrame

-- Lưới vẽ 20x20
local gridContainer = Instance.new("Frame")
gridContainer.Size = UDim2.new(0, 260, 0, 260)
gridContainer.Position = UDim2.new(0.5, -130, 0, 45)
gridContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
gridContainer.Parent = mainFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 12, 0, 12)
gridLayout.CellPadding = UDim2.new(0, 1, 0, 1)
gridLayout.Parent = gridContainer

local gridData = {}
for y = 1, 20 do
    gridData[y] = {}
    for x = 1, 20 do
        gridData[y][x] = false
        local cell = Instance.new("TextButton")
        cell.Size = UDim2.new(0, 12, 0, 12)
        cell.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        cell.Text = ""
        cell.Parent = gridContainer
        
        cell.MouseButton1Click:Connect(function()
            gridData[y][x] = not gridData[y][x]
            if gridData[y][x] then
                cell.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
            else
                cell.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)
    end
end

-- Nút mở danh sách block
local chooseBlockBtn = Instance.new("TextButton")
chooseBlockBtn.Size = UDim2.new(0, 140, 0, 30)
chooseBlockBtn.Position = UDim2.new(0.5, -140, 1, -75)
chooseBlockBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
chooseBlockBtn.Text = "Chọn Tên Block"
chooseBlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
chooseBlockBtn.TextSize = 11
chooseBlockBtn.Parent = mainFrame

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(0, 140, 0, 30)
spawnBtn.Position = UDim2.new(0.5, 0, 1, -75)
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
spawnBtn.Text = "Đẩy Block Lên Đầu"
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.TextSize = 11
spawnBtn.Parent = mainFrame

local moveBtn = Instance.new("TextButton")
moveBtn.Size = UDim2.new(0, 280, 0, 30)
moveBtn.Position = UDim2.new(0.5, -140, 1, -40)
moveBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
moveBtn.Text = "Cài đặt Move, Size & Góc Xoay (XYZ)"
moveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
moveBtn.TextSize = 11
moveBtn.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Bảng hiển thị danh sách dạng Tên & Số lượng
local blockListFrame = Instance.new("ScrollingStructure") -- Sửa lại thành ScrollingFrame cho chuẩn
local blockListFrame = Instance.new("ScrollingFrame")
blockListFrame.Size = UDim2.new(0, 260, 0, 250)
blockListFrame.Position = UDim2.new(0.5, -130, 0.5, -125)
blockListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
blockListFrame.Visible = false
blockListFrame.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = blockListFrame

local selectedBlockType = nil 
local availableDebrisCategories = {}

local function scanAndShowDebris()
    for _, child in pairs(blockListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    availableDebrisCategories = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored then
            local isChar = false
            local p = obj.Parent
            while p and p ~= Workspace do
                if p:FindFirstChild("Humanoid") then
                    isChar = true
                    break
                end
                p = p.Parent
            end
            
            -- Lọc block vỡ thực sự (bỏ nền đất to)
            if not isChar and obj.Name ~= "Terrain" and obj.Size.Magnitude >= 0.5 and obj.Size.Magnitude <= 10 then
                local key = obj.Name
                if not availableDebrisCategories[key] then
                    availableDebrisCategories[key] = {
                        name = obj.Name,
                        parts = {}
                    }
                end
                table.insert(availableDebrisCategories[key].parts, obj)
            end
        end
    end
    
    -- Tạo nút bấm hiển thị Tên và Số lượng (SL)
    for key, data in pairs(availableDebrisCategories) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.Text = "  " .. data.name .. "  |  Số lượng: " .. #data.parts
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = blockListFrame
        
        btn.MouseButton1Click:Connect(function()
            selectedBlockType = data.parts
            chooseBlockBtn.Text = "Đã chọn: " .. data.name
            blockListFrame.Visible = false
        end)
    end
end

chooseBlockBtn.MouseButton1Click:Connect(function()
    blockListFrame.Visible = not blockListFrame.Visible
    if blockListFrame.Visible then
        scanAndShowDebris()
    end
end)

-- Bảng cài đặt Move, Size, Góc xoay
local moveFrame = Instance.new("Frame")
moveFrame.Size = UDim2.new(0, 300, 0, 280)
moveFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
moveFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
moveFrame.Visible = false
moveFrame.Parent = screenGui

local offsetX, offsetY, offsetZ = 0, 4, 0
local rotX, rotY, rotZ = 0, 0, 0
local pixelSize = 0.6
local activeMapping = {}
local isFollowing = false

local function createSlider(name, posY, min, max, initialVal, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 90, 0, 25)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.Text = name .. ": " .. string.format("%.1f", initialVal)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextSize = 12
    label.Parent = moveFrame
    
    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(0, 170, 0, 10)
    sliderBar.Position = UDim2.new(0, 110, 0, posY + 8)
    sliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderBar.Text = ""
    sliderBar.Parent = moveFrame
    
    sliderBar.MouseButton1Click:Connect(function()
        initialVal = initialVal + 0.5
        if initialVal > max then initialVal = min end
        label.Text = name .. ": " .. string.format("%.1f", initialVal)
        callback(initialVal)
    end)
end

createSlider("PosX", 35, -10, 10, offsetX, function(val) offsetX = val end)
createSlider("PosY", 70, -5, 15, offsetY, function(val) offsetY = val end)
createSlider("PosZ", 105, -10, 10, offsetZ, function(val) offsetZ = val end)
createSlider("Size", 140, 0.3, 2.0, pixelSize, function(val) pixelSize = val end)
createSlider("RotX", 175, 0, 360, rotX, function(val) rotX = val end)
createSlider("RotY", 210, 0, 360, rotY, function(val) rotY = val end)

local closeMoveBtn = Instance.new("TextButton")
closeMoveBtn.Size = UDim2.new(0, 90, 0, 25)
closeMoveBtn.Position = UDim2.new(0.5, -45, 1, -30)
closeMoveBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
closeMoveBtn.Text = "Đóng"
closeMoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeMoveBtn.Parent = moveFrame

moveBtn.MouseButton1Click:Connect(function()
    moveFrame.Visible = true
end)

closeMoveBtn.MouseButton1Click:Connect(function()
    moveFrame.Visible = false
end)

-- Gắn hình và đẩy block vật lý thực tế
spawnBtn.MouseButton1Click:Connect(function()
    if not selectedBlockType or #selectedBlockType == 0 then
        return
    end
    
    mainFrame.Visible = false
    activeMapping = {}
    local debrisIndex = 1
    
    for y = 1, 20 do
        for x = 1, 20 do
            if gridData[y][x] then
                local part = selectedBlockType[debrisIndex]
                if part and part.Parent then
                    pcall(function()
                        part:SetNetworkOwner(player)
                        part.CanCollide = true
                        part.Size = Vector3.new(pixelSize, pixelSize, pixelSize)
                    end)
                    
                    table.insert(activeMapping, {
                        part = part,
                        localPos = Vector3.new((x - 10) * pixelSize, (20 - y) * pixelSize, 0)
                    })
                    
                    debrisIndex = debrisIndex + 1
                    if debrisIndex > #selectedBlockType then
                        debrisIndex = 1
                    end
                end
            end
        end
    end
    
    isFollowing = true
end)

-- Vòng lặp đẩy lực vật lý (Mọi người đều thấy và chạm được)
RunService.RenderStepped:Connect(function()
    if not isFollowing then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local head = char.Head
    
    local baseCFrame = head.CFrame * CFrame.new(offsetX, offsetY, offsetZ) * CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))
    
    for _, item in ipairs(activeMapping) do
        local p = item.part
        if p and p.Parent then
            local targetCFrame = baseCFrame * CFrame.new(item.localPos)
            local currentPos = p.Position
            local targetPos = targetCFrame.Position
            local direction = (targetPos - currentPos)
            
            p.AssemblyLinearVelocity = direction * 15
            p.CFrame = p.CFrame:Lerp(targetCFrame, 0.2)
        end
    end
end)
