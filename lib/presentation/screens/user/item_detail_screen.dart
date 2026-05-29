import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../providers/weapon_provider.dart';
import '../../widgets/common/type_badge.dart';
import 'cart_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final int weaponId;
  const ItemDetailScreen({super.key, required this.weaponId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeaponProvider>().fetchWeaponById(widget.weaponId);
    });
  }

  void _handleAddToCart() {
    final weapon = context.read<WeaponProvider>().selectedItem;
    if (weapon == null) return;

    if (weapon.stock <= 0) {
      _showSnackbar('Stok habis', isError: true);
      return;
    }

    context.read<CartProvider>().addItem(weapon);
    _showSnackbar('${weapon.name} ditambahkan ke keranjang');
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeaponProvider, CartProvider>(
      builder: (_, wp, cart, __) {
        final weapon = wp.selectedItem;

        if (wp.isLoading || weapon == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final inCart = cart.isInCart(weapon.id);
        final cartQty = cart.getQuantity(weapon.id);
        final isOutStock = weapon.stock <= 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(weapon.name),
            leading: const BackButton(),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (cart.totalCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
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
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroImage(weapon.imageUrl, weapon.name),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              weapon.name,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ),
                          const SizedBox(width: 12),
                          TypeBadge(type: weapon.type),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        Formatters.currency(weapon.price),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),

                      _buildStockChip(weapon.stock),
                      const SizedBox(height: 20),

                      const Divider(color: AppColors.primaryMedium),
                      const SizedBox(height: 16),

                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weapon.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 32),

                      if (inCart)
                        _buildCartInfo(cartQty, weapon.stock, cart, weapon.id),

                      const SizedBox(height: 16),

                      _buildActionButton(inCart, isOutStock, weapon, cart),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroImage(String imageUrl, String name) {
    return Container(
      height: 280,
      color: AppColors.bgCard,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        errorWidget: (_, __, ___) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_rounded,
                size: 80,
                color: AppColors.accent,
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockChip(int stock) {
    final isLow = stock > 0 && stock <= 3;
    final color = stock <= 0
        ? AppColors.error
        : isLow
        ? AppColors.warning
        : AppColors.success;
    final label = stock <= 0
        ? 'Out of Stock'
        : isLow
        ? 'Low Stock ($stock left)'
        : 'In Stock ($stock available)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stock <= 0
                ? Icons.remove_circle_outline
                : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartInfo(int qty, int stock, CartProvider cart, int weaponId) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          const Text(
            'In cart:',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const Spacer(),
          _QuantityStepper(
            quantity: qty,
            maxStock: stock,
            onDecrease: () => cart.updateQuantity(weaponId, qty - 1),
            onIncrease: () => cart.updateQuantity(weaponId, qty + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    bool inCart,
    bool isOutStock,
    weapon,
    CartProvider cart,
  ) {
    if (isOutStock) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bgCard,
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Out of Stock'),
        ),
      );
    }

    if (inCart) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
          icon: const Icon(Icons.shopping_cart),
          label: const Text('View Cart'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _handleAddToCart,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add to Cart'),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final int maxStock;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityStepper({
    required this.quantity,
    required this.maxStock,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onPressed: quantity > 1 ? onDecrease : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$quantity',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onPressed: quantity < maxStock ? onIncrease : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _StepButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onPressed != null
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.bgInput,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: onPressed != null
                ? AppColors.accent
                : AppColors.primaryMedium,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null ? AppColors.accent : AppColors.textHint,
        ),
      ),
    );
  }
}
