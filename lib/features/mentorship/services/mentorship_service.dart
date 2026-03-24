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
        name: 'Yassine E.',
        focusArea: 'Career Orientation',
        location: 'Tangier',
      ),
      MentorModel(
        name: 'Salma R.',
        focusArea: 'Women Entrepreneurship',
        location: 'Fes',
      ),
      MentorModel(
        name: 'Local Program Hub',
        focusArea: 'Community Support Programs',
        location: 'Agadir',
      ),
    ];
  }
}
