# City Market 🛒

Oziq-ovqat va uy-ro'zg'or buyumlari uchun e-commerce ilova (MVP).
**Flutter** (Android + iOS + Web) + **Supabase** backend · 3 til (O'zbekcha / Русский / English).

> Loyihaning batafsil rejasi va bosqichlari: [`ROADMAP.md`](ROADMAP.md)

## Tarkib

| Papka | Tavsif |
|---|---|
| [`city_market/`](city_market/) | Flutter loyihasi — xaridor ilovasi + admin panel (bitta kod bazasi) |
| [`city-market-prototype/`](city-market-prototype/) | Brauzerda bosib ko'rish mumkin bo'lgan interaktiv prototip (bir fayl HTML) |
| `ROADMAP.md` | Texnik arxitektura, DB sxemasi, bosqichlar |

## Asosiy imkoniyatlar

**Xaridor ilovasi**
- Kirish — telefon + SMS OTP (demo rejim)
- Bosh sahifa — aksiya bannerlari, kategoriyalar, tavsiyalar
- Katalog — qidiruv, filtr (narx/brend/mavjudlik), saralash
- Mahsulot sahifasi — rasm, video, narx, o'lchov birligi, tavsif, mavjudlik
- Savat va buyurtma — manzil, vaqt tanlash, naqd to'lov (Payme/Click keyin)
- Buyurtmalar tarixi + status kuzatuvi (qabul qilindi → tayyorlanmoqda → yo'lda → yetkazildi)
- Profil — manzillar, sevimlilar, til, bildirishnomalar

**Admin panel** (Flutter Web)
- Statistika dashboard (kunlik/oylik savdo)
- Mahsulot qo'shish/tahrirlash/o'chirish — **to'liq forma**: bir nechta rasm, video, SKU/shtrix-kod, brend, o'lchov birligi, qoldiq + min qoldiq, ishlab chiqarilgan davlat, ishlab chiqaruvchi, vazn, teglar, 3 tilda nom/tavsif
- Buyurtmalarni ko'rish + status o'zgartirish
- Mijozlar ro'yxati

## Ishga tushirish

```bash
# Flutter ilovasi (demo rejim — Supabase'siz darhol ishlaydi)
cd city_market
flutter pub get
flutter run

# Supabase'ga ulash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

Batafsil sozlash: [`city_market/README.md`](city_market/README.md) va `supabase/migrations/` SQL fayllari.

**Admin panelga kirish** (ilovada Profil → Admin panel):
- Email: `admin@citymarket.uz`
- Parol: `admin123`

## Texnologiyalar

Flutter · Provider · Supabase (Auth + PostgreSQL + Storage + Realtime) · video_player · image_picker
