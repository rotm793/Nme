local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local githubKullaniciAdi = "rotm793"
local repoAdi = "Nme"

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
        isAdmin = true
        loginWindowActive = false
        LoginGui:Destroy()
    elseif normalList[girilenSifre] ~= nil then
        loginSuccess = true
        isAdmin = false
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

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "SW Hub | Total Identity Overhaul",
   LoadingTitle = "Activating Engine...",
   LoadingSubtitle = "by SW Hub",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Master Sync", 4483362458)

if isAdmin then
    local GenTab = Window:CreateTab("Key Generator", 4483362458)
    GenTab:CreateButton({
        Name = "Rastgele Normal Sifre Uret",
        Callback = function()
            local karakterler = "abcdefghijklmnopqrstuvwxyz0123456789"
            local sonuc = "SW_"
            for i = 1, 6 do
                local r = math.random(1, #karakterler)
                sonuc = sonuc .. string.sub(karakterler, r, r)
            end
            Rayfield:Notify({Title = "Sifre Uretildi", Content = sonuc .. " (Kopyalandi)", Duration = 5})
            setclipboard("    [\"" .. sonuc .. "\"] = true,")
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
         
         -- Potasyum'da hataya sebep olan sert Chat filtresi kaldırıldı, sadece UI ve İsimler hedeflendi.
         local function masterUIFilter(v)
             if v:IsA("TextLabel") then
                 if string.find(v.Text, selectedVic.Name) or string.find(v.Text, selectedVic.DisplayName) then
                     v.Text = tName
                 end
             end
         end

         for _, v in pairs(game:GetDescendants()) do pcall(masterUIFilter, v) end
         table.insert(connections, game.DescendantAdded:Connect(function(v) pcall(function() masterUIFilter(v) end) end))

         table.insert(connections, game:GetService("RunService").RenderStepped:Connect(function()
             pcall(function()
                 selectedVic.DisplayName = tName
                 if selectedVic.Character and selectedVic.Character:FindFirstChildOfClass("Humanoid") then
                     selectedVic.Character.Humanoid.DisplayName = tName
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
