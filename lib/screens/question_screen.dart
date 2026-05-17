import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/question_controller.dart';
import '../services/api_service.dart';
import '../widgets/shared/app_header.dart';
import '../widgets/shared/page_layout.dart';
import 'question_detail_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _searchKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _errorMsg = 'Silakan masukkan kode soal terlebih dahulu.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final detail = await QuestionController.getQuestionSetByKey(key);
      if (!mounted) return;
      
      // Navigate to detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionDetailScreen(
            questionSetId: detail.id,
            title: detail.title,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = 'Terjadi kesalahan sistem. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      header: const AppHeader(
        icon: Icons.assignment_rounded,
        title: 'Quiz',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Illustration / Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Punya Kode Soal?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan kode soal yang diberikan oleh gurumu untuk mulai mengerjakan tugas atau ujian.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Input Field
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _keyController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchKey(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'CONTOH: MAT-01',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    letterSpacing: 1.0,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Error Message
            if (_errorMsg != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(fontSize: 13, color: AppColors.dangerDark),
                      ),
                    ),
                  ],
                ),
              ),
              
            // Search Button
            ElevatedButton(
              onPressed: _isLoading ? null : _searchKey,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Cari & Kerjakan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
