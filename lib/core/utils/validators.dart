class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Harga harus berupa angka';
    }
    if (parsed <= 0) {
      return 'Harga harus lebih dari 0';
    }
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stok tidak boleh kosong';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Stok harus berupa angka bulat';
    }
    if (parsed < 0) {
      return 'Stok tidak boleh negatif';
    }
    return null;
  }

  static String? imageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL gambar tidak boleh kosong';
    }
    final urlRegex = RegExp(
      r'^https?:\/\/.+\.(jpg|jpeg|png|gif|webp)(\?.*)?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'URL gambar tidak valid (harus http/https, format jpg/png/gif/webp)';
    }
    return null;
  }
}
