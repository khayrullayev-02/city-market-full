import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';
import '../profile/addresses_screen.dart';
import 'success_screen.dart';

/// Buyurtma berish — manzil, vaqt, to'lov usuli.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return Scaffold(
      appBar: AppBar(title: Text(S.t(lang, 'checkoutTitle'))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('📍', S.t(lang, 'address')),
                ...st.addresses.asMap().entries.map(
                  (e) => _addressTile(st, lang, e.key, e.value),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(S.t(lang, 'addAddress')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.line),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                _sectionTitle('🕐', S.t(lang, 'deliveryTime')),
                _slots(st, lang),
                _sectionTitle('💳', S.t(lang, 'paymentMethod')),
                _payment(st, lang),
                _sectionTitle('💬', S.t(lang, 'comment')),
                TextField(
                  controller: _comment,
                  maxLines: 2,
                  decoration: InputDecoration(hintText: S.t(lang, 'commentPh')),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _bottomBar(st, lang),
        ],
      ),
    );
  }

  Widget _sectionTitle(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        '$emoji $title',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }

  Widget _addressTile(AppState st, AppLang lang, int index, Address a) {
    final selected = st.selectedAddress == index;
    return GestureDetector(
      onTap: () => st.selectedAddress = index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              a.label == 'home'
                  ? '🏠'
                  : a.label == 'work'
                  ? '🏢'
                  : '📍',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${S.t(lang, a.label)}${a.isDefault ? ' · ${S.t(lang, 'defaultLabel')}' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${a.city} · ${a.address}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.green : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slots(AppState st, AppLang lang) {
    final keys = ['slot1', 'slot2', 'slot3', 'slot4'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: List.generate(keys.length, (i) {
          final selected = st.selectedSlot == i;
          return RadioListTile<int>(
            value: i,
            groupValue: st.selectedSlot,
            dense: true,
            activeColor: AppColors.green,
            title: Text(
              S.t(lang, keys[i]),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            onChanged: (v) => st.selectedSlot = v ?? 0,
          );
        }),
      ),
    );
  }

  Widget _payment(AppState st, AppLang lang) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.green, width: 2),
          ),
          child: Row(
            children: [
              const Text('💵', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  S.t(lang, 'cash'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const Icon(Icons.check_circle, color: AppColors.green),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Text('📲', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payme / Click',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      S.t(lang, 'cardSoon'),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'SOON',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomBar(AppState st, AppLang lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.t(lang, 'total'),
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                Text(
                  money(lang, st.cartTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BigButton(
                label: S.t(lang, 'confirmOrder'),
                color: AppColors.orange,
                onTap: () async {
                  await st.placeOrder(_comment.text);
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SuccessScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
