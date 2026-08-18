# City Market — E-commerce MVP

**Oziq-ovqat va uy-ro'zg'or buyumlari do'koni uchun mobil ilova + admin panel**

| | |
|---|---|
| Platforma | Flutter (Android + iOS, bitta kod bazasi) |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) |
| Admin panel | Flutter Web (bitta loyiha) |
| Tillar | O'zbekcha / Русский / English |
| To'lov | Hozir: naqd (yetkazishda) · Keyin: Payme / Click |
| Bosqich | MVP |

---

## 1. Hozirgacha bajarildi ✅

`city-market-prototype/index.html` — brauzerda bosib ko'rish mumkin bo'lgan **interaktiv prototip**:

- Xaridor ilovasi (telefon ramkasida): kirish (SMS demo), bosh sahifa, katalog + filtr/saralash, qidiruv, mahsulot sahifasi, savat, buyurtma (manzil/vaqt/to'lov), status kuzatuvi, buyurtmalar tarixi, profil (manzillar, sevimlilar, til, bildirishnomalar)
- Admin panel (veb): statistika dashboard, mahsulot CRUD, buyurtma statusini o'zgartirish, mijozlar ro'yxati
- 3 til (UZ/RU/EN) bir bosishda almashtiriladi

---

## 2. Texnologik arxitektura

```
┌─────────────────┐        ┌──────────────────────┐
│  Flutter ilova   │  ◄──►  │       Supabase        │
│  (xaridor)       │  REST/ │  Auth (SMS OTP)       │
│                  │  Realtime │  PostgreSQL         │
├─────────────────┤        │  Storage (rasmlar)   │
│  Flutter Web     │  ◄──►  │  Realtime (status)   │
│  (admin panel)   │        │  Edge Functions       │
└─────────────────┘        └──────────────────────┘
         │
         ▼
   FCM (push-bildirishnomalar)
```

### Nega Supabase?
- Relational ma'lumotlar (buyurtma ↔ mahsulotlar) SQL'da qulay
- O'rnatilgan Auth (telefon + SMS OTP) va Storage
- Realtime — buyurtma statusi mijozga darhol ko'rinadi
- Kelajakda Payme/Click webhook'larini Edge Functions orqali bog'lash oson

---

## 3. Supabase ma'lumotlar bazasi sxemasi (SQL)

```sql
-- 1. Profillar (auth.users bilan bog'lanadi)
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  phone text unique not null,
  full_name text,
  created_at timestamptz default now()
);

-- 2. Kategoriyalar
create table categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,        -- sut, non, ichimlik...
  name_uz text, name_ru text, name_en text,
  emoji text, "order" int default 0,
  is_household boolean default false -- oziq-ovqat / uy-ro'zg'or
);

-- 3. Mahsulotlar
create table products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references categories,
  name_uz text, name_ru text, name_en text,
  description_uz text, description_ru text, description_en text,
  price numeric(12,2) not null,
  old_price numeric(12,2),           -- aksiya uchun
  unit text not null,                -- kg / dona / litr
  unit_value numeric,                -- 1, 0.5, 10...
  brand text,
  image_url text,                    -- Storage
  stock int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- 4. Manzillar
create table addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles on delete cascade,
  label text,                        -- home/work/other
  city text, address text,
  is_default boolean default false
);

-- 5. Sevimlilar
create table favorites (
  user_id uuid references profiles on delete cascade,
  product_id uuid references products on delete cascade,
  primary key (user_id, product_id)
);

-- 6. Buyurtmalar
create table orders (
  id uuid primary key default gen_random_uuid(),
  number text unique,                -- CM-1042
  user_id uuid references profiles,
  address_text text,
  delivery_slot text,
  payment_method text default 'cash',-- cash | payme | click
  payment_status text default 'pending',
  subtotal numeric, delivery_fee numeric, total numeric,
  status text default 'accepted',    -- accepted|preparing|onway|delivered|cancelled
  created_at timestamptz default now()
);

-- 7. Buyurtma qatorlari
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders on delete cascade,
  product_id uuid references products,
  name text, price numeric, qty int
);
```

> `status` ustuni o'zgarganda Realtime orqali mijoz ilovasiga avtomatik push keladi.

---

## 4. Flutter loyiha tuzilishi

```
city_market/
├─ lib/
│  ├─ main.dart
│  ├─ app.dart                     # router, tema, localizatsiya
│  ├─ core/
│  │  ├─ theme/                    # yashil + to'q sariq ranglar
│  │  ├─ l10n/ (uz, ru, en)        # ARB fayllar / easy_localization
│  │  ├─ utils/                    # format, validatsiya
│  │  └─ router/                   # go_router
│  ├─ data/
│  │  ├─ models/                   # Product, Order, Address...
│  │  └─ repositories/             # SupabaseRepository (interface!)
│  │     ├─ supabase_*.dart        # supabase_flutter amali
│  │     └─ mock_*.dart            # demo rejim (offline sinov)
│  ├─ features/
│  │  ├─ auth/                     # kirish, SMS OTP
│  │  ├─ home/                     # bannerlar, kategoriyalar, tavsiyalar
│  │  ├─ catalog/                  # qidiruv, filtr, saralash
│  │  ├─ product/                  # mahsulot sahifasi
│  │  ├─ cart/                     # savat
│  │  ├─ checkout/                 # manzil, vaqt, to'lov
│  │  ├─ orders/                   # tarix + status kuzatuvi
│  │  ├─ profile/                  # profil, manzillar, sevimlilar
│  │  └─ admin/                    # dashboard, CRUD, buyurtmalar, mijozlar
│  └─ widgets/                     # umumiy komponentlar
├─ supabase/                       # migrations.sql, seed.sql
└─ pubspec.yaml
```

### Asosiy paketlar
`supabase_flutter`, `go_router`, `flutter_riverpod` (state), `cached_network_image`, `firebase_messaging` (push), `intl`, `flutter_localizations`

---

## 5. To'lov arxitekturasi (Payme/Click'ga tayyor)

```dart
abstract class PaymentProvider {
  Future<PaymentResult> pay(Order order);
  Future<void> handleCallback(Map<String, dynamic> payload);
}

class CashPayment implements PaymentProvider { ... }          // MVP: naqd
class PaymePayment implements PaymentProvider { ... }         // kelajak
class ClickPayment implements PaymentProvider { ... }         // kelajak
```

- `payment_method` ustuni allaqachon `payme/click` qiymatlarini qabul qiladi
- Webhook'lar Supabase Edge Functions'da qabul qilinadi → `payment_status` yangilanadi

---

## 6. Push-bildirishnomalar

- **Buyurtma statusi**: Supabase Realtime → ilova ichidagi xabar + FCM push
- **Aksiyalar**: admin panel'dan yuboriladigan notification (FCM topics)

---

## 7. Bosqichlar (milestones)

| # | Bosqich | Natija |
|---|---|---|
| 1 | ✅ Prototip (dizayn tasdiqlash) | `city-market-prototype/index.html` |
| 2 | ✅ Flutter loyihasi + tema + i18n | `city_market/lib` (32 fayl) |
| 3 | ✅ Supabase schema + Auth (SMS demo) | `supabase/migrations/*.sql` |
| 4 | ✅ Katalog: kategoriya, qidiruv, filtr, mahsulot sahifasi | `features/catalog`, `features/product` |
| 5 | ✅ Savat + buyurtma (manzil/vaqt/naqd) | `features/cart`, `features/checkout` |
| 6 | ✅ Buyurtmalar + status kuzatuvi | `features/orders` (Realtime keyingi qadam) |
| 7 | ✅ Profil: manzillar, sevimlilar | `features/profile` |
| 8 | ✅ Admin panel + KENGAYTIRILGAN mahsulot formasi | `admin/` (rasm, video, SKU, brend, 3 til) |
| 9 | ⏳ Push-bildirishnomalar | FCM (keyingi qadam) |
| 10 | ⏳ Payme/Click integratsiyasi | to'lov |

### ✅ Yaratilgan Flutter loyihasi: `city_market/`

**Mahsulot qo'shish formasi (siz aytgan talab bo'yicha) — to'liq maydonlar:**
- 📷 **Rasmlar** — bir nechta (galereya/kameradan, Storage'ga yuklanadi)
- 🎬 **Video** — MP4 havolasi (mahsulot sahifasida ijro etiladi)
- 📝 **Nomi** — 3 tilda (O'zbekcha / Русский / English)
- 🏷️ **Kategoriya**, **Brend**, **SKU / shtrix-kod**
- 💰 **Narx + eski narx** (chegirma), **o'lchov birligi** (kg/litr/dona/g/ml + qiymat)
- 📦 **Qoldiq + minimal qoldiq** (kam qolganda ogohlantirish)
- 🌍 **Ishlab chiqarilgan davlat, ishlab chiqaruvchi, vazn**
- #️⃣ **Teglar**, 📄 **Tavsif** (3 tilda), **faollik**

Xuddi shu maydonlar prototipning Admin panel → "Yangi mahsulot" formasiga ham qo'shildi —
`city-market-prototype/index.html` ni ochib ko'ring.

---

## 8. Prototipni ochish

`city-market-prototype/index.html` faylini istalgan brauzerda oching. Yuqoridagi tugmalar bilan **Xaridor ilovasi ↔ Admin panel** almashtiriladi, **UZ/RU/EN** tugmalari tilni o'zgartiradi.

> Keyingi qadam: dizaynni tasdiqlang — 2-bosqichdan Flutter kodini yozishni boshlayman.
