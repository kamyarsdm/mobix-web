import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vrxfhfknmxmeatnfzpcg.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZyeGZoZmtubXhtZWF0bmZ6cGNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYyNTg2MjksImV4cCI6MjA4MTgzNDYyOX0.iANOG9-g9GnVl58KDYI0A-oYNwfbL3oh2NBddZ2sLLs',
  );

  runApp(const MobixCustomerApp());
}

/// لوگو (طبق فایل واقعی شما)
const String kLogoAsset = 'assets/mobix_logo.png';

/// ==============================
/// Engineer-Grade Soft Light Palette
/// ==============================
const Color kBg = Color(0xFFF6F8FB); // Background 0
const Color kBg2 = Color(0xFFEEF2F7); // Background 1
const Color kCard = Color(0xFFFFFFFF); // Surface / Card
const Color kGold = Color(0xFF1F5EFF); // Accent (Engineer Blue)
const Color kGold2 = Color(0xFF1A4FE0); // Accent pressed / darker
const Color kTextSoft = Color(0xFF425066); // Secondary text
const Color kTextPrimary = Color(0xFF0B1220);
const Color kTextTertiary = Color(0xFF7B889C);
const Color kBorder = Color(0xFFD9E1EC);
const Color kAccentSoft = Color(0xFFE9F0FF);

Color _alpha(Color c, double opacity) {
  final a = (opacity.clamp(0.0, 1.0) * 255).round();
  return c.withAlpha(a);
}

class MobixCustomerApp extends StatelessWidget {
  const MobixCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kGold,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: kTextPrimary,
        ),
        cardTheme: CardThemeData(
          color: kCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: kBorder),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kGold, width: 1.2),
          ),
          labelStyle: const TextStyle(color: kTextSoft),
        ),
        dividerColor: kBorder,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kTextPrimary),
          bodyMedium: TextStyle(color: kTextPrimary),
          bodySmall: TextStyle(color: kTextSoft),
          titleMedium: TextStyle(color: kTextPrimary),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

/* ============================== Splash (5s) ============================== */

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BootPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBg2, kBg],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Image.asset(
              kLogoAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _alpha(Colors.black, 0.03),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.phone_android_outlined,
                    size: 72, color: kTextPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================== Storage (Profile + Chat only) ============================== */

class _Prefs {
  static const _kProfile = 'profile_json';

  // چت لوکال برای آف‌لاین (کلید per-order)
  static const _kChatPrefix = 'chat_json_';

  static const _kDailyCounterPrefix = 'daily_counter_';

  static Future<void> saveProfile(Profile? p) async {
    final sp = await SharedPreferences.getInstance();
    if (p == null) {
      await sp.remove(_kProfile);
      return;
    }
    await sp.setString(_kProfile, jsonEncode(p.toJson()));
  }

  static Future<Profile?> loadProfile() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kProfile);
    if (raw == null || raw.trim().isEmpty) return null;
    return Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<List<ChatMessage>> loadChatFor(String orderNo) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('$_kChatPrefix$orderNo');
    if (raw == null || raw.trim().isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(ChatMessage.fromJson).toList();
  }

  static Future<void> saveChatFor(String orderNo, List<ChatMessage> msgs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('$_kChatPrefix$orderNo',
        jsonEncode(msgs.map((m) => m.toJson()).toList()));
  }

  static Future<String> nextLocalOrderNo() async {
    final sp = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = '$_kDailyCounterPrefix${_yyMMdd(now)}';
    final n = (sp.getInt(key) ?? 0) + 1;
    await sp.setInt(key, n);
    final seq = n.toString().padLeft(4, '0');
    return 'MXC-${_yyMMdd(now)}-$seq';
  }
}

/* ============================== Models ============================== */

class Profile {
  final String phone;
  final String fullName;
  final bool acceptedTermsAtLeastOnce;

  const Profile({
    required this.phone,
    required this.fullName,
    required this.acceptedTermsAtLeastOnce,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'fullName': fullName,
    'acceptedTermsAtLeastOnce': acceptedTermsAtLeastOnce,
  };

  static Profile fromJson(Map<String, dynamic> j) => Profile(
    phone: j['phone'] as String,
    fullName: j['fullName'] as String,
    acceptedTermsAtLeastOnce:
    (j['acceptedTermsAtLeastOnce'] as bool?) ?? false,
  );
}

enum DeliveryMethod { inPerson, courier }

enum ChatRole { customer, mobix }

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime at;

  const ChatMessage({required this.role, required this.text, required this.at});

  Map<String, dynamic> toJson() => {
    'role': role.index,
    'text': text,
    'at': at.toIso8601String(),
  };

  static ChatMessage fromJson(Map<String, dynamic> j) => ChatMessage(
    role: ChatRole.values[(j['role'] as num).toInt()],
    text: j['text'] as String,
    at: DateTime.parse(j['at'] as String),
  );
}

/// ====== Server Order Row (from v_orders_fa) ======
class OrderDbRow {
  final int id;
  final String orderNo;
  final String customerPhone;
  final String customerName;

  final String deviceModel;
  final String issue;

  final String deliveryMethod; // in_person | courier
  final String? pickupAddress;
  final String? pickupTimeText;
  final bool needsLoanerPhone;

  final String stage; // received | ...
  final String stageFa; // فارسی
  final int quotedPriceToman;
  final String priceApproval; // pending | ...
  final String priceApprovalFa; // فارسی

  final DateTime createdAt;

  const OrderDbRow({
    required this.id,
    required this.orderNo,
    required this.customerPhone,
    required this.customerName,
    required this.deviceModel,
    required this.issue,
    required this.deliveryMethod,
    required this.pickupAddress,
    required this.pickupTimeText,
    required this.needsLoanerPhone,
    required this.stage,
    required this.stageFa,
    required this.quotedPriceToman,
    required this.priceApproval,
    required this.priceApprovalFa,
    required this.createdAt,
  });

  static OrderDbRow fromJson(Map<String, dynamic> j) => OrderDbRow(
    id: (j['id'] as num).toInt(),
    orderNo: (j['order_no'] as String?) ?? '',
    customerPhone: (j['customer_phone'] as String?) ?? '',
    customerName: (j['customer_name'] as String?) ?? '',
    deviceModel: (j['device_model'] as String?) ?? '',
    issue: (j['issue'] as String?) ?? '',
    deliveryMethod: (j['delivery_method'] as String?) ?? 'in_person',
    pickupAddress: j['pickup_address'] as String?,
    pickupTimeText: j['pickup_time_text'] as String?,
    needsLoanerPhone: (j['needs_loaner_phone'] as bool?) ?? false,
    stage: (j['stage'] as String?) ?? 'received',
    stageFa: (j['stage_fa'] as String?) ??
        _stageFaFromCode((j['stage'] as String?) ?? 'received'),
    quotedPriceToman: (j['quoted_price_toman'] as num?)?.toInt() ?? 0,
    priceApproval: (j['price_approval'] as String?) ?? 'not_needed',
    priceApprovalFa: (j['price_approval_fa'] as String?) ??
        _priceApprovalFaFromCode(
            (j['price_approval'] as String?) ?? 'not_needed'),
    createdAt: DateTime.parse(
        (j['created_at'] as String?) ?? DateTime.now().toIso8601String())
        .toLocal(),
  );

