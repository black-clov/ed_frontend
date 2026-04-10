import '../../../services/api_service.dart';
import '../models/mentor_model.dart';

class MentorshipService {
  final ApiService _apiService = ApiService();

  Future<List<MentorModel>> getMentors() async {
    try {
      await _apiService.get('/mentors');
    } catch (_) {
      // Fallback to local sample mentors.
    }

    return const [
      MentorModel(
        name: 'Dr. Abdeltif Belmkadem',
        focusArea: 'Career Orientation',
        location: 'Casablanca',
      ),
      MentorModel(
        name: 'Salma Amrani',
        focusArea: 'Women Entrepreneurship',
        location: 'Rabat',
      ),
    ];
  }
}
