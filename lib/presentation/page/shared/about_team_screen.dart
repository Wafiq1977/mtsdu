import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamMember {
  final String name;
  final String nim;
  final String role;
  final String imageUrl;
  final String githubUrl;
  final String linkedinUrl;
  final String instagramUrl;

  TeamMember({
    required this.name,
    required this.nim,
    required this.role,
    required this.imageUrl,
    this.githubUrl = '',
    this.linkedinUrl = '',
    this.instagramUrl = '',
  });
}

class AboutTeamScreen extends StatelessWidget {
  const AboutTeamScreen({super.key});

  List<TeamMember> get _members => [
    TeamMember(
      name: 'Egin Sefiano Widodo',
      nim: '24111814009',
      role: 'Team Leader',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814009.jpg',
      githubUrl: 'https://github.com/eginryzen',
      linkedinUrl: 'https://id.linkedin.com/in/egin-ryzen',
      instagramUrl: 'https://www.instagram.com/eginryzen/',
    ),

    TeamMember(
      name: 'Moch. Wafiq Izna',
      nim: '24111814018',
      role: 'Team Leader',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814018.jpg',
      githubUrl: ' https://github.com/Wafiq1977',
      linkedinUrl:
          ' https://www.linkedin.com/in/moch-wafiq-izna-0b8223377?utm_source=share_via&utm_content=profile&utm_medium=member_android',
      instagramUrl: ' https://www.instagram.com/wfqznn?igsh=d2RtbmZjcXg1ejhh',
    ),

    TeamMember(
      name: 'Lufita Setiati',
      nim: '24111814057',
      role: 'Member',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814057.jpg',
      githubUrl: ' https://github.com/lupitaaasetia',
      instagramUrl:
          ' https://www.instagram.com/lufitasetiati?igsh=MTBzdzBrZGViOGt5MQ==',
      linkedinUrl:
          'https://www.linkedin.com/in/lufita-setiati-6332b3344?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app',
    ),

    TeamMember(
      name: 'Muhammad Rifqi Iqbal Ghufron',
      nim: '24111814073',
      role: 'Member',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814073.jpg',
      githubUrl: 'https://github.com/iqbalghufron',
      instagramUrl:
          'https://www.instagram.com/iqbal.ghufron.9?igsh=MTZkZWswcHM4eHpqbA==',
    ),

    TeamMember(
      name: 'Izaz Tsany Rismawan',
      nim: '24111814088',
      role: 'Member',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814088.jpg',
      githubUrl: 'https://github.com/IzazTsany14',
      instagramUrl: 'https://www.instagram.com/sani_rsmawan/',
      linkedinUrl: 'https://www.linkedin.com/in/izaz-tsany-ab4609331/',
    ),

    TeamMember(
      name: 'Muhammad Reyhan Sheva RizQulah ',
      nim: '24111814124',
      role: 'Member',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814124.jpg',
      githubUrl: 'https://github.com/ShevaFortz',
      instagramUrl:
          'https://www.instagram.com/reyhansheva__?igsh=MTFxYWk5b3ZoY2tpag==',
      linkedinUrl:
          ' https://www.linkedin.com/in/reyhan-shevaid-70061b352?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app',
    ),

    TeamMember(
      name: 'Fearda Agnessiya Putri Dardiri',
      nim: '24111814138',
      role: 'Member',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814138.jpg',
      githubUrl: 'https://github.com/feardaa',
      instagramUrl: ' https://www.instagram.com/fyrxd_xa/',
    ),
    TeamMember(
      name: 'Naila Nurul Faizah',
      nim: '24111814144',
      role: 'Member',
      imageUrl:
          'https://wsrv.nl/?url=https://sindig.unesa.ac.id/fotomhs/200/24111814144.jpg',
      githubUrl: 'https://github.com/Nayla311',
      instagramUrl:
          'https://www.instagram.com/naymatchie?igsh=MW5ldnJlNHZncXVrMA%3D%3D&utm_source=qr',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // PISAHKAN DATA BERDASARKAN ROLE
    // Ambil semua yang role-nya 'Team Leader'
    final leaders = _members.where((m) => m.role == 'Team Leader').toList();
    // Ambil sisanya sebagai member
    final members = _members.where((m) => m.role != 'Team Leader').toList();

    const Color goldColor = Color(0xFFD4AF37);
    const Color darkBlueColor = Color(0xFF001F3F);

    const double spacing = 15.0;
    const double padding = 20.0;
    const double aspectRatio = 0.70;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/login');
          },
        ),
        title: const Text('ABOUT US'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final int crossAxisCount = availableWidth < 600 ? 1 : 3;

                final contentWidth = availableWidth - (padding * 2);
                final totalSpacing = (crossAxisCount - 1) * spacing;
                final gridContentWidth = contentWidth - totalSpacing;
                final cardWidth = gridContentWidth / crossAxisCount;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      const Text(
                        'KELOMPOK 1 PBP - MTS DU',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- SECTION LEADERS (SEJAJAR) ---
                      // Jika layar kecil (HP), tetap tampilkan sejajar tapi mungkin perlu wrap/scroll
                      // atau biarkan Grid logika menangani ukuran kartu
                      if (leaders.isNotEmpty)
                        Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          alignment: WrapAlignment.center,
                          children: leaders.map((leader) {
                            return SizedBox(
                              width:
                                  cardWidth, // Gunakan lebar yang sama dengan grid member
                              child: AspectRatio(
                                aspectRatio: aspectRatio,
                                child: _buildMemberCard(
                                  context,
                                  leader,
                                  goldColor,
                                  darkBlueColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 40),

                      // --- MEMBERS (Grid) ---
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: members.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                        itemBuilder: (context, index) {
                          return _buildMemberCard(
                            context,
                            members[index],
                            goldColor,
                            darkBlueColor,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    TeamMember member,
    Color accentColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. FOTO PROFIL
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accentColor, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(member.imageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Gagal load gambar ${member.name}: $exception');
              },
              child: member.imageUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
          ),

          const SizedBox(height: 8),

          // 2. NAMA
          Text(
            member.name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // 3. ROLE
          Text(
            member.role == 'Team Leader'
                ? 'Leader'
                : member.role, // Tampilkan 'Leader' jika Team Leader
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          // 4. NIM
          Text(
            member.nim,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // 5. SOCIAL ICONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniIcon(
                context,
                FontAwesomeIcons.github,
                Colors.black,
                "GitHub",
                member.githubUrl,
              ),
              const SizedBox(width: 8),
              _buildMiniIcon(
                context,
                FontAwesomeIcons.linkedin,
                const Color(0xFF0077B5),
                "LinkedIn",
                member.linkedinUrl,
              ),
              const SizedBox(width: 8),
              _buildMiniIcon(
                context,
                FontAwesomeIcons.instagram,
                const Color(0xFFE4405F),
                "Instagram",
                member.instagramUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniIcon(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String url,
  ) {
    final bool hasUrl = url.isNotEmpty;

    return InkWell(
      onTap: () async {
        if (hasUrl) {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal membuka link $label')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label belum tersedia'),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FaIcon(
          icon,
          size: 16,
          color: hasUrl ? color.withOpacity(0.8) : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}
