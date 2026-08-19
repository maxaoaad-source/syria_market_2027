import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/auth_service.dart';
import '../core/services/supabase_service.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final String otherId;

  const ChatScreen({super.key, required this.chatId, required this.otherId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final picker = ImagePicker();

  List<dynamic> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMessages();
    subscribeToMessages();
  }

  Future<void> loadMessages() async {
    final data = await SupabaseService.client
        .from("messages")
        .select()
        .eq("chat_id", widget.chatId)
        .order("created_at");

    setState(() {
      messages = data;
      isLoading = false;
    });
  }

  void subscribeToMessages() {
    SupabaseService.client
        .channel("chat_${widget.chatId}")
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: "INSERT",
            schema: "public",
            table: "messages",
          ),
          (payload, [ref]) {
            setState(() {
              messages.add(payload["new"]);
            });
          },
        )
        .subscribe();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final user = AuthService.currentUser;

    await SupabaseService.client.from("messages").insert({
      "chat_id": widget.chatId,
      "sender_id": user!.id,
      "text": text,
      "created_at": DateTime.now().toIso8601String(),
    });

    messageController.clear();
  }

  Future<void> sendImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final fileName = "msg_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await SupabaseService.client.storage
        .from("messages")
        .upload(fileName, file);

    final url = SupabaseService.client.storage
        .from("messages")
        .getPublicUrl(fileName);

    final user = AuthService.currentUser;

    await SupabaseService.client.from("messages").insert({
      "chat_id": widget.chatId,
      "sender_id": user!.id,
      "image": url,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("المحادثة"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg["sender_id"] == userId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: msg["image"] != null
                              ? Image.network(msg["image"], width: 200)
                              : Text(msg["text"] ?? ""),
                        ),
                      );
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "اكتب رسالة...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}