import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/businessplan_service.dart';

class BusinessPlanScreen extends StatefulWidget {
  const BusinessPlanScreen({super.key});

  @override
  State<BusinessPlanScreen> createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {
  final BusinessPlanService _service = BusinessPlanService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _nameCtrl = TextEditingController();

  String? _selectedSector;
  bool _generating = false;
  bool _saving = false;
  Map<String, dynamic>? _plan;

  // Editable controllers for each section
  final _descCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _customersCtrl = TextEditingController();
  final _costsCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();

  static const _sectors = [
    {'key': 'innovation', 'label': 'الابتكار والتكنولوجيا', 'icon': '💡'},
    {'key': 'sales', 'label': 'المبيعات والتجارة', 'icon': '🛒'},
    {'key': 'marketing', 'label': 'التسويق والإعلان', 'icon': '📢'},
    {'key': 'manual_services', 'label': 'الخدمات اليدوية', 'icon': '🔧'},
    {'key': 'management', 'label': 'الإدارة والتنظيم', 'icon': '📊'},
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
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _customersCtrl.dispose();
    _costsCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final userId = await _storage.read(key: 'userId');
    final saved = await _service.getSavedPlan(userId);
    if (saved != null) {
      setState(() {
        _nameCtrl.text = saved['projectName'] ?? '';
        _selectedSector = saved['sector'];
        _descCtrl.text = saved['description'] ?? '';
        _valueCtrl.text = saved['valueProposition'] ?? saved['value_proposition'] ?? '';
        _customersCtrl.text = saved['targetCustomers'] ?? saved['target_customers'] ?? '';
        _costsCtrl.text = saved['costs'] ?? '';
        _stepsCtrl.text = saved['firstSteps'] ?? saved['first_steps'] ?? '';
        _plan = saved;
      });
    }
  }

  Future<void> _generate() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل اسم المشروع')),
      );
      return;
    }
    setState(() => _generating = true);
    final userId = await _storage.read(key: 'userId');
    final result = await _service.generatePlan(
      userId: userId,
      projectName: name,
      sector: _selectedSector,
    );
    setState(() {
      _generating = false;
      if (result != null) {
        _plan = result;
        final sections = result['sections'] as Map<String, dynamic>? ?? {};
        _descCtrl.text = sections['description'] ?? '';
        _valueCtrl.text = sections['valueProposition'] ?? '';
        _customersCtrl.text = sections['targetCustomers'] ?? '';
        _costsCtrl.text = sections['costs'] ?? '';
        _stepsCtrl.text = sections['firstSteps'] ?? '';
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final userId = await _storage.read(key: 'userId');
    await _service.savePlan(
      userId: userId,
      projectName: _nameCtrl.text.trim(),
      description: _descCtrl.text,
      valueProposition: _valueCtrl.text,
      targetCustomers: _customersCtrl.text,
      costs: _costsCtrl.text,
      firstSteps: _stepsCtrl.text,
      sector: _selectedSector,
    );
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ خطة العمل بنجاح ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خطة العمل'),
          centerTitle: true,
          actions: [
            if (_plan != null)
              IconButton(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                tooltip: 'حفظ',
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF00897B)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'أنشئ خطة عمل لمشروعك',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'أدخل اسم المشروع واختر القطاع وغادي نولدو ليك خطة عمل بسيطة',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Project name
              TextField(
                controller: _nameCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'اسم المشروع',
                  hintText: 'مثال: مخبزة الحي',
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Sector dropdown
              const Text('القطاع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sectors.map((s) {
                  final isSelected = _selectedSector == s['key'];
                  return ChoiceChip(
                    label: Text('${s['icon']} ${s['label']}'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00897B).withAlpha(40),
                    onSelected: (val) {
                      setState(() => _selectedSector = val ? s['key'] as String : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generating ? null : _generate,
                  icon: _generating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _generating ? 'جاري التوليد...' : _plan == null ? 'توليد خطة العمل' : 'إعادة التوليد',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              // Generated plan sections
              if (_plan != null) ...[
                const SizedBox(height: 24),
                _buildPlanSection(
                  icon: Icons.description,
                  title: 'وصف المشروع',
                  color: const Color(0xFF1565C0),
                  controller: _descCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.diamond,
                  title: 'القيمة المضافة',
                  color: const Color(0xFF7B1FA2),
                  controller: _valueCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.people,
                  title: 'الزبناء المستهدفون',
                  color: const Color(0xFFE65100),
                  controller: _customersCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.account_balance_wallet,
                  title: 'التكاليف المتوقعة',
                  color: const Color(0xFFC62828),
                  controller: _costsCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.flag,
                  title: 'الخطوات الأولى',
                  color: const Color(0xFF2E7D32),
                  controller: _stepsCtrl,
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                    label: Text(
                      _saving ? 'جاري الحفظ...' : 'حفظ خطة العمل',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSection({
    required IconData icon,
    required String title,
    required Color color,
    required TextEditingController controller,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
