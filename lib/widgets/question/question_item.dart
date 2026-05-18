import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/question_set.dart';

class QuestionItem extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;

  const QuestionItem({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$questionNumber',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Options
          _OptionButton(letter: 'A', text: question.optionA, selectedAnswer: selectedAnswer, onTap: onAnswerSelected),
          const SizedBox(height: 10),
          _OptionButton(letter: 'B', text: question.optionB, selectedAnswer: selectedAnswer, onTap: onAnswerSelected),
          const SizedBox(height: 10),
          _OptionButton(letter: 'C', text: question.optionC, selectedAnswer: selectedAnswer, onTap: onAnswerSelected),
          const SizedBox(height: 10),
          _OptionButton(letter: 'D', text: question.optionD, selectedAnswer: selectedAnswer, onTap: onAnswerSelected),
        ],
      ),
    );
  }
}

/// A single selectable option button (A / B / C / D).
class _OptionButton extends StatelessWidget {
  final String letter;
  final String text;
  final String? selectedAnswer;
  final ValueChanged<String> onTap;

  const _OptionButton({
    required this.letter,
    required this.text,
    required this.selectedAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedAnswer == letter;

    return GestureDetector(
      onTap: () => onTap(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? AppColors.textDark : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
