-- Sailo Peace - Auto Teleport to Saved Position with Tween
-- Simplified: Không cần Key Spam simulate (game không hỗ trợ)

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Dùng _G để savedCFrame và trạng thái auto tồn tại qua các lần respawn / re-execute
if _G.SailoPeace_IsAutoEnabled == nil then
    _G.SailoPeace_IsAutoEnabled = false
end
if _G.SailoPeace_LoopId == nil then
    _G.SailoPeace_LoopId = 0
end
if _G.SailoPeace_LockPosition == nil then
    _G.SailoPeace_LockPosition = false
end

local currentDelay = 30
local TWEEN_SPEED = 300

-- Lấy HumanoidRootPart của nhân vật hiện tại
local function getRoot()
    local char = player.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Hàm tính thời gian tween dựa trên khoảng cách
local function calculateTweenTime(fromCFrame, toCFrame)
    local distance = (fromCFrame.Position - toCFrame.Position).Magnitude
    return distance / TWEEN_SPEED
end

-- Tạo GUI
local existingGui = player:WaitForChild("PlayerGui"):FindFirstChild("SailoPeaceAuto")
if existingGui then
    existingGui:Destroy()
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SailoPeaceAuto"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 370)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
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

-- Nút Bật/Tắt Auto Teleport
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 165)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleBtn.Text = "🔴 BẬT AUTO BAY VỀ"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

-- Nút Lock Position
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.9, 0, 0, 45)
lockBtn.Position = UDim2.new(0.05, 0, 0, 220)
lockBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
lockBtn.TextColor3 = Color3.new(1,1,1)
lockBtn.TextScaled = true
lockBtn.Parent = mainFrame

-- Status label
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 80)
status.Position = UDim2.new(0.05, 0, 0, 275)
status.BackgroundTransparency = 1
status.Text = "Trạng thái: Chưa lưu vị trí\n\n⌨️ Bấm phím thực tế từ bàn phím:\nC, X, Z, V, F để sử dụng skill"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.TextWrapped = true
status.Parent = mainFrame

-- ============ LOCK POSITION ============
local lockConnection = nil
local function startLockPosition()
    if lockConnection then lockConnection:Disconnect() end
    
    lockConnection = RunService.Heartbeat:Connect(function()
        if not _G.SailoPeace_LockPosition or not _G.SailoPeace_SavedCFrame then
            return
        end
        
        local root = getRoot()
        if root then
            local distance = (root.Position - _G.SailoPeace_SavedCFrame.Position).Magnitude
            if distance > 5 then
                root.CFrame = _G.SailoPeace_SavedCFrame
            end
        end
    end)
end

local function stopLockPosition()
    if lockConnection then
        lockConnection:Disconnect()
        lockConnection = nil
    end
end

-- ============ AUTO TELEPORT ============
local function startAutoLoop()
    _G.SailoPeace_LoopId = _G.SailoPeace_LoopId + 1
    local myId = _G.SailoPeace_LoopId
    spawn(function()
        while _G.SailoPeace_IsAutoEnabled and _G.SailoPeace_SavedCFrame and _G.SailoPeace_LoopId == myId do
            task.wait(currentDelay)
            if not _G.SailoPeace_IsAutoEnabled or not _G.SailoPeace_SavedCFrame or _G.SailoPeace_LoopId ~= myId then break end
            
            local root = getRoot()
            if root then
                local targetCFrame = _G.SailoPeace_SavedCFrame
                local tweenTime = calculateTweenTime(root.CFrame, targetCFrame)
                
                local tweenInfo = TweenInfo.new(
                    tweenTime,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.InOut
                )
                
                local goal = {CFrame = targetCFrame}
                
                local tween = TweenService:Create(root, tweenInfo, goal)
                tween:Play()
                
                tween.Completed:Wait()
                
                if _G.SailoPeace_IsAutoEnabled then
                    root.CFrame = _G.SailoPeace_SavedCFrame
                end
            end
        end
    end)
end

-- ============ LƯU VỊ TRÍ ============
saveBtn.MouseButton1Click:Connect(function()
    local root = getRoot()
    if root then
        _G.SailoPeace_SavedCFrame = root.CFrame
        status.Text = "✅ Đã lưu vị trí!\nSẵn sàng Auto\n\n⌨️ Bấm phím: C, X, Z, V, F"
        task.wait(1.5)
        status.Text = "Trạng thái: Sẵn sàng Auto\n\n⌨️ Bấm phím: C, X, Z, V, F"
    end
end)

