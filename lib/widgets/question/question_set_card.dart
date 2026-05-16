import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/question_set.dart';

/// A card representing a single QuestionSet in the QuestionScreen list.
class QuestionSetCard extends StatelessWidget {
  final QuestionSet questionSet;
  final VoidCallback onTap;

  const QuestionSetCard({
    super.key,
    required this.questionSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionSet.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      questionSet.keyCode,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.format_list_bulleted_rounded, size: 14, color: Colors.black45),
                  const SizedBox(width: 4),
                  Text(
                    '${questionSet.questionsCount ?? 0} Soal',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ]),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black38),
        ]),
      ),
    );
  }
}
