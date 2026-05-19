local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TCS = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")

-- 1. ŞİFRE SİSTEMİ (En stabil hali)
local keyList = loadstring(game:HttpGet("https://raw.githubusercontent.com/rotm793/Nme/main/key_data.lua"))()
local LoginGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", LoginGui)
MainFrame.Size = UDim2.new(0, 300, 0, 150); MainFrame.Position = UDim2.new(0.5, -150, 0.4, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); MainFrame.Active = true; MainFrame.Draggable = true
local InputBox = Instance.new("TextBox", MainFrame); InputBox.Size = UDim2.new(0, 260, 0, 35); InputBox.Position = UDim2.new(0, 20, 0, 55)
local SubmitBtn = Instance.new("TextButton", MainFrame); SubmitBtn.Size = UDim2.new(0, 260, 0, 35); SubmitBtn.Position = UDim2.new(0, 20, 0, 100)
SubmitBtn.Text = "GİRİŞ YAP"

local loginSuccess = false
SubmitBtn.MouseButton1Click:Connect(function()
    if keyList[InputBox.Text] then loginSuccess = true; LoginGui:Destroy() end
end)
repeat task.wait() until loginSuccess

-- 2. RAYFIELD ENGINE
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "SW HUB | TOTAL IDENTITY", KeySystem = false})
local Tab = Window:CreateTab("Master Sync", 4483362458)

local tName, tId = "", 0
Tab:CreateInput({Name = "İsim:", Callback = function(t) tName = t end})
Tab:CreateInput({Name = "ID:", Callback = function(t) tId = tonumber(t) or 0 end})

Tab:CreateButton({
    Name = "KİLİTLE VE GÖNDER",
    Callback = function()
        local vic = Players:FindFirstChild(tName) or Players:GetPlayers()[1]
        local actualName = Players:GetNameFromUserIdAsync(tId)
        local thumb = "rbxthumb://type=AvatarHeadShot&id=" .. tId .. "&w=150&h=150"

        -- CHAT MANİPÜLASYONU (PC'de çökmemesi için hata korumalı)
        TCS.OnIncomingMessage = function(m)
            local prop = Instance.new("TextChatMessageProperties")
            pcall(function() if m.TextSource.UserId == vic.UserId then prop.PrefixText = "<font color='#FF00FF'>" .. actualName .. "</font>" end end)
            return prop
        end

        -- GUI VE AVATAR TARAMA
        for _, v in pairs(game:GetDescendants()) do
            pcall(function()
                if v:IsA("TextLabel") and v.Text:find(vic.Name) then v.Text = actualName end
                if v:IsA("ImageLabel") and v.Name:lower():find("icon") then v.Image = thumb end
            end)
        end

        -- RENDER STEPPED (İsim Kilidi)
        RS.RenderStepped:Connect(function()
            pcall(function()
                vic.DisplayName = actualName
                vic.Character.Humanoid.DisplayName = actualName
            end)
        end)
    end
})
