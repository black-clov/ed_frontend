import 'package:flutter/material.dart';

import '../models/soft_skill_model.dart';
import '../services/soft_skills_service.dart';

class SoftSkillsScreen extends StatefulWidget {
  const SoftSkillsScreen({super.key});

  @override
  State<SoftSkillsScreen> createState() => _SoftSkillsScreenState();
}

class _SoftSkillsScreenState extends State<SoftSkillsScreen> {
  final SoftSkillsService _service = SoftSkillsService();
  List<SoftSkillQuestion>? _questions;
  int _currentIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await _service.fetchQuestions();
    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  void _selectOption(String questionId, String option) {
    setState(() {
      _service.saveAnswer(questionId, option);
    });
  }

  void _next() {
    final q = _questions![_currentIndex];
    if (_service.getAnswer(q.id) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختار جواب من فضلك')),
      );
      return;
    }
    if (_currentIndex < _questions!.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  Color _scoreColor(int optionIndex) {
    const colors = [
      Color(0xFF2E7D32), // Excellent - Green
      Color(0xFF1565C0), // Good - Blue
      Color(0xFFF9A825), // Average - Yellow
      Color(0xFFE53935), // Needs work - Red
    ];
    return colors[optionIndex % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقييم المهارات الشخصية'),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final question = _questions![_currentIndex];
    final progress = (_currentIndex + 1) / _questions!.length;
    final selectedAnswer = _service.getAnswer(question.id);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: Colors.deepPurple.shade700, size: 28),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'الصاوير - تقييم السلوك المهني',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress
          Row(
            children: [
              Text(
                'السؤال ${_currentIndex + 1}/${_questions!.length}',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.deepPurple.shade400),
            ),
          ),
          const SizedBox(height: 24),

          // Question
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, i) {
                final option = question.options[i];
                final isSelected = selectedAnswer == option;
                final color = _scoreColor(i);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: isSelected
                        ? color.withValues(alpha: 0.12)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _selectOption(question.id, option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade200,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? color
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation
          Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _prev,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('السابق'),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),
              if (_currentIndex < _questions!.length - 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('التالي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (_currentIndex == _questions!.length - 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: selectedAnswer != null ? () {} : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('إنهاء التقييم'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
