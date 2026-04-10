import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/opportunity_model.dart';
import '../services/opportunities_service.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final OpportunitiesService _service = OpportunitiesService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<OpportunityModel> _opportunities = [];
  bool _loading = true;
  bool _showMatched = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = await _storage.read(key: 'user_id');
    final list = _showMatched
        ? await _service.getMatchedOpportunities(userId)
        : await _service.getOpportunities();
    setState(() {
      _opportunities = list;
      _loading = false;
    });
  }

  Color _scoreColor(int score) {
    if (score >= 70) return const Color(0xFF2E7D32);
    if (score >= 40) return const Color(0xFFE65100);
    return Colors.grey;
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'job':
        return 'عرض عمل';
      case 'internship':
        return 'تدريب';
      case 'training':
        return 'تكوين';
      default:
        return type;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'job':
        return const Color(0xFF1565C0);
      case 'internship':
        return const Color(0xFF7B1FA2);
      case 'training':
        return const Color(0xFF00897B);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفرص المتاحة'),
          centerTitle: true,
          actions: [
            TextButton.icon(
              onPressed: () {
                setState(() => _showMatched = !_showMatched);
                _load();
              },
              icon: Icon(
                _showMatched ? Icons.auto_awesome : Icons.list,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                _showMatched ? 'الكل' : 'المطابقة',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _opportunities.isEmpty
                ? const Center(child: Text('لا توجد فرص حالياً'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _opportunities.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildHeader();
                      return _buildOpportunityCard(_opportunities[index - 1]);
                    },
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    if (!_showMatched) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فرص مطابقة لملفك الشخصي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'مرتبة حسب نسبة التوافق مع مهاراتك واحتياجاتك',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(OpportunityModel opp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with match score
            Row(
              children: [
                Expanded(
                  child: Text(
                    opp.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_showMatched && opp.matchScore > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _scoreColor(opp.matchScore).withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _scoreColor(opp.matchScore),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${opp.matchScore}%',
                      style: TextStyle(
                        color: _scoreColor(opp.matchScore),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Type & location
            Row(
              children: [
                if (opp.type.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: _typeColor(opp.type).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _typeLabel(opp.type),
                      style: TextStyle(
                        color: _typeColor(opp.type),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  opp.location,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              opp.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            // Match reasons
            if (opp.matchReasons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: opp.matchReasons
                    .map((r) => Chip(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            r,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: const Color(0xFFE8F5E9),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
