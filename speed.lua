-- ⚡ SPEED TÙY CHỈNH + BẢO VỆ
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

_G.TocDoChay = 16 -- Mặc định bình thường
_G.KhiengBat = false

-- ============ DANH SÁCH TỐC ĐỘ CHỌN NHANH ============
local speedList = {
    {text = "Bình thường (16)", value = 16},
    {text = "Nhanh nhẹ (30)",   value = 30},
    {text = "Rất nhanh (50)",   value = 50},
    {text = "Siêu nhanh (80)",   value = 80},
    {text = "Bay nhanh (150)",   value = 150},
}

-- ============ LẤY NHÂN VẬT ============
local function layNhanVat()
    local nv = player.Character
    if not nv then return nil end
    local hum = nv:FindFirstChild("Humanoid")
    local root = nv:FindFirstChild("HumanoidRootPart")
    if hum and root then return {nv, hum, root} end
    return nil
end

-- ============ CẬP NHẬT TỐC ĐỘ + BẢO VỆ ============
RunService.Heartbeat:Connect(function()
    local nv = layNhanVat()
    if not nv then return end
    local nhanVat, hum, root = nv[1], nv[2], nv[3]

    -- ⚡ Đặt tốc độ chạy
    if hum.WalkSpeed ~= _G.TocDoChay then
        hum.WalkSpeed = _G.TocDoChay
    end

    -- 🛡️ Bảo vệ nếu bật
    if _G.KhiengBat then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        root.Massless = false
        root.CustomPhysicalProperties = PhysicalProperties.new(1000, 0, 0)
        for _, con in ipairs(root:GetChildren()) do
            if con:IsA("BodyVelocity") or con:IsA("BodyForce") or con:IsA("BodyPosition") or con:IsA("AngularVelocity") then
                con:Destroy()
            end
        end
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end)

-- ============ TẠO GIAO DIỆN ============
local guiCu = player:FindFirstChild("PlayerGui", true):FindFirstChild("SpeedTuChinhGui")
if guiCu then guiCu:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedTuChinhGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local khung = Instance.new("Frame")
khung.Size = UDim2.new(0, 280, 0, 340)
khung.Position = UDim2.new(0.02, 0, 0.3, 0)
khung.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
khung.Active = true
khung.Draggable = true
khung.Parent = gui

local tieuDe = Instance.new("TextLabel")
tieuDe.Size = UDim2.new(1, 0, 0, 45)
tieuDe.BackgroundColor3 = Color3.fromRGB(220, 160, 40)
tieuDe.Text = "⚡ TỐC ĐỘ TÙY CHỈNH"
tieuDe.TextColor3 = Color3.new(1,1,1)
tieuDe.TextScaled = true
tieuDe.Font = Enum.Font.GothamBold
tieuDe.Parent = khung

-- ============ CHỌN TỐC ĐỘ NHANH ============
local speedDropdown = Instance.new("TextButton")
speedDropdown.Size = UDim2.new(0.9, 0, 0, 45)
speedDropdown.Position = UDim2.new(0.05, 0, 0, 60)
speedDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedDropdown.Text = "⚡ Chọn tốc độ nhanh..."
speedDropdown.TextColor3 = Color3.new(1,1,1)
speedDropdown.TextScaled = true
speedDropdown.Parent = khung

local speedListFrame = Instance.new("Frame")
speedListFrame.Size = UDim2.new(1, 0, 0, 0)
speedListFrame.Position = UDim2.new(0, 0, 1, 5)
speedListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedListFrame.Visible = false
speedListFrame.ClipsDescendants = true
speedListFrame.Parent = speedDropdown

-- Tạo danh sách lựa chọn
for i, item in ipairs(speedList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = item.text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = speedListFrame

    btn.MouseButton1Click:Connect(function()
        _G.TocDoChay = item.value
        speedDropdown.Text = "✅ " .. item.text
        speedListFrame.Visible = false
        nhapSpeed.Text = tostring(item.value)
    end)
end

speedDropdown.MouseButton1Click:Connect(function()
    speedListFrame.Visible = not speedListFrame.Visible
    speedListFrame.Size = UDim2.new(1, 0, 0, #speedList * 40)
end)

-- ============ Ô NHẬP TỐC ĐỘ TỰ ĐIỀN ============
local nhapLabel = Instance.new("TextLabel")
nhapLabel.Size = UDim2.new(0.9, 0, 0, 30)
nhapLabel.Position = UDim2.new(0.05, 0, 0, 120)
nhapLabel.BackgroundTransparency = 1
nhapLabel.Text = "✏️ Hoặc nhập tốc độ tùy chỉnh:"
nhapLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
nhapLabel.TextScaled = true
nhapLabel.TextXAlignment = Enum.TextXAlignment.Left
nhapLabel.Parent = khung

local nhapSpeed = Instance.new("TextBox")
nhapSpeed.Size = UDim2.new(0.5, 0, 0, 45)
nhapSpeed.Position = UDim2.new(0.05, 0, 0, 155)
nhapSpeed.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
nhapSpeed.Text = "16"
nhapSpeed.TextColor3 = Color3.new(1,1,1)
nhapSpeed.TextScaled = true
nhapSpeed.Font = Enum.Font.Gotham
nhapSpeed.Parent = khung

local apDungBtn = Instance.new("TextButton")
apDungBtn.Size = UDim2.new(0.35, -5, 0, 45)
apDungBtn.Position = UDim2.new(0.6, 5, 0, 155)
apDungBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
apDungBtn.Text = "✅ Áp dụng"
apDungBtn.TextColor3 = Color3.new(1,1,1)
apDungBtn.TextScaled = true
apDungBtn.Parent = khung

apDungBtn.MouseButton1Click:Connect(function()
    local so = tonumber(nhapSpeed.Text)
    if so and so > 0 then
        _G.TocDoChay = so
        speedDropdown.Text = "⚡ Tốc độ: " .. so
        StarterGui:SetCore("SendNotification", {
            Title = "✅ Thành công",
            Text = "Tốc độ: " .. so,
            Duration = 2
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "❌ Lỗi",
            Text = "Nhập số hợp lệ!",
            Duration = 2
        })
    end
end)

-- ============ NÚT BẢO VỆ ============
local baoVeBtn = Instance.new("TextButton")
baoVeBtn.Size = UDim2.new(0.9, 0, 0, 50)
baoVeBtn.Position = UDim2.new(0.05, 0, 0, 220)
baoVeBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
baoVeBtn.Text = "🔵 BẬT BẢO VỆ"
baoVeBtn.TextColor3 = Color3.new(1,1,1)
baoVeBtn.TextScaled = true
baoVeBtn.Font = Enum.Font.GothamBold
baoVeBtn.Parent = khung

baoVeBtn.MouseButton1Click:Connect(function()
    _G.KhiengBat = not _G.KhiengBat
    if _G.KhiengBat then
        baoVeBtn.Text = "💠 ĐANG BẢO VỆ ✅"
        baoVeBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        baoVeBtn.Text = "🔵 BẬT BẢO VỆ"
        baoVeBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
    end
end)

-- ============ TỰ ĐẶT LẠI TỐC ĐỘ SAO RESPAWN ============
player.CharacterAdded:Connect(function()
    task.wait(1.5)
    local nv = layNhanVat()
    if nv then
        nv[2].WalkSpeed = _G.TocDoChay
    end
end)

print("==================================")
print("✅ SPEED TÙY CHỈNH ĐÃ TẢI!")
print("👉 Chọn sẵn hoặc nhập số tùy thích")
print("==================================")
