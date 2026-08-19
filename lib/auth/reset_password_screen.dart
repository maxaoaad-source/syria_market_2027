import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _reset() async {
    if (emailController.text.isEmpty) {
      _showMsg("أدخل البريد الإلكتروني أولاً");
      return;
    }

    setState(() => isLoading = true);

    await AuthService.resetPassword(emailController.text.trim());

    _showMsg("تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك");

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("إعادة تعيين كلمة المرور"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور",
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "البريد الإلكتروني",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("إرسال", style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}