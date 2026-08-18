-- =============================================================
-- City Market — boshlang'ich (seed) ma'lumotlar
-- =============================================================

-- Kategoriyalar
insert into public.categories (slug, name, emoji, is_household, "order") values
  ('sut',       '{"uz":"Sut mahsulotlari","ru":"Молочные продукты","en":"Dairy"}',        '🥛', false, 1),
  ('non',       '{"uz":"Non","ru":"Хлеб","en":"Bread"}',                                   '🍞', false, 2),
  ('ichimlik',  '{"uz":"Ichimliklar","ru":"Напитки","en":"Drinks"}',                       '🥤', false, 3),
  ('meva',      '{"uz":"Meva-sabzavot","ru":"Овощи и фрукты","en":"Fruits & Veg"}',        '🥦', false, 4),
  ('gosht',     '{"uz":"Go''sht","ru":"Мясо","en":"Meat"}',                                '🍗', false, 5),
  ('shirin',    '{"uz":"Shirinliklar","ru":"Сладости","en":"Sweets"}',                     '🍫', false, 6),
  ('don',       '{"uz":"Don mahsulotlari","ru":"Бакалея","en":"Groceries"}',               '🌾', false, 7),
  ('maishiy',   '{"uz":"Yuvish vositalari","ru":"Моющие средства","en":"Detergents"}',     '🧴', true,  8),
  ('idish',     '{"uz":"Idish-tovoq","ru":"Посуда","en":"Dishes"}',                        '🍽️', true,  9),
  ('gigiyena',  '{"uz":"Shaxsiy gigiyena","ru":"Личная гигиена","en":"Personal care"}',    '🧼', true, 10)
on conflict (slug) do nothing;

-- Mahsulotlar (namuna)
insert into public.products
  (category_id, name, description, brand, sku, price, old_price, unit, unit_value, stock, min_stock, tags, country_origin)
values
  ((select id from public.categories where slug='sut'),
   '{"uz":"Sut 3,2%","ru":"Молоко 3,2%","en":"Milk 3.2%"}',
   '{"uz":"Tabiiy pasterizatsiyalangan sut","ru":"Натуральное молоко","en":"Natural pasteurized milk"}',
   'Oqtepa', '4780000000011', 12000, null, 'litr', 1, 48, 10, '{sut,tabiiy}', 'O''zbekiston'),
  ((select id from public.categories where slug='non'),
   '{"uz":"Patir non","ru":"Лепешка","en":"Flatbread (Patir)"}',
   '{"uz":"Tandirda yopilgan non","ru":"Лепешка из тандыра","en":"Tandoor-baked flatbread"}',
   'Nonvoy', '4780000000028', 8000, null, 'dona', 1, 25, 10, '{non}', 'O''zbekiston'),
  ((select id from public.categories where slug='ichimlik'),
   '{"uz":"Cola 1 l","ru":"Кола 1 л","en":"Cola 1 L"}',
   '{"uz":"Gazlangan ichimlik","ru":"Газированный напиток","en":"Sparkling soft drink"}',
   'Coca-Cola', '4780000000035', 13000, 15000, 'litr', 1, 80, 20, '{aksiya}', 'Turkiya'),
  ((select id from public.categories where slug='maishiy'),
   '{"uz":"Kir yuvish kukuni","ru":"Стиральный порошок","en":"Laundry detergent"}',
   '{"uz":"Avtomat mashina uchun 3 kg","ru":"Для стиральных машин 3 кг","en":"For washing machines, 3 kg"}',
   'Sorti', '4780000000042', 45000, 52000, 'kg', 3, 26, 8, '{aksiya,uy}', 'O''zbekistan')
on conflict do nothing;
