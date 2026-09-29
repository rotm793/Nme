-- Rayfield GUI Kütüphanesini Yükleme
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "NME Universal Identity & Avatar Spoofer",
   LoadingTitle = "NME Spoofer Yükleniyor...",
   LoadingSubtitle = "by rotm793",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Identity Spoofer", 4483362458)

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")

local function GetPlayerList()
   local list = {}
   for _, p in ipairs(Players:GetPlayers()) do
      table.insert(list, p.Name)
   end
   return list
end

-- Değişkenler
local selectedTargetName = ""
local manualUsername = ""
local manualDisplayName = ""
local avatarCopyId = ""

-- 1. Oyuncu Seçimi
local PlayerDropdown = Tab:CreateDropdown({
   Name = "Değiştirilecek Oyuncuyu Seç (Sunucudaki)",
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

Tab:CreateButton({
   Name = "🔄 Oyuncu Listesini Yenile",
   Callback = function()
      PlayerDropdown:Refresh(GetPlayerList())
   end,
})

-- 2. Manuel İsim Ayarları
Tab:CreateInput({
   Name = "Manuel Username (İsim)",
   PlaceholderText = "Örn: Builderman",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      manualUsername = Text
   end,
})

Tab:CreateInput({
   Name = "Manuel Display Name (Görünen İsim)",
   PlaceholderText = "Örn: Administrator",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      manualDisplayName = Text
   end,
})

-- 3. Avatar/Eşya ID Ayarı
Tab:CreateInput({
   Name = "Avatar Eşyaları ve Resim İçin Roblox ID",
   PlaceholderText = "Eşyaları ve Vesikalığı Çekilecek ID (Örn: 1)...",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      avatarCopyId = Text
   end,
})

-- Kıyafet ve Aksesuar Kopyalama Fonksiyonu
local function ApplyAvatarAssets(targetCharacter, copyUserId)
   pcall(function()
      -- Mevcut aksesuarları ve kıyafetleri temizle
      for _, item in ipairs(targetCharacter:GetChildren()) do
         if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") then
            item:Destroy()
         end
      end

      -- Roblox API'sinden HumanoidDescription (Tüm Eşyalar & Giysiler) Çek
      local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
      if humanoid then
         local humDesc = Players:GetHumanoidDescriptionFromUserId(copyUserId)
         if humDesc then
            humanoid:ApplyDescription(humDesc)
         end
      end
   end)
end

-- Arayüz / Metin Değiştirici
local function UpdateGUIAndNametag(targetPlayer, newUsername, newDisplayName, avatarUrl)
   local targetName = targetPlayer.Name
   local targetDisplay = targetPlayer.DisplayName

   -- 1. PlayerGui Taraması
   local localPlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
   if localPlayerGui then
      for _, desc in ipairs(localPlayerGui:GetDescendants()) do
         pcall(function()
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
               if desc.Text and (desc.Text == targetName or desc.Text == targetDisplay or string.find(desc.Text, targetName)) then
                  desc.Text = newDisplayName ~= "" and newDisplayName or newUsername
               end
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
               local nameLower = desc.Name:lower()
               if nameLower:find("avatar") or nameLower:find("headshot") or nameLower:find("icon") or nameLower:find("profile") then
                  if avatarUrl and avatarUrl ~= "" then
                     desc.Image = avatarUrl
                  end
               end
            end
         end)
      end
   end

   -- 2. Workspace (Karakter Nametag'i) Taraması
   if targetPlayer.Character then
      local char = targetPlayer.Character
      local hum = char:FindFirstChildOfClass("Humanoid")
      if hum then
         hum.DisplayName = newDisplayName ~= "" and newDisplayName or newUsername
      end

      for _, desc in ipairs(char:GetDescendants()) do
         pcall(function()
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
               if desc.Text and (desc.Text == targetName or desc.Text == targetDisplay or string.find(desc.Text, targetName)) then
                  desc.Text = newDisplayName ~= "" and newDisplayName or newUsername
               end
            end
         end)
      end
   end
end

-- 4. Çalıştırma Butonu
Tab:CreateButton({
   Name = "⚡ Kimliği ve Avatar Eşyalarını Uygula",
   Callback = function()
      if selectedTargetName == "" then
         Rayfield:Notify({ Title = "Hata", Content = "Lütfen listeden bir oyuncu seçin!", Duration = 3 })
         return
      end

      local targetPlayer = Players:FindFirstChild(selectedTargetName)
      if not targetPlayer then
         Rayfield:Notify({ Title = "Hata", Content = "Hedef oyuncu sunucuda bulunamadı!", Duration = 3 })
         return
      end

      local copyId = tonumber(avatarCopyId)
      
      -- 1. Temel Oyun İçi Kullanıcı Özelliklerini Güncelle
      pcall(function()
         if manualUsername ~= "" then targetPlayer.Name = manualUsername end
         if manualDisplayName ~= "" then targetPlayer.DisplayName = manualDisplayName end
         if copyId then targetPlayer.UserId = copyId end
      end)

      -- 2. Vesikalık Resmini Al
      local avatarIcon = ""
      if copyId then
         pcall(function()
            avatarIcon = Players:GetUserThumbnailAsync(copyId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
         end)
      end

      -- 3. Karakterin Kıyafetlerini, Saç/Aksesuarlarını (Avatar Items) Kopyala
      if copyId and targetPlayer.Character then
         ApplyAvatarAssets(targetPlayer.Character, copyId)
      end

      -- 4. Arayüzlerdeki Metinleri ve Avatar Görsellerini Değiştir
      UpdateGUIAndNametag(targetPlayer, manualUsername, manualDisplayName, avatarIcon)

      Rayfield:Notify({
         Title = "Başarılı",
         Content = selectedTargetName .. " için Kimlik ve Avatar Eşyaları Yüklendi!",
         Duration = 4
      })
   end,
})
