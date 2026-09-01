import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/businessplan_service.dart';
import '../../../core/i18n/app_i18n.dart';

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

  List<Map<String, String>> get _sectors => [
    {'key': 'innovation', 'label': tr('ent_sector_innovation_tech'), 'icon': '💡'},
    {'key': 'sales', 'label': tr('ent_sector_sales_trade'), 'icon': '🛒'},
    {'key': 'marketing', 'label': tr('ent_sector_marketing_ads'), 'icon': '📢'},
    {'key': 'manual_services', 'label': tr('ent_sector_manual_services'), 'icon': '🔧'},
    {'key': 'management', 'label': tr('ent_sector_management_org'), 'icon': '📊'},
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
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _customersCtrl.dispose();
    _costsCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final userId = await _storage.read(key: 'user_id');
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
        SnackBar(content: Text(tr('ent_enter_project_name'))),
      );
      return;
    }
    setState(() => _generating = true);
    final userId = await _storage.read(key: 'user_id');
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
    final userId = await _storage.read(key: 'user_id');
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
      SnackBar(content: Text(tr('ent_bp_saved_success'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tr('ent_bp_title')),
          centerTitle: true,
          actions: [
            if (_plan != null)
              IconButton(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                tooltip: tr('ent_save_btn'),
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
                    colors: [Color(0xFF2E7D32), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      tr('ent_bp_header_title'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('ent_bp_header_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Project name
              TextField(
                controller: _nameCtrl,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: tr('ent_project_name_label'),
                  hintText: tr('ent_bp_project_name_hint'),
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Sector dropdown
              Text(tr('ent_sector_label'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sectors.map((s) {
                  final isSelected = _selectedSector == s['key'];
                  return ChoiceChip(
                    label: Text('${s['icon']} ${s['label']}'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E7D32).withAlpha(40),
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
                    _generating ? tr('ent_generating_ellipsis') : _plan == null ? tr('ent_bp_generate_btn') : tr('ent_bp_regenerate_btn'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
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
                  title: tr('ent_bp_section_description'),
                  color: const Color(0xFF2E7D32),
                  controller: _descCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.diamond,
                  title: tr('ent_bp_section_value'),
                  color: const Color(0xFF2E7D32),
                  controller: _valueCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.people,
                  title: tr('ent_bp_section_customers'),
                  color: const Color(0xFF2E7D32),
                  controller: _customersCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.account_balance_wallet,
                  title: tr('ent_bp_section_costs'),
                  color: const Color(0xFFC62828),
                  controller: _costsCtrl,
                ),
                _buildPlanSection(
                  icon: Icons.flag,
                  title: tr('ent_bp_section_steps'),
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
                      _saving ? tr('ent_saving_ellipsis') : tr('ent_bp_save_plan_btn'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
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
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
