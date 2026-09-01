import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/pitch_service.dart';
import '../../../core/i18n/app_i18n.dart';

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

  List<Map<String, String>> get _sectors => [
    {'key': 'innovation', 'label': tr('ent_sector_short_innovation'), 'icon': '💡'},
    {'key': 'sales', 'label': tr('ent_sector_short_sales'), 'icon': '🛒'},
    {'key': 'marketing', 'label': tr('ent_sector_short_marketing'), 'icon': '📢'},
    {'key': 'manual_services', 'label': tr('ent_sector_manual_services'), 'icon': '🔧'},
    {'key': 'management', 'label': tr('ent_sector_short_management'), 'icon': '📊'},
    {'key': 'people', 'label': tr('ent_sector_people_work'), 'icon': '🤝'},
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
    final userId = await _storage.read(key: 'user_id');
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
        SnackBar(content: Text(tr('ent_enter_project_name'))),
      );
      return;
    }
    setState(() => _generating = true);
    final userId = await _storage.read(key: 'user_id');
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
    final userId = await _storage.read(key: 'user_id');
    await _service.savePitch(
      userId: userId,
      projectName: _nameCtrl.text.trim(),
      pitchText: _pitchCtrl.text,
      sector: _selectedSector,
    );
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('ent_pitch_saved_success'))),
    );
  }

  int get _wordCount {
    final text = _pitchCtrl.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tr('ent_pitch_title')),
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
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF2E7D32)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.mic, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'Elevator Pitch',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('ent_pitch_header_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Project name
              TextField(
                controller: _nameCtrl,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: tr('ent_project_name_label'),
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Sector chips
              Text(tr('ent_sector_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sectors.map((s) {
                  final selected = _selectedSector == s['key'];
                  return ChoiceChip(
                    label: Text('${s['icon']} ${s['label']}'),
                    selected: selected,
                    selectedColor: const Color(0xFF2E7D32).withAlpha(40),
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
                  label: Text(_generating ? tr('ent_generating_ellipsis') : tr('ent_pitch_generate_btn'), style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
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
                    const Icon(Icons.timer, size: 18, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    Text(
                      '$_wordCount ${tr('ent_word_unit')} ≈ ${(_wordCount / 130).toStringAsFixed(1)} ${tr('ent_minute_unit')}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (_wordCount > 160)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(tr('ent_pitch_too_long'), style: const TextStyle(fontSize: 11, color: Colors.red)),
                      ),
                    if (_wordCount <= 160 && _wordCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(tr('ent_pitch_good_duration'), style: const TextStyle(fontSize: 11, color: Colors.green)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Editable pitch
                TextField(
                  controller: _pitchCtrl,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: null,
                  minLines: 8,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: tr('ent_pitch_text_label'),
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
                    label: Text(_saving ? tr('ent_saving_ellipsis') : tr('ent_save_btn'), style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tips section
                if (_tips.isNotEmpty) ...[
                  Text(tr('ent_pitch_tips_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }
}
