import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../data/ecocycle_feature_data.dart';

class ExpertConsultationScreen extends StatefulWidget {
  const ExpertConsultationScreen({super.key});

  @override
  State<ExpertConsultationScreen> createState() =>
      _ExpertConsultationScreenState();
}

class _ExpertConsultationScreenState extends State<ExpertConsultationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = expertCategories.first;

  List<ExpertProfile> get _filteredExperts {
    final query = _searchController.text.trim().toLowerCase();

    return expertProfiles.where((expert) {
      final matchCategory =
          _selectedCategory == 'Semua' ||
          expert.focus == _selectedCategory ||
          expert.specialty.toLowerCase().contains(
            _selectedCategory.toLowerCase(),
          );
      final matchSearch =
          query.isEmpty ||
          expert.name.toLowerCase().contains(query) ||
          expert.specialty.toLowerCase().contains(query) ||
          expert.focus.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  List<ExpertProfile> get _recommendedExperts {
    final experts = _filteredExperts
        .where((expert) => expert.isOnline)
        .toList();
    return experts.isEmpty
        ? _filteredExperts.take(2).toList()
        : experts.take(2).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(ExpertProfile expert) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConsultationChatScreen(expert: expert)),
    );
  }

  void _openNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConsultationNotesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final experts = _filteredExperts;
    final recommendedExperts = _recommendedExperts;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildSearchField(),
              const SizedBox(height: 18),
              const Text(
                'Kategori Populer',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Rekomendasi Untukmu',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _openNotes,
                    child: const Text(
                      'Riwayat',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recommendedExperts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Belum ada ahli yang cocok dengan filter aktif. Coba kategori lain.',
                    style: TextStyle(color: Colors.white54, height: 1.5),
                  ),
                )
              else
                SizedBox(
                  height: 276,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedExperts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, index) => _ExpertSpotlightCard(
                      expert: recommendedExperts[index],
                      onTap: () => _openChat(recommendedExperts[index]),
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              const Text(
                'Semua Ahli',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (experts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Tidak ada ahli yang ditemukan.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                ...experts.map(
                  (expert) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ExpertListTile(
                      expert: expert,
                      onTap: () => _openChat(expert),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _SurfaceIconButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Konsultasi Ahli',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _SurfaceIconButton(icon: Icons.history, onTap: _openNotes),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Cari ahli atau topik konsultasi...',
          hintStyle: TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.search, color: Colors.white38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: expertCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final category = expertCategories[index];
          final selected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ConsultationChatScreen extends StatefulWidget {
  final ExpertProfile expert;

  const ConsultationChatScreen({super.key, required this.expert});

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final List<ChatMessageData> _messages;

  @override
  void initState() {
    super.initState();
    _messages = buildInitialChat(widget.expert);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage([String? value]) {
    final text = (value ?? _messageController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessageData(isFromExpert: false, text: text, timeLabel: _timeNow()),
      );
      _messageController.clear();
    });

    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessageData(
            isFromExpert: true,
            text:
                'Terima kasih, saya catat dulu ya. Dari informasi awal ini, saya sarankan cek kondisi akar, kelembapan media, dan foto detail gejalanya supaya diagnosisnya lebih presisi.',
            timeLabel: _timeNow(),
          ),
        );
      });
    });
  }

  String _timeNow() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _openVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationVideoCallScreen(expert: widget.expert),
      ),
    );
  }

  void _openNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConsultationNotesScreen()),
    );
  }

  void _openReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationReviewScreen(expert: widget.expert),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildChatHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Hari ini',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ..._messages.map(
                    (message) =>
                        _ChatBubble(expert: widget.expert, message: message),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: consultationQuickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () =>
                      _sendMessage(consultationQuickPrompts[index]),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3B1A),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFF2E5C2E), width: 1),
                    ),
                    child: Text(
                      consultationQuickPrompts[index],
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  _ComposerIconButton(
                    icon: Icons.attach_file,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unggah lampiran akan segera hadir.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _ComposerIconButton(
                    icon: Icons.image_outlined,
                    onTap: () =>
                        _sendMessage('Saya kirim foto kondisi tanamannya.'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _sendMessage,
                    child: Ink(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          _ExpertAvatar(expert: widget.expert, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expert.name,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.expert.isOnline ? 'Online' : 'Offline'} • ${widget.expert.specialty}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.white70),
            onPressed: _openVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.white70),
            onPressed: _openVideoCall,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: AppColors.bgCard,
            onSelected: (value) {
              if (value == 'notes') {
                _openNotes();
              } else if (value == 'review') {
                _openReview();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'notes',
                child: Text(
                  'Lihat riwayat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: 'review',
                child: Text(
                  'Beri penilaian',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConsultationNotesScreen extends StatefulWidget {
  final bool embedded;

  const ConsultationNotesScreen({super.key, this.embedded = false});

  @override
  State<ConsultationNotesScreen> createState() =>
      _ConsultationNotesScreenState();
}

class _ConsultationNotesScreenState extends State<ConsultationNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = consultationHistoryFilters.first;

  List<ConsultationNoteData> get _filteredNotes {
    final query = _searchController.text.trim().toLowerCase();

    return consultationNotes.where((note) {
      final matchesFilter =
          _selectedFilter == 'Semua' ||
          note.specialty.toLowerCase().contains(
            _selectedFilter.toLowerCase(),
          ) ||
          note.expertName.toLowerCase().contains(
            _selectedFilter.toLowerCase(),
          ) ||
          (_selectedFilter == 'Terbaru' && note == consultationNotes.first);
      final matchesQuery =
          query.isEmpty ||
          note.expertName.toLowerCase().contains(query) ||
          note.specialty.toLowerCase().contains(query) ||
          note.expertDiagnosis.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(ConsultationNoteData note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConsultationDetailScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  if (widget.embedded)
                    const SizedBox(width: 42)
                  else
                    _SurfaceIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                  const Expanded(
                    child: Text(
                      'Catatan Konsultasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _SurfaceIconButton(
                    icon: Icons.more_vert,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sinkronisasi catatan akan segera hadir.',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Cari ahli atau diagnosis...',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search, color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: consultationHistoryFilters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, index) {
                        final filter = consultationHistoryFilters[index];
                        final selected = filter == _selectedFilter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white70,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada catatan yang cocok.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      itemCount: notes.length,
                      itemBuilder: (_, index) {
                        final note = notes[index];
                        final expert = expertForNote(note);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _openDetail(note),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFF173117),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _ExpertAvatar(expert: expert, size: 56),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              note.expertName,
                                              style: const TextStyle(
                                                color: AppColors.textWhite,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              note.specialty,
                                              style: const TextStyle(
                                                color: AppColors.primaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF163016),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Text(
                                          note.sessionDate,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Diagnosis:',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    note.diagnosisPreview,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsultationDetailScreen extends StatefulWidget {
  final ConsultationNoteData note;

  const ConsultationDetailScreen({super.key, required this.note});

  @override
  State<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  late List<bool> _completedSteps;

  ExpertProfile get _expert => expertForNote(widget.note);

  @override
  void initState() {
    super.initState();
    _completedSteps = widget.note.actionSteps
        .map((step) => step.isCompleted)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedSteps.where((item) => item).length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SurfaceIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Detail Konsultasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _SurfaceIconButton(
                    icon: Icons.download_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unduh ringkasan konsultasi akan segera hadir.',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF173117)),
                ),
                child: Row(
                  children: [
                    _ExpertAvatar(expert: _expert, size: 78),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.note.expertName,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.note.specialty,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.note.expertCredential,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      title: 'Tanggal sesi',
                      value: widget.note.sessionDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      title: 'ID sesi',
                      value: widget.note.sessionId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SubHeading(
                icon: Icons.description_outlined,
                title: 'Ringkasan Masalah',
              ),
              const SizedBox(height: 12),
              _HighlightedPanel(
                text: widget.note.issueSummary,
                accentColor: _expert.accentColor,
              ),
              const SizedBox(height: 24),
              const _SubHeading(
                icon: Icons.monitor_heart_outlined,
                title: 'Diagnosis Ahli',
              ),
              const SizedBox(height: 12),
              Text(
                widget.note.expertDiagnosis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: _SubHeading(
                      icon: Icons.check_box_outlined,
                      title: 'Langkah Tindakan',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF163016),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$completedCount/${widget.note.actionSteps.length} selesai',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF173117)),
                ),
                child: Column(
                  children: widget.note.actionSteps.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final step = entry.value;
                    final isChecked = _completedSteps[index];
                    return CheckboxListTile(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() => _completedSteps[index] = value ?? false);
                      },
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      title: Text(
                        step.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          step.description,
                          style: TextStyle(
                            color: Colors.white54,
                            height: 1.5,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),
              const Row(
                children: [
                  Expanded(
                    child: _SubHeading(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Produk Rekomendasi',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 320,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.note.productSuggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, index) => _ProductSuggestionCard(
                    product: widget.note.productSuggestions[index],
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.note.productSuggestions[index].name} ditambahkan ke daftar belanja.',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultationChatScreen(expert: _expert),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Hubungi Ahli Lagi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

class ConsultationVideoCallScreen extends StatefulWidget {
  final ExpertProfile expert;

  const ConsultationVideoCallScreen({super.key, required this.expert});

  @override
  State<ConsultationVideoCallScreen> createState() =>
      _ConsultationVideoCallScreenState();
}

class _ConsultationVideoCallScreenState
    extends State<ConsultationVideoCallScreen> {
  Timer? _timer;
  int _elapsedSeconds = 324;
  bool _muted = false;
  bool _videoEnabled = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedDuration {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationReviewScreen(expert: widget.expert),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding3.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.45),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF345C3B), Color(0xFF111111)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _VideoControlButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      _VideoControlButton(
                        icon: Icons.more_vert,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pengaturan panggilan segera hadir.',
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.expert.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formattedDuration,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: widget.expert.accentColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.expert.accentColor.withOpacity(0.7),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    widget.expert.icon,
                    color: Colors.white,
                    size: 82,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 132,
                    height: 170,
                    margin: const EdgeInsets.only(right: 22, bottom: 26),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Image.asset(
                      'assets/images/onboarding1.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.bgCard,
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _VideoAction(
                        label: _muted ? 'UNMUTE' : 'MUTE',
                        icon: _muted ? Icons.mic_off : Icons.mic_none,
                        onTap: () => setState(() => _muted = !_muted),
                      ),
                      _VideoAction(
                        label: _videoEnabled ? 'VIDEO' : 'VIDEO OFF',
                        icon: _videoEnabled
                            ? Icons.videocam_outlined
                            : Icons.videocam_off_outlined,
                        onTap: () =>
                            setState(() => _videoEnabled = !_videoEnabled),
                        active: _videoEnabled,
                      ),
                      _VideoAction(
                        label: 'END',
                        icon: Icons.call_end,
                        backgroundColor: const Color(0xFFE53935),
                        onTap: _endCall,
                        emphasize: true,
                      ),
                      _VideoAction(
                        label: 'SHARE',
                        icon: Icons.screen_share_outlined,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Berbagi layar akan segera hadir.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                      _VideoAction(
                        label: 'CHAT',
                        icon: Icons.chat_bubble_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ConsultationChatScreen(expert: widget.expert),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConsultationReviewScreen extends StatefulWidget {
  final ExpertProfile expert;

  const ConsultationReviewScreen({super.key, required this.expert});

  @override
  State<ConsultationReviewScreen> createState() =>
      _ConsultationReviewScreenState();
}

class _ConsultationReviewScreenState extends State<ConsultationReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  final Set<String> _selectedTags = {'Membantu'};

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terima kasih, ulasanmu sudah terkirim.'),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ConsultationNotesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SurfaceIconButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: widget.expert.accentColor.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.expert.accentColor,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        widget.expert.icon,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.expert.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.expert.specialty,
                      style: TextStyle(
                        color: widget.expert.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Bagaimana sesi konsultasimu?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = starIndex),
                    iconSize: 38,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                    icon: Icon(
                      starIndex <= _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF2F7D32),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _rating == 0
                    ? 'Tap bintang untuk memberi nilai'
                    : 'Nilai: $_rating/5',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tag Cepat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: reviewTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withOpacity(0.35)
                            : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFF173117),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: selected
                              ? AppColors.primaryLight
                              : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tulis Ulasan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF173117)),
                ),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan pengalaman konsultasimu...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _rating == 0 ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.bgCard,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Kirim Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Masukanmu membantu EcoCycle meningkatkan kualitas konsultasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpertSpotlightCard extends StatelessWidget {
  final ExpertProfile expert;
  final VoidCallback onTap;

  const _ExpertSpotlightCard({required this.expert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF173117)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ExpertAvatar(expert: expert, size: 82, showOnlineDot: true),
          const SizedBox(height: 14),
          Text(
            expert.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            expert.specialty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
              const SizedBox(width: 6),
              Text(
                '${expert.rating} (${expert.reviewCount})',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(expert.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertListTile extends StatelessWidget {
  final ExpertProfile expert;
  final VoidCallback onTap;

  const _ExpertListTile({required this.expert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF173117)),
        ),
        child: Row(
          children: [
            _ExpertAvatar(expert: expert, size: 62, showOnlineDot: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert.name,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expert.specialty,
                    style: TextStyle(color: expert.accentColor, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${expert.yearsExperience} th pengalaman   •   ${expert.sessions}+ sesi',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      expert.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF173117),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ExpertProfile expert;
  final ChatMessageData message;

  const _ChatBubble({required this.expert, required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment = message.isFromExpert
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    final bubbleColor = message.isFromExpert
        ? const Color(0xFF294129)
        : const Color(0xFF2E7D32);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: message.isFromExpert
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.isFromExpert) ...[
                _ExpertAvatar(expert: expert, size: 34),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(
              left: message.isFromExpert ? 44 : 0,
              right: message.isFromExpert ? 0 : 8,
            ),
            child: Text(
              message.isFromExpert
                  ? message.timeLabel
                  : '${message.timeLabel} • ${message.isRead ? 'Dibaca' : 'Terkirim'}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF173117)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedPanel extends StatelessWidget {
  final String text;
  final Color accentColor;

  const _HighlightedPanel({required this.text, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 17,
          height: 1.7,
        ),
      ),
    );
  }
}

class _ProductSuggestionCard extends StatelessWidget {
  final ProductSuggestion product;
  final VoidCallback onTap;

  const _ProductSuggestionCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF173117)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 136,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    product.accentColor.withOpacity(0.85),
                    const Color(0xFF173117),
                  ],
                ),
              ),
              child: Center(
                child: Icon(product.icon, color: Colors.white, size: 64),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        product.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      product.price,
                      style: TextStyle(
                        color: product.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                          side: const BorderSide(color: Color(0xFF2C5D2F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Beli Sekarang',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SubHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ExpertAvatar extends StatelessWidget {
  final ExpertProfile expert;
  final double size;
  final bool showOnlineDot;

  const _ExpertAvatar({
    required this.expert,
    required this.size,
    this.showOnlineDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [expert.accentColor, const Color(0xFF173117)],
            ),
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(expert.icon, color: Colors.white, size: size * 0.44),
        ),
        if (showOnlineDot)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: BoxDecoration(
                color: expert.isOnline ? AppColors.primary : Colors.blueGrey,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgDark, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _SurfaceIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SurfaceIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ComposerIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }
}

class _VideoControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _VideoControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.32),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _VideoAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final bool emphasize;
  final bool active;

  const _VideoAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.emphasize = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ??
        (active
            ? AppColors.primary.withOpacity(0.28)
            : Colors.white.withOpacity(0.12));

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: emphasize ? 68 : 54,
            height: emphasize ? 68 : 54,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: emphasize ? const Color(0xFFFFCDD2) : Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
