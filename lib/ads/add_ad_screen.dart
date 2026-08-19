import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/supabase_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AddAdScreen extends StatefulWidget {
  const AddAdScreen({super.key});

  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  final picker = ImagePicker();

  File? mainImage;
  List<File> extraImages = [];

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final phoneController = TextEditingController();

  String? selectedCategory;
  String? selectedGovernorate;
  String selectedCondition = "جديد";
  String adType = "free";

  bool isLoading = false;

  final categories = [
    "موبايلات",
    "سيارات",
    "عقارات",
    "أثاث",
    "وظائف",
    "كمبيوتر",
    "ألعاب",
    "أخرى",
  ];

  final governorates = [
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

  Future<void> pickMainImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => mainImage = File(picked.path));
    }
  }

  Future<void> pickExtraImages() async {
    final picked = await picker.pickMultiImage();
    setState(() {
      extraImages = picked.map((e) => File(e.path)).toList();
    });
  }

  void showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> publishAd() async {
    if (mainImage == null ||
        titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        descController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedCategory == null ||
        selectedGovernorate == null) {
      showMsg("يرجى تعبئة جميع الحقول الأساسية");
      return;
    }

    setState(() => isLoading = true);

    final user = AuthService.currentUser;
    if (user == null) {
      showMsg("يجب تسجيل الدخول");
      setState(() => isLoading = false);
      return;
    }

    final mainUrl = await StorageService.uploadAdImage(mainImage!);

    List<String> extraUrls = [];
    for (var img in extraImages) {
      final url = await StorageService.uploadAdImage(img);
      if (url != null) extraUrls.add(url);
    }

    await SupabaseService.client.from("ads").insert({
      "user_id": user.id,
      "title": titleController.text,
      "price": int.parse(priceController.text),
      "description": descController.text,
      "phone": phoneController.text,
      "category": selectedCategory,
      "governorate": selectedGovernorate,
      "condition": selectedCondition,
      "type": adType,
      "image": mainUrl,
      "images": extraUrls,
      "is_sold": false,
      "created_at": DateTime.now().toIso8601String(),
    });

    showMsg("تم نشر الإعلان بنجاح");
    Navigator.pop(context);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("إضافة إعلان"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickMainImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: mainImage == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : Image.file(mainImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickExtraImages,
              child: const Text("إضافة صور إضافية"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "عنوان الإعلان"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "السعر"),
            ),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "الوصف"),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "رقم الهاتف"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "القسم"),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "المحافظة"),
              items: governorates
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => selectedGovernorate = v),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "الحالة"),
              value: selectedCondition,
              items: ["جديد", "مستعمل"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCondition = v!),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : publishAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("نشر الإعلان", style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}