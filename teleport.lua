-- 🥚 Steal An Egg — KHÔNG BỊ KẸT + BẤT TỬ + KHÔI PHỤC VỊ TRÍ
-- ✅ Máu không chết + tự quay về + ĐỢI NHÂN VẬT LOAD XONG → KHÔNG BỊ KẸT KHÔNG ĐIỀU KHIỂN
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============ DỮ LIỆU LƯU TRỮ ============
if _G.EggAuto_Positions == nil then _G.EggAuto_Positions = {} end
if _G.EggAuto_SelectedPos == nil then _G.EggAuto_SelectedPos = nil end
if _G.EggAuto_AutoEnabled == nil then _G.EggAuto_AutoEnabled = false end
if _G.EggAuto_LockPosEnabled == nil then _G.EggAuto_LockPosEnabled = false end
if _G.EggAuto_GodModeEnabled == nil then _G.EggAuto_GodModeEnabled = false end

-- Cấu hình
local currentDelay = 30
local LOCK_DISTANCE_THRESHOLD = 0.5  -- Nới nhẹ để không bị giật liên tục
local RESTORE_DELAY = 0.15  -- Đợi server đồng bộ rồi mới dịch chuyển
local MAX_RESTORE_ATTEMPTS = 8  -- Thử lại nhiều lần cho chắc

-- Lấy nhân vật / bộ phận
local function getChar() return player.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() local c = getChar() return c and (c:FindFirstChild("Humanoid") or c:FindFirstChildOfClass("Humanoid")) end

-- Lấy danh sách tên vị trí
local function getPosNames()
    local list = {}
    for name, _ in pairs(_G.EggAuto_Positions) do table.insert(list, name) end
    table.sort(list)
    return list
end

