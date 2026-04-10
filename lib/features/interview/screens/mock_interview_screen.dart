import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/interview_service.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  final InterviewService _service = InterviewService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Map<String, TextEditingController> _controllers = {};

  List<SimulationQuestion>? _questions;
  int _currentIndex = 0;
  bool _loading = true;
  bool _submitting = false;
  SimulationResult? _result;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _service.fetchSimulationQuestions();
    for (final q in questions) {
      _controllers[q.id] = TextEditingController();
    }
    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  void _next() {
    final q = _questions![_currentIndex];
    if ((_controllers[q.id]?.text ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كتب الجواب ديالك من فضلك')),
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

  Future<void> _submit() async {
    final q = _questions![_currentIndex];
    if ((_controllers[q.id]?.text ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كتب الجواب ديالك من فضلك')),
      );
      return;
    }

    setState(() => _submitting = true);

    final userId = await _storage.read(key: 'user_id') ?? 'anonymous';
    final answers = _questions!.map((q) {
      return {
        'questionId': q.id,
        'answer': _controllers[q.id]?.text ?? '',
      };
    }).toList();

    final result = await _service.submitSimulation(
      userId: userId,
      targetRole: 'general',
      answers: answers,
    );

    setState(() {
      _result = result;
      _submitting = false;
    });
  }

  Color _scoreColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF2E7D32);
    if (percentage >= 60) return const Color(0xFF1565C0);
    if (percentage >= 40) return const Color(0xFFF9A825);
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محاكاة المقابلة'),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _result != null
                ? _buildResults()
                : _buildQuestionView(),
      ),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions![_currentIndex];
    final progress = (_currentIndex + 1) / _questions!.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text(
                'السؤال ${_currentIndex + 1}/${_questions!.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: Colors.indigo, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Colors.indigo),
            ),
          ),
          const SizedBox(height: 20),

          // Question card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over, color: Colors.indigo),
                      const SizedBox(width: 8),
                      const Text('المحاور يسأل:',
                          style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tip
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade800, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.tips,
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Answer
          Expanded(
            child: TextField(
              controller: _controllers[question.id],
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'أكتب جوابك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          const SizedBox(height: 12),

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
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (_currentIndex == _questions!.length - 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle),
                    label: Text(_submitting ? 'جاري التقييم...' : 'إرسال الأجوبة'),
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

  Widget _buildResults() {
    final result = _result!;
    final color = _scoreColor(result.percentage);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Score circle
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color, width: 4),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${result.percentage}%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '${result.totalScore}/${result.maxScore}',
                    style: TextStyle(fontSize: 14, color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Overall feedback
        Card(
          color: color.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  result.percentage >= 60
                      ? Icons.emoji_events
                      : Icons.info_outline,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.overallFeedback,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text('تفاصيل التقييم',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // Per-question feedback
        ...result.evaluations.asMap().entries.map((entry) {
          final idx = entry.key;
          final eval = entry.value;
          final score = eval['score'] as int? ?? 0;
          final maxScore = eval['maxScore'] as int? ?? 20;
          final feedbackList = (eval['feedback'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          final qColor = _scoreColor(((score / maxScore) * 100).round());

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'السؤال ${idx + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: qColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$score/$maxScore',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: qColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...feedbackList
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.arrow_left, size: 18, color: qColor),
                                const SizedBox(width: 4),
                                Expanded(child: Text(f)),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _result = null;
                _currentIndex = 0;
                for (final c in _controllers.values) {
                  c.clear();
                }
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاكاة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
