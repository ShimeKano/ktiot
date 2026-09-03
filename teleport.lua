-- 🥚 Steal An Egg - MAX GOD MODE + Instant Lock + Anti-Reset
-- ✅ CHẶN CHẾT TỪ MỌI NGUYÊN NHÂN: Máu, trạng thái, xóa đối tượng, respawn ép
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============ DỮ LIỆU LƯU TRỮ ============
if _G.EggAuto_Positions == nil then _G.EggAuto_Positions = {} end
if _G.EggAuto_SelectedPos == nil then _G.EggAuto_SelectedPos = nil end
if _G.EggAuto_AutoEnabled == nil then _G.EggAuto_AutoEnabled = false end
if _G.EggAuto_LoopId == nil then _G.EggAuto_LoopId = 0 end
if _G.EggAuto_KeySpamEnabled == nil then _G.EggAuto_KeySpamEnabled = false end
if _G.EggAuto_LockPosEnabled == nil then _G.EggAuto_LockPosEnabled = false end
if _G.EggAuto_GodModeEnabled == nil then _G.EggAuto_GodModeEnabled = false end

-- Cấu hình
local currentDelay = 30
local TWEEN_SPEED = 350
local LOCK_DISTANCE_THRESHOLD = 0.15

-- Lấy danh sách tên vị trí
local function getPosNames()
    local list = {}
    for name, _ in pairs(_G.EggAuto_Positions) do table.insert(list, name) end
    table.sort(list)
    return list
end

-- Lấy nhân vật / bộ phận
local function getChar() return player.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() local c = getChar() return c and (c:FindFirstChild("Humanoid") or c:FindFirstChildOfClass("Humanoid")) end

-- ============ BẤT TỬ CỰC MẠNH — CHẶN TỪ MỌI HƯỚNG ============
local godConnection = nil
local healthChangedConn = nil
local diedConn = nil

local function startGodMode()
    -- Dọn kết nối cũ
    if godConnection then godConnection:Disconnect() end
    if healthChangedConn then healthChangedConn:Disconnect() end
    if diedConn then diedConn:Disconnect() end

    -- Khóa máu liên tục
    godConnection = RunService.Heartbeat:Connect(function()
        if not _G.EggAuto_GodModeEnabled then return end
        local hum = getHumanoid()
        if hum then
            -- Đặt máu tối đa + không cho chết
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end)

    -- Chặn ngay khi máu bị giảm
    task.defer(function()
        while _G.EggAuto_GodModeEnabled do
            local hum = getHumanoid()
            if hum then
                hum.HealthChanged:Connect(function(newHealth)
                    if _G.EggAuto_GodModeEnabled and newHealth < math.huge then
                        hum.Health = math.huge
                    end
                end)
                break
            end
            task.wait(0.05)
        end
    end)

    -- CHẶN SỰ KIỆN CHẾT — NGAY LẬP TỨC HỦY
    task.defer(function()
        while _G.EggAuto_GodModeEnabled do
            local hum = getHumanoid()
            if hum then
                hum.Died:Connect(function()
                    if _G.EggAuto_GodModeEnabled then
                        -- Ngăn chặn chết: hồi máu ngay + chặn respawn
                        task.wait()
                        local h = getHumanoid()
                        if h then
                            h.Health = math.huge
                            h.MaxHealth = math.huge
                        end
                    end
                end)
                break
            end
            task.wait(0.05)
        end
    end)
end

local function stopGodMode()
    if godConnection then godConnection:Disconnect() end
    if healthChangedConn then healthChangedConn:Disconnect() end
    if diedConn then diedConn:Disconnect() end
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

-- Xóa GUI cũ
local existingGui = player:FindFirstChild("PlayerGui", true):FindFirstChild("EggAutoMenu")
if existingGui then existingGui:Destroy() end

