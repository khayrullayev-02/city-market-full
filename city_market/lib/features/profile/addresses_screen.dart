import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/widgets.dart';

/// Manzillar ro'yxati + yangi manzil qo'shish.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _city = TextEditingController(text: 'Jizzax');
  final _addr = TextEditingController();

  @override
  void dispose() {
    _city.dispose();
    _addr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return Scaffold(
      appBar: AppBar(title: Text(S.t(lang, 'addresses'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...st.addresses.map((a) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Text(
                    a.label == 'home'
                        ? '🏠'
                        : a.label == 'work'
                        ? '🏢'
                        : '📍',
                    style: const TextStyle(fontSize: 22),
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
                            fontSize: 13.5,
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
                  IconButton(
                    onPressed: () => st.removeAddress(a.id),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFFB91C1C),
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _city,
                  decoration: InputDecoration(labelText: S.t(lang, 'city')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addr,
                  decoration: InputDecoration(
                    labelText: S.t(lang, 'addressPh'),
                  ),
                ),
                const SizedBox(height: 12),
                BigButton(
                  label: S.t(lang, 'addAddress'),
                  icon: Icons.add,
                  onTap: () async {
                    if (_addr.text.trim().isEmpty) return;
                    await st.addAddress(
                      Address(
                        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
                        label: 'other',
                        city: _city.text.trim(),
                        address: _addr.text.trim(),
                      ),
                    );
                    _addr.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.t(lang, 'changesSaved'))),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
