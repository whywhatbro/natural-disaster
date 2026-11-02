-- Natural Disaster Survival - Perfect Pixel Art Controller (Sync & Smooth)
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
title.Text = "Ghép Khối Pixel Chuẩn 20x20"
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
spawnBtn.Text = "Tạo Mô Hình"
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

-- Bảng cài đặt Move & Góc độ chi tiết (XYZ & Rotation)
local moveFrame = Instance.new("Frame")
moveFrame.Size = UDim2.new(0, 300, 0, 260)
moveFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
moveFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
moveFrame.Visible = false
moveFrame.Parent = screenGui

local moveTitle = Instance.new("TextLabel")
moveTitle.Size = UDim2.new(1, 0, 0, 30)
moveTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
moveTitle.Text = "Tinh Chỉnh Tọa Độ & Góc Độ"
moveTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
moveTitle.Parent = moveFrame

-- Biến cấu hình vị trí và góc xoay
local offsetX, offsetY, offsetZ = 0, 3.5, 0
local rotX, rotY, rotZ = 0, 0, 0 -- Góc xoay ngang/dọc
local activeMapping = {} -- Lưu danh sách block đang bám theo người chơi
local isFollowing = false

local function createSlider(name, posY, min, max, initialVal, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 80, 0, 25)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.Text = name .. ": " .. string.format("%.1f", initialVal)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextSize = 12
    label.Parent = moveFrame
    
    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(0, 180, 0, 10)
    sliderBar.Position = UDim2.new(0, 100, 0, posY + 8)
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

createSlider("PosX", 40, -10, 10, offsetX, function(val) offsetX = val end)
createSlider("PosY", 75, -5, 15, offsetY, function(val) offsetY = val end)
createSlider("PosZ", 110, -10, 10, offsetZ, function(val) offsetZ = val end)
createSlider("RotX", 145, 0, 360, rotX, function(val) rotX = val end)
createSlider("RotY", 180, 0, 360, rotY, function(val) rotY = val end)

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

-- Chỉ lọc đúng các mảnh vụn / block vỡ thật sự (loại bỏ người chơi, map chính, vật thể cố định)
local function getValidDebris()
    local debris = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not obj.Parent:FindFirstChild("Humanoid") then
            -- Đảm bảo chỉ lấy khối nhỏ hoặc mảnh vỡ thực sự
            if obj.Size.Magnitude < 15 and obj.Name ~= "Terrain" then
                table.insert(debris, obj)
            end
        end
    end
    return debris
end

-- Khi nhấn tạo mô hình
spawnBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    activeMapping = {}
    
    local debrisList = getValidDebris()
    if #debrisList == 0 then
        return -- Không tìm thấy mảnh vỡ nào
    end
    
    local debrisIndex = 1
    
    -- Duyệt lưới pixel 20x20 chuẩn xác từng ô nhỏ (kích thước khoảng 0.45 stud để mô hình gọn gàng)
    local pixelSize = 0.45 
    
    for y = 1, 20 do
        for x = 1, 20 do
            if gridData[y][x] then
                local part = debrisList[debrisIndex]
                if part then
                    -- Cố định kích thước block về chuẩn 1x1 nhỏ gọn (đúng chuẩn pixel)
                    pcall(function()
                        part.Size = Vector3.new(pixelSize, pixelSize, pixelSize)
                        part.CanCollide = false
                    end)
                    
                    -- Lưu thông tin vị trí tương đối trên lưới pixel
                    table.insert(activeMapping, {
                        part = part,
                        localPos = Vector3.new((x - 10) * pixelSize, (20 - y) * pixelSize, 0)
                    })
                    
                    debrisIndex = debrisIndex + 1
                    if debrisIndex > #debrisList then
                        debrisIndex = 1 -- Quay vòng danh sách nếu cần thêm khối
                    end
                end
            end
        end
    end
    
    isFollowing = true
end)

-- Vòng lặp cập nhật liên tục vị trí để mô hình bám dính chặt và xoay theo nhân vật
RunService.RenderStepped:Connect(function()
    if not isFollowing then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local head = char.Head
    
    -- Thiết lập độ xoay và góc độ (Rotation)
    local baseCFrame = head.CFrame * CFrame.new(offsetX, offsetY, offsetZ) * CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))
    
    for _, item in ipairs(activeMapping) do
        local p = item.part
        if p and p.Parent then
            p.Anchored = true
            -- Dịch chuyển block bám chính xác theo hệ tọa độ xoay quanh đầu nhân vật
            p.CFrame = baseCFrame * CFrame.new(item.localPos)
        end
    end
end)