  OrderDbRow copyWith({
    String? stage,
    String? stageFa,
    int? quotedPriceToman,
    String? priceApproval,
    String? priceApprovalFa,
  }) {
    return OrderDbRow(
      id: id,
      orderNo: orderNo,
      customerPhone: customerPhone,
      customerName: customerName,
      deviceModel: deviceModel,
      issue: issue,
      deliveryMethod: deliveryMethod,
      pickupAddress: pickupAddress,
      pickupTimeText: pickupTimeText,
      needsLoanerPhone: needsLoanerPhone,
      stage: stage ?? this.stage,
      stageFa: stageFa ?? this.stageFa,
      quotedPriceToman: quotedPriceToman ?? this.quotedPriceToman,
      priceApproval: priceApproval ?? this.priceApproval,
      priceApprovalFa: priceApprovalFa ?? this.priceApprovalFa,
      createdAt: createdAt,
    );
  }
}

/// پیام چت روی سرور
class ChatMessageDb {
  final int id;
  final String orderNo;
  final String sender; // customer | mobix
  final String text;
  final DateTime createdAt;

  const ChatMessageDb({
    required this.id,
    required this.orderNo,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  static ChatMessageDb fromJson(Map<String, dynamic> j) => ChatMessageDb(
    id: (j['id'] as num).toInt(),
    orderNo: (j['order_no'] as String?) ?? '',
    sender: (j['sender'] as String?) ?? 'customer',
    text: (j['text'] as String?) ?? '',
    createdAt: DateTime.parse(
        (j['created_at'] as String?) ?? DateTime.now().toIso8601String())
        .toLocal(),
  );

  ChatRole get role => sender == 'mobix' ? ChatRole.mobix : ChatRole.customer;
}

/// آپدیت وضعیت سفارش روی سرور (schema جدید)
class OrderUpdateDb {
  final int id;
  final int orderId;
  final String orderNo;
  final String stageCode; // received | price_quoted | price_approval:approved | ...
  final String titleFa; // فارسی
  final String? note;
  final DateTime createdAt;

  const OrderUpdateDb({
    required this.id,
    required this.orderId,
    required this.orderNo,
    required this.stageCode,
    required this.titleFa,
    required this.note,
    required this.createdAt,
  });

  static OrderUpdateDb fromJson(Map<String, dynamic> j) => OrderUpdateDb(
    id: (j['id'] as num).toInt(),
    orderId: (j['order_id'] as num).toInt(),
    orderNo: (j['order_no'] as String?) ?? '',
    stageCode: (j['stage_code'] as String?) ?? '',
    titleFa: (j['title_fa_final'] as String?) ??
        (j['title_fa'] as String?) ??
        '',
    note: j['note'] as String?,
    createdAt: DateTime.parse(
        (j['created_at'] as String?) ?? DateTime.now().toIso8601String())
        .toLocal(),
  );
}

/* ============================== Supabase insert order (schema جدید) ============================== */

Map<String, dynamic> _orderToDb({
  required String orderNo,
  required Profile profile,
  required String deviceModel,
  required String issue,
  required DeliveryMethod deliveryMethod,
  required String? pickupAddress,
  required String? pickupTimeText,
  required bool needsLoanerPhone,
}) {
  return {
    'order_no': orderNo,
    'customer_phone': profile.phone,
    'customer_name': profile.fullName,
    'device_model': deviceModel,
    'issue': issue,
    'delivery_method':
    (deliveryMethod == DeliveryMethod.inPerson) ? 'in_person' : 'courier',
    'pickup_address': pickupAddress,
    'pickup_time_text': pickupTimeText,
    'needs_loaner_phone': needsLoanerPhone,
    // stage/price_approval defaults in DB; ولی صریح هم امنه
    'stage': 'received',
    'price_approval': 'not_needed',
    'quoted_price_toman': 0,
  };
}

Future<void> _insertOrderToSupabase(Map<String, dynamic> row) async {
  final supabase = Supabase.instance.client;
  await supabase.from('orders').insert(row);
}

/* ============================== Boot ============================== */

class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      testSupabaseConnection(context);
    });
    _go();
  }

  Future<void> _go() async {
    final p = await _Prefs.loadProfile();
    if (!mounted) return;

    if (p == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignupFlowPhonePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShell(profile: p)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/* ============================== Main Shell (Logged-in) ============================== */

class MainShell extends StatelessWidget {
  final Profile profile;
  const MainShell({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _AppDrawer(profile: profile),
      body: SafeArea(bottom: true, child: HomeTab(profile: profile)),
      bottomNavigationBar: _NeoBottomBar(
        onHome: () {
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
        onCreateOrder: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CreateOrderPage(profile: profile)),
          );
        },
      ),
    );
  }
}

/* ============================== Home Tab (Lux UI) ============================== */

