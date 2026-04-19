-- Sailo Peace - Auto Teleport to Saved Position with Delay
-- Kéo GUI được + Auto bay về + Dropdown fix

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local savedCFrame = nil
local isAutoEnabled = false
local currentDelay = 30  -- mặc định 30 giây

-- Tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SailoPeaceAuto"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 260)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true   -- Kéo được toàn bộ GUI
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
title.Text = "🌊 Sailo Peace - Auto Teleport"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Nút lưu vị trí
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.9, 0, 0, 45)
saveBtn.Position = UDim2.new(0.05, 0, 0, 55)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
saveBtn.Text = "💾 Lưu Vị Trí Hiện Tại"
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.TextScaled = true
saveBtn.Parent = mainFrame

-- Dropdown chọn thời gian
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0.9, 0, 0, 45)
dropdown.Position = UDim2.new(0.05, 0, 0, 110)
dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
dropdown.Text = "⏱️ Thời gian delay: 30 giây"
dropdown.TextColor3 = Color3.new(1,1,1)
dropdown.TextScaled = true
dropdown.Parent = mainFrame

-- Frame chứa các option
local optionsFrame = Instance.new("Frame")
optionsFrame.Size = UDim2.new(1, 0, 0, 0)
optionsFrame.Position = UDim2.new(0, 0, 1, 5)
optionsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
optionsFrame.BorderSizePixel = 0
optionsFrame.Visible = false
optionsFrame.ZIndex = 10
optionsFrame.Parent = dropdown

local timeList = {
    {text = "10 giây",   value = 10},
    {text = "30 giây",   value = 30},
    {text = "1 phút",    value = 60},
    {text = "2 phút",    value = 120},
    {text = "3 phút",    value = 180},
}

for i, item in ipairs(timeList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = item.text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.ZIndex = 11
    btn.Parent = optionsFrame
    
    btn.MouseButton1Click:Connect(function()
        currentDelay = item.value
        dropdown.Text = "⏱️ Thời gian delay: " .. item.text
        optionsFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    optionsFrame.Visible = not optionsFrame.Visible
    optionsFrame.Size = UDim2.new(1, 0, 0, #timeList * 40)
end)

-- Nút Bật/Tắt Auto
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 170)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleBtn.Text = "🔴 BẬT AUTO BAY VỀ"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

-- Status label
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 30)
status.Position = UDim2.new(0.05, 0, 0, 225)
status.BackgroundTransparency = 1
status.Text = "Trạng thái: Chưa lưu vị trí"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.Parent = mainFrame

-- Lưu vị trí
saveBtn.MouseButton1Click:Connect(function()
    if root then
        savedCFrame = root.CFrame
        status.Text = "✅ Đã lưu vị trí!"
        wait(1.5)
        status.Text = "Trạng thái: Sẵn sàng Auto"
    end
end)

-- Toggle Auto
toggleBtn.MouseButton1Click:Connect(function()
    isAutoEnabled = not isAutoEnabled
    
    if isAutoEnabled then
        if not savedCFrame then
            status.Text = "❌ Chưa lưu vị trí!"
            isAutoEnabled = false
            wait(2)
            status.Text = "Trạng thái: Chưa lưu vị trí"
            return
        end
        toggleBtn.Text = "🟢 ĐANG AUTO BAY VỀ..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        status.Text = "Auto đang chạy - Delay: " .. currentDelay .. "s"
        
        -- Auto loop
        spawn(function()
            while isAutoEnabled and root and savedCFrame do
                task.wait(currentDelay)
                if isAutoEnabled and root then
                    root.CFrame = savedCFrame
                end
            end
        end)
        
    else
        toggleBtn.Text = "🔴 BẬT AUTO BAY VỀ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        status.Text = "Auto đã tắt"
    end
end)

print("✅ Sailo Peace Auto Teleport đã load! Kéo GUI bằng cách kéo title hoặc khung.")
