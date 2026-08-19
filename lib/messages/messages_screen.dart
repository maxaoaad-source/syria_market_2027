import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/supabase_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  Future<void> loadChats() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final data = await SupabaseService.client
        .from("chats")
        .select()
        .or("user1.eq.${user.id},user2.eq.${user.id}")
        .order("updated_at", ascending: false);

    setState(() {
      chats = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الرسائل"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? const Center(child: Text("لا توجد محادثات"))
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final user = AuthService.currentUser!;
                    final otherId =
                        chat["user1"] == user.id ? chat["user2"] : chat["user1"];

                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(chat["last_message"] ?? "لا توجد رسائل بعد"),
                      subtitle: Text(chat["updated_at"]),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/chat",
                          arguments: {
                            "chat_id": chat["id"],
                            "other_id": otherId,
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}