import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/weapon_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weapon_provider.dart';
import '../../widgets/common/type_badge.dart';
import '../../widgets/common/type_filter_chip.dart';
import '../auth/login_screen.dart';
import 'item_form_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

  void _goToAddForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ItemFormScreen(weapon: null)),
    ).then((_) {
      if (mounted) context.read<WeaponProvider>().fetchWeapons();
    });
  }

  void _goToEditForm(WeaponModel weapon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemFormScreen(weapon: weapon)),
    ).then((_) {
      if (mounted) context.read<WeaponProvider>().fetchWeapons();
    });
  }

  Future<void> _handleDelete(WeaponModel weapon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Delete Item',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            children: [
              const TextSpan(text: 'Delete '),
              TextSpan(
                text: weapon.name,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' permanently? This cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final wp = context.read<WeaponProvider>();
    final success = await wp.deleteWeapon(weapon.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${weapon.name} deleted successfully'
              : wp.errorMessage ?? 'Delete failed',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true && mounted) {
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
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton(
              color: AppColors.bgCard,
              icon: CircleAvatar(
                backgroundColor: AppColors.primaryMedium,
                radius: 16,
                child: Text(
                  (auth.currentUser?.name[0] ?? 'A').toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
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
                        'Administrator',
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddForm,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.bgDark,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          _buildStatsBar(),
          _buildSearchAndFilter(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Consumer<WeaponProvider>(
      builder: (_, wp, __) {
        final total = wp.weapons.length;
        final outStock = wp.weapons.where((w) => w.stock == 0).length;
        final lowStock = wp.weapons
            .where((w) => w.stock > 0 && w.stock <= 3)
            .length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.primaryDark,
          child: Row(
            children: [
              _StatChip(
                label: 'Total',
                value: '$total',
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'Low Stock',
                value: '$lowStock',
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'Out of Stock',
                value: '$outStock',
                color: AppColors.error,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: context.read<WeaponProvider>().searchWeapons,
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              isDense: true,
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
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  wp.errorMessage ?? 'Error',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: wp.fetchWeapons,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (wp.weapons.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No items found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _goToAddForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Item'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.bgCard,
          onRefresh: wp.fetchWeapons,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: wp.weapons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AdminWeaponTile(
              weapon: wp.weapons[i],
              onEdit: () => _goToEditForm(wp.weapons[i]),
              onDelete: () => _handleDelete(wp.weapons[i]),
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AdminWeaponTile extends StatelessWidget {
  final WeaponModel weapon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminWeaponTile({
    required this.weapon,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _stockColor {
    if (weapon.stock == 0) return AppColors.error;
    if (weapon.stock <= 3) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryMedium.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          weapon.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TypeBadge(type: weapon.type),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.currency(weapon.price),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 13,
                        color: _stockColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: ${weapon.stock}',
                        style: TextStyle(color: _stockColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: AppColors.accent,
                  onTap: onEdit,
                  tooltip: 'Edit',
                ),
                const SizedBox(height: 8),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
