local KeySistemi = {
    -- ["Oluşturduğun_Şifre"] = Yetki_Durumu (true = şifre üretebilir, false = sadece scripti kullanabilir)
    
    ["flopsu12"] = true,       -- Bu senin ana (Owner) şifren. Şifre üretme yetkisi var.
    ["misafir34"] = false,     -- Bu sadece scripti kullanabilir, şifre üretemez.
    ["kanka77"] = true,        -- Bu arkadaşın hem scripti kullanır hem de yeni şifre üretebilir.
}

return KeySistemi
