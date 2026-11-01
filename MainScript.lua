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
local CoreGui = game:GetService("CoreGui")

local function GetPlayerList()
   local list = {}
   for _, p in ipairs(Players:GetPlayers()) do
      table.insert(list, p.Name)
   end
   return list
end

-- Değişkenler
local selectedTargetName = ""
local selectedTargetPlayer = nil
local manualUsername = ""
local manualDisplayName = ""
local avatarCopyId = ""
local manualKills = ""

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
      selectedTargetPlayer = Players:FindFirstChild(selectedTargetName)
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

-- 4. Kill Sayısı (isteğe bağlı, boş bırakırsan dokunmaz)
Tab:CreateInput({
   Name = "Manuel Kill Sayısı (İsteğe Bağlı)",
   PlaceholderText = "Örn: 50 (boş bırakırsan değişmez)",
   RemoveTextOnFocusLost = false,
   Callback = function(Text)
      manualKills = Text
   end,
})

-- Kıyafet ve Aksesuar Kopyalama Fonksiyonu
local function ApplyAvatarAssets(targetCharacter, copyUserId)
   pcall(function()
      for _, item in ipairs(targetCharacter:GetChildren()) do
         if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") then
            item:Destroy()
         end
      end

      local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
      if humanoid then
         local humDesc = Players:GetHumanoidDescriptionFromUserId(copyUserId)
         if humDesc then
            humanoid:ApplyDescription(humDesc)
         end
      end
   end)
end

-- ============================================================
-- Yardımcı fonksiyonlar
-- ============================================================
local spoofs = {} -- [player] = bilgiler

local function trim(s)
   return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function plainReplace(str, old, new)
   if old == "" then return str end
   local i, j = str:find(old, 1, true)
   if i then
      return str:sub(1, i - 1) .. new .. str:sub(j + 1)
   end
   return str
end

-- Yazıyı "kilitler": oyun yazıyı geri değiştirirse anında tekrar bizimkini yazar
local tracked = setmetatable({}, { __mode = "k" })   -- [label] = istenen yazı
local origText = setmetatable({}, { __mode = "k" })  -- [label] = eski yazı
local conns = {}                                      -- [label] = bağlantı

local function Track(label, newText)
   if origText[label] == nil then origText[label] = label.Text end
   tracked[label] = newText
   if not conns[label] then
      conns[label] = label:GetPropertyChangedSignal("Text"):Connect(function()
         local want = tracked[label]
         if want and label.Text ~= want then
            label.Text = want
         end
      end)
   end
   label.Text = newText
end

-- Bir label'ın hangi oyuncu satırında (PlayerEntry_<UserId>) olduğunu bulur
local function EntryUserId(d, root)
   local p = d.Parent
   while p and p ~= root do
      local id = p.Name:match("^PlayerEntry_(%d+)$")
      if id then return tonumber(id) end
      p = p.Parent
   end
   return nil
end

-- Bir yazının yeni halini döndürür (değişmesi gerekmiyorsa nil)
local function Match(s, d, root)
   local t = d.Text
   local tr = trim(t)
   if tr == "" then return nil end
   if tracked[d] == t then return nil end
   local tl = tr:lower()

   local eid = EntryUserId(d, root)
   local isRow = eid and (eid == s.oldId or eid == s.newId)

   if isRow then
      local nl = d.Name:lower()
      if nl:find("name") and not nl:find("team") and t ~= s.newDisplay then
         return s.newDisplay
      end
      if s.newKills and tr:match("^%d[%d,]*$") and tr ~= tostring(s.newKills) then
         return tostring(s.newKills)
      end
   end

   if (s.oldDisplay ~= "" and tr == s.oldDisplay) or tr == s.oldName
      or (s.copyDisplay and tl == s.copyDisplay:lower()) then
      if t ~= s.newDisplay then return s.newDisplay end
   elseif tr == "@" .. s.oldName then
      return "@" .. s.newName
   elseif s.oldName ~= "" and t:find(s.oldName, 1, true) and not t:find(s.newName, 1, true) then
      return plainReplace(t, s.oldName, s.newName)
   end
   return nil
end

local function ScanRoot(root)
   for _, d in ipairs(root:GetDescendants()) do
      pcall(function()
         if d:IsA("TextLabel") or d:IsA("TextButton") then
            for _, s in pairs(spoofs) do
               local nt = Match(s, d, root)
               if nt then
                  Track(d, nt)
                  break
               end
            end
         elseif (d:IsA("ImageLabel") or d:IsA("ImageButton")) then
            for _, s in pairs(spoofs) do
               if s.newId then
                  local img = d.Image
                  if img:find("id=" .. s.oldId, 1, true) then
                     d.Image = plainReplace(img, "id=" .. s.oldId, "id=" .. s.newId)
                  end
               end
            end
         end
      end)
   end
