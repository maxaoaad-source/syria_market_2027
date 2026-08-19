import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/supabase_service.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedGovernorate;

  final picker = ImagePicker();
  File? profileImage;
  bool isLoading = false;

  final List<String> governorates = [
    "دمشق",
    "ريف دمشق",
    "حلب",
    "حمص",
    "اللاذقية",
    "طرطوس",
    "درعا",
    "السويداء",
    "الحسكة",
    "الرقة",
    "دير الزور",
    "القنيطرة",
  ];

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> _signup() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        usernameController.text.isEmpty ||
        selectedGovernorate == null) {
      _showMsg("يرجى تعبئة جميع الحقول الأساسية");
      return;
    }

    setState(() => isLoading = true);

    final res = await AuthService.signup(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (res.user == null) {
      _showMsg("فشل إنشاء الحساب");
      setState(() => isLoading = false);
      return;
    }

    String? imageUrl;
    if (profileImage != null) {
      imageUrl = await StorageService.uploadProfileImage(profileImage!);
    }

    await SupabaseService.client.from("users").insert({
      "id": res.user!.id,
      "email": emailController.text.trim(),
      "username": usernameController.text.trim(),
      "phone": phoneController.text.trim(),
      "governorate": selectedGovernorate,
      "profile_image": imageUrl,
    });

    _showMsg("تم إنشاء الحساب بنجاح");
    Navigator.pushReplacementNamed(context, "/home");

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("إنشاء حساب"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.camera_alt, size: 32)
                    : null,
              ),
            ),
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
            const SizedBox(height: 10),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "اسم المستخدم",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "رقم الهاتف",
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: "المحافظة",
                prefixIcon: Icon(Icons.location_city),
              ),
              items: governorates
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => selectedGovernorate = v),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("إنشاء حساب", style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}