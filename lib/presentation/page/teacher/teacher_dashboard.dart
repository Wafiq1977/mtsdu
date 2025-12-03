import 'dart:convert'; // [PENTING] Untuk mengubah gambar jadi string (Base64)
import 'dart:typed_data'; // [PENTING] Untuk memproses data bytes gambar

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
// HAPUS import 'dart:io'; agar bisa jalan di WEB

// Pastikan path import ini sesuai dengan struktur project Anda
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../presentation/provider/theme_provider.dart';
import '../../../data/model/schedule.dart';
import '../../../data/model/grade.dart';
import '../../../data/model/attendance.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/announcement.dart';
import '../../../presentation/widgets/animated_navigation_bar.dart';
import '../../../presentation/widgets/statistics_widget.dart';
import 'teacher_materials_view.dart';
import 'teacher_input_grades_view.dart';
import 'teacher_input_attendance_view.dart';
import 'teacher_bulk_attendance_view.dart';
import 'assignment_detail_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showTools = false;
  String? _selectedDay;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentAnimation;

  // Daftar widget utama untuk setiap tab
  static const List<Widget> _widgetOptions = <Widget>[
    TeacherAnnouncementsView(),
    TeacherHomeView(),
    TeacherScheduleView(),
    TeacherProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTools() {
    setState(() {
      _showTools = !_showTools;
    });
    if (_showTools) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _selectDay(String day) {
    setState(() {
      _selectedDay = day;
    });
    _showDaySchedule(day);
  }

  void _showDaySchedule(String day) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    final daySchedules = dataProvider.schedules
        .where((s) => s.assignedToId == user.id && s.day == day)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              Text(
                'Jadwal $day',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(height: 20),
              if (daySchedules.isEmpty)
                const Text('Tidak ada kelas pada hari ini')
              else
                Expanded(
                  child: ListView(
                    children: daySchedules
                        .map(
                          (schedule) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Icon(
                                Icons.schedule,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(schedule.subject),
                              subtitle: Text(
                                '${schedule.time} - Ruang: ${schedule.room} - Kelas: ${schedule.className}',
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayButton(String day) {
    return ElevatedButton(
      onPressed: () => _selectDay(day),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedDay == day
            ? const Color(0xFF667EEA)
            : Colors.grey[300],
        foregroundColor: _selectedDay == day ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(day.substring(0, 3), style: const TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
              Color(0xFFF5576C),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _contentAnimation,
            child: Column(
              children: [
                // Header Profil
                SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _contentAnimationController,
                          curve: const Interval(
                            0.1,
                            0.6,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _contentAnimationController,
                        curve: const Interval(0.1, 0.5, curve: Curves.easeIn),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showProfileDialog(context, user, authProvider),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                image: user.profileImagePath != null
                                    ? DecorationImage(
                                        image: AssetImage(
                                          user.profileImagePath!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: user.profileImagePath == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang, ${user.name}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Mapel: ${user.subject ?? "Umum"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Konten Utama (Tab View)
                Expanded(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _contentAnimationController,
                        curve: const Interval(
                          0.3,
                          0.9,
                          curve: Curves.elasticOut,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _contentAnimationController,
                          curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: _widgetOptions.elementAt(_selectedIndex),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tools Section (Jadwal Toggle)
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  child: _showTools
                      ? FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _fabAnimationController,
                              curve: Curves.easeIn,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Alat Jadwal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF667EEA),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildDayButton('Monday'),
                                    _buildDayButton('Tuesday'),
                                    _buildDayButton('Wednesday'),
                                    _buildDayButton('Thursday'),
                                    _buildDayButton('Friday'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(_fabAnimationController),
          child: FloatingActionButton(
            onPressed: _toggleTools,
            backgroundColor: const Color(0xFF667EEA),
            elevation: 8,
            child: Icon(
              _showTools ? Icons.close : Icons.build,
              key: ValueKey<bool>(_showTools),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: AnimatedNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.announcement),
                label: 'Pengumuman',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Jadwal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedColor: const Color(0xFF667EEA),
            unselectedColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(
    BuildContext context,
    user,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              title: const Text('Profil Guru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: user.profileImagePath != null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                user.profileImagePath!,
                              ),
                            )
                          : const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person, size: 40),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text('Nama: ${user.name}'),
                    Text('Role: ${user.role.toString().split('.').last}'),
                    Text('Mapel: ${user.subject ?? "N/A"}'),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mode Gelap',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: const Color(0xFF667EEA),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const StatisticsWidget(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.logout();
                        Navigator.of(context).pop();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// 1. TEACHER ANNOUNCEMENTS VIEW (LOGIC GAMBAR WEB COMPATIBLE)
// ============================================================================
class TeacherAnnouncementsView extends StatelessWidget {
  const TeacherAnnouncementsView({super.key});

  // Helper function: Mendeteksi apakah path adalah Asset, Network, atau Base64 (Web)
  Widget _buildAnnouncementImage(String path) {
    if (path.isEmpty) return const SizedBox.shrink();

    if (path.startsWith('assets/')) {
      // 1. ASET BAWAAN
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        ),
      );
    } else if (path.startsWith('http')) {
      // 2. INTERNET
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        ),
      );
    } else {
      // 3. BASE64 STRING (Pengganti File Lokal untuk Web/HP)
      // Kita coba decode sebagai Base64. Jika gagal, tampilkan error.
      try {
        // Hapus header data uri jika ada (misal: "data:image/png;base64,")
        final cleanBase64 = path.contains(',') ? path.split(',').last : path;
        Uint8List bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey),
                  Text('Error', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        return Container(color: Colors.grey[200]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;

    final allAnnouncements = dataProvider.announcements.where((a) {
      return a.targetRole == 'all' ||
          a.targetRole == 'teacher' ||
          a.targetRole == 'student' ||
          a.authorId == user.id;
    }).toList();

    // Urutkan dari yang terbaru
    allAnnouncements.sort((a, b) => b.date.compareTo(a.date));

    return Container(
      color: Colors.red.shade50,
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pusat Informasi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pengumuman Sekolah & Guru',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // TOMBOL TAMBAH
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _showAnnouncementDialog(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF667EEA),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LIST PENGUMUMAN
          Expanded(
            child: allAnnouncements.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('Belum ada pengumuman'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: allAnnouncements.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final announcement = allAnnouncements[index];
                      // Logic Edit/Delete: Bisa edit jika User sendiri ATAU Admin
                      final isMine =
                          announcement.authorId == user.id ||
                          announcement.authorId == 'admin';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. BAGIAN GAMBAR
                              if (announcement.imageUrl != null &&
                                  announcement.imageUrl!.isNotEmpty)
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[200],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildAnnouncementImage(
                                    announcement.imageUrl!,
                                  ),
                                ),

                              // 2. BAGIAN KONTEN TEKS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Icon, Judul, Tanggal, Edit Button
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Ikon Tipe
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isMine
                                                ? Colors.blue.shade50
                                                : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Icon(
                                            isMine
                                                ? Icons.edit_note
                                                : Icons.campaign,
                                            color: isMine
                                                ? Colors.blue
                                                : Colors.red,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Judul & Tanggal
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                announcement.title,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${announcement.date.day}/${announcement.date.month}/${announcement.date.year}",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Tombol Aksi (Edit/Hapus)
                                        if (isMine)
                                          PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.more_vert,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showAnnouncementDialog(
                                                  context,
                                                  announcement: announcement,
                                                );
                                              } else if (value == 'delete') {
                                                _showDeleteConfirmDialog(
                                                  context,
                                                  announcement,
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      size: 16,
                                                      color: Colors.blue,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      size: 16,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Hapus'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Target Label
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          'To: ${announcement.targetRole == 'all' ? 'All' : announcement.targetRole.toUpperCase()}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // DIALOG ADD/EDIT PENGUMUMAN
  void _showAnnouncementDialog(
    BuildContext context, {
    Announcement? announcement,
  }) {
    final isEditing = announcement != null;
    final titleController = TextEditingController(
      text: isEditing ? announcement.title : '',
    );
    final contentController = TextEditingController(
      text: isEditing ? announcement.content : '',
    );
    String targetRole = isEditing ? announcement.targetRole : 'all';

    // State Lokal untuk menyimpan STRING BASE64 gambar
    String? selectedImagePath = isEditing ? announcement.imageUrl : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Pengumuman' : 'Buat Pengumuman Baru'),
        content: StatefulBuilder(
          builder: (context, setState) {
            // FUNGSI PICKER YANG WEB-COMPATIBLE
            Future<void> pickImage() async {
              try {
                // [PENTING] withData: true agar bytes tersedia di Web
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  withData: true,
                );

                if (result != null && result.files.single.bytes != null) {
                  // Konversi bytes ke Base64 String
                  String base64String = base64Encode(
                    result.files.single.bytes!,
                  );
                  setState(() {
                    selectedImagePath = base64String;
                  });
                }
              } catch (e) {
                debugPrint("Error picking image: $e");
              }
            }

            // Provider untuk menampilkan gambar (Memory/Asset)
            Widget getImageWidget(String path) {
              if (path.startsWith('assets/')) {
                return Image.asset(path, fit: BoxFit.cover);
              } else {
                // Asumsi Base64
                return Image.memory(
                  base64Decode(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 50),
                );
              }
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AREA PREVIEW & UPLOAD GAMBAR
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: getImageWidget(selectedImagePath!),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Ketuk untuk tambah foto",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                  // Tombol Hapus Gambar
                  if (selectedImagePath != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedImagePath = null;
                          });
                        },
                        child: const Text(
                          'Hapus Foto',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Isi Pengumuman',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: targetRole,
                    decoration: const InputDecoration(
                      labelText: 'Target Pemirsa',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Semua Warga Sekolah'),
                      ),
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('Hanya Siswa'),
                      ),
                      DropdownMenuItem(
                        value: 'teacher',
                        child: Text('Hanya Guru'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        targetRole = value!;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Validasi Input
              if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon lengkapi judul dan konten'),
                  ),
                );
                return;
              }

              // Akses Provider
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final dataProvider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              final user = authProvider.currentUser!;

              // Logika Simpan / Update
              if (isEditing) {
                final updatedAnnouncement = Announcement(
                  id: announcement!.id,
                  title: titleController.text,
                  content: contentController.text,
                  authorId: announcement.authorId,
                  date: DateTime.now(),
                  targetRole: targetRole,
                  imageUrl: selectedImagePath, // SIMPAN BASE64
                );

                await dataProvider.updateAnnouncement(updatedAnnouncement);
              } else {
                final newAnnouncement = Announcement(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  content: contentController.text,
                  authorId: user.id,
                  date: DateTime.now(),
                  targetRole: targetRole,
                  imageUrl: selectedImagePath, // SIMPAN BASE64
                );

                await dataProvider.addAnnouncement(newAnnouncement);
              }

              // Tutup Dialog & Tampilkan SnackBar
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Berhasil diperbarui'
                          : 'Berhasil diterbitkan',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Simpan' : 'Terbitkan'),
          ),
        ],
      ),
    );
  }

  // DIALOG KONFIRMASI HAPUS
  void _showDeleteConfirmDialog(
    BuildContext context,
    Announcement announcement,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${announcement.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final dataProvider = Provider.of<DataProvider>(
                context,
                listen: false,
              );
              await dataProvider.deleteAnnouncement(announcement.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengumuman dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// 2. TEACHER HOME VIEW (Tetap Sama)
class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final grades = dataProvider.grades
        .where((g) => g.teacherId == user.id)
        .toList();
    final attendances = dataProvider.attendances
        .where((a) => a.teacherId == user.id)
        .toList();
    final assignments = dataProvider.assignments
        .where((a) => a.teacherId == user.id)
        .toList();
    final materials = dataProvider.materials
        .where((material) => material.teacherId == user.id)
        .toList();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Beranda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactFeatureCard(
                        context,
                        'Input Nilai',
                        Icons.grade,
                        Colors.green,
                        grades.length,
                        () => GoRouter.of(
                          context,
                        ).go('/teacher-dashboard/beranda/input-grades'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactFeatureCard(
                        context,
                        'Absen',
                        Icons.check_circle,
                        Colors.orange,
                        attendances.length,
                        () => _showAttendanceOptionsDialog(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactFeatureCard(
                        context,
                        'Tugas',
                        Icons.assignment,
                        Colors.purple,
                        assignments.length,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AssignmentListPage(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactFeatureCard(
                        context,
                        'Materi',
                        Icons.book,
                        Colors.blue,
                        materials.length,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeacherMaterialsView(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Container()),
                    const SizedBox(width: 12),
                    Expanded(child: Container()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  'Selamat datang di Dashboard Guru',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    int count,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$count',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Options'),
        content: const Text('Choose how you want to input attendance:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherInputAttendanceView(),
                ),
              );
            },
            child: const Text('Single Student'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherBulkAttendanceView(),
                ),
              );
            },
            child: const Text('Bulk Input'),
          ),
        ],
      ),
    );
  }
}

// 3. TEACHER SCHEDULE VIEW (Tetap Sama)
class TeacherScheduleView extends StatelessWidget {
  const TeacherScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final schedules = dataProvider.schedules
        .where((s) => s.assignedToId == user.id)
        .toList();

    final Map<String, List<Schedule>> schedulesByDay = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
    };

    for (var schedule in schedules) {
      if (schedulesByDay.containsKey(schedule.day)) {
        schedulesByDay[schedule.day]!.add(schedule);
      }
    }

    return Container(
      color: Colors.purple.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Jadwal Mengajar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: schedulesByDay.entries.map((entry) {
                final day = entry.key;
                final daySchedules = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('${daySchedules.length} kelas'),
                    children: daySchedules.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Tidak ada jadwal'),
                            ),
                          ]
                        : daySchedules.map((schedule) {
                            return ListTile(
                              leading: const Icon(
                                Icons.class_,
                                color: Color(0xFF667EEA),
                              ),
                              title: Text(schedule.subject),
                              subtitle: Text(
                                'Class: ${schedule.className}\n${schedule.time} - Room: ${schedule.room}',
                              ),
                              isThreeLine: true,
                            );
                          }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. TEACHER PROFILE VIEW (Tetap Sama)
class TeacherProfileView extends StatelessWidget {
  const TeacherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    return Container(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: user.profileImagePath != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage(user.profileImagePath!),
                          )
                        : const CircleAvatar(
                            radius: 60,
                            child: Icon(Icons.person, size: 60),
                          ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Guru',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProfileInfo('Nama Lengkap', user.name),
                        _buildProfileInfo('Role', 'Teacher'),
                        _buildProfileInfo(
                          'Mata Pelajaran',
                          user.subject ?? 'General',
                        ),
                        _buildProfileInfo('Email', user.email ?? 'Tidak ada'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        authProvider.logout();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300, height: 1),
        ],
      ),
    );
  }
}

// 5. ASSIGNMENT PAGES (Tetap Sama)
class AssignmentListPage extends StatelessWidget {
  const AssignmentListPage({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.currentUser!;
    final assignments = dataProvider.assignments
        .where((a) => a.teacherId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: const Color(0xFF667EEA),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateAssignmentPage(),
              ),
            ),
          ),
        ],
      ),
      body: assignments.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Card(
                  child: ListTile(
                    title: Text(assignment.title),
                    subtitle: Text(assignment.subject),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssignmentDetailPage(assignment: assignment),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CreateAssignmentPage extends StatefulWidget {
  const CreateAssignmentPage({super.key});
  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tugas')),
      body: const Center(child: Text('Fitur Buat Tugas (Placeholder)')),
    );
  }
}
