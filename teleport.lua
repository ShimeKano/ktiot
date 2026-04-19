-- Sailo Peace - Teleport to Saved Position with Delay
-- Script đơn giản bằng Synapse X / Fluxus / Delta / Wave...

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local savedPosition = nil

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SailoPeaceTP"
screenGui.Parent = game.CoreGui  -- hoặc player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 220)
frame.Position = UDim2.new(0.5, -140, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Sailo Peace - Teleport Delay"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

-- Nút Save vị trí hiện tại
local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(0.9, 0, 0, 40)
saveButton.Position = UDim2.new(0.05, 0, 0, 50)
saveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
saveButton.Text = "💾 Lưu Vị Trí Hiện Tại"
saveButton.TextColor3 = Color3.new(1,1,1)
saveButton.TextScaled = true
saveButton.Parent = frame

-- Dropdown chọn thời gian
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0.9, 0, 0, 40)
dropdown.Position = UDim2.new(0.05, 0, 0, 100)
dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdown.Text = "⏱️ Chọn thời gian: 30s"
dropdown.TextColor3 = Color3.new(1,1,1)
dropdown.TextScaled = true
dropdown.Parent = frame

local times = {
    ["10s"] = 10,
    ["30s"] = 30,
    ["1 phút"] = 60,
    ["2 phút"] = 120,
    ["3 phút"] = 180
}

local currentTime = 30  -- mặc định 30 giây
local timeOptions = {"10s", "30s", "1 phút", "2 phút", "3 phút"}

-- Tạo menu dropdown (click để chọn)
local isOpen = false
local optionFrame = Instance.new("Frame")
optionFrame.Size = UDim2.new(1, 0, 0, 0)
optionFrame.Position = UDim2.new(0, 0, 1, 0)
optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
optionFrame.BorderSizePixel = 0
optionFrame.Visible = false
optionFrame.Parent = dropdown

for _, t in ipairs(timeOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (#timeOptions - #timeOptions + 1) * 35) -- sắp xếp
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = t
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = optionFrame
    
    btn.MouseButton1Click:Connect(function()
        currentTime = times[t]
        dropdown.Text = "⏱️ Chọn thời gian: " .. t
        optionFrame.Visible = false
        isOpen = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    optionFrame.Visible = isOpen
    optionFrame.Size = UDim2.new(1, 0, 0, #timeOptions * 35)
end)

-- Nút Teleport
local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0.9, 0, 0, 50)
tpButton.Position = UDim2.new(0.05, 0, 0, 155)
tpButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
tpButton.Text = "🚀 Bay về vị trí sau delay"
tpButton.TextColor3 = Color3.new(1,1,1)
tpButton.TextScaled = true
tpButton.Parent = frame

-- Sự kiện nút Save
saveButton.MouseButton1Click:Connect(function()
    if humanoidRootPart then
        savedPosition = humanoidRootPart.CFrame
        saveButton.Text = "✅ Đã lưu vị trí!"
        wait(1.5)
        saveButton.Text = "💾 Lưu Vị Trí Hiện Tại"
    end
end)

-- Sự kiện nút Teleport
tpButton.MouseButton1Click:Connect(function()
    if not savedPosition then
        tpButton.Text = "❌ Chưa lưu vị trí!"
        wait(2)
        tpButton.Text = "🚀 Bay về vị trí sau delay"
        return
    end
    
    tpButton.Text = "⏳ Đang chờ " .. currentTime .. " giây..."
    tpButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    
    task.wait(currentTime)
    
    if humanoidRootPart and savedPosition then
        humanoidRootPart.CFrame = savedPosition
        tpButton.Text = "✅ Đã teleport!"
        tpButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        wait(2)
        tpButton.Text = "🚀 Bay về vị trí sau delay"
        tpButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    end
end)

print("✅ Script Sailo Peace - Teleport Delay đã load thành công!")
