// lib/blog/blog_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'blog_cubit.dart';
import 'blog_state.dart';
import '../models/blog.dart'; // Sesuaikan path jika perlu

// -------------------------------------------------------------------
// PERUBAHAN: Diubah menjadi StatefulWidget
// -------------------------------------------------------------------
=======
import 'package:go_router/go_router.dart';
import 'blog_cubit.dart';
import 'blog_state.dart';
import '../models/blog.dart';

>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
class BlogView extends StatefulWidget {
  const BlogView({super.key});

  @override
  State<BlogView> createState() => _BlogViewState();
}

class _BlogViewState extends State<BlogView> {
<<<<<<< HEAD
  // State untuk menyimpan nilai filter
  late TextEditingController _searchController;
  String _selectedSortBy = 'publishedAt'; // 'publishedAt', 'popularity', 'relevancy'
  String _selectedLanguage = 'id'; // 'id', 'en', 'ar', 'de'
=======
  late TextEditingController _searchController;
  String _selectedLanguage = 'id';
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    // Inisialisasi state filter
=======
    // Default text sesuai logic cubit
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
    _searchController = TextEditingController(text: 'Pendidikan');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // Method untuk memicu Cubit mengambil data baru
  void _applyFilters() {
    // Membaca Cubit dari context dan memanggil fetchBlogs dengan state filter saat ini
    context.read<BlogCubit>().fetchBlogs(
      searchQuery: _searchController.text.isNotEmpty ? _searchController.text : 'Pendidikan',
      sortBy: _selectedSortBy,
=======
  void _applyFilters() {
    // Menutup keyboard saat search dimulai
    FocusScope.of(context).unfocus();
    
    context.read<BlogCubit>().fetchBlogs(
      searchQuery: _searchController.text,
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
      language: _selectedLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
<<<<<<< HEAD
      // Panggilan fetch awal saat widget pertama kali dibuat
      create: (context) => BlogCubit()..fetchBlogs(
        searchQuery: _searchController.text,
        sortBy: _selectedSortBy,
        language: _selectedLanguage,
      ),
      // -------------------------------------------------------------------
      // PERUBAHAN: Membungkus BlocBuilder di dalam Column
      // -------------------------------------------------------------------
      child: Column(
        children: [
          // 1. Tampilkan UI Filter
          _buildFilterWidgets(),
          
          // 2. Tampilkan hasil dari BlocBuilder
          BlocBuilder<BlogCubit, BlogState>(
            builder: (context, state) {
              if (state is BlogLoading || state is BlogInitial) {
                // Tampilkan loading di bawah filter
=======
      create: (context) => BlogCubit()..fetchBlogs(
        searchQuery: _searchController.text,
        language: _selectedLanguage,
      ),
      child: Column(
        children: [
          _buildFilterWidgets(),
          BlocBuilder<BlogCubit, BlogState>(
            builder: (context, state) {
              if (state is BlogLoading) {
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is BlogError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
<<<<<<< HEAD
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
=======
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _applyFilters,
                          child: const Text("Coba Lagi"),
                        )
                      ],
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
                    ),
                  ),
                );
              } else if (state is BlogLoaded) {
                return _buildBlogList(context, state.blogs);
              }
<<<<<<< HEAD
              return const SizedBox.shrink(); // State tidak terduga
=======
              return const SizedBox.shrink();
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
            },
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // -------------------------------------------------------------------
  // WIDGET BARU: Untuk UI Filter (Search + Dropdown)
  // -------------------------------------------------------------------
  Widget _buildFilterWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Cari Berita',
              hintText: 'Masukkan kata kunci...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onSubmitted: (value) => _applyFilters(), // Terapkan filter saat submit
          ),
          const SizedBox(height: 8),
          // Filter Dropdowns
          Row(
            children: [
              // Filter Bahasa
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Bahasa',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10)
                  ),
                  items: const [
                    DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                    DropdownMenuItem(value: 'de', child: Text('German')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                      _applyFilters(); // Langsung terapkan filter
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Filter Urutan
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSortBy,
                   decoration: const InputDecoration(
                    labelText: 'Urutkan',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10)
                  ),
                  items: const [
                    DropdownMenuItem(value: 'publishedAt', child: Text('Terbaru')),
                    DropdownMenuItem(value: 'popularity', child: Text('Populer')),
                    DropdownMenuItem(value: 'relevancy', child: Text('Relevan')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSortBy = value;
                      });
                      _applyFilters(); // Langsung terapkan filter
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // WIDGET BARU: Helper untuk menampilkan gambar
  // -------------------------------------------------------------------
  Widget _buildBlogImage(String? imageUrl) {
    // Jika tidak ada gambar, tampilkan placeholder
=======
  Widget _buildFilterWidgets() {
    // Menggunakan Builder agar kita bisa akses context yang mengandung BlogCubit 
    // (karena BlocProvider ada di atasnya)
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search, // Ubah tombol keyboard jadi "Search"
                decoration: InputDecoration(
                  labelText: 'Cari Berita Pendidikan',
                  hintText: 'Contoh: Beasiswa, Kurikulum',
                  prefixIcon: const Icon(Icons.search),
                  // PERBAIKAN: Menambahkan tombol 'X' untuk clear atau tombol search di kanan
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      // Panggil fungsi fetchBlogs lewat context yang benar
                      context.read<BlogCubit>().fetchBlogs(
                        searchQuery: _searchController.text,
                        language: _selectedLanguage,
                      );
                    }, 
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (value) {
                  context.read<BlogCubit>().fetchBlogs(
                    searchQuery: value,
                    language: _selectedLanguage,
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Filter Bahasa
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Bahasa Berita',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)
                ),
                items: const [
                  DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                  DropdownMenuItem(value: 'en', child: Text('Inggris (English)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedLanguage = value);
                    // Langsung fetch ulang saat ganti bahasa
                    context.read<BlogCubit>().fetchBlogs(
                      searchQuery: _searchController.text,
                      language: value,
                    );
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildBlogImage(String? imageUrl) {
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
<<<<<<< HEAD
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
=======
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
        ),
        child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
      );
    }

<<<<<<< HEAD
    // Jika ada gambar, tampilkan menggunakan Image.network
    // 
=======
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
    return Image.network(
      imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
<<<<<<< HEAD
      // Tampilkan loading indicator saat gambar dimuat
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 150,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      // Tampilkan placeholder jika gambar gagal dimuat
=======
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 150,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, color: Colors.grey[400], size: 50),
        );
      },
    );
  }

<<<<<<< HEAD

  // Widget untuk menampilkan list blog
  Widget _buildBlogList(BuildContext context, List<Blog> blogs) {
    if (blogs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Tidak ada blog ditemukan untuk pencarian ini."),
=======
  // Widget List Blog
  Widget _buildBlogList(BuildContext context, List<Blog> blogs) {
    if (blogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text("Tidak ada berita ditemukan."),
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
        ),
      );
    }
    
    return ListView.builder(
      itemCount: blogs.length,
<<<<<<< HEAD
      shrinkWrap: true, // PENTING: Karena ini di dalam ListView lain
      physics: const NeverScrollableScrollPhysics(), // PENTING: Agar scroll bekerja
=======
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
<<<<<<< HEAD
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // -------------------------------------------------------------------
          // PERUBAHAN: Menambahkan clipBehavior dan Column
          // -------------------------------------------------------------------
          clipBehavior: Clip.antiAlias, // Memotong gambar agar rapi
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tampilkan Gambar
              _buildBlogImage(blog.imageUrl),

              // 2. Tampilkan Teks
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blog.content,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 3, // Batasi 3 baris
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Oleh: ${blog.author}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          // Format tanggal sederhana
                          "${blog.createdAt.day}/${blog.createdAt.month}/${blog.createdAt.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
=======
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          // ----------------------------------------------------------
          // PERUBAHAN: Bungkus isi Card dengan InkWell untuk klik
          // ----------------------------------------------------------
          child: InkWell(
            onTap: () {
              // Navigasi ke detail dengan mengirim object blog sebagai 'extra'
              context.go(
                '/beritadetail/${Uri.encodeComponent(blog.id)}', 
                extra: blog
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBlogImage(blog.imageUrl),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        blog.content,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // ... (Sisa kode UI lainnya sama) ...
                    ],
                  ),
                ),
              ],
            ),
>>>>>>> 3174971bac5fe2e2c72c9febc82ac280622d863b
          ),
        );
      },
    );
  }
}