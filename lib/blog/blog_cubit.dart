// lib/blog/blog_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'blog_state.dart';
import '../data/model/blog.dart';

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

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
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
    }
  }
}
