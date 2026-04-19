-- Sailo Peace - Auto Teleport to Saved Position with Tween + Auto Key Spam
-- Fix: Bay về vị trí rồi giữ nguyên (không reset)

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Dùng _G để savedCFrame và trạng thái auto tồn tại qua các lần respawn / re-execute
if _G.SailoPeace_IsAutoEnabled == nil then
    _G.SailoPeace_IsAutoEnabled = false
end
if _G.SailoPeace_LoopId == nil then
    _G.SailoPeace_LoopId = 0
end
if _G.SailoPeace_KeySpamEnabled == nil then
    _G.SailoPeace_KeySpamEnabled = false
end

local currentDelay = 30  -- mặc định 30 giây
local TWEEN_SPEED = 300  -- studs per second
local keySpamDelay = 0.05  -- delay giữa các lần ấn phím
local minRandomDelay = 0.02  -- min random delay
local maxRandomDelay = 0.08  -- max random delay

-- Lấy HumanoidRootPart của nhân vật hiện tại (luôn cập nhật)
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

-- Hàm ấn phím (tương tự KeyPress)
local function pressKey(key)
    local keyCode = Enum.KeyCode[key]
    if keyCode then
        UserInputService:SendKeyEvent(true, keyCode, false)
        task.wait(0.01)
        UserInputService:SendKeyEvent(false, keyCode, false)
    end
end

-- Tạo GUI (chỉ tạo một lần; tái sử dụng nếu đã có)
local existingGui = player:WaitForChild("PlayerGui"):FindFirstChild("SailoPeaceAuto")
if existingGui then
    existingGui:Destroy()
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SailoPeaceAuto"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 320)  -- Tăng chiều cao
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
title.Text = "🌊 Sailo Peace - Auto Teleport + KeySpam"
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

-- Nút Bật/Tắt Auto Key Spam
local keySpamBtn = Instance.new("TextButton")
keySpamBtn.Size = UDim2.new(0.9, 0, 0, 45)
keySpamBtn.Position = UDim2.new(0.05, 0, 0, 220)
keySpamBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
keySpamBtn.Text = "🟠 BẬT AUTO KEY SPAM"
keySpamBtn.TextColor3 = Color3.new(1,1,1)
keySpamBtn.TextScaled = true
keySpamBtn.Parent = mainFrame

-- Status label
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 40)
status.Position = UDim2.new(0.05, 0, 0, 275)
status.BackgroundTransparency = 1
status.Text = "Trạng thái: Chưa lưu vị trí\n"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.TextWrapped = true
status.Parent = mainFrame

-- Khởi động vòng lặp auto teleport (sử dụng Tween)
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
                
                -- Tạo Tween Info
                local tweenInfo = TweenInfo.new(
                    tweenTime,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.InOut
                )
                
                -- Tạo goal (CFrame property)
                local goal = {CFrame = targetCFrame}
                
                -- Tạo và phát Tween
                local tween = TweenService:Create(root, tweenInfo, goal)
                tween:Play()
                
                -- Đợi tween hoàn thành xong mới tiếp tục vòng lặp
                tween.Completed:Wait()
                
                -- Sau khi bay về, giữ nguyên vị trí (teleport lại một lần nữa để đảm bảo)
                if _G.SailoPeace_IsAutoEnabled then
                    root.CFrame = _G.SailoPeace_SavedCFrame
                end
            end
        end
    end)
end

-- Khởi động vòng lặp auto key spam (CXZVF)
local function startKeySpamLoop()
    spawn(function()
        while _G.SailoPeace_KeySpamEnabled do
            -- Random giữa các phím để tránh phát hiện
            local keys = {"C", "X", "Z", "V", "F"}
            for _, key in ipairs(keys) do
                if not _G.SailoPeace_KeySpamEnabled then break end
                pressKey(key)
                -- Random delay để tránh phát hiện (không spam quá đều)
                local randomDelay = math.random(math.floor(minRandomDelay * 1000), math.floor(maxRandomDelay * 1000)) / 1000
                task.wait(randomDelay)
            end
            -- Chút delay giữa các cycle
            task.wait(0.01)
        end
    end)
