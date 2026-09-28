-- ============================================================
-- ŞİFRE AYARI
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
   KeySystem = true,
   KeySettings = {
      Title = "NME Key System",
      Subtitle = "Giriş Şifresi Gereklidir",
      Note = "Şifrenizi giriniz.",
      FileName = "NmeKeyConfig",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = { LOCAL_KEY }
   }
})

local Tab = Window:CreateTab("Player Spoofer", 4483362458)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Sunucudaki oyuncuların listesini alma
local function GetPlayerList()
   local list = {}
   for _, p in ipairs(Players:GetPlayers()) do
      table.insert(list, p.Name)
   end
   return list
end

local selectedTargetName = ""
local targetIdToCopy = ""

-- 1. Oyuncu Seçme Listesi (Dropdown)
local PlayerDropdown = Tab:CreateDropdown({
   Name = "Değiştirilecek Oyuncuyu Seç",
   Options = GetPlayerList(),
   CurrentOption = "",
   MultipleOptions = false,
   Flag = "TargetPlayerDropdown",
   Callback = function(Option)
      if type(Option) == "table" then
         selectedTargetName = Option[1] or ""
      else
         selectedTargetName = Option or ""
      end
   end,
})

-- Oyuncu Listesini Yenileme Butonu (Biri girip çıktığında)
Tab:CreateButton({
   Name = "🔄 Oyuncu Listesini Yenile",
   Callback = function()
      PlayerDropdown:Refresh(GetPlayerList())
      Rayfield:Notify({
         Title = "Yenilendi",
         Content = "Sunucudaki oyuncu listesi güncellendi.",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 2. Kopyalanacak ID Girdisi
Tab:CreateInput({
   Name = "Dönüştürülecek Roblox ID",
   PlaceholderText = "Örn: 1 (Builderman) veya kendi ID'niz...",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      targetIdToCopy = Text
   end,
})

-- 3. Uygulama Butonu
Tab:CreateButton({
   Name = "⚡ Her Şeyi Kopyala ve Uygula",
   Callback = function()
      if selectedTargetName == "" then
         Rayfield:Notify({
            Title = "Hata",
            Content = "Lütfen listeden bir oyuncu seçin!",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end

      local targetId = tonumber(targetIdToCopy)
      if not targetId then
         Rayfield:Notify({
            Title = "Hata",
            Content = "Geçerli bir Roblox ID'si girin!",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end

      -- Roblox API'sinden Kullanıcı Bilgilerini Çekme
      local fetchedUsername = ""
      local fetchedDisplayName = ""
      
      local successInfo, err = pcall(function()
         local userInfo = Players:GetNameFromUserIdAsync(targetId)
         fetchedUsername = userInfo
         -- Display Name çekmek için kullanıcı detayları
         local playerObj = Players:GetPlayerByUserId(targetId)
         if playerObj then
            fetchedDisplayName = playerObj.DisplayName
         else
            fetchedDisplayName = userInfo
         end
      end)

      if not successInfo or fetchedUsername == "" then
         Rayfield:Notify({
            Title = "Hata",
            Content = "Bu ID'ye ait kullanıcı bilgileri alınamadı!",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end

      -- Thumbnail (Avatar Vesikalığı) Alma
      local avatarIcon = ""
      pcall(function()
         avatarIcon = Players:GetUserThumbnailAsync(targetId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
      end)

      local replaceCount = 0

      -- 1. EKRAN ARAYÜZLERİNİ (PlayerGui / Tab / Leaderboard) DEĞİŞTİR
      local localPlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
      if localPlayerGui then
         for _, guiObj in ipairs(localPlayerGui:GetDescendants()) do
            -- Yazıları Değiştir
            if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") then
               if string.find(guiObj.Text, selectedTargetName) then
                  guiObj.Text = string.gsub(guiObj.Text, selectedTargetName, fetchedDisplayName)
                  replaceCount = replaceCount + 1
               end
            end
            -- Avatarları/Resimleri Değiştir
            if guiObj:IsA("ImageLabel") or guiObj:IsA("ImageButton") then
               local nameLower = guiObj.Name:lower()
               if nameLower:find("avatar") or nameLower:find("headshot") or nameLower:find("icon") or nameLower:find("player") then
                  if avatarIcon ~= "" then
                     guiObj.Image = avatarIcon
                  end
               end
            end
         end
      end

      -- 2. KARAKTER ÜSTÜNDEKİ YAZILARI (Nametag / BillboardGui) DEĞİŞTİR (Bewitched vb. oyunlar dahil)
      for _, worldObj in ipairs(game.Workspace:GetDescendants()) do
         if worldObj:IsA("TextLabel") or worldObj:IsA("TextButton") then
            if string.find(worldObj.Text, selectedTargetName) then
               worldObj.Text = string.gsub(worldObj.Text, selectedTargetName, fetchedDisplayName)
               replaceCount = replaceCount + 1
            end
         end
      end

      Rayfield:Notify({
         Title = "İşlem Başarılı!",
         Content = selectedTargetName .. " artık " .. fetchedDisplayName .. " (" .. fetchedUsername .. ") yapıldı!",
         Duration = 5,
         Image = 4483362458,
      })
   end,
})
