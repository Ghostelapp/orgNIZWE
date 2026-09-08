import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(provider.userName.isEmpty ? 'Użytkownik' : provider.userName),
            subtitle: const Text('Tapnij, aby zmienić imię'),
            onTap: () => _showEditNameDialog(context),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Ciemny motyw'),
            subtitle: const Text('Włącz ciemny wygląd aplikacji'),
            value: provider.isDarkMode,
            onChanged: (value) => provider.setDarkMode(value),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Powiadomienia'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Personalizacja'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ustawienia AI'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: context.read<AppProvider>().userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Twoje imię'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Imię'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppProvider>().setUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }
}
