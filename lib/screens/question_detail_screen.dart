import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/question_controller.dart';
import '../models/question_set.dart';
import '../widgets/shared/app_header.dart';
import '../widgets/shared/page_layout.dart';

class QuestionDetailScreen extends StatefulWidget {
  final int questionSetId;
  final String title;
  const QuestionDetailScreen({super.key, required this.questionSetId, required this.title});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late Future<QuestionSetDetail> _futureDetail;
  final Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _futureDetail = QuestionController.getQuestionSetDetail(widget.questionSetId);
  }

  void _selectAnswer(int questionId, String letter) {
    setState(() => _selectedAnswers[questionId] = letter);
  }

  void _showResult(List<Question> questions) {
    final correct = questions.where((q) {
      final studentAnswer = _selectedAnswers[q.id]?.toUpperCase() ?? '';
      final actualAnswer = q.correctAnswer.toUpperCase();
      return studentAnswer == actualAnswer;
    }).length;
    final score   = questions.isEmpty ? 0.0 : (correct / questions.length) * 100;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hasil Latihan', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(score.toStringAsFixed(0),
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('Benar $correct dari ${questions.length} soal',
            style: const TextStyle(fontSize: 16, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: questions.isEmpty ? 0 : correct / questions.length,
            backgroundColor: AppColors.primaryLight,
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Kembali ke Daftar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      header: AppHeader(
        icon: Icons.assignment_rounded,
        title: widget.title,
        showBack: true,
      ),
      body: FutureBuilder<QuestionSetDetail>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.18)),
                const SizedBox(height: 16),
                Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
              ]),
            ));
          }
          if (!snapshot.hasData || snapshot.data!.questions.isEmpty) {
            return const Center(child: Text('Belum ada soal untuk tugas ini.',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted)));
          }

          final detail    = snapshot.data!;
          final questions = detail.questions;

          return CustomScrollView(
            slivers: [
              // Info banner (home-style)
              SliverToBoxAdapter(child: _buildInfoBanner(detail)),

              // Section header
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Row(children: [
                  const Text('Daftar Soal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                    child: Text('${questions.length} Soal',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ]),
              )),

              // Question cards
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.fromLTRB(16, index == 0 ? 8 : 10, 16, 0),
                    child: _QuestionCard(
                      question: questions[index],
                      number: index + 1,
                      selectedAnswer: _selectedAnswers[questions[index].id],
                      onAnswer: (l) => _selectAnswer(questions[index].id, l),
                    ),
                  ),
                  childCount: questions.length,
                ),
              ),

              // Submit button
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: ElevatedButton(
                  onPressed: () => _showResult(questions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('Selesaikan & Cek Nilai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner(QuestionSetDetail detail) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryAlt, AppColors.primary],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
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
              const Text('KODE SOAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(detail.keyCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 2),
              Text('${detail.questions.length} soal  •  Pilih jawaban yang benar',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Single Question Card ─────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int number;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswer;

  const _QuestionCard({
    required this.question, required this.number,
    required this.selectedAnswer, required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Question header
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('$number', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(question.questionText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.4)),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        // Options
        _option('A', question.optionA),
        const SizedBox(height: 8),
        _option('B', question.optionB),
        const SizedBox(height: 8),
        _option('C', question.optionC),
        const SizedBox(height: 8),
        _option('D', question.optionD),
      ]),
    );
  }

  Widget _option(String letter, String text) {
    final selected = selectedAnswer == letter;
    return GestureDetector(
      onTap: () => onAnswer(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.07) : Colors.transparent,
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE0E0E0), width: selected ? 1.8 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(letter, style: TextStyle(color: selected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(
              fontSize: 14,
              color: selected ? AppColors.textDark : const Color(0xFF555555),
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            )),
          ),
        ]),
      ),
    );
  }
}
