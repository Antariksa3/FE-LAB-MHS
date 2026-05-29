import 'package:flutter/material.dart';
import '../../data/models/weapon_model.dart';

class CartItem {
  final WeaponModel weapon;
  int quantity;

  CartItem({required this.weapon, this.quantity = 1});

  double get subtotal => weapon.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get totalCount => _items.values.fold(0, (sum, i) => sum + i.quantity);
  double get totalPrice => _items.values.fold(0, (sum, i) => sum + i.subtotal);
  bool get isEmpty => _items.isEmpty;

  bool isInCart(int weaponId) => _items.containsKey(weaponId);

  int getQuantity(int weaponId) => _items[weaponId]?.quantity ?? 0;

  void addItem(WeaponModel weapon) {
    if (_items.containsKey(weapon.id)) {
      final current = _items[weapon.id]!.quantity;
      if (current < weapon.stock) {
        _items[weapon.id]!.quantity++;
      }
    } else {
      _items[weapon.id] = CartItem(weapon: weapon);
    }
    notifyListeners();
  }

  void updateQuantity(int weaponId, int newQty) {
    if (!_items.containsKey(weaponId)) return;
    if (newQty <= 0) {
      removeItem(weaponId);
    } else {
      final maxStock = _items[weaponId]!.weapon.stock;
      _items[weaponId]!.quantity = newQty.clamp(1, maxStock);
      notifyListeners();
    }
  }

  void removeItem(int weaponId) {
    _items.remove(weaponId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
