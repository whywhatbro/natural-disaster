-- Natural Disaster Survival - Real Physics Block Art (Mọi người đều thấy)
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
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0, 10)
cornerFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Ghép Khối Thật 20x20 (Public View)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Parent = mainFrame

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

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(0, 120, 0, 35)
spawnBtn.Position = UDim2.new(0.5, -130, 1, -55)
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
spawnBtn.Text = "Kéo Khối Lên Đầu"
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.TextSize = 14
spawnBtn.Parent = mainFrame

local moveBtn = Instance.new("TextButton")
moveBtn.Size = UDim2.new(0, 120, 0, 35)
moveBtn.Position = UDim2.new(0.5, 10, 1, -55)
moveBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
moveBtn.Text = "Cài đặt Move (XYZ)"
moveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
moveBtn.TextSize = 14
moveBtn.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Bảng chỉnh vị trí Move XYZ
local moveFrame = Instance.new("Frame")
moveFrame.Size = UDim2.new(0, 280, 0, 180)
moveFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
moveFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
moveFrame.Visible = false
moveFrame.Parent = screenGui

local moveTitle = Instance.new("TextLabel")
moveTitle.Size = UDim2.new(1, 0, 0, 30)
moveTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
moveTitle.Text = "Điều Chỉnh Vị Trí (Offset XYZ)"
moveTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
moveTitle.Parent = moveFrame

local offsetX, offsetY, offsetZ = 0, 4, 0
local selectedParts = {}

local function createSlider(name, posY, initialVal, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 50, 0, 30)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.Text = name .. ": " .. initialVal
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Parent = moveFrame
    
    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(0, 200, 0, 10)
    sliderBar.Position = UDim2.new(0, 70, 0, posY + 10)
    sliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    sliderBar.Text = ""
    sliderBar.Parent = moveFrame
    
    sliderBar.MouseButton1Click:Connect(function()
        initialVal = initialVal + 1
        if initialVal > 10 then initialVal = -10 end
        label.Text = name .. ": " .. initialVal
        callback(initialVal)
    end)
end

createSlider("X", 45, offsetX, function(val) offsetX = val end)
createSlider("Y", 85, offsetY, function(val) offsetY = val end)
createSlider("Z", 125, offsetZ, function(val) offsetZ = val end)

local closeMoveBtn = Instance.new("TextButton")
closeMoveBtn.Size = UDim2.new(0, 80, 0, 25)
closeMoveBtn.Position = UDim2.new(0.5, -40, 1, -30)
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

-- Hàm thu thập các mảnh vỡ / block thực tế có sẵn trên bản đồ
local function getMapParts()
    local parts = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") and obj.Name ~= "Terrain" then
            -- Ưu tiên lấy những khối đang di chuyển/vỡ hoặc khối nhỏ trên map
            table.insert(parts, obj)
        end
    end
    return parts
end

-- Xử lý khi nhấn nút "Kéo Khối Lên Đầu"
spawnBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    selectedParts = {}
    
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local headPos = char.Head.Position
    
    -- Lấy danh sách các block thực tế từ bản đồ
    local availableParts = getMapParts()
    local partIndex = 1
    
    -- Duyệt lưới 20x20 người dùng đã chọn
    for y = 1, 20 do
        for x = 1, 20 do
            if gridData[y][x] then
                local targetPart = availableParts[partIndex]
                if targetPart then
                    -- Tắt vật lý tạm thời để cố định vị trí thành hình nghệ thuật trên đầu
                    pcall(function()
                        targetPart.Anchored = true
                        targetPart.CanCollide = false
                        
                        -- Tính toán tọa độ từng ô pixel bám theo đầu nhân vật + tùy chỉnh XYZ
                        local posX = headPos.X + (x - 10) * 0.7 + offsetX
                        local posY = headPos.Y + offsetY + (20 - y) * 0.7
                        local posZ = headPos.Z + offsetZ
                        
                        targetPart.CFrame = CFrame.new(posX, posY, posZ)
                    end)
                    
                    table.insert(selectedParts, targetPart)
                    partIndex = partIndex + 1
                    
                    -- Nếu danh sách block trên map ít quá thì quay vòng lại sử dụng tiếp
                    if partIndex > #availableParts then
                        partIndex = 1
                    end
                end
            end
        end
    end
end)