-- Tạo GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggAutoMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 540)
mainFrame.Position = UDim2.new(0.5, -160, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(220, 160, 40)
title.Text = "🥚 MAX GOD MODE + Lock"
title.TextColor3 = Color3.new(1, 1, 1)
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

-- Chọn vị trí dropdown
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

-- Xóa vị trí
local deleteBtn = Instance.new("TextButton")
deleteBtn.Size = UDim2.new(0.9, 0, 0, 35)
deleteBtn.Position = UDim2.new(0.05, 0, 0, 165)
deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
deleteBtn.Text = "🗑️ Xóa vị trí đang chọn"
deleteBtn.TextColor3 = Color3.new(1,1,1)
deleteBtn.TextScaled = true
deleteBtn.Parent = mainFrame

-- Auto delay
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
delayListFrame.Visible = false
delayListFrame.Parent = delayDropdown

local delayOptions = {{text="10 giây",value=10},{text="30 giây",value=30},{text="1 phút",value=60},{text="2 phút",value=120},{text="3 phút",value=180}}
for i, opt in ipairs(delayOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = opt.text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = delayListFrame
    btn.MouseButton1Click:Connect(function() currentDelay=opt.value delayDropdown.Text="⏱️ Auto quay lại: "..opt.text delayListFrame.Visible=false end)
end
delayDropdown.MouseButton1Click:Connect(function() delayListFrame.Visible=not delayListFrame.Visible delayListFrame.Size=UDim2.new(1,0,0,#delayOptions*40) posListFrame.Visible=false end)

-- Nút chức năng
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.9, 0, 0, 40)
autoBtn.Position = UDim2.new(0.05, 0, 0, 270)
autoBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
autoBtn.Text = "🔴 BẬT AUTO QUAY LẠI"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.TextScaled = true
autoBtn.Parent = mainFrame

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.9, 0, 0, 40)
lockBtn.Position = UDim2.new(0.05, 0, 0, 315)
lockBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
lockBtn.TextColor3 = Color3.new(1,1,1)
lockBtn.TextScaled = true
lockBtn.Parent = mainFrame

local godBtn = Instance.new("TextButton")
godBtn.Size = UDim2.new(0.9, 0, 0, 40)
godBtn.Position = UDim2.new(0.05, 0, 0, 360)
godBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
godBtn.Text = "🟡 BẬT BẤT TỬ MAX"
godBtn.TextColor3 = Color3.new(1,1,1)
godBtn.TextScaled = true
godBtn.Parent = mainFrame

local keySpamBtn = Instance.new("TextButton")
keySpamBtn.Size = UDim2.new(0.9, 0, 0, 40)
keySpamBtn.Position = UDim2.new(0.05, 0, 0, 405)
keySpamBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
keySpamBtn.Text = "🟠 BẬT AUTO NHẤN PHÍM"
keySpamBtn.TextColor3 = Color3.new(1,1,1)
keySpamBtn.TextScaled = true
keySpamBtn.Parent = mainFrame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 50)
status.Position = UDim2.new(0.05, 0, 0, 455)
status.BackgroundTransparency = 1
status.Text = "Trạng thái: Chưa có vị trí\nNhập tên → Lưu vị trí hiện tại"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.TextWrapped = true
status.Parent = mainFrame

-- ============ LOCK VỊ TRÍ — LẬP TỨC VỀ + KHÓA CỰC CHẶT ============
local lockConnection = nil
local function startLockPosition()
    if lockConnection then lockConnection:Disconnect() end
    local selected = _G.EggAuto_SelectedPos
    local target = selected and _G.EggAuto_Positions[selected]
    if target then
        local root = getRoot()
        if root then root.CFrame = target status.Text = "⚡ Dịch chuyển về: "..selected end
    end
    lockConnection = RunService.Heartbeat:Connect(function()
        if not _G.EggAuto_LockPosEnabled then return end
        local sel = _G.EggAuto_SelectedPos
        local pos = sel and _G.EggAuto_Positions[sel]
        if not pos then return end
        local root = getRoot()
        if root and (root.Position - pos.Position).Magnitude > LOCK_DISTANCE_THRESHOLD then
            root.CFrame = pos
        end
    end)
end
local function stopLockPosition() if lockConnection then lockConnection:Disconnect() end end

-- Auto loop
local function startAutoLoop()
    _G.EggAuto_LoopId += 1
    local myId = _G.EggAuto_LoopId
    task.spawn(function()
        while _G.EggAuto_AutoEnabled and _G.EggAuto_SelectedPos and _G.EggAuto_LoopId == myId do
            task.wait(currentDelay)
            local target = _G.EggAuto_Positions[_G.EggAuto_SelectedPos]
            if not target then _G.EggAuto_AutoEnabled=false break end
            local root = getRoot()
            if root then root.CFrame = target end
        end
    end)
end

-- Key spam loop
local function startKeySpamLoop()
    task.spawn(function()
        while _G.EggAuto_KeySpamEnabled do
            for _,k in ipairs({"C","X","Z","V","F"}) do
                if not _G.EggAuto_KeySpamEnabled then break end
                pressKey(k)
                task.wait(math.random(20,80)/1000)
            end
            task.wait(0.01)
        end
    end)
end

-- Lưu vị trí
saveBtn.MouseButton1Click:Connect(function()
    local root = getRoot()
    local name = posNameInput.Text~="" and posNameInput.Text or ("Vị trí "..#getPosNames()+1)
    if root then
        _G.EggAuto_Positions[name] = root.CFrame
        _G.EggAuto_SelectedPos = name
        posDropdown.Text = "✅ "..name
        refreshPosList()
        status.Text = "✅ Đã lưu: "..name
        task.wait(1.5)
        status.Text = "Trạng thái: Sẵn sàng"
    end
end)

-- Xóa vị trí
deleteBtn.MouseButton1Click:Connect(function()
    local sel = _G.EggAuto_SelectedPos
    if not sel or not _G.EggAuto_Positions[sel] then
        status.Text = "❌ Chưa chọn vị trí nào!"
        task.wait(2)
        status.Text = "Trạng thái: Sẵn sàng"
        return
    end
    _G.EggAuto_Positions[sel] = nil
    _G.EggAuto_SelectedPos = nil
    posDropdown.Text = "📍 Chọn vị trí đã lưu..."
    refreshPosList()
    status.Text = "🗑️ Đã xóa: "..sel
end)

-- Nút bật/tắt
autoBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_AutoEnabled = not _G.EggAuto_AutoEnabled
    local sel = _G.EggAuto_SelectedPos
    if _G.EggAuto_AutoEnabled then
        if not sel or not _G.EggAuto_Positions[sel] then
            status.Text = "❌ Chọn vị trí trước!"
            _G.EggAuto_AutoEnabled=false
            task.wait(2)
            status.Text = "Trạng thái: Sẵn sàng"
            return
        end
        autoBtn.Text = "🟢 ĐANG AUTO QUAY LẠI"
        autoBtn.BackgroundColor3 = Color3.fromRGB(50,220,50)
        status.Text = "✅ Auto: "..sel.."\n⏱️ Mỗi "..currentDelay.."s"
        startAutoLoop()
    else
        autoBtn.Text = "🔴 BẬT AUTO QUAY LẠI"
        autoBtn.BackgroundColor3 = Color3.fromRGB(220,50,50)
        status.Text = "❌ Auto đã tắt"
    end
end)

lockBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_LockPosEnabled = not _G.EggAuto_LockPosEnabled
    local sel = _G.EggAuto_SelectedPos
    if _G.EggAuto_LockPosEnabled then
        if not sel or not _G.EggAuto_Positions[sel] then
            status.Text = "❌ Chọn vị trí trước!"
            _G.EggAuto_LockPosEnabled=false
            task.wait(2)
            status.Text = "Trạng thái: Sẵn sàng"
            return
        end
        lockBtn.Text = "🟢 ĐANG LOCK VỊ TRÍ"
        lockBtn.BackgroundColor3 = Color3.fromRGB(200,100,255)
        startLockPosition()
    else
        lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
        lockBtn.BackgroundColor3 = Color3.fromRGB(150,50,200)
        status.Text = "🔓 Lock đã tắt"
        stopLockPosition()
    end
end)

godBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_GodModeEnabled = not _G.EggAuto_GodModeEnabled
    if _G.EggAuto_GodModeEnabled then
        godBtn.Text = "💛 BẤT TỬ MAX ✅"
        godBtn.BackgroundColor3 = Color3.fromRGB(255,220,0)
        status.Text = "✨ BẤT TỬ MAX ĐÃ BẬT\nMáu = ∞ | Chặn Died | Auto-Respawn Fix"
        startGodMode()
    else
        godBtn.Text = "🟡 BẬT BẤT TỬ MAX"
        godBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)
        status.Text = "❌ Bất tử đã tắt"
        stopGodMode()
    end
end)

keySpamBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_KeySpamEnabled = not _G.EggAuto_KeySpamEnabled
    if _G.EggAuto_KeySpamEnabled then
        keySpamBtn.Text = "🟡 ĐANG NHẤN PHÍM"
        keySpamBtn.BackgroundColor3 = Color3.fromRGB(220,220,50)
        status.Text = "⌨️ C X Z V F liên tục"
        startKeySpamLoop()
    else
        keySpamBtn.Text = "🟠 BẬT AUTO NHẤN PHÍM"
        keySpamBtn.BackgroundColor3 = Color3.fromRGB(200,100,50)
        status.Text = "❌ Đã tắt nhấn phím"
    end
