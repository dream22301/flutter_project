import 'package:flutter/material.dart';
import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const EduCanvasApp());
}

class EduCanvasApp extends StatelessWidget {
  const EduCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduCanvas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4444FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _SplashRouter(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH ROUTER  — checks SharedPreferences and redirects accordingly
// ─────────────────────────────────────────────────────────────────────────────

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  static const _primary = Color(0xFF4C4DDC);

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Small delay so the splash shows briefly
    await Future.delayed(const Duration(milliseconds: 800));

    final isLoggedIn = await AuthController.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), _primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: _primary.withOpacity(0.30), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 20),
            const Text(
              'EduCanvas',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _primary, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Portal Siswa Digital',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}