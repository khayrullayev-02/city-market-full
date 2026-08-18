# City Market 🛒

Oziq-ovqat va uy-ro'zg'or buyumlari uchun e-commerce ilovasi (MVP).
**Flutter** (Android + iOS + Web) + **Supabase** backend.

---

## Tuzilma

```
city_market/
├─ lib/
│  ├─ main.dart                 # kirish nuqtasi
│  ├─ app.dart                  # MaterialApp + RootGate
│  ├─ core/
│  │  ├─ theme/app_theme.dart   # yashil + to'q sariq
│  │  ├─ l10n/strings.dart      # UZ / RU / EN
│  │  └─ utils.dart
│  ├─ models/models.dart        # Product, Order, Category...
│  ├─ data/
│  │  ├─ repository.dart        # interfeys
│  │  ├─ mock_repository.dart   # demo rejim (Supabase'siz ishlaydi)
│  │  └─ supabase_repository.dart
│  ├─ state/app_state.dart      # markaziy holat (Provider)
│  ├─ widgets/widgets.dart
│  ├─ features/                 # xaridor ilovasi
│  │  ├─ auth/ home/ catalog/ product/ cart/ checkout/ orders/ profile/
│  └─ admin/                    # admin panel (web'da ham ishlaydi)
└─ supabase/migrations/         # SQL sxema + seed
```

## Ishlatish xususiyatlari

- **Xaridor**: kirish (SMS demo), bosh sahifa (banner/kategoriya/aksiya), katalog + qidiruv + filtr, mahsulot sahifasi (rasm, video, xususiyatlar), savat, buyurtma (manzil/vaqt/naqd), buyurtmalar + status kuzatuvi, profil (manzillar, sevimlilar, til).
- **Admin** (Profil → Admin panel): dashboard, mahsulot CRUD — **to'liq forma** (bir nechta rasm, video, SKU, brend, o'lchov birligi, qoldiq, min qoldiq, davlat, ishlab chiqaruvchi, vazn, teglar, 3 tilda nom/tavsif), buyurtma statusini o'zgartirish, mijozlar.
- **3 til**: O'zbekcha / Русский / English.

---

## 1. Ishga tushirish (demo rejim, Supabase'siz)

Flutter SDK o'rnatilgan bo'lishi kerak ([flutter.dev](https://docs.flutter.dev/get-started/install)).

```bash
cd city_market
flutter pub get
flutter run          # Android/iOS emulyator yoki ulangan qurilma
```

Supabase ma'lumotlari berilmagani uchun ilova **avtomatik demo (Mock) rejimda** ishlaydi —
barcha ekranlar to'liq ishlaydi, ma'lumotlar xotirada saqlanadi.

## 2. Supabase'ga ulash

1. [supabase.com](https://supabase.com) da yangi loyiha yarating.
2. **SQL Editor** da `supabase/migrations/001_init.sql` va `002_seed.sql` ni bajarib chiqing.
3. **Authentication → Providers → Phone** ni yoqing (SMS OTP uchun).
4. **Storage** da `products` bucket yaratilganini tekshiring.
5. Ilovani loyiha kalitlari bilan ishga tushiring:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

Kalitlar: **Project Settings → API** sahifasida.

## 3. Admin panelga kirish

Ilovada: **Profil → Admin panel**.
- Email: `admin@citymarket.uz`
- Parol: `admin123`

(MVP'da admin login demo holatda; keyinchalik Supabase Auth + `is_admin` ustuni bilan
haqiqiy ruxsat tekshiruviga o'tkaziladi.)

## 4. Web (admin panel brauzerda)

```bash
flutter run -d chrome
```

Admin panel responsiv — tor ekranda ixcham menyu, keng ekranda to'liq yon panel.

## 5. Push-bildirishnomalar

- **Buyurtma statusi**: `orders` jadvali `supabase_realtime` publication'ga qo'shilgan —
  ilovada `client.from('orders').stream()` bilan jonli kuzatiladi.
- **Aksiyalar**: keyingi bosqichda FCM topics orqali.

## 6. Payme / Click (keyingi bosqich)

`payment_method` ustuni allaqachon `payme | click` qiymatlarini qabul qiladi.
`repository.dart` da `PaymentProvider` interfeysi qo'shilib, Supabase Edge Functions
orqali webhook qabul qilinadi — arxitektura tayyor.

## Muhim paketlar

| Paket | Vazifasi |
|---|---|
| `provider` | holat boshqaruvi |
| `supabase_flutter` | backend |
| `video_player` | mahsulot videosi |
| `image_picker` | admin'da rasm yuklash |
| `shared_preferences` | tilni eslab qolish |
