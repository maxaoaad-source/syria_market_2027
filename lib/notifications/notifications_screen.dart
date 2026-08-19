import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/supabase_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final data = await SupabaseService.client
        .from("notifications")
        .select()
        .eq("user_id", user.id)
        .order("created_at", ascending: false);

    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> markAsRead(int id) async {
    await SupabaseService.client
        .from("notifications")
        .update({"is_read": true})
        .eq("id", id);

    setState(() {
      final index = notifications.indexWhere((n) => n["id"] == id);
      if (index != -1) notifications[index]["is_read"] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("لا توجد إشعارات"))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final isRead = n["is_read"] ?? false;

                    return Card(
                      color: isRead ? Colors.white : Colors.green.shade50,
                      child: ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: isRead ? Colors.grey : Colors.green,
                        ),
                        title: Text(n["title"] ?? ""),
                        subtitle: Text(n["body"] ?? ""),
                        trailing: !isRead
                            ? TextButton(
                                onPressed: () => markAsRead(n["id"]),
                                child: const Text("تحديد كمقروء"),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}