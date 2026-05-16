import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/question_controller.dart';
import '../models/question_set.dart';
import '../widgets/question/question_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QUESTION DETAIL SCREEN  — shows all questions for a single QuestionSet
// ─────────────────────────────────────────────────────────────────────────────

class QuestionDetailScreen extends StatefulWidget {
  final int questionSetId;
  final String title;

  const QuestionDetailScreen({
    super.key,
    required this.questionSetId,
    required this.title,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late Future<QuestionSetDetail> _futureDetail;

  /// Tracks the student's selected answer per question ID.
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
    final correct = questions.where((q) => _selectedAnswers[q.id] == q.correctAnswer).length;
    final score   = questions.isEmpty ? 0.0 : (correct / questions.length) * 100;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hasil Latihan', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toStringAsFixed(0),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Benar $correct dari ${questions.length} soal',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to list
            },
            child: const Text('Kembali', style: TextStyle(fontSize: 16)),
          ),
        ],
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
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.title,
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<QuestionSetDetail>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat soal:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.questions.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada soal untuk tugas ini.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final detail    = snapshot.data!;
          final questions = detail.questions;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            // +1 for the submit button at the end
            itemCount: questions.length + 1,
            separatorBuilder: (context, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == questions.length) {
                return _buildSubmitButton(questions);
              }
              final q = questions[index];
              return QuestionItem(
                question:        q,
                questionNumber:  index + 1,
                selectedAnswer:  _selectedAnswers[q.id],
                onAnswerSelected: (letter) => _selectAnswer(q.id, letter),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(List<Question> questions) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: ElevatedButton(
        onPressed: () => _showResult(questions),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: const Text(
          'Selesaikan & Cek Nilai',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
