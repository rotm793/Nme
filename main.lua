local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

if not game:IsLoaded() then game.Loaded:Wait() end

local LP = Players.LocalPlayer
assert(LP, "Critical Error: Player data core failed to initialize.")

-- Geliştirici Ayarları
local DEVELOPER_SETTINGS = {
    GithubUser = "rotm793",
    Repository = "Nme",
    ProjectName = "SW HUB"
}

-- =====================================================================
-- [GÜVENLİ & SABİT] LUA TABLO TABANLI WHITELIST MOTORU
-- =====================================================================
local whitelistUrl = string.format("https://raw.githubusercontent.com/%s/%s/main/whitelist.lua", DEVELOPER_SETTINGS.GithubUser, DEVELOPER_SETTINGS.Repository)

local function enforceSecurity()
    local fetchSuccess, rawData = pcall(function()
        return game:HttpGet(whitelistUrl)
    end)
    
    if not fetchSuccess or not rawData or rawData == "" then
        LP:Kick("\n\n[Roblox Error]: Teleport Failed. Authentication server is temporarily unavailable. Please try again later. (Error Code: 610)\n")
        return false
    end

    -- Gelen veriyi canlı Lua tablosuna dönüştür
    local executeSuccess, whitelistTable = pcall(function()
        return loadstring(rawData)()
    end)

    -- Eğer tablo başarıyla yüklendiyse kontrol et
    if executeSuccess and type(whitelistTable) == "table" then
        -- EĞER OYUNCUNUN ID'Sİ TABLODA VARSA GEÇİŞE İZİN VER
        if whitelistTable[LP.UserId] == true then
            return true 
        end
    end

    -- BİREBİR ROBLOX MODERASYON VE SISTEM MESAJI SIMÜLASYONU (YETKİSİZ GİRİŞ)
    local currentUserIdStr = tostring(LP.UserId)
    pcall(function()
        LP:Kick(string.format(
            "\n\n[Roblox Security Notice]\n" ..
            "Your account has been restricted from accessing this experience's external modules.\n\n" ..
            "Reason: Unauthorized Client Identity Detected.\n" ..
            "Security Hash: [SW_SECURE_GATEWAY_v4]\n" ..
            "Target User ID: %s\n\n" ..
            "Please rejoin from an authorized account or contact the experience developer for verification.", 
            currentUserIdStr
        ))
    end)
    
    -- Anti-Bypass Motoru
    task.spawn(function()
        pcall(function() LP:Destroy() end)
        while true do
            local _ = string.rep("ANTI_BYPASS", 10000)
        end
    end)
    
    error("["..DEVELOPER_SETTINGS.ProjectName.."]: Security violation handled.")
    return false
end

-- Güvenlik Kontrolünü Çalıştır
if not enforceSecurity() then return end
-- =====================================================================


-- VERİ KAYNAKLARI (KEY SYSTEM)
local adminUrl = string.format("https://raw.githubusercontent.com/%s/%s/main/admin_keys.lua", DEVELOPER_SETTINGS.GithubUser, DEVELOPER_SETTINGS.Repository)
local normalUrl = string.format("https://raw.githubusercontent.com/%s/%s/main/normal_keys.lua", DEVELOPER_SETTINGS.GithubUser, DEVELOPER_SETTINGS.Repository)

local s1, adminList = pcall(function() return loadstring(game:HttpGet(adminUrl))() end)
local s2, normalList = pcall(function() return loadstring(game:HttpGet(normalUrl))() end)

if not s1 or not s2 then
    LP:Kick("\n\n[Roblox Error]: Data sync failure. Unexpected behavior from internal game data stores.\n")
    return
end

local loginSuccess = false
local loginWindowActive = true
local isAdmin = false

-- MODERN GİRİŞ PANELİ
local LoginGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", LoginGui)
MainFrame.Size = UDim2.new(0, 320, 0, 160)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(45, 45, 55)
Stroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = DEVELOPER_SETTINGS.ProjectName .. "  |  SECURE GATEWAY"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0, 280, 0, 38)
InputBox.Position = UDim2.new(0, 20, 0, 60)
InputBox.PlaceholderText = "Enter Access Token..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
InputBox.BorderSizePixel = 0
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 12
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)

local BoxStroke = Instance.new("UIStroke", InputBox)
BoxStroke.Color = Color3.fromRGB(40, 40, 50)

local SubmitBtn = Instance.new("TextButton", MainFrame)
SubmitBtn.Size = UDim2.new(0, 280, 0, 38)
SubmitBtn.Position = UDim2.new(0, 20, 0, 108)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(90, 20, 180)
SubmitBtn.Text = "AUTHENTICATE"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 12
SubmitBtn.BorderSizePixel = 0
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

