import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/supabase_service.dart';
import '../core/models/ad_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<AdModel> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final data = await SupabaseService.client
        .from("favorites")
        .select("ad_id, ads(*)")
        .eq("user_id", user.id);

    favorites = data.map<AdModel>((e) => AdModel.fromMap(e["ads"])).toList();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المفضلة"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(child: Text("لا توجد إعلانات مفضلة"))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final ad = favorites[index];
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