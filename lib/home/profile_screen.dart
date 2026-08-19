
// ... inside load profile
final profile = await AuthService.getUserProfile();
setState(() {
  userData = profile?.toMap();
});
