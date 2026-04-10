import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/sector_model.dart';
import '../services/sectors_service.dart';

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  final SectorsService _service = SectorsService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<SectorOption> _options = [];
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
    final userId = await _storage.read(key: 'user_id');
    final saved = await _service.getUserSectors(userId);
    setState(() {
      _options = options;
      _selected.addAll(saved);
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر على الأقل قطاع واحد')),
      );
      return;
    }
    setState(() => _submitting = true);
    final userId = await _storage.read(key: 'user_id');
    await _service.submitSectors(userId: userId, sectors: _selected.toList());
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ القطاعات بنجاح ✅')),
    );
  }

  static const _sectorColors = {
    'innovation': Color(0xFF1565C0),
    'sales': Color(0xFFE65100),
    'marketing': Color(0xFF7B1FA2),
    'manual_services': Color(0xFF2E7D32),
    'management': Color(0xFF00838F),
    'people': Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختيار القطاع المهني'),
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
                          colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.business_center, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'فين بغيتي تخدم؟',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'اختر القطاعات اللي كتهمك',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Grid of sectors
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: _options.map((opt) => _buildSectorCard(opt)).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C6BC0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('حفظ الاختيار', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectorCard(SectorOption opt) {
    final isSelected = _selected.contains(opt.key);
    final color = _sectorColors[opt.key] ?? const Color(0xFF5C6BC0);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selected.remove(opt.key);
          } else {
            _selected.add(opt.key);
          }
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withAlpha(40), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(opt.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              opt.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle, color: color, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
