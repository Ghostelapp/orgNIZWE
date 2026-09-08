import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/note.dart';
import 'notes_screen.dart';
import 'shopping_screen.dart';

class OrganizationScreen extends StatelessWidget {
  const OrganizationScreen({super.key});

  final List<_OrgCategory> categories = const [
    _OrgCategory('Dokumenty', Icons.folder_outlined, Colors.blue),
    _OrgCategory('Ważne daty', Icons.event_available_outlined, Colors.orange),
    _OrgCategory('Abonamenty', Icons.subscriptions_outlined, Colors.purple),
    _OrgCategory('Kontakty', Icons.contacts_outlined, Colors.green),
    _OrgCategory('Samochód', Icons.directions_car_outlined, Colors.red),
    _OrgCategory('Dom', Icons.home_outlined, Colors.brown),
    _OrgCategory('Podróże', Icons.flight_outlined, Colors.cyan),
    _OrgCategory('Cele', Icons.flag_outlined, Colors.pink),
    _OrgCategory('Notatki', Icons.note_outlined, Colors.indigo),
    _OrgCategory('Zakupy', Icons.shopping_cart_outlined, Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizacja życia')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            category: category,
            onTap: () => _openCategory(context, category.title),
          );
        },
      ),
    );
  }

  void _openCategory(BuildContext context, String title) {
    if (title == 'Notatki') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen()));
    } else if (title == 'Zakupy') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategoria "$title" w przygotowaniu')),
      );
    }
  }
}

class _OrgCategory {
  final String title;
  final IconData icon;
  final Color color;
  const _OrgCategory(this.title, this.icon, this.color);
}

class _CategoryCard extends StatelessWidget {
  final _OrgCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: category.color.withOpacity(0.1),
                child: Icon(category.icon, color: category.color),
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
