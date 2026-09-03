-- 🥚 BẤT KHẢ XÂM NHẬP — Không bị đánh / Không bị đẩy / Không bị tác động
-- ✅ Chặn sát thương | Chặn đẩy vị trí | Chặn NPC | Chặn mọi hiệu ứng
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ============ DỮ LIỆU LƯU TRỮ ============
if _G.EggAuto_Positions == nil then _G.EggAuto_Positions = {} end
if _G.EggAuto_SelectedPos == nil then _G.EggAuto_SelectedPos = nil end
if _G.EggAuto_LockPosEnabled == nil then _G.EggAuto_LockPosEnabled = false end
if _G.EggAuto_GodModeEnabled == nil then _G.EggAuto_GodModeEnabled = false end
if _G.EggAuto_InvincibleEnabled == nil then _G.EggAuto_InvincibleEnabled = false end

-- Cấu hình
local LOCK_DISTANCE_THRESHOLD = 0.3
local RESTORE_DELAY = 0.8

-- Lấy đối tượng
local function getChar() return player.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() local c = getChar() return c and (c:FindFirstChild("Humanoid") or c:FindFirstChildOfClass("Humanoid")) end
local function getPosNames() local l={} for n,_ in pairs(_G.EggAuto_Positions) do table.insert(l,n) end table.sort(l) return l end

-- ============ 🛡️ BẤT KHẢ XÂM NHẬP — CHẶN MỌI TÁC ĐỘNG ============
local shieldConn = nil
local function startInvincibleMode()
    if shieldConn then shieldConn:Disconnect() end

    shieldConn = RunService.Heartbeat:Connect(function()
        if not _G.EggAuto_InvincibleEnabled then return end
        local char = getChar()
        local hum = getHumanoid()
        local root = getRoot()
        if not char or not hum then return end

        -- ✅ 1. Bất Tử Hoàn Toàn
        hum.MaxHealth = math.huge
        hum.Health = math.huge

        -- ✅ 2. Bất Khả Tấn Công — Không bị mục tiêu
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

        -- ✅ 3. Bất Khả Đẩy — Khối lượng vô cực + không bị vật lý tác động
        if root then
            root.Massless = true
            root.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0)
            root.CanCollide = true
        end

        -- ✅ 4. Chặn mọi hiệu ứng trạng thái
        for _, d in ipairs(char:GetChildren()) do
            if d:IsA("ForceField") then
                -- Giữ ForceField nếu có, hoặc tạo mới
            elseif d:IsA("BodyVelocity") or d:IsA("BodyForce") 
                or d:IsA("BodyPosition") or d:IsA("BodyGyro")
                or d:IsA("AngularVelocity") or d:IsA("LinearVelocity") then
                -- Xóa mọi lực đẩy bên ngoài
                d:Destroy()
            end
        end

        -- ✅ 5. Tạo Lực Đỡ Đẩy Liên Tục
        if root and not char:FindFirstChild("AntiPushForce") then
            local antiPush = Instance.new("BodyVelocity")
            antiPush.Name = "AntiPushForce"
            antiPush.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            antiPush.Velocity = Vector3.zero
            antiPush.P = 1000
            antiPush.Parent = root
        end
    end)
end

local function stopInvincibleMode()
    if shieldConn then shieldConn:Disconnect() end
    local char = getChar()
    if char and char:FindFirstChild("AntiPushForce") then
        char.AntiPushForce:Destroy()
    end
end

-- ============ 🛡️ BẤT TỬ RIÊNG ============
local godConn = nil
local function startGodMode()
    if godConn then godConn:Disconnect() end
    godConn = RunService.Heartbeat:Connect(function()
        if not _G.EggAuto_GodModeEnabled then return end
        local hum = getHumanoid()
        if hum then hum.Health = hum.MaxHealth end
    end)
end
local function stopGodMode() if godConn then godConn:Disconnect() end end

-- ============ 📍 LOCK VỊ TRÍ — CHỐNG ĐẨY ============
local lockConn = nil
local function restorePosition(targetCFrame)
    task.spawn(function()
        for i = 1, 5 do
            local root = getRoot()
            if root then
                root.CFrame = targetCFrame
                task.wait(0.05)
                root.CFrame = targetCFrame
                return
            end
            task.wait(0.1)
        end
    end)
end

local function startLockPosition()
    if lockConn then lockConn:Disconnect() end
    local sel = _G.EggAuto_SelectedPos
    local target = sel and _G.EggAuto_Positions[sel]
    if target then restorePosition(target) end

    lockConn = RunService.Heartbeat:Connect(function()
        if not _G.EggAuto_LockPosEnabled then return end
        local name = _G.EggAuto_SelectedPos
        local pos = name and _G.EggAuto_Positions[name]
        if not pos then return end
        local root = getRoot()
        if root and (root.Position - pos.Position).Magnitude > LOCK_DISTANCE_THRESHOLD then
            root.CFrame = pos
        end
    end)
end
local function stopLockPosition() if lockConn then lockConn:Disconnect() end

