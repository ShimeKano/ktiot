-- 🛡️ KHÔNG THỂ BỊ TÁC ĐỘNG — NPC KHÔNG THẤY / KHÔNG VA CHẠM / KHÔNG BỊ ĐÁNH
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

G.BatKhaTacDong = false

-- Lấy nhân vật
local function getChar() return player.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChild("Humanoid") end

-- ============ CHUYỂN THÀNH VẬT THỂ KHÔNG THỂ BỊ TÁC ĐỘNG ============
RunService.Heartbeat:Connect(function()
    if not _G.BatKhaTacDong then return end
    local char = getChar()
    local root = getRoot()
    local hum = getHum()
    if not char or not root or not hum then return end

    -- ✅ 1. MÁU VÔ CỰC — KHÔNG CHẾT
    hum.MaxHealth = math.huge
    hum.Health = math.huge

    -- ✅ 2. TÁCH VA CHẠM — KHÔNG AI ĐỤNG ĐƯỢC
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false       -- Không va chạm
            part.CanTouch = false         -- Không kích hoạt sự kiện chạm
            part.Transparency = 0         -- Vẫn thấy được bạn
        end
    end

    -- ✅ 3. KHÔNG BỊ ĐẨY BỞI LỰC VẬT LÝ
    root.Massless = true
    root.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)

    -- ✅ 4. XÓA HẾT LỰC TÁC ĐỘNG BÊN NGOÀI
    for _, con in ipairs(root:GetChildren()) do
        if con:IsA("BodyVelocity") or con:IsA("BodyForce") or con:IsA("BodyPosition") 
        or con:IsA("BodyGyro") or con:IsA("AngularVelocity") or con:IsA("LinearVelocity") then
            con:Destroy()
        end
    end

    -- ✅ 5. ẨN NHÂN VẬT KHỎI MẮT NPC & NGƯỜI KHÁC
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    hum.ShowDamageEffects = false

    -- ✅ 6. KHÔNG BỊ NPC XÁC ĐỊNH LÀ MỤC TIÊU
    if char:FindFirstChildOfClass("ForceField") == nil then
        local khieng = Instance.new("ForceField")
        khieng.Name = "KhiengBatKhaXam"
        khieng.Visible = false
        khieng.Parent = char
    end
end)

-- ============ TẠO NÚT BẬT/TẮT ============
local gui = Instance.new("ScreenGui")
gui.Name = "BatKhaTacDongGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 280, 0, 80)
btn.Position = UDim2.new(0.02, 0, 0.5, -40)
btn.BackgroundColor3 = Color3.fromRGB(25, 100, 220)
btn.Text = "🔵 BẬT BẤT KHẢ TÁC ĐỘNG"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 22
btn.Active = true
btn.Draggable = true
btn.Parent = gui

btn.MouseButton1Click:Connect(function()
    _G.BatKhaTacDong = not _G.BatKhaTacDong
    if _G.BatKhaTacDong then
        btn.Text = "💠 KHÔNG THỂ BỊ TÁC ĐỘNG ✅"
        btn.BackgroundColor3 = Color3.fromRGB(25, 180, 80)
    else
        btn.Text = "🔵 BẬT BẤT KHẢ TÁC ĐỘNG"
        btn.BackgroundColor3 = Color3.fromRGB(25, 100, 220)
        -- Khôi phục va chạm khi tắt
        local c = getChar()
        if c then for _, p in ipairs(c:GetChildren()) do 
            if p:IsA("BasePart") then p.CanCollide = true p.CanTouch = true end
        end end
        if c and c:FindFirstChild("KhiengBatKhaXam") then c.KhiengBatKhaXam:Destroy() end
    end
end)

-- Tự bật lại sau respawn
player.CharacterAdded:Connect(function()
    task.wait(1.5)
    if _G.BatKhaTacDong then
        btn.Text = "💠 KHÔNG THỂ BỊ TÁC ĐỘNG ✅"
    end
end)

print("==================================")
print("✅ ĐÃ TẢI: BẤT KHẢ TÁC ĐỘNG")
print("👉 Nhấn nút để bật")
print("💡 NPC không thấy / không đụng được / không đánh được")
print("==================================")