class HomeTab extends StatelessWidget {
  final Profile? profile;
  const HomeTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return _CenterMax(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _HeroHeader(profile: profile),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'با خیال راحت بسپارید',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: kTextPrimary),
            ),
          ),
          const SizedBox(height: 10),
          const _TrustCarousel(),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('خدمات سریع',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: kTextPrimary)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _QuickServicesGrid(
              onTap: (label) {
                if (profile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ابتدا وارد شوید.')),
                  );
                  return;
                }

                final prefill = 'خدمت انتخاب‌شده: $label';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateOrderPage(
                      profile: profile!,
                      initialIssueText: prefill,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('چرا Mobix؟',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: kTextPrimary)),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _TrustFooter(),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final Profile? profile;
  const _HeroHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [kBg2, kBg],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LogoAvatarButton(onTap: () {}),
              const Spacer(),
              Builder(
                builder: (ctx) => IconButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  icon: const Icon(Icons.menu, color: kTextPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: _alpha(Colors.black, 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.waving_hand_outlined, size: 18, color: kGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    profile == null ? 'سلام، خوش آمدید' : 'سلام، ${profile!.fullName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: kTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoAvatarButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _LogoAvatarButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: kBorder, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: _alpha(Colors.black, 0.04),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            kLogoAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.phone_android_outlined,
              size: 22,
              color: kTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================== Trust Carousel (FULL IMAGE BANNERS) ============================== */

class _TrustCarousel extends StatefulWidget {
  const _TrustCarousel();

  @override
  State<_TrustCarousel> createState() => _TrustCarouselState();
}

class _TrustCarouselState extends State<_TrustCarousel> {
  final _page = PageController(viewportFraction: 0.92);
  Timer? _t;
  int _i = 0;

  // فقط عکس‌ها
  final _items = const <String>[
    'assets/banners/banner_1.png',
    'assets/banners/banner_2.png',
    'assets/banners/banner_4.png',
  ];

  static const double _aspect = 16 / 9;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _i = (_i + 1) % _items.length;
      _page.animateToPage(
        _i,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final w =
        c.maxWidth == double.infinity ? MediaQuery.of(ctx).size.width : c.maxWidth;
        final cardW = w * 0.92;
        final h = cardW / _aspect;

        return SizedBox(
          height: h,
          child: PageView.builder(
            controller: _page,
            itemCount: _items.length,
            itemBuilder: (_, idx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _FullImageBannerCard(
                imageAsset: _items[idx],
                aspectRatio: _aspect,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FullImageBannerCard extends StatelessWidget {
  final String imageAsset;
  final double aspectRatio;
  const _FullImageBannerCard({
    required this.imageAsset,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: kAccentSoft,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: kGold2, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================== Quick Services ============================== */

class _QuickServiceItem {
  final String label;
  final IconData icon;
  const _QuickServiceItem({required this.label, required this.icon});
}

class _QuickServicesGrid extends StatelessWidget {
  final void Function(String label) onTap;
  const _QuickServicesGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = const <_QuickServiceItem>[
      _QuickServiceItem(
          label: 'تعویض باتری', icon: Icons.battery_charging_full_outlined),
      _QuickServiceItem(label: 'تعمیر برد', icon: Icons.memory_outlined),
      _QuickServiceItem(label: 'آب‌خوردگی', icon: Icons.water_drop_outlined),
      _QuickServiceItem(
          label: 'مشکلات نرم‌افزاری', icon: Icons.settings_suggest_outlined),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        final label = item.label;
        final icon = item.icon;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTap(label),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  Icon(icon, color: kGold2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: kTextPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TrustLine(
            icon: Icons.support_agent_outlined,
            title: 'پشتیبانی آنلاین',
            subtitle: 'گفت‌وگو داخل برنامه و پاسخ‌گویی سریع'),
        SizedBox(height: 10),
        _TrustLine(
            icon: Icons.local_shipping_outlined,
            title: 'پیک اختصاصی',
            subtitle: 'دریافت و تحویل دستگاه با هماهنگی'),
        SizedBox(height: 10),
        _TrustLine(
          icon: Icons.verified_outlined,
          title: 'اعلام هزینه قبل از تعمیر',
          subtitle: 'بدون تایید شما کاری انجام نمی‌شود',
        ),
      ],
    );
  }
}

class _TrustLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustLine(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kAccentSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: Icon(icon, color: kGold2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, color: kTextPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: kTextSoft, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================== Profile/Track/etc ============================== */

class TrackStandalonePage extends StatelessWidget {
  final Profile? profile;
  const TrackStandalonePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پیگیری سفارش')),
      body: SafeArea(child: TrackTab(profile: profile)),
    );
  }
}

/// ✅ TrackTab: فقط دیتابیس (v_orders_fa) — نه SharedPreferences
class TrackTab extends StatefulWidget {
  final Profile? profile;
  const TrackTab({super.key, required this.profile});

  @override
  State<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends State<TrackTab> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();

  OrderDbRow? _found;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.profile?.phone ?? '';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _error = null;
      _found = null;
      _loading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _loading = false);
      return;
    }

    final phone = _phoneCtrl.text.trim();
    final orderNo = _orderCtrl.text.trim().toUpperCase();

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('v_orders_fa')
          .select()
          .eq('customer_phone', phone)
          .eq('order_no', orderNo)
          .maybeSingle();

      if (!mounted) return;

      if (res == null) {
        setState(() {
          _error = 'سفارشی با این مشخصات پیدا نشد.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _found = OrderDbRow.fromJson((res as Map<String, dynamic>));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطا در ارتباط با سرور: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CenterMax(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('پیگیری سفارش',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: kTextPrimary)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'شماره موبایل',
                        prefixIcon: Icon(Icons.call_outlined),
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'شماره موبایل را وارد کنید';
                        if (s.length < 10) return 'شماره موبایل معتبر نیست';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _orderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'شماره سفارش',
                        hintText: 'مثلاً MXC-251216-0001',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'شماره سفارش را وارد کنید'
                          : null,
                      onFieldSubmitted: (_) => _search(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kGold,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _loading ? null : _search,
                        icon: _loading
                            ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.search),
                        label: const Text('جستجو'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: kTextPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: kTextPrimary))),
                  ],
                ),
              ),
            ),
          ],
          if (_found != null) ...[
            const SizedBox(height: 12),
            _OrderDetailsCardDb(order: _found!),
            const SizedBox(height: 12),
            OrderUpdatesPanel(orderNo: _found!.orderNo),
          ],
        ],
      ),
    );
  }
}

class ProfileStandalonePage extends StatelessWidget {
  final Profile profile;
  const ProfileStandalonePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل')),
      body: SafeArea(child: ProfileTab(profile: profile)),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final Profile profile;
  const ProfileTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return _CenterMax(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _GlassCard(
            child: ListTile(
              leading: const Icon(Icons.person_outline, color: kTextPrimary),
              title: Text(profile.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: kTextPrimary)),
              subtitle: Text('شماره: ${_toPersianDigits(profile.phone)}',
                  style: const TextStyle(color: kTextSoft)),
            ),
          ),
          const SizedBox(height: 12),
          _GlassCard(
            child: ListTile(
              leading:
              const Icon(Icons.receipt_long_outlined, color: kTextPrimary),
              title: const Text('سفارش‌های من',
                  style: TextStyle(color: kTextPrimary)),
              trailing: const Icon(Icons.arrow_forward, color: kTextTertiary),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MyOrdersPage(profile: profile))),
            ),
          ),
          _GlassCard(
            child: ListTile(
              leading: const Icon(Icons.rule_outlined, color: kTextPrimary),
              title: const Text('قوانین و مقررات',
                  style: TextStyle(color: kTextPrimary)),
              trailing: const Icon(Icons.arrow_forward, color: kTextTertiary),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TermsReadOnlyPage())),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================== Order creation (server insert) ============================== */

class CreateOrderPage extends StatefulWidget {
  final Profile profile;
  final String? initialIssueText;

  const CreateOrderPage({
    super.key,
    required this.profile,
    this.initialIssueText,
  });

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _deviceCtrl = TextEditingController();
  final _issueCtrl = TextEditingController();

  DeliveryMethod _delivery = DeliveryMethod.inPerson;
  final _addressCtrl = TextEditingController();
  final _pickupTimeCtrl = TextEditingController();
  bool _needsLoaner = false;

  @override
  void initState() {
    super.initState();
    if ((widget.initialIssueText ?? '').trim().isNotEmpty) {
      _issueCtrl.text = widget.initialIssueText!.trim();
    }
  }

  @override
  void dispose() {
    _deviceCtrl.dispose();
    _issueCtrl.dispose();
    _addressCtrl.dispose();
    _pickupTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final orderNo = await _Prefs.nextLocalOrderNo();

    final row = _orderToDb(
      orderNo: orderNo,
      profile: widget.profile,
      deviceModel: _deviceCtrl.text.trim(),
      issue: _issueCtrl.text.trim(),
      deliveryMethod: _delivery,
      pickupAddress:
      _delivery == DeliveryMethod.courier ? _addressCtrl.text.trim() : null,
      pickupTimeText:
      _delivery == DeliveryMethod.courier ? _pickupTimeCtrl.text.trim() : null,
      needsLoanerPhone: _needsLoaner,
    );

    if (!mounted) return;

    try {
      await _insertOrderToSupabase(row);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سفارش ثبت شد ✅\n$orderNo')),
      );
    } catch (e) {
      debugPrint('SUPABASE INSERT ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ثبت سفارش روی سرور ناموفق بود ❌\n$orderNo\n$e')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(orderNo: orderNo, profile: widget.profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت سفارش')),
      body: SafeArea(
        child: _CenterMax(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ثبت سفارش تعمیر',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: kTextPrimary)),
                        const SizedBox(height: 10),
                        Text(
                          'مشتری: ${widget.profile.fullName}  •  ${_toPersianDigits(widget.profile.phone)}',
                          style: const TextStyle(color: kTextSoft),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _deviceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'مدل دستگاه',
                            prefixIcon: Icon(Icons.phone_android_outlined),
                          ),
                          validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'مدل دستگاه را وارد کنید' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _issueCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'ایراد / توضیحات',
                            prefixIcon: Icon(Icons.report_problem_outlined),
                          ),
                          validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'ایراد را وارد کنید' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text('نحوه تحویل دستگاه',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, color: kTextPrimary)),
                        const SizedBox(height: 8),
                        RadioListTile<DeliveryMethod>(
                          value: DeliveryMethod.inPerson,
                          groupValue: _delivery,
                          onChanged: (v) => setState(() => _delivery = v!),
                          title: const Text('تحویل حضوری به دفتر موبیکس',
                              style: TextStyle(color: kTextPrimary)),
                        ),
                        RadioListTile<DeliveryMethod>(
                          value: DeliveryMethod.courier,
                          groupValue: _delivery,
                          onChanged: (v) => setState(() => _delivery = v!),
                          title: const Text('پیک موبیکس دستگاه را تحویل می‌گیرد',
                              style: TextStyle(color: kTextPrimary)),
                        ),
                        if (_delivery == DeliveryMethod.courier) ...[
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'آدرس',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (v) {
                              if (_delivery != DeliveryMethod.courier) return null;
                              return (v ?? '').trim().isEmpty ? 'آدرس را وارد کنید' : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pickupTimeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'زمان مراجعه پیک',
                              hintText: 'مثلاً امروز ۱۸ تا ۲۰',
                              prefixIcon: Icon(Icons.schedule_outlined),
                            ),
                            validator: (v) {
                              if (_delivery != DeliveryMethod.courier) return null;
                              return (v ?? '').trim().isEmpty
                                  ? 'زمان مراجعه را وارد کنید'
                                  : null;
                            },
                          ),
                        ],
                        CheckboxListTile(
                          value: _needsLoaner,
                          onChanged: (v) => setState(() => _needsLoaner = v ?? false),
                          title: const Text('در زمان تعمیر، به گوشی جایگزین نیاز دارم',
                              style: TextStyle(color: kTextPrimary)),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: kGold,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _submit,
                            icon: const Icon(Icons.check),
                            label: const Text('ثبت سفارش'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'زمان ثبت سفارش خودکار است: ${_formatJalaliDateTime(DateTime.now())}',
                          style: const TextStyle(
                              color: kTextSoft, fontSize: 12, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== Orders (from Supabase) ============================== */

class MyOrdersPage extends StatefulWidget {
  final Profile profile;
  const MyOrdersPage({super.key, required this.profile});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<OrderDbRow> _orders = [];
  bool _loading = true;
  String? _error;

  RealtimeChannel? _ordersCh;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeOrdersRealtime();
  }

  @override
  void dispose() {
    _ordersCh?.unsubscribe();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('v_orders_fa')
          .select()
          .eq('customer_phone', widget.profile.phone)
          .order('created_at', ascending: false)
          .limit(200);

      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .map(OrderDbRow.fromJson)
          .toList();

      if (!mounted) return;
      setState(() {
        _orders = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _subscribeOrdersRealtime() {
    final supabase = Supabase.instance.client;
    _ordersCh = supabase.channel('orders_list_${widget.profile.phone}');

    _ordersCh!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'orders',
      callback: (_) => _load(),
    )
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'orders',
      callback: (_) => _load(),
    )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سفارش‌های من')),
      body: SafeArea(
        child: _CenterMax(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (_error != null)
                _GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: kTextPrimary),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text('خطا: $_error',
                                style: const TextStyle(color: kTextPrimary))),
                        TextButton(
                            onPressed: _load,
                            child: const Text('تلاش دوباره',
                                style: TextStyle(color: kGold))),
                      ],
                    ),
                  ),
                )
              else if (_orders.isEmpty)
                const _GlassCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('سفارشی ثبت نشده است.',
                        style: TextStyle(color: kTextPrimary)),
                  ),
                )
              else
                ..._orders.map(
                      (o) => _GlassCard(
                    child: ListTile(
                      title: Text(o.orderNo,
                          style: const TextStyle(color: kTextPrimary)),
                      subtitle: Text(
                        '${o.deviceModel} • ${o.stageFa}',
                        style: const TextStyle(color: kTextSoft),
                      ),
                      trailing:
                      const Icon(Icons.arrow_forward, color: kTextTertiary),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(
                              orderNo: o.orderNo, profile: widget.profile),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailsPage extends StatefulWidget {
  final String orderNo;
  final Profile profile;
  const OrderDetailsPage({super.key, required this.orderNo, required this.profile});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  OrderDbRow? _order;
  bool _loading = true;
  String? _orderError;

  // Pricing / approval
  bool _pricingLoading = true;
  String? _pricingError;
  int _quotedToman = 0;
  String _approval = 'not_needed'; // pending/approved/rejected/not_needed
  String _approvalFa = 'نیاز ندارد';
  String _stage = 'received';
  String _stageFa = 'ثبت سفارش';

  RealtimeChannel? _ordersRealtimeCh;

  @override
  void initState() {
    super.initState();
    _loadOrderFromServer();
    _subscribeOrderRealtime();
  }

  @override
  void dispose() {
    _ordersRealtimeCh?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadOrderFromServer() async {
    setState(() {
      _loading = true;
      _orderError = null;
      _pricingLoading = true;
      _pricingError = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('v_orders_fa')
          .select()
          .eq('order_no', widget.orderNo)
          .maybeSingle();

      if (!mounted) return;

      if (res == null) {
        setState(() {
          _order = null;
          _loading = false;
          _orderError = 'سفارش پیدا نشد.';
          _pricingLoading = false;
        });
        return;
      }

      final o = OrderDbRow.fromJson(res as Map<String, dynamic>);

      setState(() {
        _order = o;
        _loading = false;

        _quotedToman = o.quotedPriceToman;
        _approval = o.priceApproval;
        _approvalFa = o.priceApprovalFa;
        _stage = o.stage;
        _stageFa = o.stageFa;

        _pricingLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _orderError = e.toString();
        _loading = false;
        _pricingError = e.toString();
        _pricingLoading = false;
      });
    }
  }

  void _subscribeOrderRealtime() {
    final supabase = Supabase.instance.client;
    _ordersRealtimeCh = supabase.channel('orders_realtime_${widget.orderNo}');

    _ordersRealtimeCh!
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'order_no',
        value: widget.orderNo,
      ),
      callback: (payload) {
        try {
          final row = payload.newRecord;
          if (row.isEmpty) return;

          final quoted =
              (row['quoted_price_toman'] as num?)?.toInt() ?? _quotedToman;
          final pa = (row['price_approval'] as String?) ?? _approval;
          final st = (row['stage'] as String?) ?? _stage;

          if (!mounted) return;

          setState(() {
            _quotedToman = quoted;
            _approval = pa;
            _approvalFa = _priceApprovalFaFromCode(pa);

            _stage = st;
            _stageFa = _stageFaFromCode(st);

            // اگر order جزئیات نمایش می‌ده، همزمان sync کنیم
            if (_order != null) {
              _order = _order!.copyWith(
                stage: st,
                stageFa: _stageFaFromCode(st),
                quotedPriceToman: quoted,
                priceApproval: pa,
                priceApprovalFa: _priceApprovalFaFromCode(pa),
              );
            }
          });
        } catch (_) {}
      },
    )
        .subscribe();
  }

  Future<void> _setApproval(String to) async {
    if (_quotedToman <= 0) return;

    setState(() => _pricingError = null);

    try {
      final supabase = Supabase.instance.client;

      // فقط update روی orders — تریگر دیتابیس خودش order_updates رو ثبت می‌کند.
      await supabase.from('orders').update({'price_approval': to}).eq('order_no', widget.orderNo);

      if (!mounted) return;

      setState(() {
        _approval = to;
        _approvalFa = _priceApprovalFaFromCode(to);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(to == 'approved' ? 'هزینه تایید شد ✅' : 'هزینه رد شد ❌')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _pricingError = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ثبت تایید/رد ❌\n$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvalCode = _approval;
    final approvalFa = _approvalFa;

    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات سفارش')),
      body: SafeArea(
        child: _CenterMax(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (_order == null)
                _GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_orderError ?? 'سفارش پیدا نشد.',
                        style: const TextStyle(color: kTextPrimary)),
                  ),
                )
              else ...[
                _OrderDetailsCardDb(order: _order!),
                const SizedBox(height: 12),
                _PricingAndPaymentPanelDb(
                  loading: _pricingLoading,
                  error: _pricingError,
                  quotedToman: _quotedToman,
                  approvalCode: approvalCode,
                  approvalFa: approvalFa,
                  stageFa: _stageFa,
                  onRefresh: _loadOrderFromServer,
                  onApprove: () => _setApproval('approved'),
                  onReject: () => _setApproval('rejected'),
                ),
                const SizedBox(height: 12),
                OrderUpdatesPanel(orderNo: widget.orderNo),
                const SizedBox(height: 12),
                _GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble_outline,
                        color: kTextPrimary),
                    title: const Text('گفت‌وگو',
                        style: TextStyle(color: kTextPrimary)),
                    trailing: const Icon(Icons.arrow_forward,
                        color: kTextTertiary),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatStandalonePage(
                            profile: widget.profile, orderNo: widget.orderNo),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== Pricing / Approval / Payment Panel (DB) ============================== */

class _PricingAndPaymentPanelDb extends StatelessWidget {
  final bool loading;
  final String? error;
  final int quotedToman;
  final String approvalCode; // pending/approved/rejected/not_needed
  final String approvalFa; // فارسی
  final String stageFa; // فارسی
  final VoidCallback onRefresh;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PricingAndPaymentPanelDb({
    required this.loading,
    required this.error,
    required this.quotedToman,
    required this.approvalCode,
    required this.approvalFa,
    required this.stageFa,
    required this.onRefresh,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuote = quotedToman > 0;

    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هزینه و پرداخت',
                style: TextStyle(fontWeight: FontWeight.w900, color: kTextPrimary)),
            const SizedBox(height: 10),

            // stage display (Persian)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _alpha(kAccentSoft, 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timeline, color: kGold2, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('مرحله فعلی: $stageFa',
                        style: const TextStyle(
                            color: kTextPrimary, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (loading)
              const Row(
                children: [
                  SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text('در حال دریافت...', style: TextStyle(color: kTextSoft)),
                ],
              )
            else ...[
              if (error != null) ...[
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: kTextPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('خطا در دریافت: $error',
                          style: const TextStyle(color: kTextPrimary)),
                    ),
                    TextButton(
                        onPressed: onRefresh,
                        child: const Text('تلاش دوباره',
                            style: TextStyle(color: kGold))),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // هزینه اعلامی
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _alpha(kAccentSoft, 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('هزینه اعلامی',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: kTextPrimary)),
                    const SizedBox(height: 6),
                    Text(
                      hasQuote
                          ? '${_toPersianDigits(_formatToman(quotedToman))} تومان'
                          : 'هزینه هنوز اعلام نشده است.',
                      style: const TextStyle(color: kTextSoft, height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // تایید/رد
              if (!hasQuote)
                const Text(
                    'بعد از اعلام هزینه توسط موبیکس، امکان تایید/پرداخت فعال می‌شود.',
                    style: TextStyle(color: kTextSoft, height: 1.6))
              else if (approvalCode == 'pending') ...[
                const Text('لطفاً هزینه را تایید یا رد کنید:',
                    style: TextStyle(
                        color: kTextPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: kGold, foregroundColor: Colors.white),
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('تایید هزینه'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('رد هزینه'),
                      ),
                    ),
                  ],
                ),
              ] else if (approvalCode == 'approved') ...[
                Row(
                  children: const [
                    Icon(Icons.verified_outlined, color: kGold2),
                    SizedBox(width: 8),
                    Text('هزینه توسط شما تایید شد ✅',
                        style: TextStyle(
                            color: kTextPrimary, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('وضعیت تایید: $approvalFa',
                    style: const TextStyle(color: kTextSoft)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('پرداخت',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: kTextPrimary)),
                      SizedBox(height: 6),
                      Text('پرداخت آنلاین به‌زودی فعال می‌شود.',
                          style: TextStyle(color: kTextSoft, height: 1.6)),
                    ],
                  ),
                ),
              ] else if (approvalCode == 'rejected') ...[
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: kTextPrimary),
                    SizedBox(width: 8),
                    Text('هزینه توسط شما رد شد.',
                        style: TextStyle(
                            color: kTextPrimary, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('وضعیت تایید: $approvalFa',
                    style: const TextStyle(color: kTextSoft)),
                const SizedBox(height: 6),
                const Text('به همین دلیل بخش پرداخت نمایش داده نمی‌شود.',
                    style: TextStyle(color: kTextSoft, height: 1.6)),
              ] else ...[
                Text('وضعیت تایید: $approvalFa',
                    style: const TextStyle(color: kTextSoft, height: 1.6)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/* ============================== Order Updates Panel (from Supabase) ============================== */

class OrderUpdatesPanel extends StatefulWidget {
  final String orderNo;
  const OrderUpdatesPanel({super.key, required this.orderNo});

  @override
  State<OrderUpdatesPanel> createState() => _OrderUpdatesPanelState();
}

class _OrderUpdatesPanelState extends State<OrderUpdatesPanel> {
  bool _loading = true;
  String? _error;
  List<OrderUpdateDb> _items = [];
  RealtimeChannel? _ch;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _ch?.unsubscribe();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('v_order_updates_fa')
          .select()
          .eq('order_no', widget.orderNo)
          .order('created_at', ascending: false)
          .limit(50);

      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .map(OrderUpdateDb.fromJson)
          .toList();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _subscribeRealtime() {
    final supabase = Supabase.instance.client;
    _ch = supabase.channel('order_updates_${widget.orderNo}');

    _ch!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'order_updates',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'order_no',
        value: widget.orderNo,
      ),
      callback: (_) {
        // برای اینکه title_fa_final از view بیاد، امن‌ترین کار reload کوتاهه
        _load();
      },
    )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آخرین وضعیت سفارش',
                style: TextStyle(fontWeight: FontWeight.w900, color: kTextPrimary)),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('در حال دریافت...', style: TextStyle(color: kTextSoft)),
                  ],
                ),
              )
            else if (_error != null)
              Row(
                children: [
                  const Icon(Icons.error_outline, color: kTextPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text('خطا در دریافت: $_error',
                          style: const TextStyle(color: kTextPrimary))),
                  TextButton(
                      onPressed: _load,
                      child: const Text('تلاش دوباره',
                          style: TextStyle(color: kGold))),
                ],
              )
            else if (_items.isEmpty)
                const Text('هنوز آپدیتی ثبت نشده است.',
                    style: TextStyle(color: kTextSoft, height: 1.6))
              else
                Column(
                  children: _items.map((u) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _alpha(kAccentSoft, 0.55),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.titleFa,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, color: kTextPrimary),
                          ),
                          if ((u.note ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(u.note!.trim(),
                                style: const TextStyle(
                                    color: kTextPrimary, height: 1.6)),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            _toPersianDigits(_formatJalaliDateTime(u.createdAt)),
                            style: const TextStyle(fontSize: 11, color: kTextSoft),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          ],
        ),
      ),
    );
  }
}

/* ============================== Details Card (DB) ============================== */

class _OrderDetailsCardDb extends StatelessWidget {
  final OrderDbRow order;
  const _OrderDetailsCardDb({required this.order});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سفارش ${order.orderNo}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: kTextPrimary)),
            const SizedBox(height: 10),
            _kv('مشتری', order.customerName),
            const SizedBox(height: 8),
            _kv('شماره تماس', _toPersianDigits(order.customerPhone)),
            const SizedBox(height: 8),
            _kv('مدل دستگاه', order.deviceModel),
            const SizedBox(height: 8),
            _kv('ایراد', order.issue),
            const SizedBox(height: 8),
            _kv('زمان ثبت', _formatJalaliDateTime(order.createdAt)),
            const SizedBox(height: 8),
            _kv('مرحله', order.stageFa),
            const SizedBox(height: 8),
            _kv('نوع تحویل', order.deliveryMethod == 'courier' ? 'پیک' : 'حضوری'),
            if (order.deliveryMethod == 'courier') ...[
              const SizedBox(height: 8),
              _kv('آدرس', order.pickupAddress ?? '-'),
              const SizedBox(height: 8),
              _kv('زمان مراجعه', order.pickupTimeText ?? '-'),
              const SizedBox(height: 8),
              _kv('گوشی جایگزین', order.needsLoanerPhone ? 'بله' : 'خیر'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(k,
              style:
              const TextStyle(fontWeight: FontWeight.w800, color: kTextSoft)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(v, style: const TextStyle(color: kTextPrimary))),
      ],
    );
  }
}

/* ============================== Drawer ============================== */

class _AppDrawer extends StatelessWidget {
  final Profile? profile;
  const _AppDrawer({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kBg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _GlassCard(
              child: ListTile(
                leading: const Icon(Icons.account_circle_outlined,
                    color: kTextPrimary),
                title: Text(profile?.fullName ?? 'مهمان',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: kTextPrimary)),
                subtitle: Text(
                  profile?.phone != null && profile!.phone.isNotEmpty
                      ? _toPersianDigits(profile!.phone)
                      : 'ورود انجام نشده',
                  style: const TextStyle(color: kTextSoft),
                ),
                onTap: () {
                  if (profile == null) return;
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProfileStandalonePage(profile: profile!)));
                },
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(context, Icons.receipt_long_outlined, 'سفارش‌های من', () {
              Navigator.pop(context);
              if (profile == null) return;
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MyOrdersPage(profile: profile!)));
            }),
            _drawerItem(context, Icons.rule_outlined, 'قوانین و مقررات', () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TermsReadOnlyPage()));
            }),
            _drawerItem(context, Icons.info_outline, 'درباره Mobix', () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Mobix',
                applicationVersion: 'v0.3',
                children: const [Text('نسخه اولیه اپ مشتری موبیکس')],
              );
            }),
            const Divider(),
            _drawerItem(context, Icons.logout, 'خروج', () async {
              await _Prefs.saveProfile(null);
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignupFlowPhonePage()),
                    (_) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kGold2),
      title: Text(title, style: const TextStyle(color: kTextPrimary)),
      onTap: onTap,
    );
  }
}

