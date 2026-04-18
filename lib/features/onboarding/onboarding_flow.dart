import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dashboard/dashboard_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  String _gender = 'boy';
  final _storage = const FlutterSecureStorage();

  // Employment Key 1 controllers
  final _empLikes = TextEditingController();
  final _empKnows = TextEditingController();
  final _empStrengths = TextEditingController();
  final _empQuiz = TextEditingController();

  // Employment Key 2 controllers
  final _empSkillsDev = TextEditingController();
  final _empBarriers = TextEditingController();
  final _empImprove = TextEditingController();

  // Entrepreneurship Key 1 controllers
  final _entLikes = TextEditingController();
  final _entKnows = TextEditingController();
  final _entStrengths = TextEditingController();
  final _entQuiz = TextEditingController();

  // Entrepreneurship Key 2 controllers
  final _entDevelop = TextEditingController();
  final _entObstacles = TextEditingController();
  final _entSupport = TextEditingController();

  // Entrepreneurship Key 4 controllers
  final _entWhatNeed = TextEditingController();
  final _entTrainingType = TextEditingController();
  final _entFunding = TextEditingController();
  final _entContact = TextEditingController();

  static const int _totalSteps = 11;

  @override
  void initState() {
    super.initState();
    _loadGender();
  }

  Future<void> _loadGender() async {
    final g = await _storage.read(key: 'gender');
    if (g != null && mounted) setState(() => _gender = g);
  }

  @override
  void dispose() {
    _empLikes.dispose();
    _empKnows.dispose();
    _empStrengths.dispose();
    _empQuiz.dispose();
    _empSkillsDev.dispose();
    _empBarriers.dispose();
    _empImprove.dispose();
    _entLikes.dispose();
    _entKnows.dispose();
    _entStrengths.dispose();
    _entQuiz.dispose();
    _entDevelop.dispose();
    _entObstacles.dispose();
    _entSupport.dispose();
    _entWhatNeed.dispose();
    _entTrainingType.dispose();
    _entFunding.dispose();
    _entContact.dispose();
    super.dispose();
  }

  void _next() async {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      await _saveData();
      await _storage.write(key: 'onboarding_done', value: 'true');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _saveData() async {
    final entries = {
      'emp_likes': _empLikes.text,
      'emp_knows': _empKnows.text,
      'emp_strengths': _empStrengths.text,
      'emp_quiz': _empQuiz.text,
      'emp_skills_dev': _empSkillsDev.text,
      'emp_barriers': _empBarriers.text,
      'emp_improve': _empImprove.text,
      'ent_likes': _entLikes.text,
      'ent_knows': _entKnows.text,
      'ent_strengths': _entStrengths.text,
      'ent_quiz': _entQuiz.text,
      'ent_develop': _entDevelop.text,
      'ent_obstacles': _entObstacles.text,
      'ent_support': _entSupport.text,
      'ent_what_need': _entWhatNeed.text,
      'ent_training_type': _entTrainingType.text,
      'ent_funding': _entFunding.text,
      'ent_contact': _entContact.text,
    };
    for (final e in entries.entries) {
      if (e.value.isNotEmpty) {
        await _storage.write(key: e.key, value: e.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: _step == 0
            ? SafeArea(child: _buildCurrentStep())
            : Stack(
                children: [
                  // FULL-SCREEN BACKGROUND IMAGE (centered and covering)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_bgImage),
                          fit: BoxFit.cover, // fills whole screen
                          alignment: Alignment.center, // centered on phone
                        ),
                      ),
                    ),
                  ),
                  // Foreground content
                  SafeArea(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withOpacity(
                        (_step == 1 || _step == 6) ? 0.0 : 0.15,
                      ), // optional slight dim on text steps
                      child: _buildCurrentStep(),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: _step == 0 ? null : _buildNavBar(),
      ),
    );
  }

  String get _bgImage {
    if (_step == 1) return 'assets/images/porte_emploi.png';
    if (_step == 6) return 'assets/images/porte_entreprenariat.png';
    if (_step <= 5) return 'assets/images/cle_emploi.png';
    return 'assets/images/cle_entreprenariat.png';
  }

  Color get _bgColor {
    if (_step <= 1) return const Color(0xFFFAF6F0);
    if (_step <= 5) return const Color(0xFFFAF6F0);
    return const Color(0xFFF0F7F0);
  }

  Widget _buildNavBar() {
    final isEmp = _step <= 5;
    final color = isEmp ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _prev,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('رجوع',
                  style: TextStyle(color: color, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _step == _totalSteps - 1 ? 'إنهاء' : 'التالي',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildIntro();
      case 1:
        return _buildDoor(true);
      case 2:
        return _buildEmpKey1();
      case 3:
        return _buildEmpKey2();
      case 4:
        return _buildEmpKey3();
      case 5:
        return _buildEmpKey4();
      case 6:
        return _buildDoor(false);
      case 7:
        return _buildEntKey1();
      case 8:
        return _buildEntKey2();
      case 9:
        return _buildEntKey3();
      case 10:
        return _buildEntKey4();
      default:
        return const SizedBox();
    }
  }

  // ──────────── STEP 0: INTRO ────────────
  Widget _buildIntro() {
    final isBoy = _gender == 'boy';
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.asset('assets/images/logo_eidmaj.png', height: 80),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE65100),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'آشكيد نتعارفو',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
        const Spacer(),
        Image.asset(
          isBoy
              ? 'assets/images/mascott_garcon.png'
              : 'assets/images/mascott_fille.png',
          height: 300,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('يلا نبداو',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ──────────── DOOR SCREENS ────────────
  Widget _buildDoor(bool isEmployment) {
    final color =
        isEmployment ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
    return GestureDetector(
      onTap: _next,
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ──────────── EMPLOYMENT KEYS ────────────
  Widget _buildEmpKey1() {
    return _buildKeyStep(
      isEmployment: true,
      keyTitle: 'شكون أنا',
      bannerTitle: 'عرف راسك مزيان',
      subtitle:
          'قبل ما تقلب على خدمة ولا تكوين،\nخاصك تعرف شكون نتا:',
      content: Column(children: [
        _buildField('شنو كتحب تدير؟', _empLikes, const Color(0xFFE65100)),
        _buildField('شنو كتعرف تدير؟', _empKnows, const Color(0xFFE65100)),
        _buildField('نقاط القوة ديالك', _empStrengths, const Color(0xFFE65100)),
        _buildField('اختبار توجيه بسيط', _empQuiz, const Color(0xFFE65100)),
      ]),
      footerText: '',
    );
  }

  Widget _buildEmpKey2() {
    return _buildKeyStep(
      isEmployment: true,
      keyTitle: 'آش خاصني؟',
      bannerTitle: 'آش خاصني؟',
      subtitle:
          'دابا ملي عرفتي شكون نتا\nجا الوقت تحدد بالضبط آش خاصك تطوّر.',
      content: Column(children: [
        _buildField('شنو المهارات اللي خاصك تطورها؟', _empSkillsDev,
            const Color(0xFFE65100)),
        _buildField('شنو اللي واقف قدامك؟', _empBarriers,
            const Color(0xFFE65100)),
        _buildField('فين خاصك تزيد تخدم على راسك؟', _empImprove,
            const Color(0xFFE65100)),
      ]),
      footerText: '',
    );
  }

  Widget _buildEmpKey3() {
    return _buildKeyStep(
      isEmployment: true,
      keyTitle: 'طريق النجاح',
      bannerTitle: 'طريق النجاح',
      subtitle: '',
      content: _buildStepTimeline(
        items: [
          'تدريب مصغر',
          'مقطع فيديو قصير',
          'اختبار تفاعلي',
          'جزّب مقابلة حقيقية',
          'صايب CV ديالك',
        ],
        color: const Color(0xFFE65100),
      ),
      footerText: '',
    );
  }

  Widget _buildEmpKey4() {
    return _buildKeyStep(
      isEmployment: true,
      keyTitle: 'كاين معامن',
      bannerTitle: 'كاين معامن',
      subtitle: '',
      content: _buildStepTimeline(
        items: [
          'اكتشف الفرص اللي قريبة ليك',
          'برامج التكوين',
          'مواكبة على أرض الواقع',
          'تواصل',
        ],
        color: const Color(0xFFE65100),
      ),
      footerText: '',
    );
  }

  // ──────────── ENTREPRENEURSHIP KEYS ────────────
  Widget _buildEntKey1() {
    return _buildKeyStep(
      isEmployment: false,
      keyTitle: 'شكون أنا',
      bannerTitle: 'عرف راسك مزيان',
      subtitle: 'باش تولي مقاول، خاصك\nقبل كلشي تعرف:',
      content: Column(children: [
        _buildField('شنو كتحب فالمقاولة؟', _entLikes, const Color(0xFF2E7D32)),
        _buildField('شنو كتعرف تدير؟', _entKnows, const Color(0xFF2E7D32)),
        _buildField('نقاط القوة ديالك', _entStrengths, const Color(0xFF2E7D32)),
        _buildField('اختبار توجيه بسيط', _entQuiz, const Color(0xFF2E7D32)),
      ]),
      footerText: '',
    );
  }

  Widget _buildEntKey2() {
    return _buildKeyStep(
      isEmployment: false,
      keyTitle: 'آش خاصني؟',
      bannerTitle: 'آش خاصني؟',
      subtitle: 'شنو ناقصك باش تزير القدّام\nفالمقاولة؟',
      content: Column(children: [
        _buildField('شنو خاصك تطوّر دابا؟', _entDevelop,
            const Color(0xFF2E7D32)),
        _buildField('شنو العوائق اللي كتواجهك؟', _entObstacles,
            const Color(0xFF2E7D32)),
        _buildField('فين خاصك الدعم أكثر؟', _entSupport,
            const Color(0xFF2E7D32))
      ]),
      footerText: '',
    );
  }

  Widget _buildEntKey3() {
    return _buildKeyStep(
      isEmployment: false,
      keyTitle: 'طريق النجاح',
      bannerTitle: 'طريق النجاح',
      subtitle: '',
      content: _buildStepTimeline(
        items: [
          'تدريب مصغر',
          'مقطع فيديو قصير',
          'اختبار تفاعلي',
          'توليد خطة عمل مصغرة',
        ],
        color: const Color(0xFF2E7D32),
      ),
      footerText: '',
    );
  }

  Widget _buildEntKey4() {
    return _buildKeyStep(
      isEmployment: false,
      keyTitle: 'كاين معامن',
      bannerTitle: 'كاين معامن',
      subtitle:
          'دابا اللي خاصك هو الربط مع\nالفرص الحقيقية والناس اللي يقدرو يعاونوك.',
      content: Column(children: [
        _buildField('شنو باغي تلقى دابا؟', _entWhatNeed,
            const Color(0xFF2E7D32)),
        _buildField('شنو نوع التكوين اللي كيناسبك؟', _entTrainingType,
            const Color(0xFF2E7D32)),
        _buildField('التمويل: فين وصلتي؟', _entFunding,
            const Color(0xFF2E7D32)),
        _buildField('شكون باغي تتواصل معاه؟', _entContact,
            const Color(0xFF2E7D32)),
      ]),
      footerText: '',
    );
  }

  // ──────────── REUSABLE BUILDERS ────────────
  Widget _buildKeyStep({
    required bool isEmployment,
    required String keyTitle,
    required String bannerTitle,
    required String subtitle,
    required Widget content,
    required String footerText,
  }) {
    final color =
        isEmployment ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
    final darkColor =
        isEmployment ? const Color(0xFF1A237E) : const Color(0xFF1B5E20);
    final doorLabel = isEmployment ? 'باب الخدمة' : 'باب المقاولة';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Door sign
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: darkColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              doorLabel,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),

          // Arrow and check
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: darkColor, shape: BoxShape.circle),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title banner
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              bannerTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.5),
          ),
          const SizedBox(height: 14),

          // Content
          content,
          const SizedBox(height: 12),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  footerText,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '• $label',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color.withAlpha(80)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color.withAlpha(80)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTimeline({
    required List<String> items,
    required Color color,
  }) {
    return Column(
      children: List.generate(items.length, (i) {
        final isLast = i == items.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column: circle + connector line
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    // Numbered circle
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(60),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Connector line + arrow
                    if (!isLast)
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: 3,
                                color: color.withAlpha(80),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: color.withAlpha(150),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Step content card
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withAlpha(60)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    items[i],
                    style: TextStyle(
                      color: color.withAlpha(220),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionItem(String label, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        '• $label',
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }
}
