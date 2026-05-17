import 'package:flutter/material.dart';
import '../controllers/announcement_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/question_controller.dart';
import '../controllers/schedule_controller.dart';
import '../models/student.dart';
import '../screens/login_screen.dart';
import '../widgets/shared/app_header.dart';
import '../widgets/shared/page_layout.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROFIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  static const _primary  = Color(0xFF4C4DDC);
  static const _textDark = Color(0xFF1A1A2E);

  Student? _student;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    // 1. Load from SharedPreferences immediately (fast, no network wait)
    final cached = await AuthController.getSession();
    if (mounted) setState(() { _student = cached; _loading = false; });

    // 2. Then quietly refresh from the server in the background
    final fresh = await AuthController.refreshProfile();
    if (mounted && fresh != null) setState(() => _student = fresh);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthController.logout();
    AnnouncementController.clearCache();
    ScheduleController.clearCache();
    QuestionController.clearCache();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      header: AppHeader(icon: Icons.person_rounded, title: 'Profil Siswa'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildProfileCard()),
                SliverToBoxAdapter(child: _buildInfoSection()),
                SliverToBoxAdapter(child: _buildLogoutButton()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
    );
  }

  // ── Profile Hero Card ──────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    final name       = _student?.name       ?? '—';
    final classMajor = _student?.shortClassMajor ?? '—';
    final nis        = _student?.nis        ?? '—';

    // Generate initials for avatar
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B5EE8), _primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar circle with initials
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.20),
                  border: Border.all(color: Colors.white.withOpacity(0.40), width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  classMajor,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Divider(color: Colors.white.withOpacity(0.20), height: 1),
              const SizedBox(height: 14),
              // NIS row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge_outlined, size: 16, color: Colors.white.withOpacity(0.70)),
                  const SizedBox(width: 6),
                  Text(
                    'NIS: $nis',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.90)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Info Section ───────────────────────────────────────────────────────────
  Widget _buildInfoSection() {
    final classMajor = _student?.shortClassMajor ?? '—';
    final nis        = _student?.nis        ?? '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                _InfoTile(icon: Icons.person_outline_rounded,  label: 'Nama Lengkap',  value: _student?.name       ?? '—'),
                const _TileDivider(),
                _InfoTile(icon: Icons.badge_outlined,          label: 'NIS',            value: nis),
                const _TileDivider(),
                _InfoTile(icon: Icons.class_outlined,          label: 'Kelas / Jurusan', value: classMajor),
                const _TileDivider(),
                const _InfoTile(icon: Icons.school_outlined,  label: 'Sekolah',         value: 'SMK Negeri 1'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout Button ──────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(
            'Keluar dari Akun',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEF2F2),
            foregroundColor: const Color(0xFFEF4444),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: const BorderSide(color: Color(0xFFFECACA)),
          ),
        ),
      ),
    );
  }


}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4C4DDC), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF999999), fontWeight: FontWeight.w500, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF0F0F0));
}
