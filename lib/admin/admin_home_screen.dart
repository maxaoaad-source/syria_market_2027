import 'package:flutter/material.dart';
import '../core/services/supabase_service.dart';
import '../core/models/ad_model.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isAdmin = false;
  bool isLoading = true;

  List<AdModel> ads = [];
  List<dynamic> categories = [];
  List<dynamic> plans = [];
  List<dynamic> badges = [];
  Map<String, dynamic> appSettings = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      Navigator.pop(context);
      return;
    }

    final adminCheck = await SupabaseService.client
        .from("admins")
        .select()
        .eq("id", user.id);

    if (adminCheck.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => isAdmin = true);
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final client = SupabaseService.client;

      final adsData = await client.from("ads").select();
      final categoriesData = await client.from("categories").select();
      final plansData = await client.from("plans").select();
      final badgesData = await client.from("badges").select();
      final settingsData = await client.from("settings").select().maybeSingle();

      setState(() {
        ads = adsData.map<AdModel>((e) => AdModel.fromMap(e)).toList();
        categories = categoriesData;
        plans = plansData;
        badges = badgesData;
        appSettings = settingsData ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const Scaffold(
        body: Center(child: Text("غير مخوّل بالدخول إلى غرفة العمليات")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("غرفة العمليات"),
        backgroundColor: Colors.red.shade700,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "الإعلانات"),
            Tab(text: "الأقسام"),
            Tab(text: "الخطط"),
            Tab(text: "الشارات"),
            Tab(text: "الإعدادات"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAdsTab(),
                _buildCategoriesTab(),
                _buildPlansTab(),
                _buildBadgesTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  // تبويب الإعلانات
  Widget _buildAdsTab() {
    return ListView.builder(
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Image.network(ad.image, width: 60, height: 60, fit: BoxFit.cover),
            title: Text(ad.title),
            subtitle: Text("${ad.price} ل.س - ${ad.governorate} - ${ad.type}"),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleAdAction(value, ad),
              itemBuilder: (context) => [
                const PopupMenuItem(value: "feature", child: Text("تعيين كمميز")),
                const PopupMenuItem(value: "sponsor", child: Text("تعيين كممول")),
                const PopupMenuItem(value: "free", child: Text("تعيين كمجاني")),
                const PopupMenuItem(value: "delete", child: Text("حذف الإعلان")),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAdAction(String action, AdModel ad) async {
    final client = SupabaseService.client;

    if (action == "delete") {
      await client.from("ads").delete().eq("id", ad.id);
      setState(() => ads.removeWhere((a) => a.id == ad.id));
      return;
    }

    String newType = ad.type;
    if (action == "feature") newType = "featured";
    if (action == "sponsor") newType = "sponsored";
    if (action == "free") newType = "free";

    await client.from("ads").update({"type": newType}).eq("id", ad.id);

    setState(() {
      final idx = ads.indexWhere((a) => a.id == ad.id);
      if (idx != -1) {
        ads[idx] = AdModel(
          id: ad.id,
          userId: ad.userId,
          title: ad.title,
          price: ad.price,
          description: ad.description,
          phone: ad.phone,
          category: ad.category,
          subcategory: ad.subcategory,
          governorate: ad.governorate,
          condition: ad.condition,
          type: newType,
          sponsoredColor: ad.sponsoredColor,
          image: ad.image,
          images: ad.images,
          isSold: ad.isSold,
          createdAt: ad.createdAt,
        );
      }
    });
  }

  // تبويب الأقسام
  Widget _buildCategoriesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                title: Text(cat["name"]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await SupabaseService.client
                        .from("categories")
                        .delete()
                        .eq("id", cat["id"]);
                    setState(() => categories.removeAt(index));
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () => _showAddCategoryDialog(),
            child: const Text("إضافة قسم جديد"),
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("إضافة قسم"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "اسم القسم"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final res = await SupabaseService.client
                  .from("categories")
                  .insert({"name": name}).select().single();
              setState(() => categories.add(res));
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // تبويب الخطط
  Widget _buildPlansTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return ListTile(
                title: Text(plan["name"]),
                subtitle: Text("${plan["price"]} ل.س - ${plan["duration_days"]} يوم"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await SupabaseService.client
                        .from("plans")
                        .delete()
                        .eq("id", plan["id"]);
                    setState(() => plans.removeAt(index));
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () => _showAddPlanDialog(),
            child: const Text("إضافة خطة جديدة"),
          ),
        ),
      ],
    );
  }

  void _showAddPlanDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("إضافة خطة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "اسم الخطة"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "السعر"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: "عدد الأيام"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text.trim()) ?? 0;
              final days = int.tryParse(durationController.text.trim()) ?? 0;

              if (name.isEmpty || price <= 0 || days <= 0) return;

              final res = await SupabaseService.client.from("plans").insert({
                "name": name,
                "price": price,
                "duration_days": days,
              }).select().single();

              setState(() => plans.add(res));
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // تبويب الشارات
  Widget _buildBadgesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return ListTile(
                title: Text(badge["name"]),
                subtitle: Text("الكود: ${badge["code"]}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await SupabaseService.client
                        .from("badges")
                        .delete()
                        .eq("id", badge["id"]);
                    setState(() => badges.removeAt(index));
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () => _showAddBadgeDialog(),
            child: const Text("إضافة شارة جديدة"),
          ),
        ),
      ],
    );
  }

  void _showAddBadgeDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("إضافة شارة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "اسم الشارة"),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "الكود"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final code = codeController.text.trim();
              if (name.isEmpty || code.isEmpty) return;

              final res = await SupabaseService.client
                  .from("badges")
                  .insert({"name": name, "code": code}).select().single();

              setState(() => badges.add(res));
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // تبويب الإعدادات
  Widget _buildSettingsTab() {
    final maintenance = appSettings["maintenance_mode"] ?? false;
    final allowRegister = appSettings["allow_register"] ?? true;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("وضع الصيانة"),
            value: maintenance,
            onChanged: (v) async {
              await SupabaseService.client
                  .from("settings")
                  .update({"maintenance_mode": v}).eq("id", appSettings["id"]);
              setState(() => appSettings["maintenance_mode"] = v);
            },
          ),
          SwitchListTile(
            title: const Text("السماح بالتسجيل"),
            value: allowRegister,
            onChanged: (v) async {
              await SupabaseService.client
                  .from("settings")
                  .update({"allow_register": v}).eq("id", appSettings["id"]);
              setState(() => appSettings["allow_register"] = v);
            },
          ),
        ],
      ),
    );
  }
}
