class WeaponModel {
  final int id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String imageUrl;
  final double price;

  WeaponModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.imageUrl,
    required this.price,
  });

  factory WeaponModel.fromJson(Map<String, dynamic> json) {
    return WeaponModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      stock: json['stock'],
      imageUrl: json['image'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'description': description,
    'stock': stock,
    'image': imageUrl,
    'price': price,
  };
}
