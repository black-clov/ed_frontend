import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/support_model.dart';
import '../services/support_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SupportService _service = SupportService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<SupportCategory> _categories = [];
  final Map<String, String> _selections = {}; // category -> chosen key
  bool _loading = true;
  bool _submitting = false;

  static const _categoryColors = {
    'incubator': Color(0xFF0D47A1),
    'mentor_type': Color(0xFF4A148C),
    'training_type': Color(0xFFE65100),
    'funding_stage': Color(0xFF2E7D32),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await _service.fetchOptions();
    final userId = await _storage.read(key: 'user_id');
    final saved = await _service.getUserData(userId);
    final savedPrefs = (saved['preferences'] as List?)?.cast<String>() ?? [];

    // Reconstruct selections from saved preferences
    for (final cat in categories) {
      for (final choice in cat.choices) {
        if (savedPrefs.contains(choice.key)) {
          _selections[cat.category] = choice.key;
          break;
        }
      }
    }

    setState(() {
      _categories = categories;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_selections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر على الأقل تفضيل واحد')),
      );
      return;
    }
    setState(() => _submitting = true);
    final userId = await _storage.read(key: 'user_id');
    await _service.submit(
      userId: userId,
      preferences: _selections.values.toList(),
      details: _selections,
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ تفضيلات الدعم ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفضيلات الدعم'),
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
                        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.support_agent, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'شنو نوع الدعم اللي بغيتي؟',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'اختر التفضيلات ديالك باش نوجهوك للدعم المناسب',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categories
                    ..._categories.map((cat) => _buildCategoryCard(cat)),

                    const SizedBox(height: 16),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('حفظ التفضيلات', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryCard(SupportCategory cat) {
    final color = _categoryColors[cat.category] ?? const Color(0xFF455A64);
    final selectedKey = _selections[cat.category];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                      if (cat.description.isNotEmpty)
                        Text(cat.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...cat.choices.map((choice) {
              final isSelected = selectedKey == choice.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _selections[cat.category] = choice.key;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withAlpha(20) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? color : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            choice.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? color : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
