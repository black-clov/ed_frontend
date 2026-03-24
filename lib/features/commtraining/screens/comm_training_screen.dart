import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/comm_module_model.dart';
import '../services/comm_training_service.dart';

class CommTrainingScreen extends StatefulWidget {
  const CommTrainingScreen({super.key});

  @override
  State<CommTrainingScreen> createState() => _CommTrainingScreenState();
}

class _CommTrainingScreenState extends State<CommTrainingScreen> {
  final CommTrainingService _service = CommTrainingService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<CommModule> _modules = [];
  final Map<String, int> _ratings = {};
  final Set<String> _completed = {};
  int? _expandedIndex;
  bool _loading = true;
  bool _submitting = false;

  static const _moduleColors = {
    'customer_talk': Color(0xFF1565C0),
    'negotiation': Color(0xFF2E7D32),
    'persuasion': Color(0xFF7B1FA2),
    'presentation': Color(0xFFE65100),
    'networking': Color(0xFF00695C),
    'conflict_resolution': Color(0xFF37474F),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final modules = await _service.fetchModules();
    final userId = await _storage.read(key: 'userId');
    final saved = await _service.getUserData(userId);

    final savedSkills = (saved['skills'] as List?)?.cast<String>() ?? [];
    final savedRatings = saved['ratings'];
    final savedCompleted = (saved['completedModules'] as List?)?.cast<String>() ?? [];

    setState(() {
      _modules = modules;
      for (final m in modules) {
        if (savedSkills.contains(m.key) && savedRatings is Map) {
          _ratings[m.key] = (savedRatings[m.key] as num?)?.toInt() ?? 0;
        }
      }
      _completed.addAll(savedCompleted);
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final rated = _ratings.entries.where((e) => e.value > 0).toList();
    if (rated.isEmpty && _completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('قيّم أو أكمل على الأقل وحدة واحدة')),
      );
      return;
    }
    setState(() => _submitting = true);
    final userId = await _storage.read(key: 'userId');
    await _service.submit(
      userId: userId,
      skills: rated.map((e) => e.key).toList(),
      ratings: Map.fromEntries(rated),
      completedModules: _completed.toList(),
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ تقدمك فالتواصل ✅')),
    );
  }

  String _ratingLabel(int value) {
    switch (value) {
      case 1: return 'مبتدئ';
      case 2: return 'أساسي';
      case 3: return 'متوسط';
      case 4: return 'جيد';
      case 5: return 'متمكن';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تدريب التواصل'),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.forum, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'مهارات التواصل لرائد الأعمال',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'تعلم كيفاش تهضر مع الزبناء، تفاوض، وتقنع',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Modules
                    ...List.generate(_modules.length, (index) {
                      final m = _modules[index];
                      return _buildModuleCard(m, index);
                    }),

                    const SizedBox(height: 16),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('حفظ التقدم', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildModuleCard(CommModule m, int index) {
    final color = _moduleColors[m.key] ?? const Color(0xFF455A64);
    final rating = _ratings[m.key] ?? 0;
    final isCompleted = _completed.contains(m.key);
    final isExpanded = _expandedIndex == index;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isCompleted ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() => _expandedIndex = isExpanded ? null : index);
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(m.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                        Text(m.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Icon(Icons.check_circle, color: color, size: 22),
                  const SizedBox(width: 4),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tips
                  Text('نصائح عملية:', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                  const SizedBox(height: 8),
                  ...m.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, color: color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.4))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // Self-rating
                  Text('قيّم مستواك:', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starVal = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _ratings[m.key] = starVal),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            starVal <= rating ? Icons.star : Icons.star_border,
                            color: starVal <= rating ? color : Colors.grey.shade400,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (rating > 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(_ratingLabel(rating), style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Mark as completed
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (isCompleted) {
                            _completed.remove(m.key);
                          } else {
                            _completed.add(m.key);
                          }
                        });
                      },
                      icon: Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined, size: 18),
                      label: Text(isCompleted ? 'مكتمل ✅' : 'حدد كمكتمل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