end

-- Dünyadaki tüm BillboardGui / SurfaceGui (karakter üstü isimler) taraması
local function ScanWorld()
   for _, d in ipairs(workspace:GetDescendants()) do
      if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
         ScanRoot(d)
      end
   end
end

-- Kill sayısı: oyuncunun içindeki "kill" adlı değerleri ve attribute'ları kilitler
local killConns = {}
local killOrig = setmetatable({}, { __mode = "k" })

local function EnforceKills(plr, s)
   if not s.newKills then return end
   for _, v in ipairs(plr:GetDescendants()) do
      if v:IsA("ValueBase") and v.Name:lower():find("kill") then
         if killOrig[v] == nil then killOrig[v] = v.Value end
         if v.Value ~= s.newKills then
            pcall(function() v.Value = s.newKills end)
         end
         if not killConns[v] then
            killConns[v] = v.Changed:Connect(function()
               local cur = spoofs[plr]
               if cur and cur.newKills and v.Value ~= cur.newKills then
                  pcall(function() v.Value = cur.newKills end)
               end
            end)
         end
      end
   end
   for k, val in pairs(plr:GetAttributes()) do
      if tostring(k):lower():find("kill") and val ~= s.newKills then
         pcall(function() plr:SetAttribute(k, s.newKills) end)
      end
   end
end

local loopStarted = false
local function StartSpoofLoop()
   if loopStarted then return end
   loopStarted = true
   task.spawn(function()
      local lastWorld = 0
      while true do
         pcall(function()
            local lp = Players.LocalPlayer
            if lp and lp:FindFirstChild("PlayerGui") then
               ScanRoot(lp.PlayerGui)
            end
            local plist = CoreGui:FindFirstChild("PlayerList")
            if plist then
               ScanRoot(plist)
            end
            for plr, s in pairs(spoofs) do
               if plr and plr.Parent then
                  if plr.Character then ScanRoot(plr.Character) end
                  EnforceKills(plr, s)
               end
            end
            if os.clock() - lastWorld > 1 then
               lastWorld = os.clock()
               ScanWorld()
            end
         end)
         task.wait(0.25)
      end
   end)
end

-- ============================================================
-- Çalıştırma Butonu
-- ============================================================
Tab:CreateButton({
   Name = "⚡ Kimliği ve Avatar Eşyalarını Uygula",
   Callback = function()
      if selectedTargetName == "" then
         Rayfield:Notify({ Title = "Hata", Content = "Lütfen listeden bir oyuncu seçin!", Duration = 3 })
         return
      end

      local targetPlayer = selectedTargetPlayer
      if not targetPlayer or not targetPlayer.Parent then
         targetPlayer = Players:FindFirstChild(selectedTargetName)
      end
      if not targetPlayer then
         Rayfield:Notify({ Title = "Hata", Content = "Hedef oyuncu sunucuda bulunamadı!", Duration = 3 })
         return
      end

      local copyId = tonumber(avatarCopyId)

      -- Eski değerler (daha önce uygulandıysa ilk kayıttaki orijinalleri kullan)
      local prev = spoofs[targetPlayer]
      local oldName = prev and prev.oldName or targetPlayer.Name
      local oldDisplay = prev and prev.oldDisplay or targetPlayer.DisplayName
      local oldId = prev and prev.oldId or targetPlayer.UserId

      -- ID girilen kişinin gerçek Roblox adını ve display adını çek
      local copyName, copyDisplay = nil, nil
      if copyId then
         pcall(function()
            local info = game:GetService("UserService"):GetUserInfosByUserIdsAsync({copyId})
            if info and info[1] then
               copyName = info[1].Username
               copyDisplay = info[1].DisplayName
            end
         end)
         if not copyName or not copyDisplay then
            pcall(function()
               local raw = game:HttpGet("https://users.roblox.com/v1/users/" .. copyId)
               local data = game:GetService("HttpService"):JSONDecode(raw)
               copyName = copyName or data.name
               copyDisplay = copyDisplay or data.displayName
            end)
         end
         if not copyName then
            pcall(function()
               copyName = Players:GetNameFromUserIdAsync(copyId)
            end)
         end
      end

      -- Ana isim: elle yazılan username > ID sahibinin gerçek adı > eski ad
      local newName = manualUsername ~= "" and manualUsername or copyName or oldName
      -- Görünen isim: elle yazılan display > ID sahibinin gerçek Roblox adı
      local newDisplay = manualDisplayName ~= "" and manualDisplayName or newName
      local newKills = tonumber(manualKills)

      spoofs[targetPlayer] = {
         oldName = oldName, oldDisplay = oldDisplay, oldId = oldId,
         copyName = copyName, copyDisplay = copyDisplay,
         newName = newName, newDisplay = newDisplay, newId = copyId,
         newKills = newKills
      }

      -- 1. Temel Oyun İçi Kullanıcı Özelliklerini Güncelle
      pcall(function() targetPlayer.DisplayName = newDisplay end)
      pcall(function() if manualUsername ~= "" then targetPlayer.Name = manualUsername end end)
      pcall(function() if copyId then targetPlayer.UserId = copyId end end)

      -- 2. Karakterin Kıyafetlerini, Saç/Aksesuarlarını (Avatar Items) Kopyala
      if copyId and targetPlayer.Character then
         ApplyAvatarAssets(targetPlayer.Character, copyId)
      end

      -- 3. Karakter üstündeki nametag (Humanoid)
      pcall(function()
         local hum = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
         if hum then hum.DisplayName = newDisplay end
      end)

      -- 4. Leaderboard, isim etiketleri ve kill sayısı için sürekli döngüyü başlat
      StartSpoofLoop()

      Rayfield:Notify({
         Title = "Başarılı",
         Content = selectedTargetName .. " için uygulandı! Bulunan ad: " .. tostring(copyName)
            .. " | display: " .. tostring(copyDisplay)
            .. (newKills and (" | kill: " .. newKills) or ""),
         Duration = 5
      })
   end,
})

