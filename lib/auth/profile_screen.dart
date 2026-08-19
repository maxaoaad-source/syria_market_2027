import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/models/user_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (profile == null) {
      setState(() => isLoading = false);
      return;
    }

    final adminCheck = await SupabaseService.client
        .from("admins")
        .select()
        .eq("id", profile.id);

    setState(() {
      user = profile;
      isAdmin = adminCheck.isNotEmpty;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("حسابي"),
        backgroundColor: AppColors.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("لم يتم العثور على بيانات المستخدم"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user!.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : null,
                        child: user!.profileImage == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(user!.username, style: AppTextStyles.title),
                      const SizedBox(height: 5),
                      Text(user!.email, style: AppTextStyles.subtitle),
                      const SizedBox(height: 5),
                      if (user!.phone != null)
                        Text("رقم الهاتف: ${user!.phone}"),
                      if (user!.governorate != null)
                        Text("المحافظة: ${user!.governorate}"),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (user!.isVerified)
                            _badge("موثّق", Colors.blue),
                          if (user!.isVip) _badge("VIP", Colors.orange),
                          if (user!.isStore) _badge("متجر رسمي", Colors.green),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.list_alt),
                        title: const Text("إعلاناتي"),
                        onTap: () => Navigator.pushNamed(context, "/my_ads"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text("المفضلة"),
                        onTap: () => Navigator.pushNamed(context, "/favorites"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.message),
                        title: const Text("الرسائل"),
                        onTap: () => Navigator.pushNamed(context, "/messages"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text("الإشعارات"),
                        onTap: () => Navigator.pushNamed(context, "/notifications"),
                      ),
                      if (isAdmin)
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings),
                          title: const Text("غرفة العمليات"),
                          onTap: () => Navigator.pushNamed(context, "/admin"),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await AuthService.logout();
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("تسجيل الخروج", style: AppTextStyles.button),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}