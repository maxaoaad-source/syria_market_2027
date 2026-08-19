
// ... inside login button onPressed
onPressed: () async {
  setState(() => isLoading = true);
  final response = await AuthService.login(
    emailController.text.trim(),
    passwordController.text.trim(),
  );
  if (response.session != null) {
    Navigator.pushReplacementNamed(context, "/home");
  } else {
    showMessage_("خطأ في تسجيل الدخول");
  }
  setState(() => isLoading = false);
}
