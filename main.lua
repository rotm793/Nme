local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RS = game:GetService("RunService")
local TCS = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")

-- GITHUB BAĞLANTI AYARLARI
local githubKullaniciAdi = "rotm793"
local repoAdi = "Nme"
local keyDataUrl = "https://raw.githubusercontent.com/"..githubKullaniciAdi.."/"..repoAdi.."/main/key_data.lua"

local keyList = loadstring(game:HttpGet(keyDataUrl))()

-- GİRİŞ PANELİ (Ayrıntılı UI)
local LoginGui = Instance.new("ScreenGui", CoreGui)
LoginGui.Name = "SW_Login_System"
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
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0, 260, 0, 35)
InputBox.Position = UDim2.new(0, 20, 0, 55)
InputBox.PlaceholderText = "Şifreyi Girin..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
InputBox.Parent = MainFrame

local SubmitBtn = Instance.new("TextButton", MainFrame)
SubmitBtn.Size = UDim2.new(0, 260, 0, 35)
SubmitBtn.Position = UDim2.new(0, 20, 0, 100)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
SubmitBtn.Text = "GİRİŞ YAP"
SubmitBtn.Parent = MainFrame

local loginSuccess = false
SubmitBtn.MouseButton1Click:Connect(function()
    if keyList[InputBox.Text] ~= nil then
        loginSuccess = true
        LoginGui:Destroy()
    else
        SubmitBtn.Text = "YANLIŞ ŞİFRE!"
        task.wait(1)
        SubmitBtn.Text = "GİRİŞ YAP"
    end
end)

repeat task.wait() until loginSuccess

-- RAYFIELD VE MOTOR AYARLARI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SW Hub | Full Identity Overhaul", KeySystem = false})
local Tab = Window:CreateTab("Master Sync", 4483362458)

local targetUsername = ""
local targetId = 0
local connections = {}

local function clearOldConnections()
    for _, con in pairs(connections) do if con then con:Disconnect() end end
    connections = {}
end

Tab:CreateInput({Name = "Kimin Kimliği Değişecek?", Callback = function(t) targetUsername = t end})
Tab:CreateInput({Name = "Klonlanacak TEK OYUNCU ID'Sİ", Callback = function(t) targetId = tonumber(t) or 0 end})

Tab:CreateButton({
   Name = "HER ŞEYİ TEK SEFERDE KİLİTLE",
   Callback = function()
      clearOldConnections()
      local selectedVic = Players:FindFirstChild(targetUsername)
      if not selectedVic then
         for _,p in pairs(Players:GetPlayers()) do
             if p.Name:lower():find(targetUsername:lower()) then selectedVic = p break end
         end
      end
      
      if selectedVic then
         local tName = Players:GetNameFromUserIdAsync(targetId)
         local thumbHead = "rbxthumb://type=AvatarHeadShot&id=" .. targetId .. "&w=150&h=150"

         -- CHAT SENKRONİZASYONU (Ayrıntılı)
         TCS.OnIncomingMessage = function(message)
            local properties = Instance.new("TextChatMessageProperties")
            if message.TextSource and message.TextSource.UserId == selectedVic.UserId then
                properties.PrefixText = "<font color='#FFFFFF'>" .. tName .. "</font>"
            end
            return properties
         end

         -- GÖRSEL VE YAZI İZLEME (Tüm GUI'yi kapsamlı tarama)
         for _, v in pairs(game:GetDescendants()) do
            if v:IsA("TextLabel") and (v.Text:find(selectedVic.Name) or v.Text:find(selectedVic.DisplayName)) then
               v.Text = tName
               table.insert(connections, v:GetPropertyChangedSignal("Text"):Connect(function() v.Text = tName end))
            elseif v:IsA("ImageLabel") and (v.Name:lower():find("icon") or v.Image:find("avatar")) then
               v.Image = thumbHead
               table.insert(connections, v:GetPropertyChangedSignal("Image"):Connect(function() v.Image = thumbHead end))
            end
         end

         -- ANA İSİM DEĞİŞTİRME MOTORU
         RS.RenderStepped:Connect(function()
            selectedVic.DisplayName = tName
            selectedVic.Name = tName
            if selectedVic.Character and selectedVic.Character:FindFirstChild("Humanoid") then
                selectedVic.Character.Humanoid.DisplayName = tName
            end
         end)
         
         Rayfield:Notify({Title = "SİSTEM", Content = "Tüm kimlikler kilitlendi!", Duration = 5})
      end
   end,
})

-- AYARLAR VE KAPATMA
local DestroyTab = Window:CreateTab("Settings", 4483362458)
DestroyTab:CreateButton({Name = "Scripti Kapat (Unload)", Callback = function() clearOldConnections() Rayfield:Destroy() end})
