import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/weapon_provider.dart';
import '../../widgets/common/weapon_card.dart';
import '../../widgets/common/type_filter_chip.dart';
import 'item_detail_screen.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeaponProvider>().fetchWeapons();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Yakin ingin keluar?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genshin Import'),
        actions: [
          _CartBadge(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton(
              icon: CircleAvatar(
                backgroundColor: AppColors.accent,
                radius: 16,
                child: Text(
                  (auth.currentUser?.name[0] ?? 'U').toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.bgDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              color: AppColors.bgCard,
              itemBuilder: (_) => <PopupMenuEntry<void>>[
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.name ?? '',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        auth.currentUser?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: _handleLogout,
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error, size: 18),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          _buildSearchAndFilter(),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: context.read<WeaponProvider>().searchWeapons,
            decoration: InputDecoration(
              hintText: 'Search weapons & artifacts...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<WeaponProvider>().searchWeapons('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 36,
            child: Consumer<WeaponProvider>(
              builder: (_, wp, __) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: WeaponProvider.weaponTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final type = WeaponProvider.weaponTypes[i];
                  return TypeFilterChip(
                    label: type,
                    isSelected: wp.filterType == type,
                    onTap: () => wp.filterByType(type),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<WeaponProvider>(
      builder: (_, wp, __) {
        if (wp.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (wp.status == WeaponStatus.error) {
          return _buildErrorState(wp);
        }

        if (wp.weapons.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.bgCard,
          onRefresh: wp.fetchWeapons,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: wp.weapons.length,
            itemBuilder: (_, i) {
              final weapon = wp.weapons[i];
              return WeaponCard(
                weapon: weapon,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailScreen(weaponId: weapon.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(WeaponProvider wp) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              wp.errorMessage ?? 'Terjadi kesalahan',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: wp.fetchWeapons,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada item ditemukan',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _CartBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) => Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: onTap,
          ),
          if (cart.totalCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${cart.totalCount}',
                  style: const TextStyle(
                    color: AppColors.bgDark,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
