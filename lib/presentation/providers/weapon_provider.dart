import 'package:flutter/material.dart';
import '../../data/models/weapon_model.dart';
import '../../data/services/abstract/i_weapon_service.dart';

enum WeaponStatus { initial, loading, loaded, error }

class WeaponProvider extends ChangeNotifier {
  final IWeaponService _weaponService;

  WeaponProvider(this._weaponService);

  WeaponStatus _status = WeaponStatus.initial;
  List<WeaponModel> _weapons = [];
  List<WeaponModel> _filtered = [];
  WeaponModel? _selectedItem;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterType = 'All';

  WeaponStatus get status => _status;
  List<WeaponModel> get weapons => _filtered;
  WeaponModel? get selectedItem => _selectedItem;
  String? get errorMessage => _errorMessage;
  String get filterType => _filterType;
  bool get isLoading => _status == WeaponStatus.loading;

  static const List<String> weaponTypes = [
    'All',
    'Sword',
    'Claymore',
    'Polearm',
    'Catalyst',
    'Bow',
  ];

  Future<void> fetchWeapons() async {
    _setStatus(WeaponStatus.loading);
    try {
      _weapons = await _weaponService.getAll();
      _applyFilter();
      _setStatus(WeaponStatus.loaded);
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Periksa koneksi Anda.';
      _setStatus(WeaponStatus.error);
    }
  }

  Future<void> fetchWeaponById(int id) async {
    final cached = _weapons.where((w) => w.id == id);
    if (cached.isNotEmpty) {
      _selectedItem = cached.first;
      notifyListeners();
      return;
    }

    try {
      _selectedItem = await _weaponService.getById(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat detail item.';
      notifyListeners();
    }
  }

  Future<bool> createWeapon(WeaponModel weapon) async {
    try {
      await _weaponService.create(weapon);
      await fetchWeapons();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan item.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWeapon(int id, WeaponModel weapon) async {
    try {
      await _weaponService.update(id, weapon);
      await fetchWeapons();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah item.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWeapon(int id) async {
    try {
      await _weaponService.delete(id);
      await fetchWeapons();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus item.';
      notifyListeners();
      return false;
    }
  }

  void searchWeapons(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void filterByType(String type) {
    _filterType = type;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filtered = _weapons.where((w) {
      final matchSearch =
          _searchQuery.isEmpty ||
          w.name.toLowerCase().contains(_searchQuery) ||
          w.type.toLowerCase().contains(_searchQuery);
      final matchType = _filterType == 'All' || w.type == _filterType;
      return matchSearch && matchType;
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(WeaponStatus status) {
    _status = status;
    notifyListeners();
  }
}
