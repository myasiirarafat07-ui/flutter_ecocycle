import 'package:flutter/material.dart';

class HelpCategoryData {
  final String label;
  final String description;
  final IconData icon;
  final Color accentColor;

  const HelpCategoryData({
    required this.label,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class FaqEntry {
  final String category;
  final String question;
  final String answer;

  const FaqEntry({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class ArticleStep {
  final String title;
  final String description;

  const ArticleStep({required this.title, required this.description});
}

class EducationArticle {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String author;
  final String authorRole;
  final String publishedAt;
  final String readTime;
  final String heroAsset;
  final IconData heroIcon;
  final Color accentColor;
  final String intro;
  final String highlightTitle;
  final List<String> highlights;
  final String stepsTitle;
  final List<ArticleStep> steps;
  final String tipTitle;
  final List<String> tips;

  const EducationArticle({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.author,
    required this.authorRole,
    required this.publishedAt,
    required this.readTime,
    required this.heroAsset,
    required this.heroIcon,
    required this.accentColor,
    required this.intro,
    required this.highlightTitle,
    required this.highlights,
    required this.stepsTitle,
    required this.steps,
    required this.tipTitle,
    required this.tips,
  });
}

class ExpertProfile {
  final String id;
  final String name;
  final String specialty;
  final String focus;
  final double rating;
  final int reviewCount;
  final int yearsExperience;
  final int sessions;
  final bool isOnline;
  final Color accentColor;
  final IconData icon;
  final String actionLabel;

  const ExpertProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.focus,
    required this.rating,
    required this.reviewCount,
    required this.yearsExperience,
    required this.sessions,
    required this.isOnline,
    required this.accentColor,
    required this.icon,
    required this.actionLabel,
  });
}

class ChatMessageData {
  final bool isFromExpert;
  final String text;
  final String timeLabel;
  final bool isRead;

  const ChatMessageData({
    required this.isFromExpert,
    required this.text,
    required this.timeLabel,
    this.isRead = true,
  });
}

class ConsultationActionStep {
  final String title;
  final String description;
  final bool isCompleted;

  const ConsultationActionStep({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

class ProductSuggestion {
  final String name;
  final String subtitle;
  final String price;
  final IconData icon;
  final Color accentColor;

  const ProductSuggestion({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.accentColor,
  });
}

class ConsultationNoteData {
  final String id;
  final String expertId;
  final String expertName;
  final String specialty;
  final String sessionDate;
  final String sessionId;
  final String expertCredential;
  final String diagnosisPreview;
  final String issueSummary;
  final String expertDiagnosis;
  final List<ConsultationActionStep> actionSteps;
  final List<ProductSuggestion> productSuggestions;

  const ConsultationNoteData({
    required this.id,
    required this.expertId,
    required this.expertName,
    required this.specialty,
    required this.sessionDate,
    required this.sessionId,
    required this.expertCredential,
    required this.diagnosisPreview,
    required this.issueSummary,
    required this.expertDiagnosis,
    required this.actionSteps,
    required this.productSuggestions,
  });
}

const List<HelpCategoryData> helpCategories = [
  HelpCategoryData(
    label: 'Penjemputan',
    description: 'Jadwal pickup, drop-off, dan status kurir.',
    icon: Icons.local_shipping_outlined,
    accentColor: Color(0xFF66BB6A),
  ),
  HelpCategoryData(
    label: 'Marketplace',
    description: 'Transaksi, pembelian, dan pengiriman.',
    icon: Icons.storefront_outlined,
    accentColor: Color(0xFFFFD54F),
  ),
  HelpCategoryData(
    label: 'Akun',
    description: 'Profil, keamanan, dan pengelolaan akun.',
    icon: Icons.person_outline,
    accentColor: Color(0xFF64B5F6),
  ),
  HelpCategoryData(
    label: 'Pembayaran',
    description: 'Metode pembayaran, refund, dan Eco Points.',
    icon: Icons.account_balance_wallet_outlined,
    accentColor: Color(0xFFEF9A9A),
  ),
];

const List<FaqEntry> faqEntries = [
  FaqEntry(
    category: 'Penjemputan',
    question: 'Bagaimana cara menjadwalkan pickup limbah?',
    answer:
        'Buka tab Market atau layanan pickup, pilih jenis limbah, isi lokasi, lalu tentukan slot waktu yang tersedia. Tim EcoCycle akan mengonfirmasi jadwalmu lewat notifikasi.',
  ),
  FaqEntry(
    category: 'Penjemputan',
    question: 'Apakah ada minimal berat untuk penjemputan?',
    answer:
        'Untuk area kota, pickup reguler tersedia mulai 3 kg. Jika di bawah itu, kamu tetap bisa mengantar ke drop-off point terdekat tanpa biaya tambahan.',
  ),
  FaqEntry(
    category: 'Marketplace',
    question: 'Material apa saja yang bisa dijual atau didaur ulang?',
    answer:
        'Saat ini EcoCycle menerima plastik PET, kardus, kertas, logam ringan, kompos matang, dan beberapa limbah organik terpilah. Lihat label kategori di halaman Market untuk daftar lengkap.',
  ),
  FaqEntry(
    category: 'Marketplace',
    question: 'Bagaimana cara melacak pengiriman limbah atau pesanan?',
    answer:
        'Masuk ke halaman transaksi atau aktivitas, lalu buka detail sesi. Di sana akan tampil status pengiriman, estimasi tiba, dan kontak petugas bila tersedia.',
  ),
  FaqEntry(
    category: 'Akun',
    question: 'Bagaimana cara menghubungi ahli pertanian di EcoCycle?',
    answer:
        'Buka layanan Konsultasi Ahli dari beranda, pilih spesialis yang sesuai, lalu mulai chat atau pesan jadwal. Riwayat konsultasimu otomatis tersimpan di aplikasi.',
  ),
  FaqEntry(
    category: 'Akun',
    question: 'Bagaimana cara menukar Eco Points?',
    answer:
        'Eco Points bisa ditukar dari menu pembayaran atau reward saat poinmu memenuhi syarat minimum. Beberapa voucher dan potongan harga juga muncul otomatis di checkout.',
  ),
  FaqEntry(
    category: 'Pembayaran',
    question: 'Kapan refund atau pencairan saldo diproses?',
    answer:
        'Permintaan refund diproses dalam 1-3 hari kerja, sedangkan pencairan hasil penjualan biasanya masuk ke rekening dalam 24 jam setelah transaksi diverifikasi.',
  ),
  FaqEntry(
    category: 'Pembayaran',
    question: 'Apakah pembayaran EcoCycle aman?',
    answer:
        'Ya. Data pembayaran disimpan secara terenkripsi dan kamu bisa menyalakan konfirmasi transaksi atau PIN di menu Pengaturan Pembayaran untuk lapisan keamanan tambahan.',
  ),
];

const List<EducationArticle> educationArticles = [
  EducationArticle(
    id: 'hydroponic-basics',
    category: 'Hidroponik',
    title: 'Panduan Lengkap Hidroponik Skala Rumah Tangga',
    summary:
        'Belajar membangun sistem wick yang sederhana untuk sayuran daun di rumah dengan peralatan yang mudah dicari.',
    author: 'Dr. Hijau',
    authorRole: 'Pakar Pertanian Berkelanjutan',
    publishedAt: '24 Mei 2024',
    readTime: '8 menit baca',
    heroAsset: 'assets/images/onboarding3.png',
    heroIcon: Icons.water_drop_outlined,
    accentColor: Color(0xFF66BB6A),
    intro:
        'Hidroponik bukan lagi sekadar tren, melainkan solusi nyata bagi masyarakat perkotaan yang ingin mengonsumsi sayuran segar tanpa membutuhkan lahan luas.',
    highlightTitle: 'Mengapa Harus Hidroponik?',
    highlights: [
      'Efisiensi penggunaan air jauh lebih tinggi dibanding pertanian konvensional.',
      'Tanaman tumbuh lebih cepat karena nutrisi lebih terkontrol.',
      'Bersih, higienis, dan cocok untuk balkon, teras, atau halaman sempit.',
    ],
    stepsTitle: 'Langkah Memulai Sistem Wick',
    steps: [
      ArticleStep(
        title: 'Persiapan alat',
        description:
            'Siapkan botol bekas, kain flanel sebagai sumbu, nutrisi AB Mix, dan rockwool untuk penyemaian.',
      ),
      ArticleStep(
        title: 'Penyemaian benih',
        description:
            'Letakkan benih di rockwool yang lembap dan tunggu hingga muncul 3-4 daun sejati.',
      ),
      ArticleStep(
        title: 'Pemindahan ke sistem',
        description:
            'Pindahkan bibit ke net pot, pastikan sumbu menyentuh larutan nutrisi agar akar bisa menyerap air dengan stabil.',
      ),
    ],
    tipTitle: 'Tips cepat',
    tips: [
      'Cek pH nutrisi setiap 2-3 hari agar tetap di kisaran 5.5-6.5.',
      'Gunakan cahaya matahari pagi atau lampu tanam minimal 6 jam per hari.',
      'Mulai dari sayuran daun seperti selada, pakcoy, atau kangkung agar lebih mudah dipelajari.',
    ],
  ),
  EducationArticle(
    id: 'kitchen-waste-compost',
    category: 'Zero Waste',
    title: 'Cara Mengubah Sampah Dapur Menjadi Pupuk Organik',
    summary:
        'Panduan praktis membuat kompos rumahan yang tidak berbau dengan teknik takakura dan pemilahan bahan hijau-cokelat.',
    author: 'Dr. Hijau',
    authorRole: 'Pakar Lingkungan EcoCycle',
    publishedAt: '12 Okt 2023',
    readTime: '5 menit baca',
    heroAsset: 'assets/icons/tips_home.png',
    heroIcon: Icons.compost_outlined,
    accentColor: Color(0xFFFFC107),
    intro:
        'Mengompos di rumah bukan hanya cara cerdas untuk mendapatkan pupuk gratis, tetapi juga langkah nyata mengurangi volume sampah yang berakhir di TPA.',
    highlightTitle: 'Bahan yang Bisa Dikomposkan',
    highlights: [
      'Bahan hijau: sisa sayuran, buah, ampas kopi, dan potongan rumput segar.',
      'Bahan cokelat: daun kering, kardus tanpa tinta, serbuk gergaji, dan ranting kecil.',
      'Hindari daging, minyak berlebih, dan produk susu agar kompos tidak mudah berbau.',
    ],
    stepsTitle: 'Metode Takakura',
    steps: [
      ArticleStep(
        title: 'Siapkan wadah berpori',
        description:
            'Gunakan keranjang plastik atau ember berlubang yang sirkulasinya baik agar proses tetap aerobik.',
      ),
      ArticleStep(
        title: 'Buat alas kompos',
        description:
            'Gunakan bantalan sekam, kardus, atau kompos matang untuk menyerap cairan dan menjaga suhu tetap stabil.',
      ),
      ArticleStep(
        title: 'Masukkan sampah sedikit demi sedikit',
        description:
            'Potong kecil bahan organik, campur rata, lalu tutup dengan bahan cokelat agar kelembapan lebih seimbang.',
      ),
      ArticleStep(
        title: 'Aduk rutin',
        description:
            'Aduk 2-3 hari sekali supaya oksigen merata dan bakteri pengurai bekerja lebih cepat.',
      ),
    ],
    tipTitle: 'Tips menghindari bau',
    tips: [
      'Pastikan tekstur campuran menyerupai spons yang diperas, tidak terlalu basah.',
      'Jika bau asam muncul, tambahkan lebih banyak bahan cokelat seperti daun kering.',
      'Taburkan bio-aktivator secukupnya ketika proses kompos terasa lambat.',
    ],
  ),
  EducationArticle(
    id: 'circular-business',
    category: 'Ekonomi Sirkular',
    title: 'Membangun Bisnis Berbasis Zero-Waste untuk Komunitas',
    summary:
        'Strategi sederhana memulai usaha berbasis limbah yang memberi nilai tambah bagi lingkungan dan warga sekitar.',
    author: 'Rani Lestari',
    authorRole: 'Konsultan UMKM Hijau',
    publishedAt: '03 Apr 2024',
    readTime: '12 menit baca',
    heroAsset: 'assets/images/onboarding2.png',
    heroIcon: Icons.store_mall_directory_outlined,
    accentColor: Color(0xFF81C784),
    intro:
        'Bisnis zero-waste yang sehat berawal dari pemetaan limbah lokal, model pendapatan yang realistis, dan edukasi yang konsisten untuk pelanggan.',
    highlightTitle: 'Fondasi bisnis sirkular',
    highlights: [
      'Petakan jenis limbah yang paling sering dihasilkan komunitasmu.',
      'Tentukan produk akhir yang benar-benar dibutuhkan pasar lokal.',
      'Bangun rantai pasok yang singkat agar margin tetap sehat dan proses lebih efisien.',
    ],
    stepsTitle: 'Langkah awal yang direkomendasikan',
    steps: [
      ArticleStep(
        title: 'Mulai dari satu alur limbah',
        description:
            'Fokus pada satu kategori seperti plastik, organik, atau tekstil sampai proses operasional benar-benar stabil.',
      ),
      ArticleStep(
        title: 'Susun standar kualitas',
        description:
            'Tentukan standar sortasi, kebersihan bahan, dan kemasan agar produk siap dijual secara konsisten.',
      ),
      ArticleStep(
        title: 'Ukur dampak',
        description:
            'Catat volume limbah yang terserap, emisi yang dihindari, dan manfaat ekonomi bagi anggota komunitas.',
      ),
    ],
    tipTitle: 'Catatan penting',
    tips: [
      'Pilih model bisnis yang bisa dimulai kecil namun mudah direplikasi.',
      'Gabungkan edukasi dengan transaksi agar pelanggan paham nilai produknya.',
      'Gunakan marketplace lokal untuk memvalidasi permintaan lebih cepat.',
    ],
  ),
  EducationArticle(
    id: 'smart-irrigation',
    category: 'Teknologi',
    title: 'Implementasi IoT untuk Efisiensi Penggunaan Air',
    summary:
        'Cara memanfaatkan sensor kelembapan tanah, timer, dan notifikasi untuk kebun rumahan yang lebih hemat air.',
    author: 'Andi Wijaya',
    authorRole: 'Praktisi Smart Farming',
    publishedAt: '08 Jan 2024',
    readTime: '10 menit baca',
    heroAsset: 'assets/images/onboarding1.png',
    heroIcon: Icons.sensors_outlined,
    accentColor: Color(0xFF4DB6AC),
    intro:
        'Sistem irigasi berbasis sensor membantu petani dan pehobi mengurangi pemborosan air sekaligus menjaga tanaman tetap sehat.',
    highlightTitle: 'Manfaat utama',
    highlights: [
      'Penyiraman berjalan berdasarkan data, bukan tebakan.',
      'Kebutuhan air tanaman bisa dipantau walau kamu tidak sedang di lokasi.',
      'Alarm dan log sederhana membantu mendeteksi kebocoran lebih cepat.',
    ],
    stepsTitle: 'Komponen minimum',
    steps: [
      ArticleStep(
        title: 'Sensor kelembapan',
        description:
            'Pasang sensor di beberapa titik agar pembacaan kondisi tanah lebih representatif.',
      ),
      ArticleStep(
        title: 'Mikrokontroler dan relay',
        description:
            'Gunakan kontroler sederhana untuk menyalakan pompa atau valve berdasarkan ambang batas kelembapan.',
      ),
      ArticleStep(
        title: 'Dashboard notifikasi',
        description:
            'Buat notifikasi singkat untuk status pompa, level air, dan histori penyiraman agar perawatan lebih mudah.',
      ),
    ],
    tipTitle: 'Supaya implementasi sukses',
    tips: [
      'Kalibrasi sensor sebelum dipakai agar pembacaan tidak meleset.',
      'Mulai dari satu bedeng atau rak tanam sebelum memperluas ke area lain.',
      'Selalu siapkan mode manual jika listrik atau koneksi sedang bermasalah.',
    ],
  ),
];

const List<String> educationCategories = [
  'Semua',
  'Hidroponik',
  'Zero Waste',
  'Ekonomi Sirkular',
  'Teknologi',
];

const List<ExpertProfile> expertProfiles = [
  ExpertProfile(
    id: 'budi',
    name: 'Dr. Budi Santoso',
    specialty: 'Ahli Tanah & Kompos',
    focus: 'Urban Farming',
    rating: 4.9,
    reviewCount: 120,
    yearsExperience: 8,
    sessions: 250,
    isOnline: true,
    accentColor: Color(0xFF81C784),
    icon: Icons.park_outlined,
    actionLabel: 'Konsultasi',
  ),
  ExpertProfile(
    id: 'siti',
    name: 'Siti Aminah, M.Sc',
    specialty: 'Urban Farming Specialist',
    focus: 'Hidroponik',
    rating: 4.8,
    reviewCount: 85,
    yearsExperience: 6,
    sessions: 192,
    isOnline: false,
    accentColor: Color(0xFFFFCC80),
    icon: Icons.spa_outlined,
    actionLabel: 'Pesan Jadwal',
  ),
  ExpertProfile(
    id: 'andi',
    name: 'Andi Wijaya',
    specialty: 'Pakar Hidroponik',
    focus: 'Pertanian',
    rating: 5.0,
    reviewCount: 64,
    yearsExperience: 8,
    sessions: 250,
    isOnline: true,
    accentColor: Color(0xFF80CBC4),
    icon: Icons.water_drop_outlined,
    actionLabel: 'Chat Sekarang',
  ),
  ExpertProfile(
    id: 'dewi',
    name: 'Dewi Lestari',
    specialty: 'Ahli Manajemen Limbah',
    focus: 'Limbah',
    rating: 4.7,
    reviewCount: 140,
    yearsExperience: 5,
    sessions: 140,
    isOnline: true,
    accentColor: Color(0xFF90CAF9),
    icon: Icons.delete_outline,
    actionLabel: 'Konsultasi',
  ),
];

const List<String> expertCategories = [
  'Semua',
  'Pertanian',
  'Limbah',
  'Hidroponik',
  'Urban Farming',
];

List<ChatMessageData> buildInitialChat(ExpertProfile expert) {
  return [
    ChatMessageData(
      isFromExpert: true,
      text:
          'Halo! Saya ${expert.name}. Ceritakan kondisi tanaman atau limbah yang sedang kamu hadapi, nanti kita cari langkah terbaik bersama.',
      timeLabel: '09:41',
    ),
    const ChatMessageData(
      isFromExpert: false,
      text: 'Saya punya masalah dengan daun padi yang mulai menguning.',
      timeLabel: '09:42',
      isRead: true,
    ),
    const ChatMessageData(
      isFromExpert: true,
      text:
          'Bisa tolong kirim foto detail daun dan ceritakan pola penyiramannya? Saya perlu melihat gejalanya lebih jelas sebelum memberi diagnosis.',
      timeLabel: '09:43',
    ),
  ];
}

const List<String> consultationQuickPrompts = [
  'Kirim foto tanaman',
  'Tanya jadwal pupuk',
  'Cek gejala daun',
  'Bahas kompos',
];

const List<ConsultationNoteData> consultationNotes = [
  ConsultationNoteData(
    id: 'note-1',
    expertId: 'budi',
    expertName: 'Dr. Budi Santoso',
    specialty: 'Spesialis Pengolahan Limbah Organik',
    sessionDate: '14 Okt 2023',
    sessionId: 'EC-2023-9841',
    expertCredential: 'Sertifikasi Eco-Consultant',
    diagnosisPreview:
        '"Tumpukan kompos di area belakang rumah mulai mengeluarkan bau tidak sedap dan menarik lalat setelah hujan deras."',
    issueSummary:
        'Tumpukan kompos di area belakang rumah mulai mengeluarkan bau tidak sedap dan menarik lalat meskipun sudah rutin dibalik. Kelembapan terlihat tinggi setelah hujan deras minggu lalu.',
    expertDiagnosis:
        'Kondisi kompos mengarah ke fase anaerobik akibat rasio bahan cokelat yang kurang dan kadar air yang berlebih. Hal ini membuat bakteri pembusuk berkembang lebih cepat dibanding bakteri pengurai aerobik.',
    actionSteps: [
      ConsultationActionStep(
        title: 'Tambahkan bahan cokelat',
        description:
            'Masukkan daun kering atau kardus sekitar 30% dari volume kompos.',
        isCompleted: true,
      ),
      ConsultationActionStep(
        title: 'Pindahkan wadah',
        description:
            'Tempatkan komposter di area yang lebih teduh dan terlindung dari hujan.',
        isCompleted: true,
      ),
      ConsultationActionStep(
        title: 'Gunakan bio-aktivator',
        description:
            'Semprotkan EM4 untuk membantu menekan bau dan menyeimbangkan mikroba.',
      ),
      ConsultationActionStep(
        title: 'Aduk berkala',
        description:
            'Aduk rata setiap dua hari sekali selama satu minggu berikutnya.',
      ),
    ],
    productSuggestions: [
      ProductSuggestion(
        name: 'Bio-aktivator EM4 1L',
        subtitle: 'Penetral bau kompos',
        price: 'Rp 25.000',
        icon: Icons.science_outlined,
        accentColor: Color(0xFF81C784),
      ),
      ProductSuggestion(
        name: 'Starter Kompos Organik',
        subtitle: 'Membantu dekomposisi',
        price: 'Rp 45.000',
        icon: Icons.grass_outlined,
        accentColor: Color(0xFF66BB6A),
      ),
    ],
  ),
  ConsultationNoteData(
    id: 'note-2',
    expertId: 'siti',
    expertName: 'Siti Aminah, M.Sc',
    specialty: 'Spesialis Pertanian Organik',
    sessionDate: '12 Okt 2023',
    sessionId: 'EC-2023-9702',
    expertCredential: 'Konsultan Urban Farm',
    diagnosisPreview:
        '"Gejala layu pada tanaman sawi dipicu kombinasi media tanam terlalu padat dan sirkulasi air yang kurang baik."',
    issueSummary:
        'Tanaman sawi di rak vertikal tampak layu saat siang hari walaupun penyiraman cukup. Daun bagian bawah mulai menguning sejak minggu lalu.',
    expertDiagnosis:
        'Media tanam terlalu padat sehingga akar kesulitan bernapas dan suhu media cepat naik. Tanaman juga menerima cahaya sore berlebih tanpa naungan sehingga stres air meningkat.',
    actionSteps: [
      ConsultationActionStep(
        title: 'Perbaiki media',
        description:
            'Campur sekam bakar dan cocopeat untuk meningkatkan porositas.',
        isCompleted: true,
      ),
      ConsultationActionStep(
        title: 'Pasang naungan ringan',
        description: 'Gunakan paranet tipis saat matahari siang terlalu terik.',
      ),
      ConsultationActionStep(
        title: 'Evaluasi frekuensi siram',
        description:
            'Gunakan semprotan pagi dan sore agar kelembapan lebih stabil.',
      ),
    ],
    productSuggestions: [
      ProductSuggestion(
        name: 'Cocopeat Premium',
        subtitle: 'Media tanam porous',
        price: 'Rp 18.000',
        icon: Icons.filter_vintage_outlined,
        accentColor: Color(0xFFFFCC80),
      ),
    ],
  ),
  ConsultationNoteData(
    id: 'note-3',
    expertId: 'dewi',
    expertName: 'Dewi Lestari',
    specialty: 'Ahli Manajemen Limbah',
    sessionDate: '08 Okt 2023',
    sessionId: 'EC-2023-9568',
    expertCredential: 'Waste Recovery Specialist',
    diagnosisPreview:
        '"Kadar pH limbah cair terlalu tinggi dan diperlukan bak sedimentasi tambahan sebelum pembuangan."',
    issueSummary:
        'Limbah cair dari usaha kecil terlihat keruh, berbau, dan menghasilkan endapan setelah proses pembersihan alat. pH awal terukur di atas ambang aman.',
    expertDiagnosis:
        'pH limbah yang terlalu tinggi dan padatan tersuspensi perlu distabilkan lebih dulu. Sistem filtrasi awal yang ada belum cukup untuk menahan partikel halus dan residu deterjen.',
    actionSteps: [
      ConsultationActionStep(
        title: 'Bangun bak sedimentasi sederhana',
        description:
            'Sediakan penampungan awal sebelum air mengalir ke filter berikutnya.',
        isCompleted: true,
      ),
      ConsultationActionStep(
        title: 'Ukur pH harian',
        description: 'Catat perubahan pH agar dosis penetral lebih akurat.',
      ),
      ConsultationActionStep(
        title: 'Gunakan filter karbon aktif',
        description: 'Tambahkan lapisan karbon untuk membantu menurunkan bau.',
      ),
    ],
    productSuggestions: [
      ProductSuggestion(
        name: 'Karbon Aktif Filter',
        subtitle: 'Mengurangi bau limbah',
        price: 'Rp 32.000',
        icon: Icons.opacity_outlined,
        accentColor: Color(0xFF90CAF9),
      ),
    ],
  ),
];

const List<String> consultationHistoryFilters = [
  'Semua',
  'Pertanian',
  'Limbah',
  'Terbaru',
];

const List<String> reviewTags = [
  'Membantu',
  'Informatif',
  'Audio Jernih',
  'Ramah',
  'Saran Praktis',
];

EducationArticle educationArticleById(String id) =>
    educationArticles.firstWhere((article) => article.id == id);

ExpertProfile expertById(String id) =>
    expertProfiles.firstWhere((expert) => expert.id == id);

ExpertProfile expertForNote(ConsultationNoteData note) {
  return expertProfiles.firstWhere(
    (expert) => expert.id == note.expertId,
    orElse: () => expertProfiles.first,
  );
}