-- ============================================================
-- Sıfırla Butonu
-- ============================================================
Tab:CreateButton({
   Name = "♻️ Her Şeyi Sıfırla",
   Callback = function()
      spoofs = {}
      for label, c in pairs(conns) do
         pcall(function() c:Disconnect() end)
      end
      for label, old in pairs(origText) do
         pcall(function() label.Text = old end)
      end
      tracked = setmetatable({}, { __mode = "k" })
      origText = setmetatable({}, { __mode = "k" })
      conns = {}
      for v, c in pairs(killConns) do
         pcall(function() c:Disconnect() end)
         pcall(function() if killOrig[v] ~= nil then v.Value = killOrig[v] end end)
      end
      killConns = {}
      Rayfield:Notify({ Title = "Sıfırlandı", Content = "Yazılar ve kill sayısı eski haline döndürüldü.", Duration = 3 })
   end,
})

-- ============================================================
-- Debug Butonu: sonucu panoya kopyalar, bana yapıştırabilirsin
-- ============================================================
Tab:CreateButton({
   Name = "🔍 Debug Bilgisini Kopyala",
   Callback = function()
      local lines = {}
      local function add(x) table.insert(lines, tostring(x)) end

      local target = selectedTargetPlayer
      local s
      for p, info in pairs(spoofs) do target = target or p; if p == target then s = info end end
      if not target then
         Rayfield:Notify({ Title = "Hata", Content = "Önce bir oyuncu seç.", Duration = 3 })
         return
      end

      local names = {}
      local function addName(v) if v ~= nil and tostring(v) ~= "" then names[tostring(v)] = true end end
      addName(selectedTargetName); addName(target.Name); addName(target.DisplayName)
      if s then
         addName(s.oldName); addName(s.oldDisplay); addName(s.newName); addName(s.newDisplay)
         addName(s.copyName); addName(s.copyDisplay); addName(s.newKills)
      end

      add("== OYUNCU ==")
      add("Name=" .. target.Name .. " Display=" .. target.DisplayName .. " UserId=" .. target.UserId)
      for _, v in ipairs(target:GetDescendants()) do
         if v:IsA("ValueBase") then
            add(v:GetFullName() .. " = " .. tostring(v.Value))
            if v.Name:lower():find("kill") then addName(v.Value) end
         end
      end
      for k, v in pairs(target:GetAttributes()) do add("Attribute " .. tostring(k) .. " = " .. tostring(v)) end

      add("== CoreGui çocukları ==")
      for _, c in ipairs(CoreGui:GetChildren()) do add(c.Name .. " (" .. c.ClassName .. ")") end

      add("== EŞLEŞEN YAZILAR ==")
      local count = 0
      local function scan(root)
         for _, d in ipairs(root:GetDescendants()) do
            if count > 80 then return end
            if d:IsA("TextLabel") or d:IsA("TextButton") then
               if names[trim(d.Text)] then
                  count += 1
                  add(d:GetFullName() .. " | " .. d.ClassName .. " | '" .. d.Text .. "'")
               end
            end
         end
      end
      pcall(scan, workspace)
      pcall(scan, CoreGui)
      pcall(function() scan(Players.LocalPlayer.PlayerGui) end)

      local out = table.concat(lines, "\n")
      local ok = pcall(function() setclipboard(out) end)
      print(out)
      Rayfield:Notify({
         Title = "Debug",
         Content = ok and "Panoya kopyalandı, bana yapıştır." or "Panoya kopyalanamadı, F9 konsoluna yazdırıldı.",
         Duration = 4
      })
   end,
})
