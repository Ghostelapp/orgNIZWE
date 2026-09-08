import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/shopping_item.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Lista zakupów')),
      body: provider.shoppingLists.isEmpty
          ? const Center(child: Text('Brak list zakupowych'))
          : ListView.builder(
              itemCount: provider.shoppingLists.first.items.length,
              itemBuilder: (context, index) {
                final item = provider.shoppingLists.first.items[index];
                return ListTile(
                  leading: Checkbox(
                    value: item.isPurchased,
                    onChanged: (_) => provider.toggleShoppingItem(
                        provider.shoppingLists.first.id, item.id),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${item.quantity} ${item.unit}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nowy produkt'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nazwa produktu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final provider = context.read<AppProvider>();
                if (provider.shoppingLists.isEmpty) {
                  provider.addShoppingList(ShoppingList(name: 'Zakupy'));
                }
                provider.addShoppingItem(
                  provider.shoppingLists.first.id,
                  ShoppingItem(name: nameController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}
