import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/entrepreneurship_model.dart';
import '../services/entrepreneurship_service.dart';

class EntrepreneurshipScreen extends StatefulWidget {
  const EntrepreneurshipScreen({super.key});

  @override
  State<EntrepreneurshipScreen> createState() => _EntrepreneurshipScreenState();
}

class _EntrepreneurshipScreenState extends State<EntrepreneurshipScreen> {
  final EntrepreneurshipService _service = EntrepreneurshipService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<EntrepreneurshipOption> _options = [];
  final Map<String, int> _ratings = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final options = await _service.fetchOptions();
    final userId = await _storage.read(key: 'userId');
    final saved = await _service.getUserData(userId);

    final savedSkills = (saved['skills'] as List?)?.cast<String>() ?? [];
    final savedRatings = saved['ratings'];

    setState(() {
      _options = options;
      for (final opt in options) {
        if (savedSkills.contains(opt.key) && savedRatings is Map) {
          _ratings[opt.key] = (savedRatings[opt.key] as num?)?.toInt() ?? 0;
        }
      }
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final rated = _ratings.entries.where((e) => e.value > 0).toList();
    if (rated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('قيّم على الأقل مهارة واحدة')),
      );
      return;
    }
    setState(() => _submitting = true);
    final userId = await _storage.read(key: 'userId');
    await _service.submitSkills(
      userId: userId,
      skills: rated.map((e) => e.key).toList(),
      ratings: Map.fromEntries(rated),
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ مهاراتك في ريادة الأعمال ✅')),
    );
  }

  String _ratingLabel(int value) {
    switch (value) {
      case 1: return 'مبتدئ';
      case 2: return 'أساسي';
      case 3: return 'متوسط';
      case 4: return 'جيد';
      case 5: return 'متمكن';
      default: return 'غير محدد';
    }
  }

  Color _ratingColor(int value) {
    switch (value) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.amber.shade700;
      case 4: return const Color(0xFF2E7D32);
      case 5: return const Color(0xFF1565C0);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مهارات ريادة الأعمال'),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.rocket_launch, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'قيّم مهاراتك في ريادة الأعمال',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'حدد مستواك فكل مهارة من 1 حتى 5',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Skills list
                    ..._options.map((opt) => _buildSkillCard(opt)),

                    const SizedBox(height: 16),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('حفظ التقييم', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSkillCard(EntrepreneurshipOption opt) {
    final rating = _ratings[opt.key] ?? 0;

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
                Text(opt.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      if (opt.description.isNotEmpty)
                        Text(opt.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (rating > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _ratingColor(rating).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _ratingLabel(rating),
                      style: TextStyle(fontSize: 11, color: _ratingColor(rating), fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _ratings[opt.key] = starValue;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starValue <= rating ? Icons.star : Icons.star_border,
                      color: starValue <= rating ? const Color(0xFFE65100) : Colors.grey.shade400,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
