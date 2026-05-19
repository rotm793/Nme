local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TCS = game:GetService("TextChatService")
local LP = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({Name = "SW HUB | ANTI-CRASH SYNC", KeySystem = false})
local Tab = Window:CreateTab("Master", 4483362458)
local target, id = "", 0

Tab:CreateInput({Name = "İsim:", Callback = function(t) target = t end})
Tab:CreateInput({Name = "ID:", Callback = function(t) id = tonumber(t) or 0 end})

Tab:CreateButton({
    Name = "KİLİTLE",
    Callback = function()
        local vic = Players:FindFirstChild(target)
        if not vic then return end
        local name = Players:GetNameFromUserIdAsync(id)
        local thumb = "rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"

        -- SADECE İSİM DEĞİŞİMİ
        RS.RenderStepped:Connect(function()
            pcall(function()
                vic.DisplayName = name
                vic.Name = name
                vic.Character.Humanoid.DisplayName = name
            end)
        end)

        -- GUI TARAMASINI HAFİFLETTİK (CRASH OLMASIN DİYE)
        task.spawn(function()
            while task.wait(1) do
                for _, v in pairs(LP.PlayerGui:GetDescendants()) do -- SADECE SENİN EKRANIN
                    pcall(function()
                        if v:IsA("TextLabel") and v.Text:find(target) then v.Text = name end
                        if v:IsA("ImageLabel") and v.Name:lower():find("icon") then v.Image = thumb end
                    end)
                end
            end
        end)
    end
})
