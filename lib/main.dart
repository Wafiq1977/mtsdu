import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:lpmmtsdu/data/model/assignment_submission.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'data/source/hive_service.dart';
import 'injector.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/bloc/auth_cubit.dart';
import 'presentation/provider/auth_provider.dart';
import 'presentation/provider/data_provider.dart';
import 'data/model/user.dart';
import 'data/model/schedule.dart';
import 'data/model/grade.dart';
import 'data/model/attendance.dart';
import 'data/model/assignment.dart';
import 'data/model/announcement.dart';
import 'data/model/payment.dart';
import 'data/model/academic_year.dart';
import 'domain/entity/user_entity.dart';
import 'domain/entity/attendance_entity.dart';
import 'domain/entity/schedule_entity.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => injector<AuthCubit>()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp.router(
        title: 'ESEMKA',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await HiveService.init();
  await _addSampleData();
  setupInjector();
  runApp(const MyApp());
}

Future<void> _addSampleData() async {
  final userBox = HiveService.getUserBox();
  if (userBox.isEmpty) {
    // Add admin
    final admin = User(
      id: 'admin',
      username: 'admin',
      password: 'admin',
      role: UserRole.admin,
      name: 'Admin User',
    );
    await userBox.put(admin.id, admin.toMap());

    // Add 20 teachers
    final subjects = [
      'B. Indo',
      'Matematika',
      'B. Inggris',
      'Agama',
      'PKN',
      'Olahraga',
      'Sistem Komputer',
      'Produk Kreatif dan Kewirausahaan',
      'Arsitektur Jaringan dan Komputer',
      'Desain Grafis Percetakan',
      'Desain Media Interaktif',
      'Teknik Animasi 2D dan 3D',
      'Pemrograman Dasar',
      'Basis Data',
      'Pemrograman Perangkat Lunak',
      'Otomatisasi Tata Kelola Perkantoran',
      'Pengelolaan Sistem Informasi',
      'Ekonomi dan Bisnis',
      'Teknologi Dasar Otomotif',
      'Pemeliharaan AC Kendaraan Ringan',
    ];
    final teacherNames = [
      'Egin',
      'Iqbal',
      'Izaz',
      'Ahmad',
      'Budi',
      'Cici',
      'Dedi',
      'Eka',
      'Fani',
      'Gina',
      'Hadi',
      'Ika',
      'Joko',
      'Kiki',
      'Lina',
      'Miko',
      'Nina',
      'Oki',
      'Pipi',
      'Rina',
    ];
    for (int i = 1; i <= 20; i++) {
      final teacher = User(
        id: 'teacher$i',
        username: teacherNames[i - 1],
        password: 'pass',
        role: UserRole.teacher,
        name: teacherNames[i - 1],
        nip: 'NIP${i.toString().padLeft(3, '0')}',
        subject: subjects[i - 1],
      );
      await userBox.put(teacher.id, teacher.toMap());
    }

    // Add students for classes 10A, 11A, 12A for each major
    final majors = [
      'Multimedia',
      'Rekayasa Perangkat Lunak',
      'Teknik Komputer dan Jaringan',
      'Manajemen',
      'Teknik Kendaraan Ringan Otomotif',
    ];
    final classes = [
      for (final major in majors)
        for (int grade = 10; grade <= 12; grade++)
          {'name': '${grade}A', 'major': major},
    ];
    final studentNames = [
      'Egin',
      'Iqbal',
      'Izaz',
      'Ahmad',
      'Budi',
      'Cici',
      'Dedi',
      'Eka',
      'Fani',
      'Gina',
      'Hadi',
      'Ika',
      'Joko',
      'Kiki',
      'Lina',
      'Miko',
      'Nina',
      'Oki',
      'Pipi',
      'Rina',
      'Sari',
      'Tono',
      'Umi',
      'Vivi',
      'Wawan',
      'Xena',
      'Yudi',
      'Zara',
      'Ali',
      'Lufita',
    ];
    int studentId = 1;
    for (final classInfo in classes) {
      for (int j = 1; j <= 5; j++) {
        final name = studentNames[(studentId - 1) % studentNames.length];
        final username = '$name ${classInfo['name']}';
        final student = User(
          id: 'student$studentId',
          username: username,
          password: 'pass',
          role: UserRole.student,
          name: name,
          className: classInfo['name'],
          major: classInfo['major'],
        );
        await userBox.put(student.id, student.toMap());
        studentId++;
      }
    }
  }
  final submissionBox = await Hive.openBox('assignment_submissions');
  if (submissionBox.isEmpty) {
    final submissions = [
      // Siswa 1: Mengumpulkan Tepat Waktu
      AssignmentSubmission(
        id: 'sub_s1_as3',
        assignmentId:
            'as3', // Mengerjakan soal Teks Eksposisi (Due: 2025-12-15)
        studentId: 'student1', // Egin 10A
        submissionDate: DateTime.parse('2025-12-14 10:00:00'),
        fileUrl: 'assets/submissions/tugas_egin.pdf',
        description: 'Tugas saya bu, sudah lengkap.',
        status: 'submitted',
      ),
      // Siswa 2: Mengumpulkan Terlambat
      AssignmentSubmission(
        id: 'sub_s2_as3',
        assignmentId: 'as3',
        studentId: 'student2', // Iqbal 10A
        submissionDate: DateTime.parse('2025-12-16 08:00:00'), // Telat 1 hari
        fileUrl: 'assets/submissions/tugas_iqbal_revisi.pdf',
        description: 'Maaf terlambat mengumpulkan karena sakit.',
        status: 'late',
      ),
      // Siswa 4: Sudah Dinilai (Graded)
      AssignmentSubmission(
        id: 'sub_s4_as3',
        assignmentId: 'as3',
        studentId: 'student4', // Ahmad 10A
        submissionDate: DateTime.parse('2025-12-10 09:00:00'),
        fileUrl: 'assets/submissions/tugas_ahmad.pdf',
        status: 'graded',
      ),
      // Siswa 6: Mengumpulkan
      AssignmentSubmission(
        id: 'sub_s6_as4',
        assignmentId: 'as4', // Soal Ulangan Harian (Due: 2025-12-02)
        studentId: 'student6', // Cici 11A
        submissionDate: DateTime.parse('2025-12-01 14:30:00'),
        fileUrl: 'assets/submissions/ulangan_cici.jpg',
        status: 'submitted',
      ),
      // Siswa 7: Mengumpulkan
      AssignmentSubmission(
        id: 'sub_s7_as4',
        assignmentId: 'as4',
        studentId: 'student7', // Dedi 11A
        submissionDate: DateTime.parse('2025-12-01 15:00:00'),
        fileUrl: 'assets/submissions/ulangan_dedi.jpg',
        status: 'submitted',
      ),

      // Skenario 3: Tugas Pemrograman Dasar (as13) - Kelas 10A RPL
      // RPL 10A adalah student16 s/d student20 (Urutan Major ke-2)
      AssignmentSubmission(
        id: 'sub_s16_as13',
        assignmentId: 'as13', // Kalkulator Python
        studentId: 'student16', // Miko 10A RPL
        submissionDate: DateTime.parse('2025-12-10 20:00:00'),
        fileUrl: 'github.com/miko/kalkulator.py',
        description: 'Source code ada di github pak.',
        status: 'submitted',
      ),
    ];

    // Simpan ke Hive
    for (final sub in submissions) {
      // Jika Anda belum men-generate Adapter, gunakan toMap()
      // Jika sudah ada Adapter: await submissionBox.put(sub.id, sub);
      await submissionBox.put(sub.id, sub.toMap());
    }

    // Add sample schedules
    final scheduleBox = HiveService.getScheduleBox();
    if (scheduleBox.isEmpty) {
      final schedules = [
        Schedule(
          id: 's1',
          subject: 'B. Indo',
          assignedToId: 'Egin',
          className: '10A',
          day: 'Monday',
          time: '08:00-09:00',
          room: '101',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 's2',
          subject: 'Matematika',
          assignedToId: 'Iqbal',
          className: '10A',
          day: 'Tuesday',
          time: '09:00-10:00',
          room: '102',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 's3',
          subject: 'B. Inggris',
          assignedToId: 'Izaz',
          className: '10A',
          day: 'Wednesday',
          time: '10:00-11:00',
          room: '103',
          scheduleType: ScheduleType.teacher,
        ),
      ];
      for (final schedule in schedules) {
        await scheduleBox.put(schedule.id, schedule.toMap());
      }
    }

    // Add sample grades
    final gradeBox = HiveService.getGradeBox();
    if (gradeBox.isEmpty) {
      final grades = [
        Grade(
          id: 'g1',
          studentId: 'student1',
          subject: 'Mathematics',
          assignment: 'Quiz 1',
          score: 85.0,
          date: '2024-01-15',
          teacherId: 'teacher1',
        ),
        Grade(
          id: 'g2',
          studentId: 'student1',
          subject: 'Physics',
          assignment: 'Lab Report',
          score: 92.0,
          date: '2024-01-20',
          teacherId: 'teacher2',
        ),
      ];
      for (final grade in grades) {
        await gradeBox.put(grade.id, grade.toMap());
      }
    }

    // Add sample attendance
    final attendanceBox = HiveService.getAttendanceBox();
    if (attendanceBox.isEmpty) {
      final attendances = [
        Attendance(
          id: 'a1',
          studentId: 'student1',
          subject: 'Mathematics',
          date: '2024-01-15',
          status: AttendanceStatus.present,
          teacherId: 'teacher2',
        ),
        Attendance(
          id: 'a2',
          studentId: 'student1',
          subject: 'Physics',
          date: '2024-01-16',
          status: AttendanceStatus.present,
          teacherId: 'teacher2',
        ),
      ];
      for (final attendance in attendances) {
        await attendanceBox.put(attendance.id, attendance.toMap());
      }
    }

    // Add sample assignments
    final assignmentBox = HiveService.getAssignmentBox();
    if (assignmentBox.isEmpty) {
      final assignments = [
        Assignment(
          id: 'as1',
          title: 'Mathematics Homework!',
          description: 'Complete exercises 1-10 from chapter 5',
          subject: 'Matematika',
          teacherId: 'teacher2',
          className: '10A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2024-01-25',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as2',
          title: 'Physics Lab Report',
          description: 'Write a report on the pendulum experiment',
          subject: 'B. Inggris',
          teacherId: 'teacher3',
          className: '12A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2024-01-30',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as3',
          title: 'Mengerjakan soal Teks Eksposisi',
          description:
              'Bacalah Materi tentang Teks Eksposisi lalu kerjakan Lembar Kerja dari Bab I, II, dan III',
          subject: 'B.Indo',
          teacherId: 'teacher1',
          className: '10A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2025-12-15',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as4',
          title: 'Soal Ulangan Harian',
          description:
              'Soal ulangan harian ini disusun untuk menguji pemahaman siswa kelas XI Multimedia II pada materi invitation text (undangan). Siswa diminta membaca dan memahami teks undangan untuk menjawab pertanyaan berupa reading comprehension, serta mengidentifikasi bagian-bagian undangan pada soal penulisan personal invitation. Waktu pengerjaan adalah 45 menit.',
          subject: 'B.Inggris',
          teacherId: 'teacher3',
          className: '11A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2025-12-2',
          attachmentPath: '../../asset/Soal_Ulangan_Harian_B.Inggris.pdf',
        ),
        Assignment(
          id: 'as2_mat',
          title: 'Latihan Soal Matriks',
          description:
              'Mengerjakan 20 soal tentang operasi matriks dan determinan',
          subject: 'Matematika',
          teacherId: 'teacher2',
          className: '11A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2025-12-12',
          attachmentPath: 'assets/assignments/soal_matriks.pdf',
        ),
        Assignment(
          id: 'as3_eng',
          title: 'Membuat Invitation Card',
          description:
              'Buatlah sebuah undangan formal dan informal dalam bahasa Inggris',
          subject: 'B. Inggris',
          teacherId: 'teacher3',
          className: '11A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2025-12-08',
          attachmentPath: 'assets/assignments/template_invitation.docx',
        ),
        Assignment(
          id: 'as4_agama',
          title: 'Hafalan Rukun Iman dan Islam',
          description:
              'Hafalkan rukun iman dan rukun Islam beserta penjelasannya',
          subject: 'Agama',
          teacherId: 'teacher4',
          className: '10A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2025-12-15',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as5',
          title: 'Essay Nilai-nilai Pancasila',
          description:
              'Tulis essay 500 kata tentang implementasi nilai Pancasila di kehidupan sehari-hari',
          subject: 'PKN',
          teacherId: 'teacher5',
          className: '10A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2025-12-20',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as6',
          title: 'Program Latihan Kebugaran',
          description:
              'Buat program latihan kebugaran selama 2 minggu dan dokumentasikan pelaksanaannya',
          subject: 'Olahraga',
          teacherId: 'teacher6',
          className: '10A',
          major: [
            'Rekayasa Perangkat Lunak',
            'Teknik Komputer dan Jaringan',
            'Menajemen',
            'Teknik Kendaraan Ringan Otomotif',
            'Multimedia',
          ],
          dueDate: '2025-12-25',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as7',
          title: 'Diagram Arsitektur Komputer',
          description:
              'Gambar dan jelaskan diagram blok arsitektur komputer Von Neumann',
          subject: 'Sistem Komputer',
          teacherId: 'teacher7',
          className: '10A',
          major: ['Teknik Komputer dan Jaringan'],
          dueDate: '2025-12-18',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as8',
          title: 'Presentasi Business Model Canvas',
          description:
              'Buat BMC untuk ide bisnis kreatif dan presentasikan di kelas',
          subject: 'Produk Kreatif dan Kewirausahaan',
          teacherId: 'teacher8',
          className: '12A',
          major: ['Multimedia'],
          dueDate: '2025-12-22',
          attachmentPath: 'assets/assignments/template_bmc.pptx',
        ),
        Assignment(
          id: 'as9',
          title: 'Konfigurasi Jaringan LAN',
          description:
              'Praktik konfigurasi jaringan LAN sederhana dan buat laporan',
          subject: 'Arsitektur Jaringan dan Komputer',
          teacherId: 'teacher9',
          className: '11A',
          major: ['Teknik Komputer dan Jaringan'],
          dueDate: '2025-12-14',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as10',
          title: 'Desain Poster Digital',
          description:
              'Buat desain poster digital dengan tema lingkungan hidup',
          subject: 'Desain Grafis Percetakan',
          teacherId: 'teacher10',
          className: '10A',
          major: ['Multimedia'],
          dueDate: '2025-12-16',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as11',
          title: 'Prototype Website Interaktif',
          description: 'Buat prototype website interaktif menggunakan Figma',
          subject: 'Desain Media Interaktif',
          teacherId: 'teacher11',
          className: '12A',
          major: ['Multimedia'],
          dueDate: '2025-12-19',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as12',
          title: 'Animasi Karakter 2D',
          description:
              'Buat animasi karakter 2D berjalan dengan minimal 12 frame',
          subject: 'Teknik Animasi 2D dan 3D',
          teacherId: 'teacher12',
          className: '11A',
          major: ['Multimedia'],
          dueDate: '2025-12-21',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as13',
          title: 'Program Kalkulator Sederhana',
          description: 'Buat program kalkulator sederhana menggunakan Python',
          subject: 'Pemrograman Dasar',
          teacherId: 'teacher13',
          className: '10A',
          major: ['Rekayasa Perangkat Lunak'],
          dueDate: '2025-12-11',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as14',
          title: 'Desain Database Perpustakaan',
          description: 'Buat ERD dan normalisasi database sistem perpustakaan',
          subject: 'Basis Data',
          teacherId: 'teacher14',
          className: '11A',
          major: ['Rekayasa Perangkat Lunak'],
          dueDate: '2025-12-17',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as15',
          title: 'Aplikasi CRUD Sederhana',
          description: 'Buat aplikasi CRUD sederhana dengan PHP dan MySQL',
          subject: 'Pemrograman Perangkat Lunak',
          teacherId: 'teacher15',
          className: '12A',
          major: ['Rekayasa Perangkat Lunak'],
          dueDate: '2025-12-23',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as16',
          title: 'Surat Bisnis',
          description: 'Buat 5 contoh surat bisnis dengan format yang benar',
          subject: 'Otomatisasi Tata Kelola Perkantoran',
          teacherId: 'teacher16',
          className: '11A',
          major: ['Manajemen'],
          dueDate: '2025-12-13',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as17',
          title: 'Analisis Sistem Informasi',
          description: 'Analisis sistem informasi pada sebuah perusahaan',
          subject: 'Pengelolaan Sistem Informasi',
          teacherId: 'teacher17',
          className: '12A',
          major: ['Manajemen'],
          dueDate: '2025-12-24',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as18',
          title: 'Studi Kasus Ekonomi',
          description: 'Analisis kasus ekonomi Indonesia terkini',
          subject: 'Ekonomi dan Bisnis',
          teacherId: 'teacher18',
          className: '11A',
          major: ['Manajemen'],
          dueDate: '2025-12-26',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as19',
          title: 'Identifikasi Komponen Mesin',
          description:
              'Identifikasi dan jelaskan fungsi 20 komponen mesin mobil',
          subject: 'Teknologi Dasar Otomotif',
          teacherId: 'teacher19',
          className: '10A',
          major: ['Teknik Kendaraan Ringan Otomotif'],
          dueDate: '2025-12-09',
          attachmentPath: 'null',
        ),
        Assignment(
          id: 'as20',
          title: 'Praktik Perawatan AC Mobil',
          description: 'Lakukan perawatan rutin AC mobil dan buat laporan',
          subject: 'Pemeliharaan AC Kendaraan Ringan',
          teacherId: 'teacher20',
          className: '11A',
          major: ['Teknik Kendaraan Ringan Otomotif'],
          dueDate: '2025-12-27',
          attachmentPath: 'null',
        ),
      ];
      for (final assignment in assignments) {
        await assignmentBox.put(assignment.id, assignment.toMap());
      }
    }

    // Add sample announcements
    final announcementBox = HiveService.getAnnouncementBox();
    if (announcementBox.isEmpty) {
      final announcements = [
        Announcement(
          id: 'an1',
          title: 'School Holiday',
          content: 'School will be closed on Monday due to national holiday.',
          authorId: 'admin',
          date: DateTime.parse('2024-01-10'),
          targetRole: 'all',
        ),
        Announcement(
          id: 'an2',
          title: 'Exam Schedule',
          content: 'Mid-term exams will start next week. Check your schedules.',
          authorId: 'admin',
          date: DateTime.parse('2024-01-12'),
          targetRole: 'student',
        ),
      ];
      for (final announcement in announcements) {
        await announcementBox.put(announcement.id, announcement.toMap());
      }
    }

    // Add sample payments
    final paymentBox = HiveService.getPaymentBox();
    if (paymentBox.isEmpty) {
      final payments = [
        Payment(
          id: 'p1',
          studentId: '1',
          month: 'January',
          year: 2024,
          amount: 500000.0,
          status: PaymentStatus.paid,
          paymentDate: '2024-01-05',
        ),
        Payment(
          id: 'p2',
          studentId: '1',
          month: 'February',
          year: 2024,
          amount: 500000.0,
          status: PaymentStatus.unpaid,
        ),
      ];
      for (final payment in payments) {
        await paymentBox.put(payment.id, payment.toMap());
      }
    }

    // Add sample materials
    final materialBox = HiveService.getMaterialBox();
    if (materialBox.isEmpty) {
      final materials = [
        // Materi untuk setiap guru
        material_model.Material(
          id: 'mat1',
          title: 'Pengenalan Teks Eksposisi',
          description:
              'Materi lengkap tentang teks eksposisi meliputi pengertian, struktur, dan ciri-ciri kebahasaan',
          subject: 'B. Indo',
          teacherId: 'teacher1', // Egin is teacher1
          className: '10A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/teks_eksposisi.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat2',
          title: 'Aljabar Linear',
          description:
              'Pembahasan matriks, determinan, dan sistem persamaan linear',
          subject: 'Matematika',
          teacherId: 'teacher2', // Iqbal is teacher2
          className: '11A',
          major: 'Rekayasa Perangkat Lunak',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/aljabar_linear.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat3',
          title: 'Invitation Text',
          description:
              'Materi tentang undangan formal dan informal dalam bahasa Inggris',
          subject: 'B. Inggris',
          teacherId: 'teacher3', // Izaz is teacher3
          className: '11A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/invitation_text.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat4',
          title: 'Akidah dan Akhlak Islam',
          description:
              'Penjelasan tentang rukun iman dan rukun Islam serta akhlak mulia',
          subject: 'Agama',
          teacherId: 'teacher4', // Ahmad is teacher4
          className: '10A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/akidah_akhlak.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat5',
          title: 'Pancasila dan UUD 1945',
          description:
              'Materi PKN tentang nilai-nilai Pancasila dan implementasinya',
          subject: 'PKN',
          teacherId: 'teacher5', // Budi is teacher5
          className: '10A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/pancasila.pptx',
          type: 'ppt',
        ),
        material_model.Material(
          id: 'mat6',
          title: 'Kebugaran Jasmani',
          description: 'Panduan latihan kebugaran dan kesehatan tubuh',
          subject: 'Olahraga',
          teacherId: 'teacher6', // Cici is teacher6
          className: '10A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/kebugaran.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat7',
          title: 'Arsitektur Komputer',
          description:
              'Penjelasan tentang komponen sistem komputer dan cara kerjanya',
          subject: 'Sistem Komputer',
          teacherId: 'teacher7', // Dedi is teacher7
          className: '10A',
          major: 'Teknik Komputer dan Jaringan',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/arsitektur_komputer.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat8',
          title: 'Business Model Canvas',
          description: 'Materi kewirausahaan tentang model bisnis canvas',
          subject: 'Produk Kreatif dan Kewirausahaan',
          teacherId: 'teacher8', // Eka is teacher8
          className: '12A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/business_canvas.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_tkj_10',
          title: 'Sistem Komputer - Komponen Hardware',
          description:
              'Pengenalan komponen hardware komputer: CPU, RAM, Motherboard, Storage, dan fungsinya dalam sistem komputer',
          subject: 'Sistem Komputer',
          teacherId: 'teacher7', // Dedi
          className: '10A',
          major: 'Teknik Komputer dan Jaringan',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/tkj/sistem_komputer_hardware.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_tkj_11',
          title:
              'Produk Kreatif dan Kewirausahaan - Strategi Pemasaran Digital',
          description:
              'Materi tentang strategi pemasaran digital untuk produk kreatif di bidang teknologi',
          subject: 'Produk Kreatif dan Kewirausahaan',
          teacherId: 'teacher8', // Eka
          className: '11A',
          major: 'Teknik Komputer dan Jaringan',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/tkj/pkk_pemasaran_digital.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_tkj_12',
          title: 'Arsitektur Jaringan Komputer - OSI Layer',
          description:
              'Pembahasan lengkap tentang model OSI 7 layer dan TCP/IP dalam jaringan komputer',
          subject: 'Arsitektur Jaringan dan Komputer',
          teacherId: 'teacher9', // Fani
          className: '12A',
          major: 'Teknik Komputer dan Jaringan',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/tkj/arsitektur_jaringan_osi.pdf',
          type: 'pdf',
        ),

        // MATERI PENJURUSAN MULTIMEDIA
        material_model.Material(
          id: 'mat_mm_10',
          title: 'Desain Grafis Percetakan - Prinsip Desain',
          description:
              'Materi tentang prinsip-prinsip desain grafis: komposisi, tipografi, warna, dan layout untuk media cetak',
          subject: 'Desain Grafis Percetakan',
          teacherId: 'teacher10', // Gina
          className: '10A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/multimedia/desain_grafis_prinsip.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_mm_11',
          title: 'Desain Media Interaktif - UI/UX Design',
          description:
              'Pengenalan User Interface dan User Experience design untuk website dan aplikasi mobile',
          subject: 'Desain Media Interaktif',
          teacherId: 'teacher11', // Hadi
          className: '11A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/multimedia/ui_ux_design.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_mm_12',
          title: 'Teknik Animasi 2D dan 3D - Prinsip Animasi',
          description:
              'Materi 12 prinsip animasi dan teknik pembuatan animasi 2D menggunakan frame by frame',
          subject: 'Teknik Animasi 2D dan 3D',
          teacherId: 'teacher12', // Ika
          className: '12A',
          major: 'Multimedia',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/multimedia/prinsip_animasi.pdf',
          type: 'pdf',
        ),

        // MATERI PENJURUSAN RPL (Rekayasa Perangkat Lunak)
        material_model.Material(
          id: 'mat_rpl_10',
          title: 'Pemrograman Dasar - Algoritma dan Flowchart',
          description:
              'Dasar-dasar algoritma pemrograman, flowchart, dan pseudocode untuk pemula',
          subject: 'Pemrograman Dasar',
          teacherId: 'teacher13', // Joko
          className: '10A',
          major: 'Rekayasa Perangkat Lunak',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/rpl/algoritma_flowchart.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_rpl_11',
          title: 'Basis Data - Normalisasi Database',
          description:
              'Materi tentang normalisasi database: 1NF, 2NF, 3NF, dan BCNF dengan contoh kasus',
          subject: 'Basis Data',
          teacherId: 'teacher14', // Kiki
          className: '11A',
          major: 'Rekayasa Perangkat Lunak',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/rpl/normalisasi_database.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_rpl_12',
          title: 'Pemrograman Perangkat Lunak - OOP dengan PHP',
          description:
              'Konsep Object Oriented Programming (OOP) dalam PHP: Class, Object, Inheritance, Polymorphism',
          subject: 'Pemrograman Perangkat Lunak',
          teacherId: 'teacher15', // Lina
          className: '12A',
          major: 'Rekayasa Perangkat Lunak',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/rpl/oop_php.pdf',
          type: 'pdf',
        ),

        // MATERI PENJURUSAN MANAJEMEN
        material_model.Material(
          id: 'mat_mnj_10',
          title: 'Otomatisasi Tata Kelola Perkantoran - Surat Menyurat',
          description:
              'Materi tentang jenis-jenis surat, format surat resmi, dan tata cara penulisan surat bisnis',
          subject: 'Otomatisasi Tata Kelola Perkantoran',
          teacherId: 'teacher16', // Miko
          className: '10A',
          major: 'Manajemen',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/manajemen/surat_menyurat.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_mnj_11',
          title: 'Pengelolaan Sistem Informasi - ERP System',
          description:
              'Pengenalan Enterprise Resource Planning (ERP) dan implementasinya dalam perusahaan',
          subject: 'Pengelolaan Sistem Informasi',
          teacherId: 'teacher17', // Nina
          className: '11A',
          major: 'Manajemen',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/manajemen/erp_system.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_mnj_12',
          title: 'Ekonomi dan Bisnis - Analisis SWOT',
          description:
              'Materi tentang analisis SWOT untuk strategi bisnis dan studi kasus perusahaan',
          subject: 'Ekonomi dan Bisnis',
          teacherId: 'teacher18', // Oki
          className: '12A',
          major: 'Manajemen',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/manajemen/analisis_swot.pdf',
          type: 'pdf',
        ),

        // MATERI PENJURUSAN TKRO (Teknik Kendaraan Ringan Otomotif)
        material_model.Material(
          id: 'mat_tkro_10',
          title: 'Teknologi Dasar Otomotif - Sistem Mesin',
          description:
              'Pengenalan sistem mesin kendaraan: mesin 2 tak, 4 tak, komponen utama, dan cara kerjanya',
          subject: 'Teknologi Dasar Otomotif',
          teacherId: 'teacher19', // Pipi
          className: '10A',
          major: 'Teknik Kendaraan Ringan Otomotif',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/tkro/sistem_mesin_otomotif.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_tkro_11',
          title: 'Pemeliharaan AC Kendaraan Ringan - Sistem Refrigerasi',
          description:
              'Materi tentang sistem refrigerasi AC mobil, komponen, dan prosedur perawatan berkala',
          subject: 'Pemeliharaan AC Kendaraan Ringan',
          teacherId: 'teacher20', // Rina
          className: '11A',
          major: 'Teknik Kendaraan Ringan Otomotif',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/tkro/ac_sistem_refrigerasi.pdf',
          type: 'pdf',
        ),
        material_model.Material(
          id: 'mat_tkro_12',
          title: 'Pemeliharaan Kelistrikan - Sistem Kelistrikan Body',
          description:
              'Pembahasan sistem kelistrikan body kendaraan: lampu, wiper, power window, dan central lock',
          subject: 'Pemeliharaan Kelistrikan',
          teacherId: 'teacher20', // Rina (karena hanya ada 20 guru)
          className: '12A',
          major: 'Teknik Kendaraan Ringan Otomotif',
          uploadDate: DateTime.now().toIso8601String(),
          url: 'assets/materials/tkro/kelistrikan_body.pdf',
          type: 'pdf',
        ),
      ];
      for (final material in materials) {
        await materialBox.put(material.id, material.toMap());
      }
    }
  }
}
