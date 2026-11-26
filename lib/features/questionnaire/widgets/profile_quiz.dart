import 'package:flutter/material.dart';

import '../../../core/i18n/app_i18n.dart';
import '../../../services/api_service.dart';

const _red = Color(0xFFC62828);
const _green = Color(0xFF2E7D32);

/// Which questionnaire to show. Questions come from GET /questionnaire,
/// saved answers from GET /questionnaire/me/answers.
enum ProfileQuizKind {
  personality(
    sectionKey: 'personalityQuestions',
    answersKey: 'personality',
    savePath: '/questionnaire/me/personality',
    titleKey: 'quiz_personality_title',
    introKey: 'quiz_personality_intro',
    icon: Icons.emoji_people_rounded,
  ),
  softSkills(
    sectionKey: 'softSkillsQuestions',
    answersKey: 'softSkills',
    savePath: '/questionnaire/me/softskills',
    titleKey: 'quiz_softskills_title',
    introKey: 'quiz_softskills_intro',
    icon: Icons.psychology_rounded,
  );

  const ProfileQuizKind({
    required this.sectionKey,
    required this.answersKey,
    required this.savePath,
    required this.titleKey,
    required this.introKey,
    required this.icon,
  });

  final String sectionKey;
  final String answersKey;
  final String savePath;
  final String titleKey;
  final String introKey;
  final IconData icon;
}

class _Choice {
  final String id, fr, ar;
  const _Choice(this.id, this.fr, this.ar);
  String get label => isRtl ? ar : (fr.isNotEmpty ? fr : ar);
}

class _Question {
  final String id, fr, ar;
  final List<_Choice> choices;
  const _Question(this.id, this.fr, this.ar, this.choices);
  String get label => isRtl ? ar : (fr.isNotEmpty ? fr : ar);

  factory _Question.fromJson(Map<String, dynamic> j) {
    final choices = (j['choices'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((c) => _Choice(
              c['id'].toString(),
              (c['fr'] ?? '').toString(),
              (c['ar'] ?? '').toString(),
            ))
        .toList();
    return _Question(
      j['id'].toString(),
      (j['questionFr'] ?? '').toString(),
      (j['questionAr'] ?? j['question'] ?? '').toString(),
      choices,
    );
  }
}

/// One question per page, answers saved on the user's account at the end.
class ProfileQuiz extends StatefulWidget {
  final ProfileQuizKind kind;
  const ProfileQuiz({super.key, required this.kind});

  @override
  State<ProfileQuiz> createState() => _ProfileQuizState();
}

class _ProfileQuizState extends State<ProfileQuiz> {
  final _api = ApiService();
  List<_Question> _questions = [];
  final Map<String, String> _answers = {};
  int _index = 0;
  bool _loading = true;
  bool _loadError = false;
  bool _saving = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = false;
    });
    try {
      final qResp = await _api.get('/questionnaire');
      final raw = (qResp.data['sections']?[widget.kind.sectionKey] as List<dynamic>?) ?? [];
      final questions = raw
          .whereType<Map>()
          .map((e) => _Question.fromJson(Map<String, dynamic>.from(e)))
          .where((q) => q.choices.isNotEmpty)
          .toList();
      final saved = <String, String>{};
      try {
        final aResp = await _api.get('/questionnaire/me/answers');
        final map = aResp.data is Map ? aResp.data[widget.kind.answersKey] : null;
        if (map is Map) map.forEach((k, v) => saved[k.toString()] = v.toString());
      } catch (_) {
        // Nothing saved yet: start empty.
      }
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _answers
          ..clear()
          ..addAll(saved);
        _loading = false;
        _loadError = questions.isEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = true;
      });
    }
  }

  void _snack(String key) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(key))));

  void _next() {
    if (_answers[_questions[_index].id] == null) return _snack('quiz_select_answer');
    if (_index < _questions.length - 1) setState(() => _index++);
  }

  Future<void> _save() async {
    if (_answers[_questions[_index].id] == null) return _snack('quiz_select_answer');
    setState(() => _saving = true);
    try {
      await _api.put(widget.kind.savePath, data: {'answers': _answers});
      if (!mounted) return;
      setState(() {
        _saving = false;
        _done = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('quiz_save_error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, _, _) => Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        appBar: AppBar(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          title: Text(tr(widget.kind.titleKey), style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _red))
            : _loadError
                ? _buildError()
                : _done
                    ? _buildDone()
                    : _buildQuestion(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(tr('quiz_load_error'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: Text(tr('retry'))),
          ],
        ),
      ),
    );
  }

  Widget _buildDone() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 72, color: _green),
            const SizedBox(height: 16),
            Text(tr('quiz_done_title'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _green)),
            const SizedBox(height: 8),
            Text(tr('quiz_done_text'),
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(tr('quiz_back'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _done = false;
                _index = 0;
              }),
              child: Text(tr('quiz_review'), style: const TextStyle(color: _red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_index];
    final selected = _answers[q.id];
    final isLast = _index == _questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_index == 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(widget.kind.icon, color: _red, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tr(widget.kind.introKey),
                        style: const TextStyle(fontSize: 13.5, color: _red, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Text('${tr('quiz_question')} ${_index + 1}/${_questions.length}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${_answers.length}/${_questions.length}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(_red),
            ),
          ),
          const SizedBox(height: 22),
          Text(q.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.45)),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: [
                for (final c in q.choices) _choiceTile(q, c, selected == c.id),
              ],
            ),
          ),
          Row(
            children: [
              if (_index > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _index--),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _red),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(tr('quiz_prev'), style: const TextStyle(color: _red)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : (isLast ? _save : _next),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLast ? _green : _red,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(tr(isLast ? 'quiz_save' : 'quiz_next'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _choiceTile(_Question q, _Choice c, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected ? _red.withAlpha(25) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _answers[q.id] = c.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? _red : Colors.grey.shade300, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? _red : Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(c.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? _red : Colors.black87,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
