import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen_new.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Listen to animation completion
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    // Start the main animation
    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      // Check if user is already logged in
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        // Navigate to home screen if user is authenticated
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreenNew()),
        );
      } else {
        // Navigate to login screen if user is not authenticated
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 239, 240),
      body: Center(
        child: Lottie.asset(
          'assets/splash1.json',
          controller: _animationController,
          width: 300.w,
          height: 300.h,
          fit: BoxFit.contain,
          repeat: false,
        ),
      ),
    );
  }
}
