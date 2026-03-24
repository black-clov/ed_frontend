import 'package:flutter/material.dart';

import '../models/interest_category_model.dart';
import '../services/interests_service.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final InterestsService _service = InterestsService();
  List<InterestCategory>? _categories;
  bool _loading = true;
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _service.fetchCategories();
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  IconData _iconForCategory(String iconName) {
    switch (iconName) {
      case 'computer':
        return Icons.computer;
      case 'palette':
        return Icons.palette;
      case 'build':
        return Icons.build;
      case 'people':
        return Icons.people;
      default:
        return Icons.category;
    }
  }

  Color _colorForCategory(int index) {
    const colors = [
      Color(0xFF1565C0), // Blue - Technology
      Color(0xFF7B1FA2), // Purple - Creativity
      Color(0xFFE65100), // Orange - Manual
      Color(0xFF2E7D32), // Green - People
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اكتشف اهتماماتك'),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final totalSelected = _service.totalSelected;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'اختار المجالات اللي كتهمك ($totalSelected مختار)',
                  style: const TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _categories!.length,
            itemBuilder: (context, index) {
              final cat = _categories![index];
              final isExpanded = _expandedIndex == index;
              final color = _colorForCategory(index);
              final selectedCount =
                  _service.getSelections()[cat.id]?.length ?? 0;

              return Card(
                elevation: isExpanded ? 4 : 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isExpanded
                      ? BorderSide(color: color, width: 2)
                      : BorderSide.none,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(_iconForCategory(cat.icon), color: color),
                      ),
                      title: Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$selectedCount',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          Icon(
                            isExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: color,
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? -1 : index;
                        });
                      },
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cat.subItems.map((sub) {
                            final selected =
                                _service.isSelected(cat.id, sub.id);
                            return FilterChip(
                              label: Text(sub.label),
                              selected: selected,
                              selectedColor: color.withValues(alpha: 0.2),
                              checkmarkColor: color,
                              onSelected: (_) {
                                setState(() {
                                  _service.toggleSubItem(cat.id, sub.id);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
