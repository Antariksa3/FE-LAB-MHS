import 'package:genshin_import/data/models/weapon_model.dart';
import '../abstract/i_weapon_service.dart';

class MockWeaponService implements IWeaponService {
  final List<WeaponModel> _db = [
    WeaponModel(
      id: 1,
      name: 'Skyward Blade',
      type: 'Sword',
      stock: 5,
      price: 1250000,
      imageUrl: 'https://i.imgur.com/placeholder1.png',
      description: 'A sword imbued with the essence of the ancient sky.',
    ),
    WeaponModel(
      id: 2,
      name: 'Wolf\'s Gravestone',
      type: 'Claymore',
      stock: 3,
      price: 1800000,
      imageUrl: 'https://i.imgur.com/placeholder2.png',
      description: 'A longsword that was a relic of the Wolf Knights.',
    ),
    WeaponModel(
      id: 3,
      name: 'Staff of Homa',
      type: 'Polearm',
      stock: 2,
      price: 2100000,
      imageUrl: 'https://i.imgur.com/placeholder3.png',
      description: 'A mysterious polearm made of ebony and bones.',
    ),
    WeaponModel(
      id: 4,
      name: 'Skyward Atlas',
      type: 'Catalyst',
      stock: 4,
      price: 1600000,
      imageUrl: 'https://i.imgur.com/placeholder4.png',
      description: 'A catalyst that records the movements of the sky.',
    ),
    WeaponModel(
      id: 5,
      name: 'Amos\' Bow',
      type: 'Bow',
      stock: 6,
      price: 1400000,
      imageUrl: 'https://i.imgur.com/placeholder5.png',
      description: 'A bow that was once a beloved relic.',
    ),
  ];

  @override
  Future<List<WeaponModel>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_db);
  }

  @override
  Future<WeaponModel> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db.firstWhere((w) => w.id == id);
  }

  @override
  Future<void> create(WeaponModel weapon) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = _db.isEmpty ? 1 : _db.last.id + 1;
    _db.add(
      WeaponModel(
        id: newId,
        name: weapon.name,
        type: weapon.type,
        description: weapon.description,
        stock: weapon.stock,
        imageUrl: weapon.imageUrl,
        price: weapon.price,
      ),
    );
  }

  @override
  Future<void> update(int id, WeaponModel weapon) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _db.indexWhere((w) => w.id == id);
    if (idx != -1) {
      _db[idx] = WeaponModel(
        id: id,
        name: weapon.name,
        type: weapon.type,
        description: weapon.description,
        stock: weapon.stock,
        imageUrl: weapon.imageUrl,
        price: weapon.price,
      );
    }
  }

  @override
  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.removeWhere((w) => w.id == id);
  }
}