end

-- Lưu vị trí
saveBtn.MouseButton1Click:Connect(function()
    local root = getRoot()
    if root then
        _G.SailoPeace_SavedCFrame = root.CFrame
        status.Text = "✅ Đã lưu vị trí!\nSẵn sàng Auto"
        task.wait(1.5)
        status.Text = "Trạng thái: Sẵn sàng Auto"
    end
end)

-- Toggle Auto Teleport
toggleBtn.MouseButton1Click:Connect(function()
    _G.SailoPeace_IsAutoEnabled = not _G.SailoPeace_IsAutoEnabled

    if _G.SailoPeace_IsAutoEnabled then
        if not _G.SailoPeace_SavedCFrame then
            status.Text = "❌ Chưa lưu vị trí!\n"
            _G.SailoPeace_IsAutoEnabled = false
            task.wait(2)
            status.Text = "Trạng thái: Chưa lưu vị trí"
            return
        end
        toggleBtn.Text = "🟢 ĐANG AUTO BAY VỀ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        status.Text = "✈️ Auto bay về chạy\n⏱️ Delay: " .. currentDelay .. "s"
        startAutoLoop()
    else
        toggleBtn.Text = "🔴 BẬT AUTO BAY VỀ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        status.Text = "❌ Auto bay về tắt"
    end
end)

-- Toggle Auto Key Spam
keySpamBtn.MouseButton1Click:Connect(function()
    _G.SailoPeace_KeySpamEnabled = not _G.SailoPeace_KeySpamEnabled

    if _G.SailoPeace_KeySpamEnabled then
        keySpamBtn.Text = "🟡 ĐANG AUTO KEY SPAM"
        keySpamBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 50)
        status.Text = "⌨️ Auto Key Spam chạy\n(CXZVF spam liên tục)"
        startKeySpamLoop()
    else
        keySpamBtn.Text = "🟠 BẬT AUTO KEY SPAM"
        keySpamBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        status.Text = "❌ Auto Key Spam tắt"
    end
end)

-- Khi nhân vật respawn: cập nhật root và tiếp tục auto nếu đang bật
player.CharacterAdded:Connect(function(newCharacter)
    newCharacter:WaitForChild("HumanoidRootPart")
    if _G.SailoPeace_IsAutoEnabled and _G.SailoPeace_SavedCFrame then
        status.Text = "♻️ Respawn - Tiếp tục Auto..."
        task.wait(1)
        status.Text = "✈️ Auto bay về chạy\n⏱️ Delay: " .. currentDelay .. "s"
        startAutoLoop()
    end
end)

-- Đồng bộ trạng thái UI nếu auto đang bật từ lần chạy trước
if _G.SailoPeace_IsAutoEnabled and _G.SailoPeace_SavedCFrame then
    toggleBtn.Text = "🟢 ĐANG AUTO BAY VỀ"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
    status.Text = "✈️ Auto bay về chạy\n⏱️ Delay: " .. currentDelay .. "s"
    startAutoLoop()
elseif _G.SailoPeace_SavedCFrame then
    status.Text = "Trạng thái: Sẵn sàng Auto"
end

if _G.SailoPeace_KeySpamEnabled then
    keySpamBtn.Text = "🟡 ĐANG AUTO KEY SPAM"
    keySpamBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 50)
    status.Text = "⌨️ Auto Key Spam chạy\n(CXZVF spam liên tục)"
    startKeySpamLoop()
end

print("✅ Sailo Peace Auto Teleport + KeySpam đã load!")
print("🎮 Auto Bay Về: Ctrl + Click nút xanh")
print("⌨️ Auto Key Spam (CXZVF): Click nút cam để bật spam tự động")
