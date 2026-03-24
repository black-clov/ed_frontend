import 'package:flutter/material.dart';

import '../models/question_model.dart';
import '../services/questionnaire_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}


class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final QuestionnaireService _service = QuestionnaireService();

  List<QuestionModel>? _questions;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _loading = true;
  String? _error;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final questions = await _service.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
        _currentIndex = 0;
        _selectedOption = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load questions. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _onNext() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    final currentQuestion = _questions![_currentIndex];
    _service.saveAnswer(currentQuestion.id, _selectedOption!);

    if (_currentIndex == _questions!.length - 1) {
      setState(() {
        _submitting = true;
      });
      try {
        final ok = await _service.submitAnswers();
        setState(() {
          _submitting = false;
          _submitted = ok;
        });
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Answers submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission failed.')), 
          );
        }
      } catch (e) {
        setState(() {
          _submitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission failed.')), 
        );
      }
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('الاهتمامات والشخصية')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الاهتمامات والشخصية')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('الاهتمامات والشخصية')),
        body: const Center(
          child: Text('شكرًا لك! تم إرسال إجاباتك بنجاح.'),
        ),
      );
    }
    final question = _questions![_currentIndex];
    final progress = (_currentIndex + 1) / _questions!.length;

    return Scaffold(
      appBar: AppBar(title: const Text('الاهتمامات والشخصية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 16),
            Text(
              'السؤال ${_currentIndex + 1}/${_questions!.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.options
                  .map(
                    (option) => ChoiceChip(
                      label: Text(option),
                      selected: _selectedOption == option,
                      onSelected: (_) {
                        setState(() {
                          _selectedOption = option;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            
          ],
        ),
      ),
    );
  }
}
