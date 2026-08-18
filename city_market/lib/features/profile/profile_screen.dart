import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_login_screen.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_state.dart';
import 'addresses_screen.dart';
import 'favorites_screen.dart';

/// Profil — manzillar, sevimlilar, til, bildirishnomalar, admin panel.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final lang = st.lang;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.greenLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('👤', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        st.user?.fullName ?? 'Diyor Karimov',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        st.user?.phone ?? '+998 90 123 45 67',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await st.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.t(lang, 'loggedOut'))),
                      );
                    }
                  },
                  child: Text(
                    S.t(lang, 'logout'),
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                _menuTile(
                  context,
                  '📍',
                  S.t(lang, 'myAddresses'),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  ),
                ),
                _menuTile(
                  context,
                  '❤️',
                  S.t(lang, 'favorites'),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                ),
                _menuTile(context, '🔔', S.t(lang, 'notifications'), () {}),
                _menuTile(context, '❓', S.t(lang, 'help'), () {}),
                _menuTile(
                  context,
                  '🖥️',
                  S.t(lang, 'adminPanel'),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌐 ${S.t(lang, 'language')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _langBtn(st, lang, AppLang.uz, 'O\'zbekcha'),
                    const SizedBox(width: 8),
                    _langBtn(st, lang, AppLang.ru, 'Русский'),
                    const SizedBox(width: 8),
                    _langBtn(st, lang, AppLang.en, 'English'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    String emoji,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 19)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _langBtn(AppState st, AppLang lang, AppLang value, String label) {
    final active = lang == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => st.setLang(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.green : AppColors.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: active ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
