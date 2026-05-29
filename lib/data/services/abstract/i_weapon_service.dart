import '../../../data/models/weapon_model.dart';

abstract class IWeaponService {
  Future<List<WeaponModel>> getAll();
  Future<WeaponModel> getById(int id);
  Future<void> create(WeaponModel weapon);
  Future<void> update(int id, WeaponModel weapon);
  Future<void> delete(int id);
}
