import 'package:flutter/material.dart';
import '../core/models/ad_model.dart';
import '../core/services/supabase_service.dart';
import '../core/theme/app_colors.dart';

class AdDetailsScreen extends StatefulWidget {
  final AdModel ad;

  const AdDetailsScreen({super.key, required this.ad});

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends State<AdDetailsScreen> {
  bool isSold = false;

  @override
  void initState() {
    super.initState();
    isSold = widget.ad.isSold;
  }

  Future<void> toggleSold() async {
    await SupabaseService.client
        .from("ads")
        .update({"is_sold": !isSold})
        .eq("id", widget.ad.id);

    setState(() => isSold = !isSold);
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(ad.title),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.network(ad.image, height: 250, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(ad.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("${ad.price} ل.س", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text(ad.description),
          const SizedBox(height: 10),
          Text("القسم: ${ad.category}"),
          Text("المحافظة: ${ad.governorate}"),
          Text("الحالة: ${ad.condition}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: toggleSold,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSold ? Colors.red : Colors.green,
            ),
            child: Text(isSold ? "إلغاء البيع" : "تم البيع"),
          ),
        ],
      ),
    );
  }
}