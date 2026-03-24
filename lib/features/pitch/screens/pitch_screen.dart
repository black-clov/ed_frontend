import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/pitch_service.dart';

class PitchScreen extends StatefulWidget {
  const PitchScreen({super.key});

  @override
  State<PitchScreen> createState() => _PitchScreenState();
}

class _PitchScreenState extends State<PitchScreen> {
  final PitchService _service = PitchService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _pitchCtrl = TextEditingController();

  String? _selectedSector;
  bool _generating = false;
  bool _saving = false;
  Map<String, dynamic>? _result;
  List<dynamic> _tips = [];

  static const _sectors = [
    {'key': 'innovation', 'label': 'الابتكار', 'icon': '💡'},
    {'key': 'sales', 'label': 'المبيعات', 'icon': '🛒'},
    {'key': 'marketing', 'label': 'التسويق', 'icon': '📢'},
    {'key': 'manual_services', 'label': 'الخدمات اليدوية', 'icon': '🔧'},
    {'key': 'management', 'label': 'الإدارة', 'icon': '📊'},
    {'key': 'people', 'label': 'العمل مع الناس', 'icon': '🤝'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pitchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final userId = await _storage.read(key: 'userId');
    final saved = await _service.getSavedPitch(userId);
    if (saved != null && saved['pitchText'] != null) {
      setState(() {
        _nameCtrl.text = saved['projectName'] ?? '';
        _pitchCtrl.text = saved['pitchText'] ?? '';
        _selectedSector = saved['sector'];
        _result = saved;
      });
    }
  }

  Future<void> _generate() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل اسم المشروع')),
      );
      return;
    }
    setState(() => _generating = true);
    final userId = await _storage.read(key: 'userId');
    final result = await _service.generatePitch(
      userId: userId,
      projectName: _nameCtrl.text.trim(),
      sector: _selectedSector,
    );
    setState(() {
      _generating = false;
      if (result != null) {
        _result = result;
        _pitchCtrl.text = result['pitchText'] ?? '';
        _tips = (result['tips'] as List?) ?? [];
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final userId = await _storage.read(key: 'userId');
    await _service.savePitch(
      userId: userId,
      projectName: _nameCtrl.text.trim(),
      pitchText: _pitchCtrl.text,
      sector: _selectedSector,
    );
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الـ Pitch ديالك ✅')),
    );
  }

  int get _wordCount {
    final text = _pitchCtrl.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تحضير العرض التقديمي'),
          centerTitle: true,
          actions: [
            if (_result != null)
              IconButton(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.mic, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Elevator Pitch',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'حضّر عرض تقديمي قصير (1 دقيقة) باش تقنع المستثمرين',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Project name
              TextField(
                controller: _nameCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'اسم المشروع',
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Sector chips
              const Text('القطاع:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sectors.map((s) {
                  final selected = _selectedSector == s['key'];
                  return ChoiceChip(
                    label: Text('${s['icon']} ${s['label']}'),
                    selected: selected,
                    selectedColor: const Color(0xFF7B1FA2).withAlpha(40),
                    onSelected: (val) => setState(() => _selectedSector = val ? s['key'] as String : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Generate
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generating ? null : _generate,
                  icon: _generating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome),
                  label: Text(_generating ? 'جاري التوليد...' : 'توليد Pitch', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 20),

                // Word count + time estimate
                Row(
                  children: [
                    const Icon(Icons.timer, size: 18, color: Color(0xFF4A148C)),
                    const SizedBox(width: 6),
                    Text(
                      '$_wordCount كلمة ≈ ${(_wordCount / 130).toStringAsFixed(1)} دقيقة',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4A148C), fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (_wordCount > 160)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('طويل شوية ⚠️', style: TextStyle(fontSize: 11, color: Colors.red)),
                      ),
                    if (_wordCount <= 160 && _wordCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('مدة مناسبة ✅', style: TextStyle(fontSize: 11, color: Colors.green)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Editable pitch
                TextField(
                  controller: _pitchCtrl,
                  textDirection: TextDirection.rtl,
                  maxLines: null,
                  minLines: 8,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'النص ديال الـ Pitch',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: const TextStyle(fontSize: 15, height: 1.8),
                ),
                const SizedBox(height: 14),

                // Save
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                    label: Text(_saving ? 'جاري الحفظ...' : 'حفظ', style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tips section
                if (_tips.isNotEmpty) ...[
                  const Text('نصائح للـ Pitch الناجح:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._tips.map((tip) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Text(tip['icon'] ?? '💡', style: const TextStyle(fontSize: 22)),
                      title: Text(tip['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(tip['description'] ?? '', style: const TextStyle(fontSize: 12)),
                    ),
                  )),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
