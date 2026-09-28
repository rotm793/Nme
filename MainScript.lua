-- ============================================================
-- ŞİFRE AYARI (Şifreyi değiştirmek için burayı düzenle)
-- ============================================================
local LOCAL_KEY = "semihinamikokuyo"

-- ============================================================
-- RAYFIELD GUI VE KOD BÜTÜNÜ
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "NME Identity & Profile Spoofer",
   LoadingTitle = "NME System Yükleniyor...",
   LoadingSubtitle = "by rotm793",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true, -- Şifre sistemi aktif
   KeySettings = {
      Title = "NME Key System",
      Subtitle = "Giriş Şifresi Gereklidir",
      Note = "Şifrenizi giriniz.",
      FileName = "NmeKeyConfig",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = { LOCAL_KEY } -- Yukarıdaki şifreyi kullanır
   }
})

local Tab = Window:CreateTab("Identity Changer", 4483362458)

-- Kullanıcı Değişkenleri
local targetUsername = ""
local newName = ""
local newDisplayName = ""
local newUserId = 0

-- Inputs / Girdiler
Tab:CreateInput({
   Name = "Hedef Oyuncu Adı",
   PlaceholderText = "İsmi değiştirilecek oyuncunun tam adı...",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      targetUsername = Text
   end,
})

Tab:CreateInput({
   Name = "Yeni Username (İsim)",
   PlaceholderText = "Örn: Builderman",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      newName = Text
   end,
})

Tab:CreateInput({
   Name = "Yeni Display Name",
   PlaceholderText = "Örn: Administrator",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      newDisplayName = Text
   end,
})

Tab:CreateInput({
   Name = "Yeni Player ID (Tab Vesikalığı)",
   PlaceholderText = "Avatar vesikalığının çekileceği ID...",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      newUserId = tonumber(Text) or 0
   end,
})

-- Buton
Tab:CreateButton({
   Name = "Kimliği Uygula",
   Callback = function()
      local Players = game:GetService("Players")
      local targetPlayer = Players:FindFirstChild(targetUsername)

      if not targetPlayer then
         Rayfield:Notify({
            Title = "Hata",
            Content = "Hedef oyuncu sunucuda bulunamadı!",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end

      -- Player nesnesi kimlik değişimi
      pcall(function()
         if newName ~= "" then targetPlayer.Name = newName end
         if newDisplayName ~= "" then targetPlayer.DisplayName = newDisplayName end
         if newUserId and newUserId > 0 then targetPlayer.UserId = newUserId end
      end)

      -- Nametag değişimi
      local character = targetPlayer.Character
      if character and character:FindFirstChild("Humanoid") then
         if newDisplayName ~= "" then
            character.Humanoid.DisplayName = newDisplayName
         elseif newName ~= "" then
            character.Humanoid.DisplayName = newName
         end
      end

      -- UI ve Tab vesikalık değişimi
      for _, gui in ipairs(Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
         if gui:IsA("TextLabel") and targetUsername ~= "" then
            if string.find(gui.Text, targetUsername) then
               if newDisplayName ~= "" then
                  gui.Text = string.gsub(gui.Text, targetUsername, newDisplayName)
               elseif newName ~= "" then
                  gui.Text = string.gsub(gui.Text, targetUsername, newName)
               end
            end
         elseif gui:IsA("ImageLabel") and (gui.Name:lower():find("avatar") or gui.Name:lower():find("headshot")) then
            if newUserId and newUserId > 0 then
               local content = Players:GetUserThumbnailAsync(newUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
               gui.Image = content
            end
         end
      end

      Rayfield:Notify({
         Title = "Başarılı",
         Content = targetPlayer.Name .. " için veriler güncellendi!",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})
