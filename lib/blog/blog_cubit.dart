// lib/blog/blog_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'blog_state.dart';
<<<<<<< HEAD
import '../models/blog.dart'; // Sesuaikan path jika perlu

class BlogCubit extends Cubit<BlogState> {
  // API Key diambil dari contoh Anda
  final String _apiKey = '33c217971fa5491dbe7abb038c95d399';

  BlogCubit() : super(BlogInitial());

  // -------------------------------------------------------------------
  // PERUBAHAN: fetchBlogs() sekarang menerima parameter
  // -------------------------------------------------------------------
  Future<void> fetchBlogs({
    String? searchQuery,
    String? sortBy,
    String? language,
  }) async {
    emit(BlogLoading());
    try {
      // Menyiapkan parameter kueri
      final Map<String, String> queryParameters = {
        'q': searchQuery ?? 'Pendidikan', // Default jika null
        'language': language ?? 'id', // Default jika null
        'sortBy': sortBy ?? 'publishedAt', // Default jika null
        'apiKey': _apiKey,
        'pageSize': '10', // Batasi 10 berita
      };

      // Membuat URI
      final uri = Uri.https('newsapi.org', '/v2/everything', queryParameters);
=======
import '../models/blog.dart';

class BlogCubit extends Cubit<BlogState> {
  final String _apiKey = 'pub_995e693ea40d47dc8d79482124903dc3';

  BlogCubit() : super(BlogInitial());

  Future<void> fetchBlogs({
    String? searchQuery,
    String? language, // Parameter ini sebelumnya diabaikan
  }) async {
    emit(BlogLoading());
    try {
      // Logika Query: Jika user mengetik pencarian sendiri, gunakan itu.
      // Jika kosong, default ke 'Pendidikan'.
      final String query = (searchQuery != null && searchQuery.isNotEmpty) 
          ? searchQuery 
          : 'Pendidikan';

      // Logika Bahasa: Gunakan pilihan user, jika null default ke 'id'
      final String lang = language ?? 'id';

      final Map<String, String> queryParameters = {
        'apikey': _apiKey,
        'q': query,
        'country': 'id',           
        'category': 'education',   // Tetap memfilter kategori pendidikan
        'language': lang,          // PERBAIKAN: Menggunakan variabel lang, bukan string 'id'
      };

      final uri = Uri.https('newsdata.io', '/api/1/latest', queryParameters);
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
<<<<<<< HEAD
        if (responseData['status'] == 'ok') {
          // Mengambil list 'articles' dari respons
          final List<dynamic> data = responseData['articles'];
          final blogs = data.map((json) => Blog.fromJson(json)).toList();
          
          emit(BlogLoaded(blogs));
        } else {
          // Menampilkan pesan error dari NewsAPI
          emit(BlogError(responseData['message'] ?? 'Gagal memuat blog'));
        }
      } else {
        // Menampilkan error status code (401, 500, dll.)
        emit(BlogError("Gagal memuat blog (Status: ${response.statusCode})"));
      }
    } catch (e) {
      // Menampilkan error koneksi atau timeout
      emit(BlogError("Terjadi kesalahan jaringan: ${e.toString()}"));
=======
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['results'];
          final blogs = data.map((json) => Blog.fromJson(json)).toList();
          emit(BlogLoaded(blogs));
        } else {
          // Menangani jika API sukses tapi results kosong atau error message dari API
          emit(BlogError(responseData['message'] ?? 'Gagal memuat berita.'));
        }
      } else {
        emit(BlogError("Error ${response.statusCode}: Gagal memuat data."));
      }
    } catch (e) {
      emit(BlogError("Kesalahan koneksi: ${e.toString()}"));
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
    }
  }
}