-- Natural Disaster Survival - Real Public Debris Pixel Art
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
mainFrame.Size = UDim2.new(0, 320, 0, 460)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0, 10)
cornerFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Chọn Mảnh Vỡ Thật (Public View)"
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

-- Nút quét block vỡ khả dụng
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0, 140, 0, 30)
scanBtn.Position = UDim2.new(0.5, -140, 1, -80)
scanBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
scanBtn.Text = "Quét Block Vỡ (0)"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 12
scanBtn.Parent = mainFrame

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(0, 140, 0, 30)
spawnBtn.Position = UDim2.new(0.5, 0, 1, -80)
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
spawnBtn.Text = "Gắn Hình Lên Đầu"
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.TextSize = 12
spawnBtn.Parent = mainFrame

local moveBtn = Instance.new("TextButton")
moveBtn.Size = UDim2.new(0, 280, 0, 30)
moveBtn.Position = UDim2.new(0.5, -140, 1, -45)
moveBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
moveBtn.Text = "Cài đặt Move, Size & Góc Xoay (XYZ)"
moveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
moveBtn.TextSize = 12
moveBtn.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Bảng cài đặt chi tiết (Move, Size, Góc độ)
local moveFrame = Instance.new("Frame")
moveFrame.Size = UDim2.new(0, 300, 0, 280)
moveFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
moveFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
moveFrame.Visible = false
moveFrame.Parent = screenGui

local moveTitle = Instance.new("TextLabel")
moveTitle.Size = UDim2.new(1, 0, 0, 30)
moveTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
moveTitle.Text = "Tinh Chỉnh Nâng Cao"
moveTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
moveTitle.Parent = moveFrame

local offsetX, offsetY, offsetZ = 0, 4, 0
local rotX, rotY, rotZ = 0, 0, 0
local pixelSize = 0.6 -- Tùy chỉnh kích thước block cho chuẩn
local activeMapping = {}
local isFollowing = false
local validDebrisList = {}

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

-- Chức năng quét đúng các block vỡ thực sự (Unanchored và có thể va chạm/di chuyển)
local function scanRealDebris()
    validDebrisList = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not obj.Parent:FindFirstChild("Humanoid") then
            -- Chỉ lấy các mảnh vỡ có kích thước hợp lý (loại bỏ mấy hạt bụi hoặc khối quá khổng lồ)
            if obj.Size.Magnitude >= 1 and obj.Size.Magnitude <= 12 and obj.Name ~= "Terrain" then
                table.insert(validDebrisList, obj)
            end
        end
    end
    scanBtn.Text = "Đã tìm thấy: " .. #validDebrisList
end

scanBtn.MouseButton1Click:Connect(scanRealDebris)

-- Gắn hình pixel lên đầu và bám theo nhân vật
spawnBtn.MouseButton1Click:Connect(function()
    if #validDebrisList == 0 then
        scanRealDebris()
        if #validDebrisList == 0 then return end
    end
    
    mainFrame.Visible = false
    activeMapping = {}
    local debrisIndex = 1
    
    for y = 1, 20 do
        for x = 1, 20 do
            if gridData[y][x] then
                local part = validDebrisList[debrisIndex]
                if part and part.Parent then
                    pcall(function()
                        -- Tắt trọng lực tạm thời để giữ nguyên hình dáng nghệ thuật trên đầu
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        part.CanCollide = false
                    end)
                    
                    table.insert(activeMapping, {
                        part = part,
                        localPos = Vector3.new((x - 10) * pixelSize, (20 - y) * pixelSize, 0)
                    })
                    
                    debrisIndex = debrisIndex + 1
                    if debrisIndex > #validDebrisList then
                        debrisIndex = 1 -- Lặp lại danh sách nếu hình vẽ cần nhiều block hơn số lượng quét được
                    end
                end
            end
        end
    end
    
    isFollowing = true
end)

-- Vòng lặp cập nhật liên tục bám theo người chơi và góc xoay
RunService.RenderStepped:Connect(function()
    if not isFollowing then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local head = char.Head
    
    local baseCFrame = head.CFrame * CFrame.new(offsetX, offsetY, offsetZ) * CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))
    
    for _, item in ipairs(activeMapping) do
        local p = item.part
        if p and p.Parent then
            p.CFrame = baseCFrame * CFrame.new(item.localPos)
        end
    end
end)
