import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

/// Menentukan `MediaType` (Content-Type) untuk file gambar yang akan diunggah.
///
/// Tanpa ini, `http.MultipartFile` mengirim `application/octet-stream`, sehingga
/// filter gambar di backend (`/^image\//`) menolak unggahan dengan pesan
/// "Hanya file gambar yang diperbolehkan". Kita pakai `mimeType` dari picker
/// bila tersedia, jika tidak tebak dari ekstensi nama file.
MediaType imageMediaType(XFile file) {
  final fromPicker = file.mimeType;
  if (fromPicker != null && fromPicker.startsWith('image/')) {
    return MediaType.parse(fromPicker);
  }

  final name = file.name.toLowerCase();
  final dot = name.lastIndexOf('.');
  final ext = dot >= 0 ? name.substring(dot + 1) : '';
  switch (ext) {
    case 'png':
      return MediaType('image', 'png');
    case 'gif':
      return MediaType('image', 'gif');
    case 'webp':
      return MediaType('image', 'webp');
    case 'heic':
      return MediaType('image', 'heic');
    case 'heif':
      return MediaType('image', 'heif');
    case 'bmp':
      return MediaType('image', 'bmp');
    case 'jpg':
    case 'jpeg':
    default:
      return MediaType('image', 'jpeg');
  }
}
