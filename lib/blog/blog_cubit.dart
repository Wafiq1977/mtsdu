// lib/blog/blog_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'blog_state.dart';
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

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
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
    }
  }
}