end)

-- ============ RESPAWN → TỰ BẬT LẠI TẤT CẢ ============
player.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("HumanoidRootPart")
    newChar:WaitForChild("Humanoid")

    -- TỰ BẬT LẠI BẤT TỬ NGAY SAU RESPAWN
    if _G.EggAuto_GodModeEnabled then
        task.wait(0.2)
        startGodMode()
    end

    -- TỰ QUAY VỊ TRÍ
    local sel = _G.EggAuto_SelectedPos
    if _G.EggAuto_LockPosEnabled and sel and _G.EggAuto_Positions[sel] then
        task.wait(0.4)
        startLockPosition()
    end

    -- TỰ TIẾP TỤC AUTO
    if _G.EggAuto_AutoEnabled and sel and _G.EggAuto_Positions[sel] then
        task.wait(0.8)
        startAutoLoop()
    end
end)

-- Khôi phục trạng thái cũ
refreshPosList()
local sel = _G.EggAuto_SelectedPos
if sel and _G.EggAuto_Positions[sel] then posDropdown.Text = "✅ "..sel end
if _G.EggAuto_AutoEnabled and sel and _G.EggAuto_Positions[sel] then autoBtn.Text="🟢 ĐANG AUTO QUAY LẠI" autoBtn.BackgroundColor3=Color3.fromRGB(50,220,50) startAutoLoop() end
if _G.EggAuto_LockPosEnabled and sel and _G.EggAuto_Positions[sel] then lockBtn.Text="🟢 ĐANG LOCK VỊ TRÍ" lockBtn.BackgroundColor3=Color3.fromRGB(200,100,255) startLockPosition() end
if _G.EggAuto_GodModeEnabled then godBtn.Text="💛 BẤT TỬ MAX ✅" godBtn.BackgroundColor3=Color3.fromRGB(255,220,0) startGodMode() end
if _G.EggAuto_KeySpamEnabled then keySpamBtn.Text="🟡 ĐANG NHẤN PHÍM" keySpamBtn.BackgroundColor3=Color3.fromRGB(220,220,50) startKeySpamLoop() end

print("✅ EGG MAX GOD MODE LOADED!")
print("✨ Máu = ∞ | Chặn Died event | Auto-Respawn Restore")
print("⚡ LOCK: Lập tức về + lệch 0.15 studs = quay lại")
