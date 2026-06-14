local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Oyuncunun verilerinin tam yüklenmesini bekle (Güvenlik Önlemi)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LP = Players.LocalPlayer
assert(LP, "Oyuncu verisi yuklenemedi.")

local githubKullaniciAdi = "rotm793"
local repoAdi = "Nme"

-- =====================================================================
-- [YENİ] Gelişmiş Whitelist (ID Kontrolü) Sistemi - Olmayanlar Direkt Kicklenir
-- =====================================================================
local whitelistUrl = "https://raw.githubusercontent.com/"..githubKullaniciAdi.."/"..repoAdi.."/main/whitelist.txt"

local function checkWhitelist()
    local success, response = pcall(function()
        return HttpService:GetAsync(whitelistUrl)
    end)
    
    if success and response then
        -- GitHub'dan gelen ID listesini satır satır tarar
        for id in string.gmatch(response, "[^\r\n]+") do
            if tonumber(id) == LP.UserId then
                return true -- ID listede var, erişim onaylandı.
            end
        end
    end
    return false -- Bağlantı hatası veya ID listede yoksa reddet.
end

-- ID Kontrolünü hemen başlat (Şifre ekranından önce)
if not checkWhitelist() then
    LP:Kick() -- Parantez içi boş: Sessizce ve uyarısız direkt oyundan atar.
    while true do end -- Exploit bypass koruması (Oyunu dondurur/crash atar)
    return
end
-- =====================================================================


-- İki ayrı dosyayı da internetten çekiyoruz
local adminUrl = "https://raw.githubusercontent.com/"..githubKullaniciAdi.."/"..repoAdi.."/main/admin_keys.lua"
local normalUrl = "https://raw.githubusercontent.com/"..githubKullaniciAdi.."/"..repoAdi.."/main/normal_keys.lua"

local s1, adminList = pcall(function() return loadstring(game:HttpGet(adminUrl))() end)
local s2, normalList = pcall(function() return loadstring(game:HttpGet(normalUrl))() end)

if not s1 or not s2 then
    LP:Kick("SW HUB: Sifre dosyalari yuklenemedi!")
    return
end

local loginSuccess = false
local loginWindowActive = true
local isAdmin = false

-- GİRİŞ PANELİ (Tertemiz, parantezsiz)
local LoginGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", LoginGui)
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SW HUB | KEY SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0, 260, 0, 35)
InputBox.Position = UDim2.new(0, 20, 0, 55)
InputBox.PlaceholderText = "Sifreyi Girin..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
InputBox.BorderSizePixel = 0
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 13

local SubmitBtn = Instance.new("TextButton", MainFrame)
SubmitBtn.Size = UDim2.new(0, 260, 0, 35)
SubmitBtn.Position = UDim2.new(0, 20, 0, 100)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
SubmitBtn.Text = "GIRIS YAP"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 13
SubmitBtn.BorderSizePixel = 0
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

SubmitBtn.MouseButton1Click:Connect(function()
    local girilenSifre = InputBox.Text
    
    if adminList[girilenSifre] ~= nil then
        loginSuccess = true
        isAdmin = true -- Admin olarak açar
        loginWindowActive = false
        LoginGui:Destroy()
    elseif normalList[girilenSifre] ~= nil then
        loginSuccess = true
        isAdmin = false -- Normal kullanıcı olarak açar
        loginWindowActive = false
        LoginGui:Destroy()
    else
        SubmitBtn.Text = "YANLIS SIFRE!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        task.wait(1.5)
        SubmitBtn.Text = "GIRIS YAP"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
    end
end)

while loginWindowActive do task.wait(0.1) end
if not loginSuccess then return end

-- BURADAN SONRASI RAYFIELD MENÜSÜ VE SENKRONİZASYON MOTORU (Değişmedi)
local RS = game:GetService("RunService")
local TCS = game:GetService("TextChatService")

if game:GetService("CoreGui"):FindFirstChild("Rayfield") then game:GetService("CoreGui").Rayfield:Destroy() end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SW Hub | Total Identity Overhaul",
   LoadingTitle = "All-In-One Engine Activating...",
   LoadingSubtitle = "by SW Hub",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Master Sync", 4483362458)

-- Admin Paneli (Sadece admin_keys.lua'daki şifreyle girenlerde açılır)
if isAdmin then
    local GenTab = Window:CreateTab("Key Generator", 4483362458)
    local GeneratedKeyStr = ""
    
    GenTab:CreateButton({
        Name = "Rastgele Normal Sifre Uret",
        Callback = function()
            local karakterler = "abcdefghijklmnopqrstuvwxyz0123456789"
            local sonuc = "SW_"
            for i = 1, 6 do
                local r = math.random(1, #karakterler)
                sonuc = sonuc .. string.sub(karakterler, r, r)
            end
            GeneratedKeyStr = sonuc
            Rayfield:Notify({Title = "Sifre Uretildi", Content = sonuc .. " (Kopyalandi)", Duration = 5})
            setclipboard("    [\"" .. sonuc .. "\"] = true,") 
            -- Direkt GitHub'a yapıştırılacak hazır satırı panoya kopyalar!
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
   Name = "Kimin Kimliği Değişecek?",
   PlaceholderText = "Örn: Berenscp23",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) targetUsername = Text end,
})

Tab:CreateInput({
   Name = "Klonlanacak TEK OYUNCU ID'Sİ",
   PlaceholderText = "Örn: 1",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) targetId = tonumber(Text) or 0 end,
})

Tab:CreateButton({
   Name = "HER ŞEYİ TEK SEFERDE KİLİTLE",
   Callback = function()
      if targetUsername ~= "" and targetId ~= 0 then
         clearOldConnections()
         Rayfield:Notify({Title = "MASTER SYNC AKTIF", Content = "Veriler kilitleniyor...", Duration = 4})

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
            Rayfield:Notify({ Title = "Hata", Content = "Oyuncu bulunamadi.", Duration = 4 })
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

         Rayfield:Notify({Title = "TAM SENKRONIZASYON", Content = "Islem basarili!", Duration = 5})
      else
         Rayfield:Notify({ Title = "Hata", Content = "Lutfen tum kutulari doldurun.", Duration = 4 })
      end
   end,
})

local DestroyTab = Window:CreateTab("Settings", 4483362458)
DestroyTab:CreateButton({
   Name = "Scripti Kapat (Unload)",
   Callback = function() clearOldConnections() Rayfield:Destroy() end,
})