-- ============ BẤT TỬ ============
local godConn = nil
local function startGodMode()
    if godConn then godConn:Disconnect() end
    godConn = RunService.Heartbeat:Connect(function()
        if not _G.EggAuto_GodModeEnabled then return end
        local hum = getHumanoid()
        if hum and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end
local function stopGodMode() if godConn then godConn:Disconnect() end end

-- ============ DỊCH CHUYỂN AN TOÀN — ĐỢI LOAD XONG RỒI MỚI DI CHUYỂN ============
local function safeTeleportTo(targetCFrame)
    task.spawn(function()
        -- Đợi nhân vật sẵn sàng hoàn toàn
        local root = nil
        for attempt = 1, MAX_RESTORE_ATTEMPTS do
            root = getRoot()
            if root then
                -- Dịch chuyển nhiều lần trong vài khung hình để chống server ghi đè
                root.CFrame = targetCFrame
                task.wait(RESTORE_DELAY)
                root.CFrame = targetCFrame
                task.wait(RESTORE_DELAY * 2)
                root.CFrame = targetCFrame
                return true
            end
            task.wait(RESTORE_DELAY * 2)
        end
        return false
    end)
end

-- ============ LOCK VỊ TRÍ — KHÔNG GIẬT, KHÔNG BỊ KẸT ============
local lockConn = nil
local function startLockPosition()
    if lockConn then lockConn:Disconnect() end
    local selected = _G.EggAuto_SelectedPos
    local target = selected and _G.EggAuto_Positions[selected]
    if target then
        safeTeleportTo(target)  -- Dịch chuyển an toàn
    end
    -- Theo dõi và khôi phục từ từ
    lockConn = RunService.Heartbeat:Connect(function()
        if not _G.EggAuto_LockPosEnabled then return end
        local sel = _G.EggAuto_SelectedPos
        local pos = sel and _G.EggAuto_Positions[sel]
        if not pos then return end
        local root = getRoot()
        if root then
            local dist = (root.Position - pos.Position).Magnitude
            if dist > LOCK_DISTANCE_THRESHOLD then
                root.CFrame = pos  -- Khôi phục nhẹ nhàng
            end
        end
    end)
end
local function stopLockPosition() if lockConn then lockConn:Disconnect() end end

-- ============ AUTO QUAY LẠI ============
local function startAutoLoop()
    task.spawn(function()
        while _G.EggAuto_AutoEnabled and _G.EggAuto_SelectedPos do
            task.wait(currentDelay)
            local target = _G.EggAuto_Positions[_G.EggAuto_SelectedPos]
            if target then safeTeleportTo(target) end
        end
    end)
end

-- ============ TẠO GUI ============
local existingGui = player:FindFirstChild("PlayerGui", true):FindFirstChild("EggAutoMenu")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggAutoMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 490)
mainFrame.Position = UDim2.new(0.5, -160, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(220, 160, 40)
title.Text = "🥚 Không Kẹt + Bất Tử + Lock"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Lưu vị trí
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
posNameInput.TextColor3 = Color3.new(1,1,1)
posNameInput.TextScaled = true
posNameInput.Parent = saveFrame

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.35, -5, 1, 0)
saveBtn.Position = UDim2.new(0.65, 5, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
saveBtn.Text = "💾 Lưu"
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.TextScaled = true
saveBtn.Parent = saveFrame

-- Chọn vị trí
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
posListFrame.Visible = false
posListFrame.ClipsDescendants = true
posListFrame.Parent = posDropdown

local function refreshPosList()
    for _, c in ipairs(posListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local names = getPosNames()
    if #names == 0 then posDropdown.Text = "📍 Chọn vị trí đã lưu..." return end
    for i, name in ipairs(names) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = "📍 "..name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Parent = posListFrame
        btn.MouseButton1Click:Connect(function()
            _G.EggAuto_SelectedPos = name
            posDropdown.Text = "✅ "..name
            posListFrame.Visible = false
            status.Text = "✅ Đã chọn: "..name
            task.wait(1.5)
            status.Text = "Trạng thái: Sẵn sàng"
        end)
    end
    posListFrame.Size = UDim2.new(1, 0, 0, #names*40)
    if _G.EggAuto_SelectedPos then posDropdown.Text = "✅ ".._G.EggAuto_SelectedPos end
end
posDropdown.MouseButton1Click:Connect(function() refreshPosList() posListFrame.Visible = not posListFrame.Visible end)

-- Nút chức năng
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.9, 0, 0, 40)
autoBtn.Position = UDim2.new(0.05, 0, 0, 170)
autoBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
autoBtn.Text = "🔴 BẬT AUTO QUAY LẠI"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.TextScaled = true
autoBtn.Parent = mainFrame

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.9, 0, 0, 40)
lockBtn.Position = UDim2.new(0.05, 0, 0, 215)
lockBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
lockBtn.TextColor3 = Color3.new(1,1,1)
lockBtn.TextScaled = true
lockBtn.Parent = mainFrame

local godBtn = Instance.new("TextButton")
godBtn.Size = UDim2.new(0.9, 0, 0, 40)
godBtn.Position = UDim2.new(0.05, 0, 0, 260)
godBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
godBtn.Text = "🟡 BẬT BẤT TỬ"
godBtn.TextColor3 = Color3.new(1,1,1)
godBtn.TextScaled = true
godBtn.Parent = mainFrame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 80)
status.Position = UDim2.new(0.05, 0, 0, 310)
status.BackgroundTransparency = 1
status.Text = "Trạng thái: Chưa có vị trí\n💾 Lưu vị trí an toàn trước"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.TextWrapped = true
status.Parent = mainFrame

-- ============ NÚT NHẤN ============
saveBtn.MouseButton1Click:Connect(function()
    local root = getRoot()
    local name = posNameInput.Text~="" and posNameInput.Text or ("Vị trí "..#getPosNames()+1)
    if root then
        _G.EggAuto_Positions[name] = root.CFrame
        _G.EggAuto_SelectedPos = name
        posDropdown.Text = "✅ "..name
        refreshPosList()
        status.Text = "✅ Đã lưu: "..name.."\nSẵn sàng khóa vị trí"
    end
end)

autoBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_AutoEnabled = not _G.EggAuto_AutoEnabled
    local sel = _G.EggAuto_SelectedPos
    if _G.EggAuto_AutoEnabled then
        if not sel then status.Text="❌ Chọn vị trí trước!" task.wait(2) return end
        autoBtn.Text = "🟢 ĐANG AUTO"
        autoBtn.BackgroundColor3 = Color3.fromRGB(50,220,50)
        startAutoLoop()
    else
        autoBtn.Text = "🔴 BẬT AUTO QUAY LẠI"
        autoBtn.BackgroundColor3 = Color3.fromRGB(220,50,50)
    end
end)

lockBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_LockPosEnabled = not _G.EggAuto_LockPosEnabled
    local sel = _G.EggAuto_SelectedPos
    if _G.EggAuto_LockPosEnabled then
        if not sel then status.Text="❌ Chọn vị trí trước!" task.wait(2) return end
        lockBtn.Text = "🟢 ĐANG LOCK"
        lockBtn.BackgroundColor3 = Color3.fromRGB(200,100,255)
        status.Text = "🔒 Khóa vị trí: "..sel.."\nĐợi server đồng bộ rồi di chuyển"
        startLockPosition()
    else
        lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
        lockBtn.BackgroundColor3 = Color3.fromRGB(150,50,200)
        stopLockPosition()
    end
end)

godBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_GodModeEnabled = not _G.EggAuto_GodModeEnabled
    if _G.EggAuto_GodModeEnabled then
        godBtn.Text = "💛 BẤT TỬ ✅"
        godBtn.BackgroundColor3 = Color3.fromRGB(255,220,0)
        status.Text = "✨ Bất tử đã bật\nMáu luôn đầy"
        startGodMode()
    else
        godBtn.Text = "🟡 BẬT BẤT TỬ"
        godBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)
        stopGodMode()
    end
end)

-- ============ RESPAWN → TỰ BẬT LẠI NHƯNG ĐỢI ĐỦ THỜI GIAN ============
player.CharacterAdded:Connect(function(newChar)
    -- Đợi nhân vật load hoàn toàn + server đồng bộ xong
    newChar:WaitForChild("HumanoidRootPart")
    newChar:WaitForChild("Humanoid")

    -- Tự bật Bất Tử
    if _G.EggAuto_GodModeEnabled then
        task.wait(0.5)  -- Đợi server ổn định
        startGodMode()
    end

    -- Tự quay về vị trí cũ — ĐỢI RỒI MỚI DI CHUYỂN
    local sel = _G.EggAuto_SelectedPos
    local target = sel and _G.EggAuto_Positions[sel]
    if _G.EggAuto_LockPosEnabled and target then
        status.Text = "♻️ Đợi server đồng bộ..."
        task.wait(1.2)  -- ⚠️ ĐỢI KỸ → KHÔNG BỊ KẸT
        safeTeleportTo(target)
        task.wait(0.5)
        startLockPosition()
        status.Text = "✅ Đã khôi phục: "..sel
    end
end)

-- Khôi phục trạng thái
refreshPosList()
local sel = _G.EggAuto_SelectedPos
if sel and _G.EggAuto_Positions[sel] then posDropdown.Text = "✅ "..sel end
if _G.EggAuto_GodModeEnabled then godBtn.Text="💛 BẤT TỬ ✅" godBtn.BackgroundColor3=Color3.fromRGB(255,220,0) startGodMode() end
if _G.EggAuto_LockPosEnabled and sel and _G.EggAuto_Positions[sel] then lockBtn.Text="🟢 ĐANG LOCK" lockBtn.BackgroundColor3=Color3.fromRGB(200,100,255) startLockPosition() end

print("✅ Đã Load — KHÔNG BỊ KẸT + BẤT TỬ + KHÔI PHỤC VỊ TRÍ")
print("💡 Lưu vị trí an toàn → Chọn → Bật Bất Tử → Bật Lock")
print("⏳ Mỗi lần reset → đợi 1-2 giây tự quay về, ĐỪNG nhấn gì trong lúc đó")
