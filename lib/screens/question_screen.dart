import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/question_controller.dart';
import '../models/question_set.dart';
import '../widgets/question/question_set_card.dart';
import 'question_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QUESTION SCREEN  — lists all available QuestionSets
// ─────────────────────────────────────────────────────────────────────────────

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
    setState(() {
      _futureQuestionSets = QuestionController.getQuestionSets(forceRefresh: true);
    });
  }

  void _openDetail(QuestionSet qs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionDetailScreen(
          questionSetId: qs.id,
          title: qs.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Daftar Tugas & Latihan',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QuestionSet>>(
        future: _futureQuestionSets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat tugas:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sets = snapshot.data ?? [];
          if (sets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada tugas saat ini',
                    style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sets.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => QuestionSetCard(
                questionSet: sets[index],
                onTap: () => _openDetail(sets[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
