-- 🛡️ BẤT KHẢ XÂM NHẬP ĐƠN GIẢN — Không bị đánh / Không bị đẩy
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

_G.BatKhaXamNhap = false

local function getChar() return player.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChild("Humanoid") end

-- CHẠY LIÊN TỤC — KHÔNG DỪNG
RunService.Heartbeat:Connect(function()
    if not _G.BatKhaXamNhap then return end
    local char = getChar()
    local root = getRoot()
    local hum = getHum()
    if not char or not root or not hum then return end

    -- ✅ 1. MÁU VÔ CỰC — KHÔNG CHẾT
    hum.MaxHealth = math.huge
    hum.Health = math.huge

    -- ✅ 2. KHÔNG BỊ ĐẨY — KHỐI LƯỢNG NẶNG VÔ CÙNG
    root.Massless = false
    root.CustomPhysicalProperties = PhysicalProperties.new(1000, 0, 0)

    -- ✅ 3. XÓA HẾT LỰC ĐẨY BÊN NGOÀI
    for _, v in ipairs(root:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyPosition") or v:IsA("AngularVelocity") then
            v:Destroy()
        end
    end

    -- ✅ 4. NPC KHÔNG TẤN CÔNG
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
end)

-- TẠO NÚT BẬT/TẮT
local gui = Instance.new("ScreenGui")
gui.Name = "BatKhaXamNhapGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 220, 0, 60)
btn.Position = UDim2.new(0.02, 0, 0.5, -30)
btn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
btn.Text = "🔵 BẬT BẤT KHẢ XÂM NHẬP"
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Font = Enum.Font.GothamBold
btn.Active = true
btn.Draggable = true
btn.Parent = gui

btn.MouseButton1Click:Connect(function()
    _G.BatKhaXamNhap = not _G.BatKhaXamNhap
    if _G.BatKhaXamNhap then
        btn.Text = "💠 ĐANG BẢO VỆ ✅"
        btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        btn.Text = "🔵 BẬT BẤT KHẢ XÂM NHẬP"
        btn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
    end
end)

-- TỰ BẬT LẠI SAO RESPAWN
player.CharacterAdded:Connect(function()
    task.wait(1)
    if _G.BatKhaXamNhap then
        btn.Text = "💠 ĐANG BẢO VỆ ✅"
    end
end)

print("✅ Đã tải — Nhấn nút BẬT LÀ XONG!")