/* ============================== Signup Flow (CUSTOM OTP via Edge Functions) ============================== */

/// خروجی: شماره استاندارد ملی برای اپ (09xxxxxxxxx)
/// اگر ورودی +98 یا 98 یا 0 یا بدون صفر باشد، درستش می‌کند.
String _normalizeIranPhoneToNational(String input) {
  var s = input.trim();
  s = s.replaceAll(RegExp(r'[^0-9+]'), '');

  // +98xxxxxxxxxx
  if (s.startsWith('+')) {
    if (s.startsWith('+98')) {
      s = s.substring(3);
    } else {
      // کشور دیگری است
      return input.trim();
    }
  }

  // 98xxxxxxxxxx
  if (s.startsWith('98')) {
    s = s.substring(2);
  }

  // اگر با 0 شروع می‌شود، همان بماند
  if (s.startsWith('0')) {
    // ok
  } else {
    // اگر 10 رقم است (912xxxxxxx) یک 0 جلوش می‌گذاریم
    if (RegExp(r'^\d{10}$').hasMatch(s)) {
      s = '0$s';
    }
  }

  return s;
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) {
    return data.map((k, v) => MapEntry(k.toString(), v));
  }
  return <String, dynamic>{};
}

/// ✅ invoke helper (NEW supabase_flutter: no resp.error)
Future<Map<String, dynamic>> _invokeEdgeFunction(
    String functionName, {
      required Map<String, dynamic> body,
      String? invalidResponseMessage,
    }) async {
  final supabase = Supabase.instance.client;

  try {
    final resp = await supabase.functions.invoke(functionName, body: body);

    final m = _asMap(resp.data);
    if (m.isEmpty) {
      throw Exception(
          invalidResponseMessage ?? 'پاسخ نامعتبر از سرور ($functionName)');
    }

    return m;
  } catch (e) {
    throw Exception('خطا در فراخوانی $functionName: $e');
  }
}

