import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/question_controller.dart';
import '../models/question_set.dart';
import '../widgets/shared/app_header.dart';
import '../widgets/shared/page_layout.dart';
import 'question_detail_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late Future<List<QuestionSet>> _futureQuestionSets;

  @override
  void initState() {
    super.initState();
    _futureQuestionSets = QuestionController.getQuestionSets();
  }

  Future<void> _onRefresh() async {
    setState(() => _futureQuestionSets = QuestionController.getQuestionSets(forceRefresh: true));
  }

  void _openDetail(QuestionSet qs) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestionDetailScreen(questionSetId: qs.id, title: qs.title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      header: AppHeader(
        icon: Icons.assignment_rounded,
        title: 'Tugas & Latihan',
        trailing: [
          HeaderAction(icon: Icons.refresh_rounded, onTap: _onRefresh),
        ],
      ),
      body: FutureBuilder<List<QuestionSet>>(
        future: _futureQuestionSets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          final sets = snapshot.data ?? [];
          if (sets.isEmpty) return _buildEmpty();
          return _buildList(sets);
        },
      ),
    );
  }

  // ── States ────────────────────────────────────────────────────────────────

  Widget _buildError(String err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.18)),
          const SizedBox(height: 16),
          Text(err, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.assignment_turned_in_rounded, size: 72, color: AppColors.primary.withValues(alpha: 0.18)),
        const SizedBox(height: 16),
        const Text('Tidak ada tugas saat ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 6),
        const Text('Pantau terus, tugas baru akan muncul di sini.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildList(List<QuestionSet> sets) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Summary banner (home-style)
          SliverToBoxAdapter(child: _buildSummaryCard(sets)),

          // Section header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(children: [
              const Text('Daftar Soal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                child: Text('${sets.length} Set', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ]),
          )),

          // Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.fromLTRB(16, index == 0 ? 12 : 8, 16, 0),
                child: _QuestionSetCard(qs: sets[index], onTap: () => _openDetail(sets[index])),
              ),
              childCount: sets.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<QuestionSet> sets) {
    final totalSoal = sets.fold<int>(0, (sum, s) => sum + (s.questionsCount ?? 0));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryAlt, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('RINGKASAN TUGAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text('${sets.length} Paket Soal  •  $totalSoal Total Soal',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 2),
              const Text('Kerjakan semua soal dengan baik!',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Question Set Card ────────────────────────────────────────────────────────

class _QuestionSetCard extends StatelessWidget {
  final QuestionSet qs;
  final VoidCallback onTap;
  const _QuestionSetCard({required this.qs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            // Accent bar
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
              ),
            ),
            const SizedBox(width: 12),
            // Icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(qs.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                      child: Text(qs.keyCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.format_list_bulleted_rounded, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${qs.questionsCount ?? 0} Soal',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                  ]),
                ]),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
            ),
          ]),
        ),
      ),
    );
  }
}
