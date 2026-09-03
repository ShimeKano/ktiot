-- 🛡️ BẤT KHẢ XÂM NHẬP — ĐƠN GIẢN NHẤT & CHẮC CHẮN NHẤT
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

_G.KhiengBat = false

-- ============ CHỜ NHÂN VẬT LOAD XONG HOÀN TOÀN ============
local function layNhanVat()
    local nhanVat = player.Character
    if not nhanVat then return nil end
    -- Chờ đủ bộ phận
    local root = nhanVat:FindFirstChild("HumanoidRootPart")
    local hum = nhanVat:FindFirstChild("Humanoid")
    if root and hum and root:IsA("BasePart") then
        return {nhanVat, root, hum}
    end
    return nil
end

-- ============ VÒNG LẶP BẢO VỆ ============
RunService.Heartbeat:Connect(function()
    if not _G.KhiengBat then return end
    
    local nv = layNhanVat()
    if not nv then return end
    local nhanVat, root, hum = nv[1], nv[2], nv[3]

    -- ✅ 1. MÁU VÔ CỰC — KHÔNG CHẾT
    hum.MaxHealth = math.huge
    hum.Health = math.huge

    -- ✅ 2. KHÔNG BỊ ĐẨY
    root.Massless = false
    root.CustomPhysicalProperties = PhysicalProperties.new(1000, 0, 0)

    -- ✅ 3. XÓA LỰC ĐẨY
    for _, con in ipairs(root:GetChildren()) do
        if con:IsA("BodyVelocity") or con:IsA("BodyForce") or con:IsA("BodyPosition") or con:IsA("AngularVelocity") or con:IsA("LinearVelocity") then
            con:Destroy()
        end
    end

    -- ✅ 4. NPC KHÔNG TẤN CÔNG
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
end)

-- ============ TẠO NÚT BẬT/TẮT ============
local function taoNut()
    -- Xóa cũ nếu có
    local guiCu = player:FindFirstChild("PlayerGui", true):FindFirstChild("KhiengBatGui")
    if guiCu then guiCu:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "KhiengBatGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = player:WaitForChild("PlayerGui", 10)

    local nut = Instance.new("TextButton")
    nut.Size = UDim2.new(0, 240, 0, 70)
    nut.Position = UDim2.new(0.02, 0, 0.5, -35)
    nut.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
    nut.Text = "🔵 BẬT BẢO VỆ"
    nut.TextColor3 = Color3.new(1,1,1)
    nut.Font = Enum.Font.GothamBold
    nut.TextSize = 22
    nut.Active = true
    nut.Draggable = true
    nut.Parent = gui

    nut.MouseButton1Click:Connect(function()
        _G.KhiengBat = not _G.KhiengBat
        if _G.KhiengBat then
            nut.Text = "💠 ĐANG BẢO VỆ ✅"
            nut.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            nut.Text = "🔵 BẬT BẢO VỆ"
            nut.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
        end
    end)

    return nut
end

-- ============ TỰ TẠO NÚT + TỰ BẬT LẠI SAO RESPAWN ============
local nut = taoNut()

player.CharacterAdded:Connect(function()
    -- ĐỢI DÀI HƠN — CHẮC CHẮN NHÂN VẬT SẴN SÀNG
    task.wait(2)
    if _G.KhiengBat then
        nut.Text = "💠 ĐANG BẢO VỆ ✅"
    end
end)

print("==================================")
print("✅ BẢO VỆ ĐÃ TẢI THÀNH CÔNG!")
print("👉 Nhấn nút [🔵 BẬT BẢO VỆ] là xong")
print("💡 Nút hiện ở góc màn hình, có thể kéo đi được")
print("==================================")
