// lib/blog/blog_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'blog_state.dart';
import '../data/model/blog.dart';

class BlogCubit extends Cubit<BlogState> {
  final String _apiKey = 'pub_995e693ea40d47dc8d79482124903dc3';
  
  // Instance Dio. Bisa di-pass lewat constructor (Injection) atau buat baru.
  final Dio _dio;

  // Constructor: Jika dio tidak dilempar (dari GetIt), buat instance baru.
  BlogCubit({Dio? dio}) : _dio = dio ?? Dio(), super(BlogInitial());

  Future<void> fetchBlogs({
    String? searchQuery,
    String? language,
  }) async {
    emit(BlogLoading());
    try {
      // 1. Logika Query
      final String query = (searchQuery != null && searchQuery.isNotEmpty) 
          ? searchQuery 
          : 'Pendidikan';

      // 2. Logika Bahasa
      final String lang = language ?? 'id';

      // 3. Persiapan Parameter
      final Map<String, dynamic> queryParameters = {
        'apikey': _apiKey,
        'q': query,
        'country': 'id',
        'category': 'education',
        'language': lang,
      };

      final response = await _dio.get(
        'https://newsdata.io/api/1/latest',
        queryParameters: queryParameters,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['results'];
          final blogs = data.map((json) => Blog.fromJson(json)).toList();
          emit(BlogLoaded(blogs));
        } else {
          emit(BlogError(responseData['message'] ?? 'Gagal memuat berita.'));
        }
      } else {
        emit(BlogError("Error ${response.statusCode}: Gagal memuat data."));
      }

    } on DioException catch (e) {
      String errorMessage = "Terjadi kesalahan koneksi.";
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Koneksi timeout. Silakan coba lagi.";
      } else if (e.response != null) {
        errorMessage = "Server Error: ${e.response?.statusCode}";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Tidak ada koneksi internet.";
      }

      emit(BlogError(errorMessage));
    } catch (e) {
      emit(BlogError("Kesalahan tidak terduga: ${e.toString()}"));
    }
  }
}