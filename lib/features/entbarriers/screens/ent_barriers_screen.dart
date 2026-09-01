import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/ent_barrier_model.dart';
import '../services/ent_barriers_service.dart';
import '../../../core/i18n/app_i18n.dart';

class EntBarriersScreen extends StatefulWidget {
  const EntBarriersScreen({super.key});

  @override
  State<EntBarriersScreen> createState() => _EntBarriersScreenState();
}

class _EntBarriersScreenState extends State<EntBarriersScreen> {
  final EntBarriersService _service = EntBarriersService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _notesCtrl = TextEditingController();

  List<EntBarrierOption> _options = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final options = await _service.fetchOptions();
    final userId = await _storage.read(key: 'user_id');
    final saved = await _service.getUserData(userId);
    final savedBarriers = (saved['barriers'] as List?)?.cast<String>() ?? [];

    setState(() {
      _options = options;
      _selected.addAll(savedBarriers);
      _notesCtrl.text = (saved['notes'] as String?) ?? '';
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('ent_barriers_select_at_least_one'))),
      );
      return;
    }
    setState(() => _submitting = true);
    final userId = await _storage.read(key: 'user_id');
    await _service.submit(
      userId: userId,
      barriers: _selected.toList(),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('ent_barriers_saved_success'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tr('ent_barriers_title')),
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
                        gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFEF5350)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.block, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            tr('ent_barriers_header_title'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr('ent_barriers_header_subtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Barriers list
                    ..._options.map((opt) {
                      final isSelected = _selected.contains(opt.key);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? const BorderSide(color: Color(0xFFC62828), width: 2)
                              : BorderSide.none,
                        ),
                        color: isSelected ? const Color(0xFFC62828).withAlpha(12) : null,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selected.remove(opt.key);
                              } else {
                                _selected.add(opt.key);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Text(opt.icon, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
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
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? const Color(0xFFC62828) : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Notes
                    TextField(
                      controller: _notesCtrl,
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: tr('ent_barriers_notes_label'),
                        hintText: tr('ent_barriers_notes_hint'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(tr('ent_save_btn'), style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
