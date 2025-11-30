// lib/blog/blog_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blog_cubit.dart';
import 'blog_state.dart';
import '../data/model/blog.dart';

class BlogView extends StatefulWidget {
  const BlogView({super.key});

  @override
  State<BlogView> createState() => _BlogViewState();
}

class _BlogViewState extends State<BlogView> {
  late TextEditingController _searchController;
  String _selectedLanguage = 'id';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'Pendidikan');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    FocusScope.of(context).unfocus();
    context.read<BlogCubit>().fetchBlogs(
      searchQuery: _searchController.text,
      language: _selectedLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is BlogError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                    ),
                  ),
                );
              } else if (state is BlogLoaded) {
                return _buildResponsiveBlogList(context, state.blogs);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterWidgets() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Cari Berita Pendidikan',
                  hintText: 'Contoh: Beasiswa, Kurikulum',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
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
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
      );
    }

    return Image.network(
      imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 150,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, color: Colors.grey[400], size: 50),
        );
      },
    );
  }

  // Fungsi Baru: Menangani Logika Responsif (Grid vs List)
  Widget _buildResponsiveBlogList(BuildContext context, List<Blog> blogs) {
    if (blogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text("Tidak ada berita ditemukan."),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Anggap Desktop jika lebar > 900 pixel
        bool isDesktop = constraints.maxWidth > 900;

        if (isDesktop) {
          // --- TAMPILAN GRID (DESKTOP) ---
          return GridView.builder(
            itemCount: blogs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 Kolom
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 320, // Tinggi tetap agar kartu rapi
            ),
            itemBuilder: (context, index) {
              return _buildBlogCard(context, blogs[index], isGrid: true);
            },
          );
        } else {
          // --- TAMPILAN LIST (TABLET & HP) ---
          return ListView.builder(
            itemCount: blogs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemBuilder: (context, index) {
              return _buildBlogCard(context, blogs[index], isGrid: false);
            },
          );
        }
      },
    );
  }

  // Widget Kartu Berita yang diekstrak agar bisa dipakai ulang
  Widget _buildBlogCard(BuildContext context, Blog blog, {required bool isGrid}) {
    return Card(
      // Jika di Grid, margin ditangani oleh GridDelegate (spacing).
      // Jika di List, kita beri margin manual.
      margin: isGrid 
          ? EdgeInsets.zero 
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go(
            '/blog/${Uri.encodeComponent(blog.id)}', 
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}