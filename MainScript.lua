-- RAYFIELD GUI VE ŞİFRE SİSTEMİ (KEY SYSTEM)

-- 1. GitHub Raw Linki (Kendi GitHub Raw Linkinizle Değiştirin!)
local KEY_URL = "https://raw.githubusercontent.com/KULLANICI_ADI/DEPO_ADI/main/KeySystem.lua"

-- GitHub'dan Anlık Şifreyi Çekme İşlemi
local function getOnlineKey()
    local success, result = pcall(function()
        return game:HttpGet(KEY_URL)
    end)
    
    if success then
        -- Tırnak işaretlerini ve boşlukları temizler
        local cleanKey = result:gsub('"', ''):gsub("'", ""):gsub("%s+", "")
        return cleanKey
    else
        return nil
    end
end

local SERVER_KEY = getOnlineKey()

-- Rayfield GUI Kütüphanesini Yükleme
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Ana Pencere
local Window = Rayfield:CreateWindow({
   Name = "Identity & Profile Spoofer",
   LoadingTitle = "Sistem Yükleniyor...",
   LoadingSubtitle = "Key System Enabled",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true, -- Rayfield Dahili Şifre Sistemini Aktif Etme
   KeySettings = {
      Title = "Giriş Anahtarı (Key)",
      Subtitle = "Şifreyi Giriniz",
      Note = "Şifreyi almak için geliştirici ile iletişime geçin.",
      FileName = "SpooferKeyConfig",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = { SERVER_KEY or "DEFAULT_BACKUP_KEY" } -- GitHub'dan çekilen şifre
   }
})

-- Şifre Başarıyla Girilirse Açılacak Sekme
local Tab = Window:CreateTab("Identity Control", 4483362458)

-- Global Değişkenler
local targetUsername = ""
local newName = ""
local newDisplayName = ""
local newUserId = 0

-- 1. Hedef Oyuncu Seçimi
Tab:CreateInput({
   Name = "Hedef Oyuncu Adı (Target)",
   PlaceholderText = "İsmi değiştirilecek kişinin tam adı...",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      targetUsername = Text
   end,
})

-- 2. Yeni Kullanıcı Adı (Username)
Tab:CreateInput({
   Name = "Yeni Username (İsim)",
   PlaceholderText = "Örn: Builderman",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      newName = Text
   end,
})

-- 3. Yeni Ekran Adı (DisplayName)
Tab:CreateInput({
   Name = "Yeni Display Name",
   PlaceholderText = "Örn: Administrator",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      newDisplayName = Text
   end,
})

-- 4. Yeni Player ID
Tab:CreateInput({
   Name = "Yeni Player ID (Profil & Tab İkonu)",
   PlaceholderText = "Vesikalık avatarın çekileceği ID...",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      newUserId = tonumber(Text) or 0
   end,
})

-- 5. İşlem Butonu
Tab:CreateButton({
   Name = "Kimlik Bilgilerini Uygula",
   Callback = function()
      local Players = game:GetService("Players")
      local targetPlayer = Players:FindFirstChild(targetUsername)

      -- Oyuncu Kontrolü
      if not targetPlayer then
         Rayfield:Notify({
            Title = "Hata",
            Content = "Belirtilen oyuncu sunucuda bulunamadı!",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end

      -- A) Player Nesnesinin Kimlik Verilerini Değiştirme (Name, DisplayName, UserId)
      pcall(function()
         if newName ~= "" then
            targetPlayer.Name = newName
         end
         if newDisplayName ~= "" then
            targetPlayer.DisplayName = newDisplayName
         end
         if newUserId and newUserId > 0 then
            targetPlayer.UserId = newUserId
         end
      end)

      -- B) Karakterin Başının Üzerindeki İsmi (Nametag) Güncelleme
      local character = targetPlayer.Character
      if character and character:FindFirstChild("Humanoid") then
         if newDisplayName ~= "" then
            character.Humanoid.DisplayName = newDisplayName
         elseif newName ~= "" then
            character.Humanoid.DisplayName = newName
         end
      end

      -- C) Custom Tab Listesi / PlayerList UI Taraması ve Metin/Görsel Güncelleme
      for _, gui in ipairs(Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
         if gui:IsA("TextLabel") then
            if targetUsername ~= "" and string.find(gui.Text, targetUsername) then
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
         Content = targetPlayer.Name .. " için isim, DisplayName, UserId ve Tab görselleri güncellendi!",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})
