
// ... inside signup logic
final response = await AuthService.signup(
  emailController.text.trim(),
  passwordController.text.trim(),
);
if (response.user != null) {
  // رَفْع الصورة
  String? imageUrl;
  if (profileImage != null) {
    imageUrl = await StorageService.uploadProfileImage(profileImage!);
  }
  // حِفْظ بيانات المستخدم
  await SupabaseService.client.from("users").insert({
    "id": response.user!.id,
    "email": emailController.text.trim(),
    "username": usernameController.text.trim(),
    "phone": phoneController.text.trim(),
    "governorate": selectedGovernorate,
    "profile_image": imageUrl
  });
  Navigator.pushReplacementNamed(context, "/home");
}
