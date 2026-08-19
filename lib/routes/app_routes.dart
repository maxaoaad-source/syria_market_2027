import 'package:flutter/material.dart';

// AUTH
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../auth/reset_password_screen.dart';
import '../auth/profile_screen.dart';

// HOME
import '../home/home_screen.dart';
import '../home/sidebar_menu.dart';

// ADS
import '../ads/add_ad_screen.dart';
import '../ads/ad_details_screen.dart';
import '../ads/my_ads_screen.dart';
import '../ads/favorites_screen.dart';

// MESSAGES
import '../messages/messages_screen.dart';
import '../messages/chat_screen.dart';

// NOTIFICATIONS
import '../notifications/notifications_screen.dart';

// ADMIN
import '../admin/admin_home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        // AUTH
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/reset_password': (_) => const ResetPasswordScreen(),
        '/profile': (_) => const ProfileScreen(),

        // HOME
        '/home': (_) => const HomeScreen(),
        '/menu': (_) => const SidebarMenu(),

        // ADS
        '/add_ad': (_) => const AddAdScreen(),
        '/my_ads': (_) => const MyAdsScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/ad_details': (context) {
          final ad = ModalRoute.of(context)!.settings.arguments;
          return AdDetailsScreen(ad: ad);
        },

        // MESSAGES
        '/messages': (_) => const MessagesScreen(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ChatScreen(
            chatId: args["chat_id"],
            otherId: args["other_id"],
          );
        },

        // NOTIFICATIONS
        '/notifications': (_) => const NotificationsScreen(),

        // ADMIN
        '/admin': (_) => const AdminHomeScreen(),
      };
}