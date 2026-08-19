import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _login() async {
    setState(() => isLoading = true);

    final res = await AuthService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (res.session != null) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      _showMsg("فشل تسجيل الدخول، تحقق من البيانات");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("تسجيل الدخول", style: AppTextStyles.title),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "البريد الإلكتروني",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "كلمة المرور",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("دخول", style: AppTextStyles.button),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/reset_password"),
                child: const Text("نسيت كلمة المرور؟"),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/signup"),
                child: const Text("إنشاء حساب جديد"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}