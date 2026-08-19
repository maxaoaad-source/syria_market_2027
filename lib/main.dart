import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Initialization
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_ID.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق الإعلانات',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: AppRoutes.routes,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Colors.green,
        useMaterial3: false,
      ),
    );
  }
}