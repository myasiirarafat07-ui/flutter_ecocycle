import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import '../../services/product_api_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/product_image.dart';

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
  final _wasteController = TextEditingController();
  final _weightController = TextEditingController();
  final _urlController = TextEditingController();
  final _descController = TextEditingController();

  /// Galeri foto produk (maks 5): URL relatif file terunggah, URL tempelan,
  /// atau base64. Foto pertama = utama/thumbnail.
  final List<String> _images = [];
  static const int _maxImages = 5;

  final List<String> _categories = const ['Pupuk & Kompos', 'Karya Daur Ulang'];
  String _category = 'Pupuk & Kompos';
  bool _isLoading = false;
  bool _savingLocation = false;
  bool _uploadingImages = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _stockController.text = p.stock.toString();
      _wasteController.text = p.wasteKg > 0 ? p.wasteKg.toString() : '';
      _weightController.text = p.weightKg > 0 ? p.weightKg.toString() : '';
      _images.addAll(p.images);
      _descController.text = p.description;
      _category = _categories.contains(p.category) ? p.category : _categories.first;
    }
  }

  /// Unggah file gambar ke server lalu tambahkan URL hasilnya ke galeri.
  Future<void> _uploadAndAdd(List<XFile> files) async {
    if (files.isEmpty) return;
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) {
      _snack('Maksimal $_maxImages gambar');
      return;
    }
    final token = context.read<UserProvider>().token;
    if (token.isEmpty) {
      _snack('Kamu harus login untuk mengunggah gambar');
      return;
    }
    setState(() => _uploadingImages = true);
    try {
      final urls =
          await _api.uploadImages(token: token, files: files.take(remaining).toList());
      if (!mounted) return;
      setState(() => _images.addAll(urls));
    } on ProductApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Gagal mengunggah gambar');
    } finally {
      if (mounted) setState(() => _uploadingImages = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_images.length >= _maxImages) {
      _snack('Maksimal $_maxImages gambar');
      return;
    }
    try {
      final picked = await ImagePicker().pickMultiImage(
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      await _uploadAndAdd(picked);
    } catch (_) {
      if (mounted) _snack('Gagal memilih gambar');
    }
  }

  Future<void> _pickFromCamera() async {
    if (_images.length >= _maxImages) {
      _snack('Maksimal $_maxImages gambar');
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (picked == null) return;
      await _uploadAndAdd([picked]);
    } catch (_) {
      if (mounted) _snack('Gagal mengambil gambar');
    }
  }

  void _addUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    if (_images.length >= _maxImages) {
      _snack('Maksimal $_maxImages gambar');
      return;
    }
    setState(() {
      _images.add(url);
      _urlController.clear();
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _wasteController.dispose();
    _weightController.dispose();
    _urlController.dispose();
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
    final wasteKg = double.tryParse(_wasteController.text.trim().replaceAll(',', '.')) ?? 0;
    final weightKg = double.tryParse(_weightController.text.trim().replaceAll(',', '.')) ?? 0;

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
    if (wasteKg < 0) {
      _snack('Berat limbah tidak valid');
      return;
    }
    if (weightKg < 0) {
      _snack('Berat produk tidak valid');
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
          imageUrl: _images.isNotEmpty ? _images.first : '',
          images: _images,
          wasteKg: wasteKg,
          weightKg: weightKg,
        );
      } else {
        await _api.createProduct(
          token: token,
          name: name,
          category: _category,
          description: _descController.text.trim(),
          price: price,
          stock: stock,
          imageUrl: _images.isNotEmpty ? _images.first : '',
          images: _images,
          wasteKg: wasteKg,
          weightKg: weightKg,
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

  Future<void> _simpanLokasi() async {
    if (_savingLocation) return;
    setState(() => _savingLocation = true);
    try {
      final pos = await LocationService.getCurrentPosition();
      if (!mounted) return;
      await context.read<UserProvider>().updateLocation(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
      if (mounted) _snack('Lokasi penjualan tersimpan');
    } on LocationException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Gagal menyimpan lokasi');
    } finally {
      if (mounted) setState(() => _savingLocation = false);
    }
  }

  Widget _buildLocationSection() {
    final user = context.watch<UserProvider>();
    final hasLocation = user.hasLocation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasLocation ? Icons.location_on : Icons.location_off_outlined,
                color: hasLocation ? AppColors.primary : context.mutedColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lokasi Penjualan',
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasLocation
                ? 'Tersimpan: ${user.latitude!.toStringAsFixed(5)}, ${user.longitude!.toStringAsFixed(5)}'
                : 'Belum diatur. Lokasi dipakai menghitung ongkos kirim untuk pembeli.',
            style: TextStyle(color: context.mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _savingLocation ? null : _simpanLokasi,
              icon: _savingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(
                hasLocation ? 'Perbarui Lokasi Saya' : 'Gunakan Lokasi Saya',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final canAddMore = _images.length < _maxImages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Gambar Produk',
                style: TextStyle(color: context.textColor, fontSize: 14)),
            const SizedBox(width: 6),
            Text('(${_images.length}/$_maxImages, foto pertama jadi utama)',
                style: TextStyle(color: context.mutedColor, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        if (_images.isNotEmpty) ...[
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _imageThumb(context, i),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (_uploadingImages || !canAddMore)
                    ? null
                    : _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Galeri'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    (_uploadingImages || !canAddMore) ? null : _pickFromCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Kamera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_uploadingImages)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
                SizedBox(width: 8),
                Text('Mengunggah gambar...',
                    style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        LabeledField(
          label: 'atau tempel URL gambar',
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _urlController,
                  hint: 'https://...',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: canAddMore ? _addUrl : null,
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imageThumb(BuildContext context, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ProductImage(
            imageUrl: _images[index],
            width: 96,
            height: 96,
            iconSize: 28,
          ),
        ),
        if (index == 0)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: const Text('Utama',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
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
                label: 'Berat Limbah Terselamatkan (kg/unit)',
                child: AppTextField(
                  controller: _wasteController,
                  hint: 'mis. 2.5 — berat limbah yang didaur ulang per unit',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Dipakai menghitung dampak lingkungan pembeli & kamu. Kosongkan jika tidak relevan.',
                style: TextStyle(color: context.mutedColor, fontSize: 12),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Berat Produk (kg/unit)',
                child: AppTextField(
                  controller: _weightController,
                  hint: 'mis. 5 — berat fisik per unit untuk ongkos kirim',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Dipakai menghitung ongkos kirim berdasarkan berat & jarak.',
                style: TextStyle(color: context.mutedColor, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _buildLocationSection(),
              const SizedBox(height: 16),
              _buildImageSection(context),
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
