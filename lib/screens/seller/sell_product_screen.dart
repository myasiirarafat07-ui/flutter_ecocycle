import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/user_provider.dart';
import '../../services/product_api_service.dart';
import '../../widgets/app_text_field.dart';

class SellProductScreen extends StatefulWidget {
  /// Jika diisi, layar berfungsi sebagai mode edit.
  final Product? product;

  const SellProductScreen({super.key, this.product});

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _api = ProductApiService();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();
  final _descController = TextEditingController();

  final List<String> _categories = const ['Pupuk & Kompos', 'Karya Daur Ulang'];
  String _category = 'Pupuk & Kompos';
  bool _isLoading = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _stockController.text = p.stock.toString();
      _imageController.text = p.imageUrl;
      _descController.text = p.description;
      _category = _categories.contains(p.category) ? p.category : _categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  Future<void> _submit() async {
    final token = context.read<UserProvider>().token;
    if (token.isEmpty) {
      _snack('Kamu harus login untuk menjual produk');
      return;
    }

    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? -1;
    final stock = int.tryParse(_stockController.text.trim()) ?? -1;

    if (name.length < 3) {
      _snack('Nama produk minimal 3 karakter');
      return;
    }
    if (price < 0) {
      _snack('Harga tidak valid');
      return;
    }
    if (stock < 0) {
      _snack('Stok tidak valid');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isEdit) {
        await _api.updateProduct(
          token: token,
          id: widget.product!.id,
          name: name,
          category: _category,
          description: _descController.text.trim(),
          price: price,
          stock: stock,
          imageUrl: _imageController.text.trim(),
        );
      } else {
        await _api.createProduct(
          token: token,
          name: name,
          category: _category,
          description: _descController.text.trim(),
          price: price,
          stock: stock,
          imageUrl: _imageController.text.trim(),
        );
      }
      if (!mounted) return;
      _snack(_isEdit ? 'Produk diperbarui' : 'Produk berhasil ditambahkan');
      Navigator.pop(context, true);
    } on ProductApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Tidak bisa terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Produk' : 'Jual Produk'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledField(
                label: 'Nama Produk',
                child: AppTextField(
                  controller: _nameController,
                  hint: 'mis. Pupuk Kompos Premium',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kategori',
                style: TextStyle(color: context.textColor, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.dividerColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    dropdownColor: context.surfaceColor,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                    ),
                    style: TextStyle(color: context.textColor, fontSize: 15),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Harga (Rp)',
                child: AppTextField(
                  controller: _priceController,
                  hint: 'mis. 45000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Stok',
                child: AppTextField(
                  controller: _stockController,
                  hint: 'mis. 100',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'URL Gambar',
                child: AppTextField(
                  controller: _imageController,
                  hint: 'https://...',
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Deskripsi',
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.dividerColor),
                  ),
                  child: TextField(
                    controller: _descController,
                    maxLines: 4,
                    style: TextStyle(color: context.textColor, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Jelaskan produkmu...',
                      hintStyle: TextStyle(color: context.mutedColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Simpan Perubahan' : 'Tambahkan Produk',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
