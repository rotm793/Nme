-- =========================================================================
-- SW HUB | MASTER IDENTITY OVERHAUL - ULTIMATE VERSION
-- =========================================================================
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TCS = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- [BAĞLANTI AYARLARI]
local githubKullaniciAdi = "rotm793"
local repoAdi = "Nme"
local keyDataUrl = "https://raw.githubusercontent.com/"..githubKullaniciAdi.."/"..repoAdi.."/main/key_data.lua"

local keyList = loadstring(game:HttpGet(keyDataUrl))()

-- [GELİŞMİŞ AUTH PANELİ]
local LoginGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", LoginGui)
MainFrame.Size = UDim2.new(0, 320, 0, 180); MainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.BorderSizePixel = 0
MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40); Header.Text = "AUTHENTICATION REQUIRED"
Header.Font = Enum.Font.GothamBold; Header.TextSize = 16; Header.TextColor3 = Color3.fromRGB(200, 200, 200)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Header.Parent = MainFrame

local KeyInput = Instance.new("TextBox", MainFrame)
KeyInput.Size = UDim2.new(0, 280, 0, 40); KeyInput.Position = UDim2.new(0, 20, 0, 60)
KeyInput.PlaceholderText = "Lisans anahtarını giriniz..."; KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255); KeyInput.BorderSizePixel = 0

local SubmitBtn = Instance.new("TextButton", MainFrame)
SubmitBtn.Size = UDim2.new(0, 280, 0, 40); SubmitBtn.Position = UDim2.new(0, 20, 0, 110)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 120); SubmitBtn.Text = "SİSTEMİ BAŞLAT"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255); SubmitBtn.Font = Enum.Font.GothamBold

local authSuccess = false
SubmitBtn.MouseButton1Click:Connect(function()
    if keyList[KeyInput.Text] then authSuccess = true; LoginGui:Destroy() else SubmitBtn.Text = "HATALI LİSANS!" task.wait(2) SubmitBtn.Text = "SİSTEMİ BAŞLAT" end
end)
repeat task.wait() until authSuccess

-- [RAYFIELD CORE ENGINE]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SW HUB | TOTAL IDENTITY ENGINE", LoadingTitle = "Syncing with Server...", KeySystem = false})

local Tab = Window:CreateTab("Identity Master", 4483362458)
local targetName, targetId = "", 0

Tab:CreateInput({Name = "Hedef Oyuncu Adı", Callback = function(t) targetName = t end})
Tab:CreateInput({Name = "Klonlanacak ID", Callback = function(t) targetId = tonumber(t) or 0 end})

Tab:CreateButton({
    Name = "TÜM KİMLİĞİ SENKRONİZE ET",
    Callback = function()
        local vic = Players:FindFirstChild(targetName)
        if not vic then for _,p in pairs(Players:GetPlayers()) do if p.Name:lower():find(targetName:lower()) then vic = p end end end
        if not vic or targetId == 0 then return end

        local newName = Players:GetNameFromUserIdAsync(targetId)
        local thumb = "rbxthumb://type=AvatarHeadShot&id=" .. targetId .. "&w=150&h=150"

        -- [CHAT MANIPULATION]
        TCS.OnIncomingMessage = function(m)
            local prop = Instance.new("TextChatMessageProperties")
            pcall(function() if m.TextSource.UserId == vic.UserId then prop.PrefixText = "<font color='#FF00FF'>" .. newName .. "</font>" end end)
            return prop
        end

        -- [RENDER STEPPED - HIGH PRIORITY]
        RS.RenderStepped:Connect(function()
            pcall(function()
                vic.DisplayName = newName
                vic.Name = newName
                if vic.Character and vic.Character:FindFirstChild("Humanoid") then
                    vic.Character.Humanoid.DisplayName = newName
                end
            end)
        end)

        -- [GUI WATCHER - DEEP SCAN]
        task.spawn(function()
            while task.wait(0.1) do
                for _, v in pairs(game:GetDescendants()) do
                    pcall(function()
                        if v:IsA("TextLabel") and (v.Text == targetName or v.Text == vic.DisplayName) then
                            v.Text = newName
                        elseif v:IsA("ImageLabel") and (v.Name:lower():find("icon") or v.Name:lower():find("avatar")) then
                            v.Image = thumb
                        end
                    end)
                end
            end
        end)
        Rayfield:Notify({Title = "İşlem Başarılı", Content = "Master Sync aktif, tüm kanallar kilitlendi.", Duration = 5})
    end
})

-- [SETTINGS]
local SetTab = Window:CreateTab("Settings", 4483362458)
SetTab:CreateButton({Name = "Sistemi Kapat (Unload)", Callback = function() Rayfield:Destroy() end})