/// ✅ request-otp
Future<Map<String, dynamic>> _requestOtpViaEdge(String phoneNational) async {
  return _invokeEdgeFunction(
    'request-otp',
    body: {'phone': phoneNational},
    invalidResponseMessage: 'پاسخ نامعتبر از سرور OTP',
  );
}

/// ✅ verify-otp
Future<Map<String, dynamic>> _verifyOtpViaEdge({
  required String phoneNational,
  required String code,
}) async {
  return _invokeEdgeFunction(
    'verify-otp',
    body: {'phone': phoneNational, 'code': code},
    invalidResponseMessage: 'پاسخ نامعتبر از سرور تایید OTP',
  );
}

class SignupFlowPhonePage extends StatefulWidget {
  const SignupFlowPhonePage({super.key});

  @override
  State<SignupFlowPhonePage> createState() => _SignupFlowPhonePageState();
}

class _SignupFlowPhonePageState extends State<SignupFlowPhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  bool _acceptedTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برای ادامه باید قوانین را بپذیرید.')),
      );
      return;
    }

    final national = _normalizeIranPhoneToNational(_phoneCtrl.text);

    // اعتبارسنجی ساده ایران
    final onlyDigits = national.replaceAll(RegExp(r'[^0-9]'), '');
    if (!(onlyDigits.startsWith('09') && onlyDigits.length == 11)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'شماره موبایل ایران معتبر وارد کنید (مثلاً 09123456789).')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final r = await _requestOtpViaEdge(national);

      final ok = (r['ok'] == true);
      if (!ok) {
        final where = r['where']?.toString();
        final msg = r['error']?.toString() ??
            r['message']?.toString() ??
            r['smsir_response']?.toString() ??
            'ارسال کد ناموفق بود';
        throw Exception('${where ?? 'server'}: $msg');
      }

      final expires = (r['expires_in_seconds'] is num)
          ? (r['expires_in_seconds'] as num).toInt()
          : 120;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد تایید ارسال شد ✅')),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SignupOtpPage(
            phoneNational: national,
            expiresInSeconds: expires,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ارسال کد ناموفق بود ❌\n$e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _acceptedTerms && !_loading;

    return Scaffold(
      appBar: AppBar(title: const Text('ورود / ثبت‌نام')),
      body: SafeArea(
        child: _CenterMax(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      kLogoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _alpha(Colors.black, 0.03),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Icon(Icons.phone_android_outlined,
                            size: 54, color: kTextPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('خوش آمدید',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    color: kTextPrimary)),
                            const SizedBox(height: 8),
                            const Text(
                              'برای ثبت سفارش و پیگیری تعمیر، شماره موبایل خود را وارد کنید.',
                              style: TextStyle(color: kTextSoft, height: 1.6),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'مثلاً 09120000000',
                                prefixIcon: const Icon(Icons.call_outlined),
                                suffixIcon: _loading
                                    ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                )
                                    : null,
                              ),
                              validator: (v) {
                                final s = (v ?? '').trim();
                                if (s.isEmpty) return 'شماره موبایل را وارد کنید';
                                final n = _normalizeIranPhoneToNational(s)
                                    .replaceAll(RegExp(r'[^0-9]'), '');
                                if (!(n.startsWith('09') && n.length == 11)) {
                                  return 'شماره موبایل معتبر نیست';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _next(),
                            ),
                            const SizedBox(height: 12),

                            // ✅ چک‌باکس واقعی پذیرش قوانین
                            CheckboxListTile(
                              value: _acceptedTerms,
                              onChanged: (v) =>
                                  setState(() => _acceptedTerms = v ?? false),
                              title: const Text(
                                  'قوانین و مقررات را مطالعه کرده و می‌پذیرم.',
                                  style: TextStyle(color: kTextPrimary)),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const TermsReadOnlyPage()),
                                ),
                                child: const Text('مشاهده قوانین و مقررات',
                                    style: TextStyle(color: kGold)),
                              ),
                            ),

                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                    backgroundColor: kGold,
                                    foregroundColor: Colors.white),
                                onPressed: canContinue ? _next : null,
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(_loading ? 'در حال ارسال...' : 'ادامه'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupOtpPage extends StatefulWidget {
  final String phoneNational; // 09...
  final int expiresInSeconds;

  const SignupOtpPage({
    super.key,
    required this.phoneNational,
    required this.expiresInSeconds,
  });

  @override
  State<SignupOtpPage> createState() => _SignupOtpPageState();
}

class _SignupOtpPageState extends State<SignupOtpPage> {
  final _codeCtrl = TextEditingController();
  Timer? _timer;
  int _seconds = 120;

  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer(widget.expiresInSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _startTimer(int secs) {
    _timer?.cancel();
    setState(() => _seconds = secs <= 0 ? 120 : secs);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _verify() async {
    if (_verifying) return;

    final code = _codeCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد تایید باید ۶ رقم باشد.')),
      );
      return;
    }

    setState(() => _verifying = true);

    try {
      final r = await _verifyOtpViaEdge(
        phoneNational: widget.phoneNational,
        code: code,
      );

      final ok = (r['ok'] == true);
      if (!ok) {
        final msg = r['error']?.toString() ??
            r['message']?.toString() ??
            'کد نامعتبر است';
        throw Exception(msg);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ورود موفق ✅')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProfileNamePage(phone: widget.phoneNational),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('کد نامعتبر است یا منقضی شده ❌\n$e')),
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    if (_seconds > 0) return;

    setState(() => _resending = true);

    try {
      final r = await _requestOtpViaEdge(widget.phoneNational);

      final ok = (r['ok'] == true);
      if (!ok) {
        final where = r['where']?.toString();
        final msg = r['error']?.toString() ??
            r['message']?.toString() ??
            r['smsir_response']?.toString() ??
            'ارسال مجدد ناموفق بود';
        throw Exception('${where ?? 'server'}: $msg');
      }

      final expires = (r['expires_in_seconds'] is num)
          ? (r['expires_in_seconds'] as num).toInt()
          : 120;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد جدید ارسال شد ✅')),
      );

      _startTimer(expires);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ارسال مجدد ناموفق بود ❌\n$e')),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneFa = _toPersianDigits(widget.phoneNational);

    return Scaffold(
      appBar: AppBar(title: const Text('تایید شماره')),
      body: SafeArea(
        child: _CenterMax(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'کد تایید را وارد کنید',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: kTextPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'کد تایید را به شماره $phoneFa ارسال کردیم',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kTextSoft, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: 'مثلاً 123456',
                        prefixIcon: const Icon(Icons.password_outlined),
                        counterText: '',
                        suffixIcon: _verifying
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2)),
                        )
                            : null,
                      ),
                      onSubmitted: (_) => _verify(),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed:
                      _verifying ? null : () => Navigator.of(context).pop(),
                      child: const Text('شماره موبایل اشتباه است؟ ویرایش',
                          style: TextStyle(color: kGold)),
                    ),
                    const SizedBox(height: 8),
                    if (_seconds > 0)
                      Text(
                        'ارسال مجدد تا ${_toPersianDigits(_seconds.toString())} ثانیه دیگر',
                        style: const TextStyle(color: kTextSoft),
                        textAlign: TextAlign.center,
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _resending ? null : _resend,
                              child: Text(
                                  _resending ? 'در حال ارسال...' : 'ارسال دوباره کد'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: kGold, foregroundColor: Colors.white),
                        onPressed: _verifying ? null : _verify,
                        child: Text(_verifying ? 'در حال تایید...' : 'تایید و ادامه'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileNamePage extends StatefulWidget {
  final String phone;
  const ProfileNamePage({super.key, required this.phone});

  @override
  State<ProfileNamePage> createState() => _ProfileNamePageState();
}

class _ProfileNamePageState extends State<ProfileNamePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ acceptedTermsAtLeastOnce = true
    final p = Profile(
      phone: widget.phone,
      fullName: _nameCtrl.text.trim(),
      acceptedTermsAtLeastOnce: true,
    );
    await _Prefs.saveProfile(p);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(profile: p)),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تکمیل پروفایل')),
      body: SafeArea(
        child: _CenterMax(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('شماره: ${_toPersianDigits(widget.phone)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, color: kTextPrimary)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'نام و نام‌خانوادگی',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'نام و نام‌خانوادگی را وارد کنید'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: kGold,
                                foregroundColor: Colors.white),
                            onPressed: _finish,
                            icon: const Icon(Icons.check),
                            label: const Text('ورود به برنامه'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TermsReadOnlyPage extends StatelessWidget {
  const TermsReadOnlyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قوانین و مقررات')),
      body: SafeArea(
        child: _CenterMax(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _GlassCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'شرایط و مقررات موبیکس (نسخه اولیه)\n\n'
                        '1) مشتری موظف است اطلاعات صحیح وارد کند.\n'
                        '2) هزینه‌ها پس از بررسی اعلام می‌شود.\n'
                        '3) زمان تحویل بسته به نوع تعمیر متغیر است.\n'
                        '4) حفظ حریم خصوصی مشتری رعایت می‌شود.\n\n'
                        'این متن در نسخه بعدی کامل و رسمی می‌شود.',
                    style: TextStyle(height: 1.7, color: kTextSoft),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== Chat (Only inside order details) ============================== */

class ChatStandalonePage extends StatelessWidget {
  final Profile profile;
  final String orderNo;
  const ChatStandalonePage({super.key, required this.profile, required this.orderNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('چت سفارش $orderNo')),
      body: SafeArea(child: ChatCore(profile: profile, orderNo: orderNo, title: '')),
    );
  }
}

class ChatCore extends StatefulWidget {
  final Profile profile;
  final String orderNo;
  final String title;
  const ChatCore(
      {super.key, required this.profile, required this.orderNo, required this.title});

  @override
  State<ChatCore> createState() => _ChatCoreState();
}

class _ChatCoreState extends State<ChatCore> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  List<ChatMessageDb> _serverMsgs = [];
  bool _loading = true;
  String? _error;

  RealtimeChannel? _ch;

  final _faq = const [
    'هزینه تعمیر چقدر می‌شود؟',
    'چقدر زمان می‌برد آماده شود؟',
    'آیا امکان پیک دارید؟',
    'برای ثبت سفارش چه اطلاعاتی لازم است؟',
    'وضعیت سفارش من چیست؟',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _ch?.unsubscribe();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final local = await _Prefs.loadChatFor(widget.orderNo);
      debugPrint('LOCAL CHAT loaded: ${local.length}');
    } catch (_) {}

    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('chat_messages')
          .select()
          .eq('order_no', widget.orderNo)
          .order('created_at', ascending: true)
          .limit(200);

      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .map(ChatMessageDb.fromJson)
          .toList();
      if (!mounted) return;
      setState(() {
        _serverMsgs = list;
        _loading = false;
      });
      _jumpToBottom();
    } catch (e) {
      try {
        final local = await _Prefs.loadChatFor(widget.orderNo);
        if (!mounted) return;
        setState(() {
          _serverMsgs = local
              .asMap()
              .entries
              .map((e) => ChatMessageDb(
            id: -1 - e.key,
            orderNo: widget.orderNo,
            sender: e.value.role == ChatRole.mobix ? 'mobix' : 'customer',
            text: e.value.text,
            createdAt: e.value.at,
          ))
              .toList();
          _loading = false;
          _error = 'اتصال سرور مشکل دارد (نمایش آفلاین).';
        });
        _jumpToBottom();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _subscribeRealtime() {
    final supabase = Supabase.instance.client;
    _ch = supabase.channel('chat_${widget.orderNo}');

    _ch!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'order_no',
        value: widget.orderNo,
      ),
      callback: (payload) {
        try {
          final row = payload.newRecord;
          if (row.isEmpty) return;
          final m = ChatMessageDb.fromJson(row);

          final exists = _serverMsgs.any((x) => x.id == m.id);
          if (exists) return;

          if (!mounted) return;
          setState(() => _serverMsgs = [..._serverMsgs, m]);
          _jumpToBottom();
        } catch (_) {}
      },
    )
        .subscribe();
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;

    final optimistic = ChatMessageDb(
      id: -DateTime.now().millisecondsSinceEpoch,
      orderNo: widget.orderNo,
      sender: 'customer',
      text: t,
      createdAt: DateTime.now(),
    );

    setState(() => _serverMsgs = [..._serverMsgs, optimistic]);
    _ctrl.clear();
    _jumpToBottom();

    try {
      final local = await _Prefs.loadChatFor(widget.orderNo);
      final newLocal = [
        ...local,
        ChatMessage(role: ChatRole.customer, text: t, at: optimistic.createdAt),
      ];
      await _Prefs.saveChatFor(widget.orderNo, newLocal);
    } catch (_) {}

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('chat_messages').insert({
        'order_no': widget.orderNo,
        'sender': 'customer',
        'text': t,
      });
    } catch (e) {
      debugPrint('CHAT INSERT ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ارسال به سرور ناموفق بود ❌\n$e')),
      );
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 250,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        if (_error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccentSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: kTextPrimary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child:
                    Text(_error!, style: const TextStyle(color: kTextPrimary))),
                TextButton(
                    onPressed: _load,
                    child: const Text('Refresh', style: TextStyle(color: kGold))),
              ],
            ),
          ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            children: _faq
                .map((q) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ActionChip(
                label: Text(q, style: const TextStyle(color: kTextPrimary)),
                backgroundColor: kAccentSoft,
                side: const BorderSide(color: kBorder),
                onPressed: () => _send(q),
              ),
            ))
                .toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _serverMsgs.length,
            itemBuilder: (_, i) {
              final m = _serverMsgs[i];
              final isMe = m.sender != 'mobix';

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isMe ? kAccentSoft : Colors.white,
                    border: Border.all(color: kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: _alpha(Colors.black, 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.text,
                          style: const TextStyle(height: 1.5, color: kTextPrimary)),
                      const SizedBox(height: 6),
                      Text(
                        _toPersianDigits(_formatJalaliDateTime(m.createdAt)),
                        style: const TextStyle(fontSize: 11, color: kTextSoft),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'پیام خود را بنویسید…',
                      prefixIcon: Icon(Icons.message_outlined),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: kGold, foregroundColor: Colors.white),
                  onPressed: () => _send(_ctrl.text),
                  child: const Text('ارسال'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ============================== Bottom Bar (No public chat) ============================== */

class _NeoBottomBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onCreateOrder;

  const _NeoBottomBar({
    required this.onHome,
    required this.onCreateOrder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: _alpha(Colors.black, 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NeoHomeCenter(selected: true, onTap: onHome),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NeoSideItem(
                  label: 'ثبت سفارش',
                  icon: Icons.add_circle_outline,
                  selected: false,
                  onTap: onCreateOrder,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeoHomeCenter extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _NeoHomeCenter({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? kGold : kAccentSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? kGold2 : kBorder),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: _alpha(kGold, 0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined,
                color: selected ? Colors.white : kGold2, size: 22),
            const SizedBox(width: 8),
            Text(
              'خانه',
              style: TextStyle(
                color: selected ? Colors.white : kGold2,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeoSideItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NeoSideItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? kGold2 : kTextTertiary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kAccentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? kBorder : Colors.transparent),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 11.3,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== UI helpers ============================== */

class _CenterMax extends StatelessWidget {
  final Widget child;
  const _CenterMax({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: child,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder),
        ),
        child: child,
      ),
    );
  }
}

Future<void> testSupabaseConnection(BuildContext context) async {
  try {
    final res =
    await Supabase.instance.client.from('orders').select('order_no').limit(1);
    debugPrint('SUPABASE OK ✅ $res');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('SUPABASE OK ✅  ${res is List ? "rows:${res.length}" : res.toString()}')),
      );
    }
  } catch (e) {
    debugPrint('SUPABASE ERROR ❌ $e');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SUPABASE ERROR ❌  $e')),
      );
    }
  }
}

/* ============================== Helpers ============================== */

String _stageFaFromCode(String stage) {
  final s = stage.trim().toLowerCase();
  switch (s) {
    case 'received':
      return 'ثبت سفارش';
    case 'at_shop':
      return 'ورود به دفتر';
    case 'diagnosing':
      return 'بررسی ایراد';
    case 'price_quoted':
      return 'اعلام هزینه';
    case 'repairing':
      return 'در حال تعمیر';
    case 'ready':
      return 'آماده تحویل';
    case 'delivered':
      return 'تحویل شد';
    default:
      return stage;
  }
}

String _priceApprovalFaFromCode(String raw) {
  final s = raw.trim().toLowerCase();
  switch (s) {
    case 'not_needed':
      return 'نیاز ندارد';
    case 'pending':
      return 'در انتظار تایید';
    case 'approved':
      return 'تایید شد';
    case 'rejected':
      return 'رد شد';
    default:
      return raw;
  }
}

String _formatToman(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    final isLast = i == s.length - 1;
    if (!isLast && idxFromEnd % 3 == 1) {
      buf.write('٬');
    }
  }
  return buf.toString();
}

String _yyMMdd(DateTime d) {
  final yy = (d.year % 100).toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '$yy$mm$dd';
}

String _formatJalaliDateTime(DateTime d) {
  final j = _gregorianToJalali(d.year, d.month, d.day);
  final yy = (j.jy % 100).toString().padLeft(2, '0');
  final mm = j.jm.toString().padLeft(2, '0');
  final dd = j.jd.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mi = d.minute.toString().padLeft(2, '0');
  return _toPersianDigits('$yy/$mm/$dd  $hh:$mi');
}

String _toPersianDigits(String input) {
  const map = {
    '0': '۰',
    '1': '۱',
    '2': '۲',
    '3': '۳',
    '4': '۴',
    '5': '۵',
    '6': '۶',
    '7': '۷',
    '8': '۸',
    '9': '۹',
  };
  final out = StringBuffer();
  for (final ch in input.split('')) {
    out.write(map[ch] ?? ch);
  }
  return out.toString();
}

class _JalaliDate {
  final int jy;
  final int jm;
  final int jd;
  const _JalaliDate(this.jy, this.jm, this.jd);
}

/// Returns Jalali date (jy, jm, jd)
_JalaliDate _gregorianToJalali(int gy, int gm, int gd) {
  final g_d_m = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  int gy2 = (gm > 2) ? (gy + 1) : gy;
  int days = 355666 +
      (365 * gy) +
      ((gy2 + 3) ~/ 4) -
      ((gy2 + 99) ~/ 100) +
      ((gy2 + 399) ~/ 400) +
      gd +
      g_d_m[gm - 1];

  int jy = -1595 + 33 * (days ~/ 12053);
  days %= 12053;

  jy += 4 * (days ~/ 1461);
  days %= 1461;

  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }

  int jm;
  int jd;
  if (days < 186) {
    jm = 1 + (days ~/ 31);
    jd = 1 + (days % 31);
  } else {
    jm = 7 + ((days - 186) ~/ 30);
    jd = 1 + ((days - 186) % 30);
  }
  return _JalaliDate(jy, jm, jd);
}
