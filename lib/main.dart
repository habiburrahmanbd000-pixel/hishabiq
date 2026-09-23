import 'package:flutter/material.dart';

void main() {
  runApp(const MudirDokanUltimateApp());
}

class MudirDokanUltimateApp extends StatelessWidget {
  const MudirDokanUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'আমার মুদি দোকান - স্মার্ট পিওএস ও খাতা',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C3A),
          primary: const Color(0xFF0D5C3A),
        ),
        useMaterial3: true,
      ),
      home: const MainLayoutScreen(),
    );
  }
}

// ------------------- ডেটা মডেল -------------------
class Product {
  final String id;
  final String name;
  final String category;
  final String unit;
  int stock;
  double buyPrice;
  double sellPrice;
  final int minAlertLimit;
  final DateTime expiryDate;
  final String supplierName;
  final String supplierPhone;
  final String supplierVisitDay;
  int totalSoldQty;
  double totalRevenue;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.buyPrice,
    required this.sellPrice,
    required this.minAlertLimit,
    required this.expiryDate,
    required this.supplierName,
    required this.supplierPhone,
    required this.supplierVisitDay,
    this.totalSoldQty = 0,
    this.totalRevenue = 0,
  });

  double get profitPerUnit => sellPrice - buyPrice;
  double get totalProfitGenerated => totalSoldQty * profitPerUnit;
}

class CustomerDue {
  final String name;
  final String phone;
  double dueAmount;
  int daysPending;
  final List<String> logs;

  CustomerDue({
    required this.name,
    required this.phone,
    required this.dueAmount,
    required this.daysPending,
    List<String>? logs,
  }) : logs = logs ?? [];
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, required this.quantity});
}

class UtilityExpense {
  final String title;
  final double amount;
  final DateTime date;
  UtilityExpense({required this.title, required this.amount, required this.date});
}

