import 'package:flutter/material.dart';
import 'main.dart' show menu;

class CheckoutScreen extends StatelessWidget {
  final double total;
  final VoidCallback onBackToShop;

  const CheckoutScreen({
    super.key,
    required this.total,
    required this.onBackToShop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order placed successfully!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your total is GHS ${total.toStringAsFixed(2)}.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onBackToShop,
                    icon: const Icon(Icons.storefront),
                    label: const Text('Back to shop'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final Map<int, int> qty;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;

  const CartScreen({
    super.key,
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _checkedOut = false;

  double get _total {
    var sum = 0.0;
    widget.qty.forEach((i, q) => sum += menu[i].price * q);
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.qty.entries.where((e) => e.value > 0).toList();

    if (_checkedOut) {
      return CheckoutScreen(
        total: _total,
        onBackToShop: () => setState(() => _checkedOut = false),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: entries.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final index = entries[i].key;
                final q = entries[i].value;
                final item = menu[index];
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'GHS ${item.price.toStringAsFixed(2)} x $q',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => widget.onDecrement(index),
                            ),
                            Text('$q'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => widget.onIncrement(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5EDE0))),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'GHS ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: entries.isEmpty
                      ? null
                      : () => setState(() => _checkedOut = true),
                  icon: const Icon(Icons.payment),
                  label: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
