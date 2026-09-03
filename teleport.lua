-- 🥚 Steal An Egg - Auto Return + Instant Teleport On Lock + Multi Positions
-- ✅ BẬT LOCK = LẬP TỨC VỀ VỊ TRÍ + KHÓA LIÊN TỤC
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============ DỮ LIỆU LƯU TRỮ ============
if _G.EggAuto_Positions == nil then
    _G.EggAuto_Positions = {}
end
if _G.EggAuto_SelectedPos == nil then
    _G.EggAuto_SelectedPos = nil
end
if _G.EggAuto_AutoEnabled == nil then
    _G.EggAuto_AutoEnabled = false
end
if _G.EggAuto_LoopId == nil then
    _G.EggAuto_LoopId = 0
end
if _G.EggAuto_KeySpamEnabled == nil then
    _G.EggAuto_KeySpamEnabled = false
end
if _G.EggAuto_LockPosEnabled == nil then
    _G.EggAuto_LockPosEnabled = false
end

-- Cấu hình
local currentDelay = 30
local TWEEN_SPEED = 350
local minRandomDelay = 0.02
local maxRandomDelay = 0.08

-- Lấy danh sách tên vị trí
local function getPosNames()
    local list = {}
    for name, _ in pairs(_G.EggAuto_Positions) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

-- Lấy HumanoidRootPart
local function getRoot()
    local char = player.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Tính thời gian tween
local function calculateTweenTime(fromCFrame, toCFrame)
    local distance = (fromCFrame.Position - toCFrame.Position).Magnitude
    return math.max(distance / TWEEN_SPEED, 0.1)
end

-- Nhấn phím
local function pressKey(key)
    local keyCode = Enum.KeyCode[key]
    if keyCode then
        UserInputService:SendKeyEvent(true, keyCode, false)
        task.wait(0.01)
        UserInputService:SendKeyEvent(false, keyCode, false)
    end
end

-- Xóa GUI cũ nếu có
local existingGui = player:WaitForChild("PlayerGui"):FindFirstChild("EggAutoMenu")
if existingGui then existingGui:Destroy() end

-- Tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggAutoMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 480)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(220, 160, 40)
title.Text = "🥚 Steal An Egg - Instant Lock"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- ============ LƯU VỊ TRÍ MỚI ============
local saveFrame = Instance.new("Frame")
saveFrame.Size = UDim2.new(0.9, 0, 0, 45)
saveFrame.Position = UDim2.new(0.05, 0, 0, 55)
saveFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
saveFrame.Parent = mainFrame

