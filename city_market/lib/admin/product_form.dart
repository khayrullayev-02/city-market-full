import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Mahsulot qo'shish / tahrirlash — TO'LIQ ma'lumotlar bilan:
/// nom (3 til), kategoriya, brend, SKU, narx, eski narx, o'lchov birligi,
/// qoldiq, min. qoldiq, RASMLAR (bir nechta), VIDEO, ishlab chiqarilgan davlat,
/// ishlab chiqaruvchi, vazn, teglar, tavsif (3 til), faollik.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  late final TextEditingController _brand;
  late final TextEditingController _sku;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _unitValue;
  late final TextEditingController _stock;
  late final TextEditingController _minStock;
  late final TextEditingController _videoUrl;
  late final TextEditingController _country;
  late final TextEditingController _manufacturer;
  late final TextEditingController _weight;
  late final TextEditingController _tags;
  late final TextEditingController _descUz;
  late final TextEditingController _descRu;
  late final TextEditingController _descEn;

  String _categoryId = '';
  String _unit = 'dona';
  bool _isActive = true;
  List<String> _images = []; // mavjud URL lar
  List<Uint8List> _newImages = []; // yangi tanlangan rasmlar (bayt)

  static const _unitOptions = [
    ('kg', 'uKg'),
    ('litr', 'uL'),
    ('dona', 'uPcs'),
    ('g', 'uG'),
    ('ml', 'uMl'),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameUz = TextEditingController(text: p?.name.uz ?? '');
    _nameRu = TextEditingController(text: p?.name.ru ?? '');
    _nameEn = TextEditingController(text: p?.name.en ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _price = TextEditingController(text: p != null ? _fmt(p.price) : '');
    _oldPrice = TextEditingController(
      text: p?.oldPrice != null ? _fmt(p.oldPrice!) : '',
    );
    _unitValue = TextEditingController(
      text: p != null ? _fmt(p.unitValue) : '1',
    );
    _stock = TextEditingController(text: p != null ? '${p.stock}' : '20');
    _minStock = TextEditingController(text: p != null ? '${p.minStock}' : '5');
    _videoUrl = TextEditingController(text: p?.videoUrl ?? '');
    _country = TextEditingController(text: p?.country ?? '');
    _manufacturer = TextEditingController(text: p?.manufacturer ?? '');
    _weight = TextEditingController(
      text: p?.weightKg != null ? _fmt(p.weightKg!) : '',
    );
    _tags = TextEditingController(text: (p?.tags ?? []).join(', '));
    _descUz = TextEditingController(text: p?.description.uz ?? '');
    _descRu = TextEditingController(text: p?.description.ru ?? '');
    _descEn = TextEditingController(text: p?.description.en ?? '');
    _categoryId = p?.categoryId ?? '';
    _unit = p?.unit ?? 'dona';
    _isActive = p?.isActive ?? true;
    _images = List.of(p?.images ?? const []);
  }

  String _fmt(num n) {
    if (n == n.roundToDouble()) return n.round().toString();
    return n.toString();
  }

  @override
  void dispose() {
    for (final c in [
      _nameUz,
      _nameRu,
      _nameEn,
      _brand,
      _sku,
      _price,
      _oldPrice,
      _unitValue,
      _stock,
      _minStock,
      _videoUrl,
      _country,
      _manufacturer,
      _weight,
      _tags,
      _descUz,
      _descRu,
      _descEn,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      final files = await picker.pickMultiImage();
      for (final f in files) {
        final bytes = await f.readAsBytes();
        if (mounted) {
          setState(() => _newImages.add(bytes));
        }
      }
    } catch (_) {}
  }

  Future<List<String>> _resolveImages() async {
    final list = List<String>.from(_images);
    final st = context.read<AppState>();
    final ts = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < _newImages.length; i++) {
      final url = await st.repo.uploadImage('$ts-$i.jpg', _newImages[i]);
      list.add(url);
    }
    return list;
  }

  Future<void> _save() async {
    final lang = context.read<AppState>().lang;
    if (_nameUz.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.t(lang, 'productName')} — ${S.t(lang, 'reqField')}',
          ),
        ),
      );
      return;
    }
    final st = context.read<AppState>();
    final product = Product(
      id: widget.product?.id ?? 'p-${DateTime.now().millisecondsSinceEpoch}',
      categoryId: _categoryId,
      name: L10n(
        uz: _nameUz.text.trim(),
        ru: _nameRu.text.trim(),
        en: _nameEn.text.trim(),
      ),
      description: L10n(
        uz: _descUz.text.trim(),
        ru: _descRu.text.trim(),
        en: _descEn.text.trim(),
      ),
      brand: _brand.text.trim(),
      sku: _sku.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? 0,
      oldPrice: _oldPrice.text.trim().isEmpty
          ? null
          : (double.tryParse(_oldPrice.text.trim()) ?? 0),
      unit: _unit,
      unitValue: double.tryParse(_unitValue.text.trim()) ?? 1,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      minStock: int.tryParse(_minStock.text.trim()) ?? 0,
      images: await _resolveImages(),
      videoUrl: _videoUrl.text.trim().isEmpty ? null : _videoUrl.text.trim(),
      tags: _tags.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      country: _country.text.trim(),
      manufacturer: _manufacturer.text.trim(),
      weightKg: _weight.text.trim().isEmpty
          ? null
          : (double.tryParse(_weight.text.trim()) ?? 0),
      isActive: _isActive,
    );
    await st.saveProduct(product);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.t(lang, 'prodForm')),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              S.t(lang, 'save'),
              style: const TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('📷', S.t(lang, 'images')),
          _imagesPicker(lang),
          const SizedBox(height: 14),
          _section('🎬', S.t(lang, 'videoUrl')),
          _field(_videoUrl, hint: S.t(lang, 'videoHint')),
          const SizedBox(height: 14),
          _section('📝', S.t(lang, 'productName')),
          _field(_nameUz, label: S.t(lang, 'nameUz')),
          const SizedBox(height: 10),
          _field(_nameRu, label: S.t(lang, 'nameRu')),
          const SizedBox(height: 10),
          _field(_nameEn, label: S.t(lang, 'nameEn')),
          const SizedBox(height: 14),
          _section('🏷️', S.t(lang, 'category')),
          _categoryDropdown(st, lang),
          const SizedBox(height: 14),
          _section('💰', S.t(lang, 'price')),
          Row(
            children: [
              Expanded(
                child: _field(
                  _price,
                  label: '${S.t(lang, 'price')} (${S.t(lang, 'sum')})',
                  number: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  _oldPrice,
                  label: '${S.t(lang, 'oldPrice')} (${S.t(lang, 'sum')})',
                  number: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _section('⚖️', S.t(lang, 'unit')),
          Row(
            children: [
              Expanded(child: _unitDropdown(lang)),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  _unitValue,
                  label: S.t(lang, 'unitValue'),
                  number: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _section('📦', S.t(lang, 'stock')),
          Row(
            children: [
              Expanded(
                child: _field(_stock, label: S.t(lang, 'stock'), number: true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  _minStock,
                  label: S.t(lang, 'minStock'),
                  number: true,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '💡 ${S.t(lang, 'minStockHint')}',
              style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
            ),
          ),
          const SizedBox(height: 14),
          _section('🔖', S.t(lang, 'sku')),
          Row(
            children: [
              Expanded(child: _field(_brand, label: S.t(lang, 'brand'))),
              const SizedBox(width: 10),
              Expanded(child: _field(_sku, label: S.t(lang, 'sku'))),
            ],
          ),
          const SizedBox(height: 14),
          _section('🌍', S.t(lang, 'countryOfOrigin')),
          Row(
            children: [
              Expanded(
                child: _field(_country, label: S.t(lang, 'countryOfOrigin')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  _manufacturer,
                  label: S.t(lang, 'manufacturerLbl'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _field(_weight, label: S.t(lang, 'weightLbl'), number: true),
          const SizedBox(height: 14),
          _section('#️⃣', S.t(lang, 'tagsLbl')),
          _field(_tags),
          const SizedBox(height: 14),
          _section('📄', S.t(lang, 'description')),
          _field(_descUz, label: S.t(lang, 'descUz'), lines: 2),
          const SizedBox(height: 10),
          _field(_descRu, label: S.t(lang, 'descRu'), lines: 2),
          const SizedBox(height: 10),
          _field(_descEn, label: S.t(lang, 'descEn'), lines: 2),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _isActive,
            activeColor: AppColors.green,
            contentPadding: EdgeInsets.zero,
            title: Text(
              S.t(lang, 'active'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            onChanged: (v) => setState(() => _isActive = v),
          ),
          const SizedBox(height: 14),
          BigButton(label: S.t(lang, 'save'), onTap: _save),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$emoji $title',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }

  Widget _field(
    TextEditingController c, {
    String? label,
    String? hint,
    bool number = false,
    int lines = 1,
  }) {
    return TextField(
      controller: c,
      maxLines: lines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _imagesPicker(AppLang lang) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_images.isEmpty && _newImages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                S.t(lang, 'noImages'),
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._images.map(
                  (src) => _thumb(
                    Image.network(
                      src,
                      fit: BoxFit.cover,
                      width: 72,
                      height: 72,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    ),
                    () => setState(() => _images.remove(src)),
                  ),
                ),
                ..._newImages.asMap().entries.map(
                  (e) => _thumb(
                    Image.memory(
                      e.value,
                      fit: BoxFit.cover,
                      width: 72,
                      height: 72,
                    ),
                    () => setState(() => _newImages.removeAt(e.key)),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(
              '${S.t(lang, 'addImages')} · ${_images.length + _newImages.length} ${S.t(lang, 'imagesCount')}',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: AppColors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(Widget img, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: img),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFB91C1C),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
    width: 72,
    height: 72,
    color: AppColors.greenLight,
    alignment: Alignment.center,
    child: const Text('🛒', style: TextStyle(fontSize: 28)),
  );

  Widget _categoryDropdown(AppState st, AppLang lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: st.categories.any((c) => c.id == _categoryId)
              ? _categoryId
              : null,
          isExpanded: true,
          hint: Text(S.t(lang, 'selectCategory')),
          items: st.categories
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    '${c.emoji} ${c.name.tr(lang)}',
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _categoryId = v ?? ''),
        ),
      ),
    );
  }

  Widget _unitDropdown(AppLang lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _unit,
          isExpanded: true,
          items: _unitOptions
              .map(
                (o) =>
                    DropdownMenuItem(value: o.$1, child: Text(S.t(lang, o.$2))),
              )
              .toList(),
          onChanged: (v) => setState(() => _unit = v ?? 'dona'),
        ),
      ),
    );
  }
}
