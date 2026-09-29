-- ============================================================
-- ŞİFRE AYARI
-- ============================================================
local LOCAL_KEY = "semihinamikokuyo"

-- ============================================================
-- RAYFIELD GUI VE KOD BÜTÜNÜ
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "NME Identity & Inventory Spoofer",
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

local Tab = Window:CreateTab("Full Spoofer", 4483362458)

local Players = game:GetService("Players")

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

-- Oyuncu Listesini Yenileme
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
   PlaceholderText = "Örn: 1 (Builderman)...",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      targetIdToCopy = Text
   end,
})

-- Derin UI ve Nesne Tarayıcı Fonksiyon
local function ScanAndReplace(parent, targetName, newName, avatarUrl)
   for _, obj in ipairs(parent:GetDescendants()) do
      -- Text / Item / Name Etiketlerini Değiştirme
      if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
         if obj.Text and string.find(obj.Text, targetName) then
            obj.Text = string.gsub(obj.Text, targetName, newName)
         end
      end

      -- Tab Listesi & Envanter Item Görsellerini Değiştirme
      if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
         local objName = obj.Name:lower()
         if objName:find("avatar") or objName:find("headshot") or objName:find("icon") or objName:find("profile") or objName:find("player") or objName:find("portrait") then
            if avatarUrl and avatarUrl ~= "" then
               pcall(function()
                  obj.Image = avatarUrl
               end)
            end
         end
      end

      -- Custom Tab / Envanter Tooltip veya Attribute İçerikleri
      pcall(function()
         if obj:GetAttribute("Owner") and tostring(obj:GetAttribute("Owner")) == targetName then
            obj:SetAttribute("Owner", newName)
         end
         if obj:GetAttribute("PlayerName") and tostring(obj:GetAttribute("PlayerName")) == targetName then
            obj:SetAttribute("PlayerName", newName)
         end
      end)
   end
end

-- 3. Derin Uygulama Butonu
Tab:CreateButton({
   Name = "⚡ Derin Kimlik & Item/Tab Değişimi Yap",
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

      -- Roblox API'sinden Bilgi Çekme
      local fetchedUsername = ""
      local fetchedDisplayName = ""
      
      pcall(function()
         fetchedUsername = Players:GetNameFromUserIdAsync(targetId)
         local pObj = Players:GetPlayerByUserId(targetId)
         if pObj then
            fetchedDisplayName = pObj.DisplayName
         else
            fetchedDisplayName = fetchedUsername
         end
      end)

      if fetchedUsername == "" then
         Rayfield:Notify({
            Title = "Hata",
            Content = "ID bilgisi alınamadı!",
            Duration = 3,
            Image = 4483362458,
         })
         return
      end

      -- Vesikalık Görseli Alma
      local avatarIcon = ""
      pcall(function()
         avatarIcon = Players:GetUserThumbnailAsync(targetId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
      end)

      -- 1. Oyuncu Arayüzünü (PlayerGui) Derinlemesine Tara (Tab ve Envanter Dahil)
      local localPlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
      if localPlayerGui then
         ScanAndReplace(localPlayerGui, selectedTargetName, fetchedDisplayName, avatarIcon)
      end

      -- 2. Varsayılan Roblox CoreGui (Varsayılan Tab Menüsü) Tara
      pcall(function()
         local coreGui = game:GetService("CoreGui")
         ScanAndReplace(coreGui, selectedTargetName, fetchedDisplayName, avatarIcon)
      end)

      -- 3. Harita / Workspace (3D Karakterler, Itemlar, Nametagler) Tara
      ScanAndReplace(game.Workspace, selectedTargetName, fetchedDisplayName, avatarIcon)

      Rayfield:Notify({
         Title = "Başarılı!",
         Content = selectedTargetName .. " için Tab, Arayüz ve Envanter öğeleri güncellendi!",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})
