
// ... inside reset password button
await AuthService.resetPassword(emailController.text.trim());
showMessage_("تم إرسال رابط إعادة التعيين");