SubmitBtn.MouseButton1Click:Connect(function()
    local girilenSifre = InputBox.Text
    
    if adminList[girilenSifre] ~= nil then
        loginSuccess = true
        isAdmin = true
        loginWindowActive = false
        LoginGui:Destroy()
    elseif normalList[girilenSifre] ~= nil then
        loginSuccess = true
        isAdmin = false
        loginWindowActive = false
        LoginGui:Destroy()
    else
        SubmitBtn.Text = "INVALID TOKEN"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        task.wait(1.5)
        SubmitBtn.Text = "AUTHENTICATE"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(90, 20, 180)
    end
end)

while loginWindowActive do task.wait(0.1) end
if not loginSuccess then return end

-- RAYFIELD ENGINE VE MASTER SYNC MOTORU
local RS = game:GetService("RunService")
local TCS = game:GetService("TextChatService")

if game:GetService("CoreGui"):FindFirstChild("Rayfield") then game:GetService("CoreGui").Rayfield:Destroy() end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = DEVELOPER_SETTINGS.ProjectName .. " | Identity Overhaul Engine",
   LoadingTitle = "Core Systems Initializing...",
   LoadingSubtitle = "by " .. DEVELOPER_SETTINGS.ProjectName,
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Master Sync", 4483362458)

-- OWNER / ADMIN PANELİ (Sadece admin_keys.lua şifresiyle girenlerde açılır)
if isAdmin then
    local GenTab = Window:CreateTab("Owner Panel", 4483362458)
    
    -- Şifre Üretme Butonu
    GenTab:CreateButton({
        Name = "Generate Standard Token",
        Callback = function()
            local karakterler = "abcdefghijklmnopqrstuvwxyz0123456789"
            local sonuc = "SW_"
            for i = 1, 6 do
                local r = math.random(1, #karakterler)
                sonuc = sonuc .. string.sub(karakterler, r, r)
            end
            Rayfield:Notify({Title = "Token Generated", Content = sonuc .. " (Copied to Clipboard)", Duration = 5})
            setclipboard("    [\"" .. sonuc .. "\"] = true,") 
        end,
    })

    -- Gelişmiş Whitelist Format Üretici (Kullanman gereken kodu panoya kopyalar)
    local inputWhitelistId = ""
    GenTab:CreateInput({
        Name = "Whitelist ID Girişi",
        PlaceholderText = "Eklenecek Oyuncu ID'sini Yaz...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text) inputWhitelistId = Text end,
    })

    GenTab:CreateButton({
        Name = "Kullanılacak Whitelist Kodunu Al",
        Callback = function()
            local cleanId = string.gsub(inputWhitelistId, "%s+", "")
            if cleanId ~= "" and tonumber(cleanId) then
                -- GitHub'daki whitelist.lua dosyasının içine direkt yapıştırabileceğin kodu hazır üretir
                local formattedCode = string.format("    [%s] = true,", cleanId)
                setclipboard(formattedCode)
                Rayfield:Notify({
                    Title = "Kod Panoya Kopyalandı!",
                    Content = "GitHub'daki whitelist.lua tablosunun içine girip yapıştır.",
                    Duration = 6
                })
            else
                Rayfield:Notify({Title = "Hata", Content = "Lütfen geçerli bir sayısal ID girin.", Duration = 4})
            end
        end,
    })
end

local targetUsername = ""
local targetId = 0
local connections = {}

local function clearOldConnections()
    for _, con in pairs(connections) do if con then con:Disconnect() end end
    connections = {}
end

Tab:CreateInput({
   Name = "Target Identity (Username/Display)",
   PlaceholderText = "Target Player Name...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) targetUsername = Text end,
})

Tab:CreateInput({
   Name = "Target User ID (Clone Target)",
   PlaceholderText = "Target Asset ID...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) targetId = tonumber(Text) or 0 end,
})

Tab:CreateButton({
   Name = "EXECUTE COMPLETE IDENTITY OVERHAUL",
   Callback = function()
      if targetUsername ~= "" and targetId ~= 0 then
         clearOldConnections()
         Rayfield:Notify({Title = "SYNCHRONIZING", Content = "Overhauling interface layers...", Duration = 4})

         local selectedVic = Players:FindFirstChild(targetUsername)
         if not selectedVic then
            for _, p in pairs(Players:GetPlayers()) do
               if p.DisplayName:lower() == targetUsername:lower() or p.Name:lower() == targetUsername:lower() then
                  selectedVic = p
                  break
               end
            end
         end

         if not selectedVic then
            Rayfield:Notify({ Title = "Error", Content = "Target player context not found.", Duration = 4 })
            return
         end

         local s, tName = pcall(function() return Players:GetNameFromUserIdAsync(targetId) end)
         if not s then tName = "crydollz" end
         local info = game:GetService("UserService"):GetUserInfosByUserIdsAsync({targetId})[1]
         local tDisplay = (info and info.DisplayName ~= "" and info.DisplayName) or tName
         
         local thumbHead = "rbxthumb://type=AvatarHeadShot&id=" .. targetId .. "&w=150&h=150"
         local thumbBust = "rbxthumb://type=AvatarBust&id=" .. targetId .. "&w=150&h=150"

         local oldNameStr = selectedVic.Name
         local oldDisplayStr = selectedVic.DisplayName
         local oldUserIdStr = tostring(selectedVic.UserId)

         TCS.OnIncomingMessage = function(message)
            local properties = Instance.new("TextChatMessageProperties")
            if message.TextSource and message.TextSource.UserId == selectedVic.UserId then
                local originalPrefix = message.PrefixText or ""
                local fixedPrefix = originalPrefix
                if string.find(fixedPrefix, oldDisplayStr) then fixedPrefix = string.gsub(fixedPrefix, oldDisplayStr, tDisplay) end
                if string.find(fixedPrefix, oldNameStr) then fixedPrefix = string.gsub(fixedPrefix, oldNameStr, tName) end
                if fixedPrefix == "" then fixedPrefix = "<font color='#FFFFFF'>" .. tDisplay .. "</font>" end
                properties.PrefixText = fixedPrefix
            end
            return properties
         end

         local function masterUIFilter(v)
             if v:IsA("TextLabel") then
                 if string.find(v.Text, oldNameStr) or string.find(v.Text, oldDisplayStr) or string.find(string.lower(v.Text), "berenscp") then
                     v.Text = string.gsub(string.gsub(v.Text, oldDisplayStr, tDisplay), oldNameStr, tName)
                     table.insert(connections, v:GetPropertyChangedSignal("Text"):Connect(function()
                         v.Text = string.gsub(string.gsub(v.Text, oldDisplayStr, tDisplay), oldNameStr, tName)
                     end))
                 end
             elseif v:IsA("ImageLabel") then
                 local imgStr = string.lower(v.Image)
                 local isExactlyTarget = false
                 if string.find(imgStr, oldUserIdStr) then isExactlyTarget = true
                 elseif v:GetAttribute("PlayerId") == selectedVic.UserId or v:GetAttribute("UserId") == selectedVic.UserId then isExactlyTarget = true
                 elseif v.Parent then
                     for _, child in pairs(v.Parent:GetChildren()) do
                         if child:IsA("TextLabel") and (child.Text == tDisplay or child.Text == tName or string.find(child.Text, oldDisplayStr)) then
                             if string.find(imgStr, "rbxthumb") or string.find(imgStr, "avatar") then isExactlyTarget = true break end
                         end
                     end
                 end
                 if isExactlyTarget then
                     local currentThumb = string.find(imgStr, "bust") and thumbBust or thumbHead
                     v.Image = currentThumb
                     table.insert(connections, v:GetPropertyChangedSignal("Image"):Connect(function() v.Image = currentThumb end))
                 end
             end
         end

         for _, v in pairs(game:GetDescendants()) do pcall(masterUIFilter, v) end
         table.insert(connections, game.DescendantAdded:Connect(function(v) pcall(function() masterUIFilter(v) end) end))

         table.insert(connections, RS.RenderStepped:Connect(function()
             pcall(function()
                 selectedVic.DisplayName = tDisplay
                 selectedVic.Name = tName
                 if selectedVic.Character and selectedVic.Character:FindFirstChildOfClass("Humanoid") then
                     selectedVic.Character.Humanoid.DisplayName = tDisplay
                 end
             end)
         end))

         Rayfield:Notify({Title = "OVERHAUL SUCCESSFUL", Content = "All interface vectors locked.", Duration = 5})
      else
         Rayfield:Notify({ Title = "Warning", Content = "Required input vectors are missing.", Duration = 4 })
      end
   end,
})

local DestroyTab = Window:CreateTab("Configuration", 4483362458)
DestroyTab:CreateButton({
   Name = "Unload Engine",
   Callback = function() clearOldConnections() Rayfield:Destroy() end,
})
