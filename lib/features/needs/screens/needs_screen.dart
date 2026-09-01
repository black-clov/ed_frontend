import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/needs_model.dart';
import '../services/needs_service.dart';
import '../../../core/i18n/app_i18n.dart';

class NeedsScreen extends StatefulWidget {
  const NeedsScreen({super.key});

  @override
  State<NeedsScreen> createState() => _NeedsScreenState();
}

class _NeedsScreenState extends State<NeedsScreen> {
  final NeedsService _service = NeedsService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<NeedsOption> _options = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final options = await _service.fetchOptions();
    // Pre-select previously saved
    final userId = await _storage.read(key: 'user_id');
    final saved = await _service.getUserNeeds(userId);
    setState(() {
      _options = options;
      _selected.addAll(saved);
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('emp1_needs_select_at_least_one'))),
      );
      return;
    }
    setState(() => _submitting = true);
    final userId = await _storage.read(key: 'user_id');
    await _service.submitNeeds(userId: userId, needs: _selected.toList());
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('emp1_needs_save_success'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('emp1_needs_title')),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC62828), Color(0xFFC62828)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.assignment, color: Colors.white, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          tr('emp1_needs_header_title'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('emp1_needs_header_subtitle'),
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options grid
                  ..._options.map((opt) => _buildOptionTile(opt)),

                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              tr('emp1_needs_save_btn'),
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOptionTile(NeedsOption opt) {
    final isSelected = _selected.contains(opt.key);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFFC62828) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? const Color(0xFFFFEBEE) : Colors.white,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(opt.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFFC62828) : Colors.black87,
                  ),
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
  }
}
