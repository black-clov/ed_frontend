import 'package:flutter/material.dart';

class GenderWelcomeScreen extends StatelessWidget {
  final String gender;
  const GenderWelcomeScreen({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final isBoy = gender == 'boy';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset('assets/images/logo_eidmaj.png', height: 80),
              const SizedBox(height: 20),
              // Avatar circle
              CircleAvatar(
                radius: 40,
                backgroundColor: isBoy ? Colors.blue.shade100 : Colors.pink.shade100,
                child: Icon(
                  Icons.person,
                  size: 45,
                  color: isBoy ? Colors.blue : Colors.pink,
                ),
              ),
              const SizedBox(height: 24),
              // Ready button (green)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isBoy ? 'يلا مستعد؟' : 'يلا مستعدة؟',
                      style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Not ready button (red)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isBoy ? 'اهو ماشي مستعد ؟' : 'اهو ماشي مستعدة؟',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Mascot image
              Image.asset(
                isBoy ? 'assets/images/mascott_garcon.png' : 'assets/images/mascott_fille.png',
                height: 300,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