-- ============ TOGGLE AUTO TELEPORT ============
toggleBtn.MouseButton1Click:Connect(function()
    _G.SailoPeace_IsAutoEnabled = not _G.SailoPeace_IsAutoEnabled

    if _G.SailoPeace_IsAutoEnabled then
        if not _G.SailoPeace_SavedCFrame then
            status.Text = "❌ Chưa lưu vị trí!\n\n⌨️ Bấm phím: C, X, Z, V, F"
            _G.SailoPeace_IsAutoEnabled = false
            task.wait(2)
            status.Text = "Trạng thái: Chưa lưu vị trí\n\n⌨️ Bấm phím: C, X, Z, V, F"
            return
        end
        toggleBtn.Text = "🟢 ĐANG AUTO BAY VỀ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        status.Text = "✈️ Auto bay về chạy\n⏱️ Delay: " .. currentDelay .. "s\n\n⌨️ Bấm phím: C, X, Z, V, F"
        startAutoLoop()
    else
        toggleBtn.Text = "🔴 BẬT AUTO BAY VỀ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        status.Text = "❌ Auto bay về tắt\n\n⌨️ Bấm phím: C, X, Z, V, F"
    end
end)

-- ============ TOGGLE LOCK POSITION ============
lockBtn.MouseButton1Click:Connect(function()
    _G.SailoPeace_LockPosition = not _G.SailoPeace_LockPosition

    if _G.SailoPeace_LockPosition then
        if not _G.SailoPeace_SavedCFrame then
            status.Text = "❌ Chưa lưu vị trí!\n\n⌨️ Bấm phím: C, X, Z, V, F"
            _G.SailoPeace_LockPosition = false
            task.wait(2)
            status.Text = "Trạng thái: Chưa lưu vị trí\n\n⌨️ Bấm phím: C, X, Z, V, F"
            return
        end
        lockBtn.Text = "🟣 ĐANG LOCK VỊ TRÍ"
        lockBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
        status.Text = "🔒 Lock vị trí chạy\n(Chống game teleport)\n\n⌨️ Bấm phím: C, X, Z, V, F"
        startLockPosition()
    else
        lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
        lockBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
        status.Text = "🔓 Lock vị trí tắt\n\n⌨️ Bấm phím: C, X, Z, V, F"
        stopLockPosition()
    end
end)

-- ============ KHI RESPAWN ============
player.CharacterAdded:Connect(function(newCharacter)
    newCharacter:WaitForChild("HumanoidRootPart")
    if _G.SailoPeace_IsAutoEnabled and _G.SailoPeace_SavedCFrame then
        status.Text = "♻️ Respawn - Tiếp tục Auto...\n\n⌨️ Bấm phím: C, X, Z, V, F"
        task.wait(1)
        status.Text = "✈️ Auto bay về chạy\n⏱️ Delay: " .. currentDelay .. "s\n\n⌨️ Bấm phím: C, X, Z, V, F"
        startAutoLoop()
    end
    if _G.SailoPeace_LockPosition and _G.SailoPeace_SavedCFrame then
        startLockPosition()
    end
end)

-- ============ ĐỒNG BỘ TRẠNG THÁI ============
if _G.SailoPeace_IsAutoEnabled and _G.SailoPeace_SavedCFrame then
    toggleBtn.Text = "🟢 ĐANG AUTO BAY VỀ"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
    status.Text = "✈️ Auto bay về chạy\n⏱️ Delay: " .. currentDelay .. "s\n\n⌨️ Bấm phím: C, X, Z, V, F"
    startAutoLoop()
elseif _G.SailoPeace_SavedCFrame then
    status.Text = "Trạng thái: Sẵn sàng Auto\n\n⌨️ Bấm phím: C, X, Z, V, F"
end

if _G.SailoPeace_LockPosition and _G.SailoPeace_SavedCFrame then
    lockBtn.Text = "🟣 ĐANG LOCK VỊ TRÍ"
    lockBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
    status.Text = "🔒 Lock vị trí chạy\n(Chống game teleport)\n\n⌨️ Bấm phím: C, X, Z, V, F"
    startLockPosition()
end

print("✅ Sailo Peace v4 - Simplified!")
print("🎮 Auto Bay Về: Click nút xanh (tween 300 studs/s)")
print("🔒 Lock Vị Trí: Click nút tím (chống game teleport)")
print("⌨️ Bấm phím: C, X, Z, V, F trên bàn phím để dùng skill")
