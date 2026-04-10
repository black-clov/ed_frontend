class CvModel {
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String education;
  final String age;
  final List<String> skills;
  final List<String> interests;
  final List<String> personalityHighlights;
  final List<String> needs;
  final List<String> workPreferences;

  const CvModel({
    required this.fullName,
    this.email = '',
    this.phone = '',
    this.city = '',
    this.education = '',
    this.age = '',
    required this.skills,
    required this.interests,
    required this.personalityHighlights,
    this.needs = const [],
    this.workPreferences = const [],
  });
}