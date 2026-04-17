import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final _service = ContentService();
  List<ContentModel> _items = [];
  bool _loading = true;
  String? _error;
  String _selectedType = 'all';

  final _types = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'article', 'label': 'مقالات'},
    {'id': 'document', 'label': 'مستندات'},
    {'id': 'guide', 'label': 'أدلة'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _items = await _service.fetchContent(
        type: _selectedType == 'all' ? null : _selectedType,
      );
    } catch (_) {
      _error = 'تعذر تحميل المحتوى. تحقق من الاتصال وأعد المحاولة.';
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحتوى والمقالات'),
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Type filter
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _types.length,
                itemBuilder: (_, i) {
                  final t = _types[i];
                  final selected = t['id'] == _selectedType;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(t['label']!),
                      selected: selected,
                      selectedColor: const Color(0xFF1565C0),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (_) {
                        _selectedType = t['id']!;
                        _load();
                      },
                    ),
                  );
                },
              ),
            ),
            // List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(fontSize: 15, color: Colors.grey), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : _items.isEmpty
                      ? const Center(
                          child: Text('لا يوجد محتوى حالياً',
                              style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _items.length,
                            itemBuilder: (_, i) => _ContentCard(
                              item: _items[i],
                              onTap: () => _openDetail(_items[i]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(ContentModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailSheet(item: item),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final ContentModel item;
  final VoidCallback onTap;

  const _ContentCard({required this.item, required this.onTap});

  IconData _iconForType(String type) {
    switch (type) {
      case 'article':
        return Icons.article_outlined;
      case 'document':
        return Icons.description_outlined;
      case 'guide':
        return Icons.menu_book_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'article':
        return const Color(0xFF1565C0);
      case 'document':
        return const Color(0xFFE65100);
      case 'guide':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(item.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForType(item.type), color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Chip(label: item.typeLabel, color: color),
                        if (item.category != null) ...[
                          const SizedBox(width: 6),
                          _Chip(
                              label: item.category!,
                              color: Colors.grey.shade600),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final ContentModel item;
  const _DetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),
            Text(item.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              _Chip(
                  label: item.typeLabel,
                  color: const Color(0xFF1565C0)),
              if (item.category != null) ...[
                const SizedBox(width: 6),
                _Chip(label: item.category!, color: Colors.grey.shade600),
              ],
            ]),
            const SizedBox(height: 16),
            if (item.body != null && item.body!.isNotEmpty)
              Text(item.body!,
                  style: const TextStyle(fontSize: 15, height: 1.7)),
            if (item.fileUrl != null && item.fileUrl!.isNotEmpty) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openUrl(item.fileUrl!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('فتح الملف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
