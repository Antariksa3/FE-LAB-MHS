import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/weapon_model.dart';
import '../../providers/weapon_provider.dart';
import '../../widgets/common/gold_button.dart';

class ItemFormScreen extends StatefulWidget {
  final WeaponModel? weapon;

  const ItemFormScreen({super.key, required this.weapon});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  String _selectedType = 'Sword';
  bool _isSubmitting = false;

  bool get _isEditMode => widget.weapon != null;

  static const List<String> _weaponTypes = [
    'Sword',
    'Claymore',
    'Polearm',
    'Catalyst',
    'Bow',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final w = widget.weapon!;
      _nameCtrl.text = w.name;
      _descCtrl.text = w.description;
      _stockCtrl.text = w.stock.toString();
      _priceCtrl.text = w.price.toStringAsFixed(0);
      _imageCtrl.text = w.imageUrl;
      _selectedType = w.type;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final weapon = WeaponModel(
      id: _isEditMode ? widget.weapon!.id : 0,
      name: _nameCtrl.text.trim(),
      type: _selectedType,
      description: _descCtrl.text.trim(),
      stock: int.parse(_stockCtrl.text.trim()),
      price: double.parse(_priceCtrl.text.trim()),
      imageUrl: _imageCtrl.text.trim(),
    );

    final wp = context.read<WeaponProvider>();
    final success = _isEditMode
        ? await wp.updateWeapon(widget.weapon!.id, weapon)
        : await wp.createWeapon(weapon);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _showSuccessAndPop();
    } else {
      _showErrorSnackbar(wp.errorMessage ?? 'Operasi gagal');
    }
  }

  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? '${_nameCtrl.text} updated successfully'
              : '${_nameCtrl.text} added successfully',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) return true;

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            title: const Text(
              'Discard Changes?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'Perubahan yang belum disimpan akan hilang.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Stay',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Discard',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  bool _hasChanges() {
    if (!_isEditMode) {
      return _nameCtrl.text.isNotEmpty ||
          _descCtrl.text.isNotEmpty ||
          _stockCtrl.text.isNotEmpty ||
          _priceCtrl.text.isNotEmpty ||
          _imageCtrl.text.isNotEmpty;
    }
    final w = widget.weapon!;
    return _nameCtrl.text != w.name ||
        _descCtrl.text != w.description ||
        _stockCtrl.text != w.stock.toString() ||
        _priceCtrl.text != w.price.toStringAsFixed(0) ||
        _imageCtrl.text != w.imageUrl ||
        _selectedType != w.type;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Item' : 'Add New Item'),
          leading: BackButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePreview(),
                const SizedBox(height: 24),

                _sectionLabel('Basic Information'),
                const SizedBox(height: 12),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildTypeDropdown(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 24),

                _sectionLabel('Inventory & Pricing'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStockField()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPriceField()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildImageUrlField(),
                const SizedBox(height: 32),

                GoldButton(
                  label: _isSubmitting
                      ? (_isEditMode ? 'Updating...' : 'Adding...')
                      : (_isEditMode ? 'Update Item' : 'Add Item'),
                  isLoading: _isSubmitting,
                  icon: _isEditMode ? Icons.save_outlined : Icons.add,
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () async {
                      final shouldPop = await _onWillPop();
                      if (shouldPop && context.mounted) Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.primaryMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _imageCtrl,
      builder: (_, value, __) {
        final url = value.text.trim();
        return Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryMedium),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image preview',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  )
                : Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Invalid image URL',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Weapon / Artifact Name',
        prefixIcon: Icon(Icons.shield_outlined, color: AppColors.textSecondary),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (v) => Validators.required(v, fieldName: 'Nama item'),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      style: const TextStyle(color: AppColors.textPrimary),
      dropdownColor: AppColors.bgCard,
      decoration: const InputDecoration(
        labelText: 'Weapon Type',
        prefixIcon: Icon(
          Icons.category_outlined,
          color: AppColors.textSecondary,
        ),
      ),
      items: _weaponTypes
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(
                type,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedType = v ?? 'Sword'),
      validator: (v) => v == null ? 'Pilih tipe senjata' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descCtrl,
      style: const TextStyle(color: AppColors.textPrimary),
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Description',
        prefixIcon: Icon(Icons.notes_outlined, color: AppColors.textSecondary),
        alignLabelWithHint: true,
      ),
      validator: (v) => Validators.required(v, fieldName: 'Deskripsi'),
    );
  }

  Widget _buildStockField() {
    return TextFormField(
      controller: _stockCtrl,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Stock',
        prefixIcon: Icon(
          Icons.inventory_2_outlined,
          color: AppColors.textSecondary,
        ),
      ),
      validator: Validators.stock,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceCtrl,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Price (Mora)',
        prefixIcon: Icon(
          Icons.monetization_on_outlined,
          color: AppColors.textSecondary,
        ),
      ),
      validator: Validators.price,
    );
  }

  Widget _buildImageUrlField() {
    return TextFormField(
      controller: _imageCtrl,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: TextInputType.url,
      decoration: const InputDecoration(
        labelText: 'Image URL',
        prefixIcon: Icon(Icons.link, color: AppColors.textSecondary),
        hintText: 'https://example.com/image.jpg',
      ),
      validator: Validators.imageUrl,
    );
  }
}