// ------------------- মূল লেআউট স্ক্রিন -------------------
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  // ১. দোকান প্রোফাইল (এডিটেবল)
  String _shopName = 'আমার মুদি দোকান';
  String _shopSlogan = 'সফল ব্যবসার নির্ভরযোগ্য সাথী';

  // ২. অথরিটি / রোল কন্ট্রোল
  bool _isHostMode = true; // true = মালিক, false = কর্মচারী
  final String _hostPin = '1234';

  // ডামি ডেটাবেস
  late List<Product> _products;
  late List<CustomerDue> _customers;
  late List<UtilityExpense> _utilities;
  final List<CartItem> _cart = [];
  String _posCategoryFilter = 'সব';
  double _cashInHand = 5240.0;
  double _todayTotalSales = 8450.0;
  double _todayTotalProfit = 2340.0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _products = [
      Product(
        id: '1',
        name: 'মিনিকেট চাল',
        category: 'চাল-ডাল',
        unit: 'কেজি',
        stock: 25,
        buyPrice: 38,
        sellPrice: 52,
        minAlertLimit: 10,
        expiryDate: now.add(const Duration(days: 120)),
        supplierName: 'মেসার্স রাইস এজেন্সি',
        supplierPhone: '01711112233',
        supplierVisitDay: 'রবিবার',
        totalSoldQty: 142,
        totalRevenue: 7384,
      ),
      Product(
        id: '2',
        name: 'সয়াবিন তেল',
        category: 'তেল',
        unit: 'লিটার',
        stock: 1, // কম স্টক অ্যালার্ট
        buyPrice: 160,
        sellPrice: 210,
        minAlertLimit: 5,
        expiryDate: now.add(const Duration(days: 45)),
        supplierName: 'মেঘনা ডিলার',
        supplierPhone: '01822334455',
        supplierVisitDay: 'মঙ্গলবার',
        totalSoldQty: 98,
        totalRevenue: 20580,
      ),
      Product(
        id: '3',
        name: 'আইসক্রিম (কর্ন)',
        category: 'ঠান্ডা আইটেম',
        unit: 'পিস',
        stock: 12,
        buyPrice: 35,
        sellPrice: 50,
        minAlertLimit: 5,
        expiryDate: now, // আজকেই মেয়াদ শেষ (লাল অ্যালার্ট)
        supplierName: 'ইগলু ডিপো',
        supplierPhone: '01933445566',
        supplierVisitDay: 'বৃহস্পতিবার',
        totalSoldQty: 65,
        totalRevenue: 3250,
      ),
      Product(
        id: '4',
        name: 'কোল্ড ড্রিংকস (৫০০ মিলি)',
        category: 'ঠান্ডা আইটেম',
        unit: 'পিস',
        stock: 4, // কম স্টক অ্যালার্ট
        buyPrice: 32,
        sellPrice: 40,
        minAlertLimit: 8,
        expiryDate: now.add(const Duration(days: 2)), // ৩ দিনের মধ্যে মেয়াদ শেষ
        supplierName: 'প্রাণ বেভারেজ',
        supplierPhone: '01755667788',
        supplierVisitDay: 'সোমবার',
        totalSoldQty: 80,
        totalRevenue: 3200,
      ),
      Product(
        id: '5',
        name: 'স্পেশাল চাটনি মসলা',
        category: 'মসলা',
        unit: 'প্যাকেট',
        stock: 18,
        buyPrice: 40,
        sellPrice: 55,
        minAlertLimit: 5,
        expiryDate: now.add(const Duration(days: 180)),
        supplierName: 'রাঁধুনী স্কয়ার',
        supplierPhone: '01611223344',
        supplierVisitDay: 'বুধবার',
        totalSoldQty: 3, // স্লো-মুভিং প্রোডাক্ট
        totalRevenue: 165,
      ),
    ];

    _customers = [
      CustomerDue(name: 'রহিম উদ্দিন', phone: '01712-345678', dueAmount: 1250, daysPending: 18, logs: ['৫ দিন আগে চাল বাকি ৳৪৫০', '১৩ দিন আগে তেল ৳৮০০']),
      CustomerDue(name: 'সেলিম মিয়া', phone: '01819-876543', dueAmount: 980, daysPending: 3, logs: ['৩ দিন আগে ডাল ও চিনি ৳৯৮০']),
      CustomerDue(name: 'করিম উদ্দিন', phone: '01670-123456', dueAmount: 2400, daysPending: 22, logs: ['৭ দিন আগে বাকি ৳১০০০', '১৫ দিন আগে বাকি ৳১৪০০']),
      CustomerDue(name: 'আব্দুল কাদের', phone: '01911-223344', dueAmount: 1500, daysPending: 14, logs: ['৬ দিন আগে বাকি ৳১৫০০']),
    ];

    _utilities = [
      UtilityExpense(title: 'দোকান বিদ্যুৎ বিল', amount: 1850, date: now.subtract(const Duration(days: 5))),
      UtilityExpense(title: 'দোকান ভাড়া', amount: 6000, date: now.subtract(const Duration(days: 10))),
    ];
  }

  // --- ক্যালকুলেশনস ---
  double get _totalCustomerDue => _customers.fold(0, (sum, c) => sum + c.dueAmount);
  double get _totalStockWorth => _products.fold(0, (sum, p) => sum + (p.stock * p.buyPrice));
  double get _shopNetWorth => _totalStockWorth + _cashInHand + _totalCustomerDue; // লাইভ Shop Worth
  List<Product> get _expiredTodayProducts {
    final now = DateTime.now();
    return _products.where((p) => p.expiryDate.year == now.year && p.expiryDate.month == now.month && p.expiryDate.day == now.day).toList();
  }
  List<Product> get _expiringSoonProducts {
    final now = DateTime.now();
    return _products.where((p) {
      final diff = p.expiryDate.difference(now).inDays;
      return diff > 0 && diff <= 3;
    }).toList();
  }
  List<Product> get _lowStockProducts => _products.where((p) => p.stock <= p.minAlertLimit).toList();

  // --- মেথডস ---
  void _toggleAuthorityMode() {
    if (_isHostMode) {
      // মালিক থেকে কর্মচারী মোডে যাওয়া
      setState(() => _isHostMode = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কর্মচারী/ইউজার মোড চালু হয়েছে। কেনা দাম ও নিট লাভ লক করা।')));
    } else {
      // হোস্ট মোডে ফিরতে পিন প্রয়োজন
      final pinCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('হোস্ট / মালিক পিন লিখুন'),
          content: TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: const InputDecoration(labelText: '৪ ডিজিটের পিন (ডিফল্ট: 1234)', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white),
              onPressed: () {
                if (pinCtrl.text == _hostPin) {
                  setState(() => _isHostMode = true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('হোস্ট মোডে প্রবেশ সফল হয়েছে!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ভুল পিন নম্বর!')));
                }
              },
              child: const Text('আনলক'),
            ),
          ],
        ),
      );
    }
  }

  void _editShopProfile() {
    if (!_isHostMode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('দোকানের তথ্য পরিবর্তনের অনুমতি কেবল হোস্টের রয়েছে।')));
      return;
    }
    final nameCtrl = TextEditingController(text: _shopName);
    final sloganCtrl = TextEditingController(text: _shopSlogan);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('দোকানের প্রোফাইল এডিট করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'দোকানের নাম', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: sloganCtrl, decoration: const InputDecoration(labelText: 'স্লোগান', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _shopName = nameCtrl.text.trim();
                  _shopSlogan = sloganCtrl.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D5C3A),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.storefront, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_shopName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(_shopSlogan, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.white),
            tooltip: 'দোকান এডিট করুন',
            onPressed: _editShopProfile,
          ),
          // অথরিটি টগল বাটন
          GestureDetector(
            onTap: _toggleAuthorityMode,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isHostMode ? Colors.amber.shade700 : Colors.blueGrey.shade800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(_isHostMode ? Icons.admin_panel_settings : Icons.person, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(_isHostMode ? 'হোস্ট' : 'ইউজার', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeScreen(),
          _buildPosScreen(),
          _buildStockScreen(),
          _buildCustomerDueScreen(),
          _buildReportScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D5C3A),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'হোম'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_outlined), activeIcon: Icon(Icons.point_of_sale), label: 'বিক্রি (POS)'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'স্টক'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'বাকি খাতা'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), activeIcon: Icon(Icons.insert_chart), label: 'রিপোর্ট'),
        ],
      ),
    );
  }

  // ===================== ১. হোম স্ক্রিন =====================
  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ৩টি মূল মেট্রিক কার্ড
          Row(
            children: [
              _metricCard('আজকের বিক্রি', '৳ ${_todayTotalSales.toStringAsFixed(0)}', Icons.payments, Colors.teal),
              const SizedBox(width: 8),
              _metricCard(
                'আজকের নিট লাভ',
                _isHostMode ? '৳ ${_todayTotalProfit.toStringAsFixed(0)}' : '৳ ••••••',
                Icons.trending_up,
                Colors.green,
                locked: !_isHostMode,
              ),
              const SizedBox(width: 8),
              _metricCard(
                'দোকানের মোট Worth',
                _isHostMode ? '৳ ${_shopNetWorth.toStringAsFixed(0)}' : '৳ ••••••',
                Icons.account_balance,
                Colors.indigo,
                locked: !_isHostMode,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ৭ম দিনের মেয়াদ উত্তীর্ণ লাল স্টিকি ব্যানার
          if (_expiredTodayProducts.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade400, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dangerous, color: Colors.red, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('সতর্কতা: আজকেই মেয়াদ শেষ!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${_expiredTodayProducts.map((p) => "${p.name} (${p.stock} ${p.unit})").join(", ")} অবিলম্বে তাক থেকে সরান।',
                            style: TextStyle(color: Colors.red.shade900, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // মেয়াদ শেষ হতে চলা (৩ দিনের ওয়ার্নিং অ্যালার্ম)
          if (_expiringSoonProducts.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.orange, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('অ্যালার্ম: ${_expiringSoonProducts.length}টি পণ্যের মেয়াদ ৩ দিনের মধ্যে শেষ হবে!',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 2),
                    child: const Text('দেখুন >', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),

          // দ্রুত কাজ করুন বাটন গ্রিড
          const Text('দ্রুত কাজ করুন', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _actionTile('নতুন বিক্রি (POS)', Icons.shopping_cart_checkout, const Color(0xFF0D5C3A), () => setState(() => _currentIndex = 1)),
              _actionTile('পণ্য ও ডিলার যোগ', Icons.add_business, Colors.blue.shade800, () => _openAddProductDialog()),
              _actionTile('বাকি তাগাদা ও জমা', Icons.assignment_ind, Colors.deepOrange, () => setState(() => _currentIndex = 3)),
              _actionTile('স্টক ও মেয়াদ চেক', Icons.fact_check, Colors.purple.shade700, () => setState(() => _currentIndex = 2)),
            ],
          ),

          const SizedBox(height: 14),

          // ডাবল অ্যালার্ট কার্ড: কম স্টক অ্যালার্ট
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                          SizedBox(width: 6),
                          Text('কম স্টক অ্যালার্ট (মজুদ ফুরিয়ে আসছে)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
                        ],
                      ),
                      TextButton(onPressed: () => setState(() => _currentIndex = 2), child: const Text('সব দেখুন >', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                  const Divider(height: 10),
                  ..._lowStockProducts.take(3).map(
                        (p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('• ${p.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text('${p.stock} ${p.unit} বাকি', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // লেট-পেমেন্ট কাস্টমার ফ্ল্যাগ
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('দেরিতে বাকি পরিশোধের রিমাইন্ডার (১৫+ দিন)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
                      Icon(Icons.access_time_filled, color: Colors.orange, size: 18),
                    ],
                  ),
                  const Divider(height: 10),
                  ..._customers.where((c) => c.daysPending >= 15).map(
                        (c) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('বাকি: ৳${c.dueAmount.toStringAsFixed(0)} (${c.daysPending} দিন অতিবাহিত)'),
                          trailing: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                            icon: const Icon(Icons.send, size: 12),
                            label: const Text('তাগাদা SMS', style: TextStyle(fontSize: 11)),
                            onPressed: () => _sendReminderSms(c),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== ২. বিক্রি / ক্যাশ কাউন্টার (POS) =====================
  Widget _buildPosScreen() {
    final filtered = _posCategoryFilter == 'সব' ? _products : _products.where((p) => p.category == _posCategoryFilter).toList();
    final categories = ['সব', 'ঠান্ডা আইটেম', 'চাল-ডাল', 'তেল', 'মসলা'];

    double cartTotal = _cart.fold(0, (sum, item) => sum + (item.product.sellPrice * item.quantity));

    return Column(
      children: [
        // ক্যাটাগরি চিপস
        Container(
          color: Colors.white,
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final isSel = _posCategoryFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : Colors.black87)),
                  selected: isSel,
                  selectedColor: const Color(0xFF0D5C3A),
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (val) => setState(() => _posCategoryFilter = cat),
                ),
              );
            },
          ),
        ),

        // প্রোডাক্ট কুইক গ্রিড
        Expanded(
          flex: 4,
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final p = filtered[i];
              return InkWell(
                onTap: () {
                  if (p.stock <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name}-এর স্টক শেষ!')));
                    return;
                  }
                  setState(() {
                    final existing = _cart.firstWhere((c) => c.product.id == p.id, orElse: () => CartItem(product: p, quantity: 0));
                    if (existing.quantity == 0) {
                      _cart.add(existing);
                    }
                    if (existing.quantity < p.stock) {
                      existing.quantity++;
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: p.category == 'ঠান্ডা আইটেম' ? Colors.blue.shade100 : Colors.teal.shade50,
                        child: Icon(
                          p.category == 'ঠান্ডা আইটেম' ? Icons.ac_unit : Icons.shopping_basket,
                          color: p.category == 'ঠান্ডা আইটেম' ? Colors.blue : const Color(0xFF0D5C3A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(p.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('৳${p.sellPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF0D5C3A), fontWeight: FontWeight.bold)),
                      Text('স্টক: ${p.stock}', style: TextStyle(fontSize: 10, color: p.stock <= p.minAlertLimit ? Colors.red : Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // কার্ট ও বিলিং প্যানেল
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('কার্ট / বিল (${_cart.length} পণ্য)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (_cart.isNotEmpty)
                    InkWell(
                      onTap: () => setState(() => _cart.clear()),
                      child: const Text('মুছুন', style: TextStyle(color: Colors.red, fontSize: 12)),
                    )
                ],
              ),
              const SizedBox(height: 6),
              if (_cart.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('পণ্য সিলেক্ট করুন...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                )
              else
                SizedBox(
                  height: 65,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cart.length,
                    itemBuilder: (ctx, i) {
                      final item = _cart[i];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Text('${item.product.name} (x${item.quantity})', style: const TextStyle(fontSize: 12)),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, size: 16, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  if (item.quantity > 1) {
                                    item.quantity--;
                                  } else {
                                    _cart.removeAt(i);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Divider(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('মোট: ৳ ${cartTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D5C3A))),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                        onPressed: _cart.isEmpty ? null : () => _completeSale(cartTotal, isDue: true),
                        child: const Text('বাকিতে বিক্রি'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white),
                        onPressed: _cart.isEmpty ? null : () => _completeSale(cartTotal, isDue: false),
                        child: const Text('নগদ পরিশোধ'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _completeSale(double total, {required bool isDue}) {
    double generatedProfit = 0;
    for (var item in _cart) {
      item.product.stock -= item.quantity;
      item.product.totalSoldQty += item.quantity;
      item.product.totalRevenue += (item.quantity * item.product.sellPrice);
      generatedProfit += (item.quantity * item.product.profitPerUnit);
    }

    setState(() {
      _todayTotalSales += total;
      _todayTotalProfit += generatedProfit;
      if (!isDue) {
        _cashInHand += total;
      }
      _cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isDue ? 'বাকি খাতায় বিক্রয় সম্পন্ন!' : 'নগদ বিক্রি সম্পন্ন ও ক্যাশে যোগ হয়েছে!')));
  }

  // ===================== ৩. পণ্যের স্টক ও ইনভেন্টরি =====================
  Widget _buildStockScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('মোট পণ্য: ${_products.length}টি', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white),
                onPressed: _openAddProductDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('নতুন পণ্য ও ডিলার'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _products.length,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            itemBuilder: (ctx, i) {
              final p = _products[i];
              final isLow = p.stock <= p.minAlertLimit;
              final daysToExpiry = p.expiryDate.difference(DateTime.now()).inDays;
              return Card(
                elevation: 0,
                color: isLow ? Colors.red.shade50 : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: isLow ? Colors.red : const Color(0xFF0D5C3A),
                    child: Icon(Icons.inventory_2, color: Colors.white, size: 18),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    'মজুদ: ${p.stock} ${p.unit} | বিক্রয়: ৳${p.sellPrice.toStringAsFixed(0)} ${_isHostMode ? "| কেনা: ৳" + p.buyPrice.toStringAsFixed(0) : ""}',
                    style: TextStyle(fontSize: 12, color: isLow ? Colors.red : Colors.black87),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('৳${p.sellPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D5C3A))),
                      Text(
                        daysToExpiry <= 0 ? 'মেয়াদ শেষ!' : '$daysToExpiry দিন বাকি',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: daysToExpiry <= 3 ? Colors.red : Colors.grey),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text('ডিলার / সাপ্লায়ার তথ্য:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
                          Text('• ডিলার: ${p.supplierName} (${p.supplierPhone})', style: const TextStyle(fontSize: 12)),
                          Text('• আসার দিন: প্রতি ${p.supplierVisitDay}', style: const TextStyle(fontSize: 12)),
                          if (_isHostMode) Text('• প্রতি এককে নিট লাভ: ৳${p.profitPerUnit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  final addCtrl = TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (dCtx) => AlertDialog(
                                      title: Text('${p.name} - স্টক রিফিল'),
                                      content: TextField(controller: addCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'নতুন মালের সংখ্যা')),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('বাতিল')),
                                        ElevatedButton(
                                          onPressed: () {
                                            final qty = int.tryParse(addCtrl.text) ?? 0;
                                            if (qty > 0) {
                                              setState(() => p.stock += qty);
                                              Navigator.pop(dCtx);
                                            }
                                          },
                                          child: const Text('যোগ করুন'),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('স্টক বাড়ান'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===================== ৪. বাকির খাতা ও লেট পেমেন্ট =====================
  Widget _buildCustomerDueScreen() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.red.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('বাজারে মোট বাকি পাওনা', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text('৳ ${_totalCustomerDue.toStringAsFixed(0)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white),
                onPressed: _openAddCustomerDialog,
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('নতুন কাস্টমার'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _customers.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (ctx, i) {
              final c = _customers[i];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: c.daysPending >= 15 ? Colors.red.shade100 : Colors.green.shade100,
                    child: Icon(Icons.person, color: c.daysPending >= 15 ? Colors.red : Colors.green),
                  ),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('মোবাইল: ${c.phone}\nবাকি: ৳${c.dueAmount.toStringAsFixed(0)} (${c.daysPending} দিন আগে)', style: const TextStyle(fontSize: 12)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
                    onPressed: () => _openCustomerPaymentDialog(c),
                    child: const Text('জমা / বাকি'),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('লেনদেন বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              TextButton.icon(
                                onPressed: () => _sendReminderSms(c),
                                icon: const Icon(Icons.sms, size: 14, color: Colors.teal),
                                label: const Text('তাগাদা SMS পাঠান', style: TextStyle(fontSize: 12, color: Colors.teal)),
                              ),
                            ],
                          ),
                          ...c.logs.map((log) => Text('• $log', style: const TextStyle(fontSize: 12, color: Colors.black87))),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _sendReminderSms(CustomerDue c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${c.name}-এর নম্বরে (${c.phone}) বকেয়া ৳${c.dueAmount.toStringAsFixed(0)}-এর তাগাদা মেসেজ পাঠানো হয়েছে!')),
    );
  }

  // ===================== ৫. হিসাব ও রিপোর্ট (P&L এবং অ্যানালিটিক্স) =====================
  Widget _buildReportScreen() {
    if (!_isHostMode) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('রিপোর্ট ও প্রফিট/লস স্টেটমেন্ট কেবল হোস্টের জন্য সংরক্ষিত।', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _toggleAuthorityMode, child: const Text('হোস্ট মোডে আনলক করুন')),
          ],
        ),
      );
    }

    // ১. টপ সেলিং প্রোডাক্টস
    final sortedByQty = List<Product>.from(_products)..sort((a, b) => b.totalSoldQty.compareTo(a.totalSoldQty));
    final sortedByProfit = List<Product>.from(_products)..sort((a, b) => b.totalProfitGenerated.compareTo(a.totalProfitGenerated));
    final slowestProducts = List<Product>.from(_products)..sort((a, b) => a.totalSoldQty.compareTo(b.totalSoldQty));

    // ২. ক্যাটাগরি প্রফিট মার্জিন
    double coldItemsSales = _products.where((p) => p.category == 'ঠান্ডা আইটেম').fold(0, (sum, p) => sum + p.totalRevenue);
    double coldItemsProfit = _products.where((p) => p.category == 'ঠান্ডা আইটেম').fold(0, (sum, p) => sum + p.totalProfitGenerated);

    // ৩. ইউটিলিটি খরচ ও মাসিক নিট লাভ
    double totalUtilities = _utilities.fold(0, (sum, u) => sum + u.amount);
    double monthlyNetProfit = _todayTotalProfit * 30 - totalUtilities;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // মাসিক মুনাফা-ক্ষতি স্টেটমেন্ট (P&L)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF0D5C3A), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('মাসিক প্রবাবল প্রফিট/লস (P&L)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
                      tooltip: 'ইউটিলিটি বিল যোগ করুন',
                      onPressed: _openAddUtilityDialog,
                    )
                  ],
                ),
                const Divider(color: Colors.white24),
                Text('দোকান ইউটিলিটি বিল (ভাড়া/বিদ্যুৎ): ৳ ${totalUtilities.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text('সম্ভাব্য নিট মাসিক মুনাফা: ৳ ${monthlyNetProfit.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ক্যাটাগরিভিত্তিক পারফরম্যান্স (ঠান্ডা আইটেম স্পেশাল)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ক্যাটাগরি ট্রেন্ড: ঠান্ডা আইটেম (কোল্ড ড্রিংকস/আইসক্রিম)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _kpiMini('মোট বিক্রি', '৳ ${coldItemsSales.toStringAsFixed(0)}'),
                      _kpiMini('নিট মুনাফা', '৳ ${coldItemsProfit.toStringAsFixed(0)}', color: Colors.green),
                      _kpiMini('মার্জিন', '${coldItemsSales > 0 ? ((coldItemsProfit / coldItemsSales) * 100).toStringAsFixed(1) : 0}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // টপ ১০ সেলিং প্রোডাক্টস (পরিমাণে)
          const Text('টপ সেলিং প্রোডাক্টস (সর্বোচ্চ বিক্রয় সংখ্যা)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          ...sortedByQty.take(5).map((p) => ListTile(
                dense: true,
                leading: CircleAvatar(radius: 12, backgroundColor: Colors.teal.shade50, child: Text('${sortedByQty.indexOf(p) + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                trailing: Text('${p.totalSoldQty} ${p.unit} বিক্রি', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),

          const SizedBox(height: 12),

          // স্লো-মুভিং প্রোডাক্টস (ধীরগতির পণ্য)
          const Text('স্লো-মুভিং প্রোডাক্টস (দোকানে আটকে থাকা পণ্য)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrange)),
          const SizedBox(height: 6),
          ...slowestProducts.take(3).map((p) => ListTile(
                dense: true,
                leading: const Icon(Icons.hourglass_bottom, color: Colors.deepOrange, size: 20),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('স্টকে পড়ে আছে: ${p.stock} ${p.unit}'),
                trailing: Text('বিক্রি হয়েছে মাত্র ${p.totalSoldQty}', style: const TextStyle(color: Colors.red, fontSize: 12)),
              )),
        ],
      ),
    );
  }

  // --- ডায়ালগস ও হেল্পার্স ---
  void _openAddProductDialog() {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'মুদি');
    final stockCtrl = TextEditingController();
    final buyCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    final suppNameCtrl = TextEditingController();
    final suppPhoneCtrl = TextEditingController();
    final visitDayCtrl = TextEditingController(text: 'রবিবার');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('পণ্য ও ডিলারের তথ্য যোগ করুন'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'পণ্যের নাম', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'ক্যাটাগরি (ঠান্ডা/চাল-ডাল/তেল)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মজুদ', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: buyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'কেনা দাম (৳)', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: sellCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'বিক্রি দাম (৳)', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 8),
              TextField(controller: suppNameCtrl, decoration: const InputDecoration(labelText: 'ডিলার/সাপ্লায়ারের নাম', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: suppPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'ডিলারের মোবাইল নম্বর', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: visitDayCtrl, decoration: const InputDecoration(labelText: 'আসার দিন (যেমন: বুধবার)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _products.insert(
                    0,
                    Product(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text,
                      category: catCtrl.text,
                      unit: 'কেজি/পিস',
                      stock: int.tryParse(stockCtrl.text) ?? 10,
                      buyPrice: double.tryParse(buyCtrl.text) ?? 50,
                      sellPrice: double.tryParse(sellCtrl.text) ?? 60,
                      minAlertLimit: 5,
                      expiryDate: DateTime.now().add(const Duration(days: 90)),
                      supplierName: suppNameCtrl.text.isEmpty ? 'লোকাল ডিলার' : suppNameCtrl.text,
                      supplierPhone: suppPhoneCtrl.text.isEmpty ? '01700000000' : suppPhoneCtrl.text,
                      supplierVisitDay: visitDayCtrl.text,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  void _openAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final dueCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন কাস্টমার খাতা'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'কাস্টমারের নাম', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: dueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রারম্ভিক বাকি (৳)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final d = double.tryParse(dueCtrl.text) ?? 0;
                setState(() {
                  _customers.insert(0, CustomerDue(name: nameCtrl.text, phone: phoneCtrl.text, dueAmount: d, daysPending: 1, logs: d > 0 ? ['প্রারম্ভিক বাকি ৳$d'] : []));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('খুলুন'),
          )
        ],
      ),
    );
  }

  void _openCustomerPaymentDialog(CustomerDue c) {
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${c.name} - জমা / বাকি'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('বর্তমান বকেয়া: ৳ ${c.dueAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              final a = double.tryParse(amtCtrl.text) ?? 0;
              if (a > 0) {
                setState(() {
                  c.dueAmount -= a;
                  if (c.dueAmount < 0) c.dueAmount = 0;
                  c.daysPending = 0;
                  c.logs.insert(0, 'জমা পরিশোধ: ৳$a');
                  _cashInHand += a;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('জমা নিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              final a = double.tryParse(amtCtrl.text) ?? 0;
              if (a > 0) {
                setState(() {
                  c.dueAmount += a;
                  c.logs.insert(0, 'নতুন বাকি নিল: ৳$a');
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('বাকি নিল'),
          ),
        ],
      ),
    );
  }

  void _openAddUtilityDialog() {
    final titleCtrl = TextEditingController();
    final amtCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ইউটিলিটি খরচ যোগ করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'খরচের নাম (যেমন: দোকান বিদ্যুৎ বিল)', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () {
              final a = double.tryParse(amtCtrl.text) ?? 0;
              if (titleCtrl.text.isNotEmpty && a > 0) {
                setState(() => _utilities.add(UtilityExpense(title: titleCtrl.text, amount: a, date: DateTime.now())));
                Navigator.pop(ctx);
              }
            },
            child: const Text('যুক্ত করুন'),
          )
        ],
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color, {bool locked = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black54))),
                if (locked) const Icon(Icons.lock, size: 10, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 6),
            Text(val, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _kpiMini(String label, String value, {Color color = Colors.black87}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}