local posNameInput = Instance.new("TextBox")
posNameInput.Size = UDim2.new(0.65, -5, 1, 0)
posNameInput.Position = UDim2.new(0, 5, 0, 0)
posNameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
posNameInput.Text = "Vị trí 1"
posNameInput.PlaceholderText = "Tên vị trí..."
posNameInput.TextColor3 = Color3.new(1,1,1)
posNameInput.TextScaled = true
posNameInput.Font = Enum.Font.Gotham
posNameInput.Parent = saveFrame

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.35, -5, 1, 0)
saveBtn.Position = UDim2.new(0.65, 5, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
saveBtn.Text = "💾 Lưu"
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.TextScaled = true
saveBtn.Parent = saveFrame

-- ============ DROPDOWN CHỌN VỊ TRÍ ============
local posDropdown = Instance.new("TextButton")
posDropdown.Size = UDim2.new(0.9, 0, 0, 45)
posDropdown.Position = UDim2.new(0.05, 0, 0, 110)
posDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
posDropdown.Text = "📍 Chọn vị trí đã lưu..."
posDropdown.TextColor3 = Color3.new(1,1,1)
posDropdown.TextScaled = true
posDropdown.Parent = mainFrame

local posListFrame = Instance.new("Frame")
posListFrame.Size = UDim2.new(1, 0, 0, 0)
posListFrame.Position = UDim2.new(0, 0, 1, 5)
posListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
posListFrame.BorderSizePixel = 0
posListFrame.Visible = false
posListFrame.ClipsDescendants = true
posListFrame.ZIndex = 10
posListFrame.Parent = posDropdown

-- Cập nhật danh sách vị trí
local function refreshPosList()
    for _, child in ipairs(posListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local posNames = getPosNames()
    if #posNames == 0 then
        posDropdown.Text = "📍 Chọn vị trí đã lưu..."
        return
    end

    for i, name in ipairs(posNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = "📍 " .. name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.ZIndex = 11
        btn.Parent = posListFrame

        btn.MouseButton1Click:Connect(function()
            _G.EggAuto_SelectedPos = name
            posDropdown.Text = "✅ " .. name
            posListFrame.Visible = false
            status.Text = "✅ Đã chọn: " .. name
            task.wait(1.5)
            status.Text = "Trạng thái: Sẵn sàng"
        end)
    end

    if _G.EggAuto_SelectedPos then
        posDropdown.Text = "✅ " .. _G.EggAuto_SelectedPos
    end
end

-- Nút xóa vị trí
local deleteBtn = Instance.new("TextButton")
deleteBtn.Size = UDim2.new(0.9, 0, 0, 35)
deleteBtn.Position = UDim2.new(0.05, 0, 0, 165)
deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
deleteBtn.Text = "🗑️ Xóa vị trí đang chọn"
deleteBtn.TextColor3 = Color3.new(1,1,1)
deleteBtn.TextScaled = true
deleteBtn.Parent = mainFrame

-- Dropdown chọn thời gian Auto
local delayDropdown = Instance.new("TextButton")
delayDropdown.Size = UDim2.new(0.9, 0, 0, 45)
delayDropdown.Position = UDim2.new(0.05, 0, 0, 210)
delayDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
delayDropdown.Text = "⏱️ Auto quay lại: 30s"
delayDropdown.TextColor3 = Color3.new(1,1,1)
delayDropdown.TextScaled = true
delayDropdown.Parent = mainFrame

local delayListFrame = Instance.new("Frame")
delayListFrame.Size = UDim2.new(1, 0, 0, 0)
delayListFrame.Position = UDim2.new(0, 0, 1, 5)
delayListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
delayListFrame.BorderSizePixel = 0
delayListFrame.Visible = false
delayListFrame.ZIndex = 10
delayListFrame.Parent = delayDropdown

local delayOptions = {
    {text = "10 giây", value = 10},
    {text = "30 giây", value = 30},
    {text = "1 phút", value = 60},
    {text = "2 phút", value = 120},
    {text = "3 phút", value = 180},
}
for i, item in ipairs(delayOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = item.text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.ZIndex = 11
    btn.Parent = delayListFrame

    btn.MouseButton1Click:Connect(function()
        currentDelay = item.value
        delayDropdown.Text = "⏱️ Auto quay lại: " .. item.text
        delayListFrame.Visible = false
    end)
end

delayDropdown.MouseButton1Click:Connect(function()
    delayListFrame.Visible = not delayListFrame.Visible
    delayListFrame.Size = UDim2.new(1, 0, 0, #delayOptions * 40)
    posListFrame.Visible = false
end)

posDropdown.MouseButton1Click:Connect(function()
    refreshPosList()
    posListFrame.Visible = not posListFrame.Visible
    posListFrame.Size = UDim2.new(1, 0, 0, #getPosNames() * 40)
    delayListFrame.Visible = false
end)

-- Nút Auto Quay Lại Vị Trí
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.9, 0, 0, 45)
autoBtn.Position = UDim2.new(0.05, 0, 0, 270)
autoBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
autoBtn.Text = "🔴 BẬT AUTO QUAY LẠI"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.TextScaled = true
autoBtn.Parent = mainFrame

-- Nút Lock Vị Trí
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.9, 0, 0, 45)
lockBtn.Position = UDim2.new(0.05, 0, 0, 325)
lockBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
lockBtn.TextColor3 = Color3.new(1,1,1)
lockBtn.TextScaled = true
lockBtn.Parent = mainFrame

-- Nút Key Spam
local keySpamBtn = Instance.new("TextButton")
keySpamBtn.Size = UDim2.new(0.9, 0, 0, 45)
keySpamBtn.Position = UDim2.new(0.05, 0, 0, 380)
keySpamBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
keySpamBtn.Text = "🟠 BẬT AUTO NHẤN PHÍM"
keySpamBtn.TextColor3 = Color3.new(1,1,1)
keySpamBtn.TextScaled = true
keySpamBtn.Parent = mainFrame

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 45)
status.Position = UDim2.new(0.05, 0, 0, 435)
status.BackgroundTransparency = 1
status.Text = "Trạng thái: Chưa có vị trí\nNhập tên → Lưu vị trí hiện tại"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.TextWrapped = true
status.Parent = mainFrame

-- ============ LOCK VỊ TRÍ + LẬP TỨC VỀ ============
local lockConnection = nil
local function startLockPosition()
    if lockConnection then lockConnection:Disconnect() end

    -- ✅ LẬP TỨC DỊCH CHUYỂN NGAY VỀ VỊ TRÍ ĐÃ CHỌN
    local selected = _G.EggAuto_SelectedPos
    local target = selected and _G.EggAuto_Positions[selected]
    if target then
        local root = getRoot()
        if root then
            root.CFrame = target  -- Teleport ngay lập tức
            status.Text = "⚡ Đã dịch chuyển về: " .. selected
        end
    end

    -- Sau đó liên tục khóa vị trí
    lockConnection = RunService.Heartbeat:Connect(function()
        local selectedName = _G.EggAuto_SelectedPos
        if not _G.EggAuto_LockPosEnabled or not selectedName then return end
        local targetPos = _G.EggAuto_Positions[selectedName]
        if not targetPos then return end

        local root = getRoot()
        if root then
            -- Chỉ cần lệch chút là quay lại ngay
            local distance = (root.Position - targetPos.Position).Magnitude
            if distance > 0.5 then  -- Giảm ngưỡng = khóa chặt hơn
                root.CFrame = targetPos
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

-- ============ AUTO QUAY LẠI VỊ TRÍ ============
local function startAutoLoop()
    _G.EggAuto_LoopId = _G.EggAuto_LoopId + 1
    local myId = _G.EggAuto_LoopId
    spawn(function()
        while _G.EggAuto_AutoEnabled and _G.EggAuto_SelectedPos and _G.EggAuto_LoopId == myId do
            task.wait(currentDelay)
            if not _G.EggAuto_AutoEnabled or not _G.EggAuto_SelectedPos or _G.EggAuto_LoopId ~= myId then break end

            local target = _G.EggAuto_Positions[_G.EggAuto_SelectedPos]
            if not target then
                status.Text = "❌ Vị trí không tồn tại!"
                _G.EggAuto_AutoEnabled = false
                break
            end

            local root = getRoot()
            if root then
                local tweenTime = calculateTweenTime(root.CFrame, target)
                local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                local goal = {CFrame = target}
                local tween = TweenService:Create(root, tweenInfo, goal)
                tween:Play()
                tween.Completed:Wait()
                if _G.EggAuto_AutoEnabled then
                    root.CFrame = target
                end
            end
        end
    end)
end

-- ============ AUTO NHẤN PHÍM ============
local function startKeySpamLoop()
    spawn(function()
        while _G.EggAuto_KeySpamEnabled do
            local keys = {"C", "X", "Z", "V", "F"}
            for _, key in ipairs(keys) do
                if not _G.EggAuto_KeySpamEnabled then break end
                pressKey(key)
                local randomDelay = math.random(math.floor(minRandomDelay * 1000), math.floor(maxRandomDelay * 1000)) / 1000
                task.wait(randomDelay)
            end
            task.wait(0.01)
        end
    end)
end

-- ============ LƯU VỊ TRÍ ============
saveBtn.MouseButton1Click:Connect(function()
    local root = getRoot()
    local name = posNameInput.Text or ("Vị trí " .. os.time())
    if name == "" then name = "Vị trí " .. #getPosNames() + 1 end

    if root then
        _G.EggAuto_Positions[name] = root.CFrame
        _G.EggAuto_SelectedPos = name
        status.Text = "✅ Đã lưu: " .. name
        posDropdown.Text = "✅ " .. name
        refreshPosList()
        task.wait(1.5)
        status.Text = "Trạng thái: Sẵn sàng"
    end
end)

-- ============ XÓA VỊ TRÍ ============
deleteBtn.MouseButton1Click:Connect(function()
    local selected = _G.EggAuto_SelectedPos
    if not selected or not _G.EggAuto_Positions[selected] then
        status.Text = "❌ Chưa chọn vị trí nào!"
        task.wait(2)
        status.Text = "Trạng thái: Sẵn sàng"
        return
    end

    _G.EggAuto_Positions[selected] = nil
    _G.EggAuto_SelectedPos = nil
    posDropdown.Text = "📍 Chọn vị trí đã lưu..."
    refreshPosList()
    status.Text = "🗑️ Đã xóa: " .. selected
    task.wait(1.5)
    status.Text = next(_G.EggAuto_Positions) and "Trạng thái: Sẵn sàng" or "Trạng thái: Chưa có vị trí"
end)

-- ============ BẬT/TẮT AUTO QUAY LẠI ============
autoBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_AutoEnabled = not _G.EggAuto_AutoEnabled
    local selected = _G.EggAuto_SelectedPos
    if _G.EggAuto_AutoEnabled then
        if not selected or not _G.EggAuto_Positions[selected] then
            status.Text = "❌ Chọn vị trí trước khi bật!"
            _G.EggAuto_AutoEnabled = false
            task.wait(2)
            status.Text = "Trạng thái: Sẵn sàng"
            return
        end
        autoBtn.Text = "🟢 ĐANG AUTO QUAY LẠI"
        autoBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        status.Text = "✅ Auto: " .. selected .. "\n⏱️ Mỗi " .. currentDelay .. "s quay lại"
        startAutoLoop()
    else
        autoBtn.Text = "🔴 BẬT AUTO QUAY LẠI"
        autoBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        status.Text = "❌ Auto đã tắt"
    end
end)

-- ============ BẬT/TẮT LOCK VỊ TRÍ ============
lockBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_LockPosEnabled = not _G.EggAuto_LockPosEnabled
    local selected = _G.EggAuto_SelectedPos
    if _G.EggAuto_LockPosEnabled then
        if not selected or not _G.EggAuto_Positions[selected] then
            status.Text = "❌ Chọn vị trí trước khi bật Lock!"
            _G.EggAuto_LockPosEnabled = false
            task.wait(2)
            status.Text = "Trạng thái: Sẵn sàng"
            return
        end
        lockBtn.Text = "🟢 ĐANG LOCK VỊ TRÍ"
        lockBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
        -- startLockPosition() sẽ tự động dịch chuyển ngay về vị trí
        startLockPosition()
    else
        lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
        lockBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
        status.Text = "🔓 Lock đã tắt"
        stopLockPosition()
    end
end)

-- ============ BẬT/TẮT AUTO NHẤN PHÍM ============
keySpamBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_KeySpamEnabled = not _G.EggAuto_KeySpamEnabled
    if _G.EggAuto_KeySpamEnabled then
        keySpamBtn.Text = "🟡 ĐANG NHẤN PHÍM"
        keySpamBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 50)
        status.Text = "⌨️ Nhấn: C X Z V F liên tục"
        startKeySpamLoop()
    else
        keySpamBtn.Text = "🟠 BẬT AUTO NHẤN PHÍM"
        keySpamBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        status.Text = "❌ Đã tắt nhấn phím"
    end
end)