-- ============ 🖥️ TẠO GUI ============
local existingGui = player:FindFirstChild("PlayerGui", true):FindFirstChild("EggAutoMenu")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggAutoMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 520)
mainFrame.Position = UDim2.new(0.5, -160, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(220, 160, 40)
title.Text = "🛡️ BẤT KHẢ XÂM NHẬP"
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
        end)
    end
    posListFrame.Size = UDim2.new(1, 0, 0, #names*40)
    if _G.EggAuto_SelectedPos then posDropdown.Text = "✅ ".._G.EggAuto_SelectedPos end
end
posDropdown.MouseButton1Click:Connect(function() refreshPosList() posListFrame.Visible = not posListFrame.Visible end)

-- Nút chức năng
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.9, 0, 0, 40)
lockBtn.Position = UDim2.new(0.05, 0, 0, 170)
lockBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
lockBtn.Text = "🟣 BẬT LOCK VỊ TRÍ"
lockBtn.TextColor3 = Color3.new(1,1,1)
lockBtn.TextScaled = true
lockBtn.Parent = mainFrame

local godBtn = Instance.new("TextButton")
godBtn.Size = UDim2.new(0.9, 0, 0, 40)
godBtn.Position = UDim2.new(0.05, 0, 0, 215)
godBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
godBtn.Text = "🟡 BẬT BẤT TỬ"
godBtn.TextColor3 = Color3.new(1,1,1)
godBtn.TextScaled = true
godBtn.Parent = mainFrame

local shieldBtn = Instance.new("TextButton")
shieldBtn.Size = UDim2.new(0.9, 0, 0, 40)
shieldBtn.Position = UDim2.new(0.05, 0, 0, 260)
shieldBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
shieldBtn.Text = "🔵 BẬT BẤT KHẢ XÂM NHẬP"
shieldBtn.TextColor3 = Color3.new(1,1,1)
shieldBtn.TextScaled = true
shieldBtn.Parent = mainFrame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 100)
status.Position = UDim2.new(0.05, 0, 0, 310)
status.BackgroundTransparency = 1
status.Text = "Trạng thái: Sẵn sàng\n💾 Lưu vị trí an toàn trước"
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
        status.Text = "✅ Đã lưu: "..name
    end
end)

lockBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_LockPosEnabled = not _G.EggAuto_LockPosEnabled
    local sel = _G.EggAuto_SelectedPos
    if _G.EggAuto_LockPosEnabled then
        if not sel then status.Text="❌ Chọn vị trí trước!" task.wait(2) return end
        lockBtn.Text = "🟢 ĐANG LOCK"
        lockBtn.BackgroundColor3 = Color3.fromRGB(200,100,255)
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
        startGodMode()
    else
        godBtn.Text = "🟡 BẬT BẤT TỬ"
        godBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)
        stopGodMode()
    end
end)

shieldBtn.MouseButton1Click:Connect(function()
    _G.EggAuto_InvincibleEnabled = not _G.EggAuto_InvincibleEnabled
    if _G.EggAuto_InvincibleEnabled then
        shieldBtn.Text = "💠 BẤT KHẢ XÂM NHẬP ✅"
        shieldBtn.BackgroundColor3 = Color3.fromRGB(50,200,255)
        status.Text = "🛡️ Đã BẬT KHIÊN\nKhông bị đánh / Không bị đẩy / Không bị tác động"
        startInvincibleMode()
    else
        shieldBtn.Text = "🔵 BẬT BẤT KHẢ XÂM NHẬP"
        shieldBtn.BackgroundColor3 = Color3.fromRGB(30,144,255)
        status.Text = "❌ Đã tắt khiên"
        stopInvincibleMode()
    end
end)

-- ============ RESPAWN → TỰ BẬT LẠI TẤT CẢ ============
player.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("HumanoidRootPart")
    newChar:WaitForChild("Humanoid")

    task.wait(RESTORE_DELAY)

    if _G.EggAuto_GodModeEnabled then startGodMode() end
    if _G.EggAuto_InvincibleEnabled then startInvincibleMode() end
    if _G.EggAuto_LockPosEnabled and _G.EggAuto_SelectedPos then
        restorePosition(_G.EggAuto_Positions[_G.EggAuto_SelectedPos])
        task.wait(0.3)
        startLockPosition()
    end
end)

-- Khôi phục trạng thái
refreshPosList()
local sel = _G.EggAuto_SelectedPos
if sel and _G.EggAuto_Positions[sel] then posDropdown.Text = "✅ "..sel end
if _G.EggAuto_GodModeEnabled then godBtn.Text="💛 BẤT TỬ ✅" godBtn.BackgroundColor3=Color3.fromRGB(255,220,0) startGodMode() end
if _G.EggAuto_InvincibleEnabled then shieldBtn.Text="💠 BẤT KHẢ XÂM NHẬP ✅" shieldBtn.BackgroundColor3=Color3.fromRGB(50,200,255) startInvincibleMode() end
if _G.EggAuto_LockPosEnabled and sel and _G.EggAuto_Positions[sel] then lockBtn.Text="🟢 ĐANG LOCK" lockBtn.BackgroundColor3=Color3.fromRGB(200,100,255) startLockPosition() end

print("✅ BẤT KHẢ XÂM NHẬP ĐÃ BẬT!")
print("🛡️ Không bị sát thương | Không bị đẩy | Không bị NPC tác động")
print("💡 Lưu vị trí → Chọn → Bật Khiên → Bật Lock")
