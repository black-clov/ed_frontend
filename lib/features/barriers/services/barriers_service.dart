import '../models/barriers_model.dart';

class BarriersService {
  final List<String> _selectedBarriers = [];

  List<String> get barriersCatalog => const [
        'No diploma',
        'No experience',
        'Lack of confidence',
        'Lack of internet access',
        'Financial constraints',
        'Family situation',
      ];

  void toggleBarrier(String barrier) {
    if (_selectedBarriers.contains(barrier)) {
      _selectedBarriers.remove(barrier);
      return;
    }

    _selectedBarriers.add(barrier);
  }

  BarriersModel getCurrentSelection() {
    return BarriersModel(
      selectedBarriers: List<String>.from(_selectedBarriers),
    );
  }
}