-- ============ KHI RESPAWN ============
player.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("HumanoidRootPart")
    local selected = _G.EggAuto_SelectedPos
    if _G.EggAuto_AutoEnabled and selected and _G.EggAuto_Positions[selected] then
        status.Text = "♻️ Đang tiếp tục..."
        task.wait(1)
        status.Text = "✅ Auto: " .. selected .. "\n⏱️ Mỗi " .. currentDelay .. "s quay lại"
        startAutoLoop()
    end
    -- Khi respawn + Lock đang bật → tự động dịch chuyển ngay về vị trí
    if _G.EggAuto_LockPosEnabled and selected and _G.EggAuto_Positions[selected] then
        task.wait(0.5)
        startLockPosition()
    end
end)

-- ============ KHÔI PHỤC TRẠNG THÁI SAU RE-EXECUTE ============
refreshPosList()
local selected = _G.EggAuto_SelectedPos
if selected and _G.EggAuto_Positions[selected] then
    posDropdown.Text = "✅ " .. selected
    status.Text = "Trạng thái: Sẵn sàng"
elseif next(_G.EggAuto_Positions) then
    status.Text = "Trạng thái: Chọn vị trí từ danh sách"
end

if _G.EggAuto_AutoEnabled and selected and _G.EggAuto_Positions[selected] then
    autoBtn.Text = "🟢 ĐANG AUTO QUAY LẠI"
    autoBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
    status.Text = "✅ Auto: " .. selected .. "\n⏱️ Mỗi " .. currentDelay .. "s quay lại"
    startAutoLoop()
end
if _G.EggAuto_LockPosEnabled and selected and _G.EggAuto_Positions[selected] then
    lockBtn.Text = "🟢 ĐANG LOCK VỊ TRÍ"
    lockBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
    startLockPosition()
end
if _G.EggAuto_KeySpamEnabled then
    keySpamBtn.Text = "🟡 ĐANG NHẤN PHÍM"
    keySpamBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 50)
    startKeySpamLoop()
end

print("✅ EggAuto Menu đã load!")
print("⚡ BẬT LOCK = LẬP TỨC VỀ VỊ TRÍ + KHÓA LIÊN TỤC")
