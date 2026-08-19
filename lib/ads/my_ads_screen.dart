import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/supabase_service.dart';
import '../core/models/ad_model.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  List<AdModel> ads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  Future<void> loadAds() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final data = await SupabaseService.client
        .from("ads")
        .select()
        .eq("user_id", user.id)
        .order("created_at", ascending: false);

    setState(() {
      ads = data.map<AdModel>((e) => AdModel.fromMap(e)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إعلاناتي"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ads.isEmpty
              ? const Center(child: Text("لا يوجد إعلانات"))
              : ListView.builder(
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(ad.image, width: 70, height: 70, fit: BoxFit.cover),
                        title: Text(ad.title),
                        subtitle: Text("${ad.price} ل.س"),
                        onTap: () {
                          Navigator.pushNamed(context, "/ad_details", arguments: ad);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}