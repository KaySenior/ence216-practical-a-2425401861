import 'package:flutter/material.dart';
import 'cart_screen.dart';

void main() {
  runApp(const CampusCafeApp());
}

class CampusCafeApp extends StatelessWidget {
  const CampusCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Market',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCE8D8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCE8D8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.6),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: Color(0xFFDCE8D8),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class MenuItem {
  final String name;
  final double price;
  final IconData icon;
  const MenuItem(this.name, this.price, this.icon);
}

// Local Ghanaian grocery / market items, priced per typical unit (GHS)
const menu = [
  MenuItem('Gari (1 rubber/bowl)', 8.00, Icons.grain),
  MenuItem('Local Rice (5kg bag)', 65.00, Icons.rice_bowl),
  MenuItem('Yam (1 tuber)', 15.00, Icons.egg_alt),
  MenuItem('Plantain (1 hand)', 12.00, Icons.forest),
  MenuItem('Cassava (3 tubers)', 10.00, Icons.eco),
  MenuItem('Kontomire (bundle)', 5.00, Icons.local_florist),
  MenuItem('Fresh Tomatoes (1 basket)', 40.00, Icons.local_grocery_store),
  MenuItem('Onions (1 net)', 25.00, Icons.emoji_food_beverage),
  MenuItem('Palm Oil (1.5L bottle)', 30.00, Icons.oil_barrel),
  MenuItem('Groundnut Paste (1 bowl)', 18.00, Icons.set_meal),
  MenuItem('Smoked Fish (small basket)', 35.00, Icons.set_meal),
  MenuItem('Shito (1 jar)', 20.00, Icons.local_fire_department),
  MenuItem('Koko (Millet Porridge, 1L)', 10.00, Icons.local_drink),
  MenuItem('Eggs (crate of 30)', 45.00, Icons.egg),
  MenuItem('Sobolo (500 ml)', 8.00, Icons.water_drop),
];

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDecrement,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

/// Owns cart state and the bottom NavigationBar, switching between
/// OrderPage and CartScreen without losing either screen's state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _navIndex = 0;
  final Map<int, int> _qty = {};

  double get _total {
    var sum = 0.0;
    _qty.forEach((i, q) => sum += menu[i].price * q);
    return sum;
  }

  int get _itemCount => _qty.values.fold(0, (a, b) => a + b);

  void _change(int index, int delta) {
    setState(() {
      final next = (_qty[index] ?? 0) + delta;
      if (next <= 0) {
        _qty.remove(index);
      } else {
        _qty[index] = next;
      }
    });
  }

  void _goToCart() => setState(() => _navIndex = 1);

  Future<void> _clearOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear order?'),
        content: const Text('All quantities will reset to zero.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _qty.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      OrderPage(
        qty: _qty,
        total: _total,
        onChange: _change,
        onClear: _qty.isEmpty ? null : _clearOrder,
        onGoToCart: _itemCount == 0 ? null : _goToCart,
      ),
      BulkPage(
        qty: _qty,
        total: _total,
        onChange: _change,
        onGoToCart: _itemCount == 0 ? null : _goToCart,
      ),
      CartScreen(
        qty: _qty,
        onIncrement: (i) => _change(i, 1),
        onDecrement: (i) => _change(i, -1),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Market',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Bulk',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$_itemCount'),
              isLabelVisible: _itemCount > 0,
              child: const Icon(Icons.shopping_basket_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_basket),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class BulkPage extends StatelessWidget {
  final Map<int, int> qty;
  final double total;
  final void Function(int index, int delta) onChange;
  final VoidCallback? onGoToCart;

  const BulkPage({
    super.key,
    required this.qty,
    required this.total,
    required this.onChange,
    required this.onGoToCart,
  });

  static const List<int> _bulkIndices = [0, 1, 6, 12];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy in Bulk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCE8D8)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_bag, color: Color(0xFF2E7D32)),
                      SizedBox(width: 8),
                      Text(
                        'Bulk deals for homes and businesses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose larger quantities for everyday essentials and market-day savings.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final i in _bulkIndices)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5EDE0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFE9F5E4),
                            child: Icon(
                              menu[i].icon,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu[i].name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'GHS ${menu[i].price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          QuantityStepper(
                            quantity: qty[i] ?? 0,
                            onIncrement: () => onChange(i, 1),
                            onDecrement: (qty[i] ?? 0) == 0
                                ? null
                                : () => onChange(i, -1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5EDE0))),
        ),
        child: InkWell(
          onTap: onGoToCart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(
                      'GHS ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onGoToCart != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderPage extends StatefulWidget {
  final Map<int, int> qty;
  final double total;
  final void Function(int index, int delta) onChange;
  final VoidCallback? onClear;
  final VoidCallback? onGoToCart;

  const OrderPage({
    super.key,
    required this.qty,
    required this.total,
    required this.onChange,
    required this.onClear,
    required this.onGoToCart,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<int> get _visibleIndices {
    if (_query.isEmpty) return List.generate(menu.length, (i) => i);
    return [
      for (var i = 0; i < menu.length; i++)
        if (menu[i].name.toLowerCase().contains(_query)) i,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleIndices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear order',
            onPressed: widget.onClear,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search groceries…',
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: const Color(0xFF2E7D32),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No items match your search'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4FBEE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDCE8D8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shopping_bag, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Buy in Bulk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Great for households, schools, and market days.',
                                style: TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: const [
                                  Chip(label: Text('Rice + Gari bundles')),
                                  Chip(label: Text('Tomato crates')),
                                  Chip(label: Text('Egg crates')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        for (final i in visible)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              color: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE5EDE0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(0xFFE9F5E4),
                                        child: Icon(
                                          menu[i].icon,
                                          color: const Color(0xFF2E7D32),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menu[i].name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'GHS ${menu[i].price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      QuantityStepper(
                                        quantity: widget.qty[i] ?? 0,
                                        onIncrement: () => widget.onChange(i, 1),
                                        onDecrement: (widget.qty[i] ?? 0) == 0
                                            ? null
                                            : () => widget.onChange(i, -1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5EDE0))),
        ),
        child: InkWell(
          onTap: widget.onGoToCart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(
                      'GHS ${widget.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (widget.onGoToCart != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
