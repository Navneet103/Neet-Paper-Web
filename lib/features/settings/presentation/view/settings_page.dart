import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../injection/injection_container.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text('Offline Mode'),
            subtitle: Text('Always enabled (Enterprise Native)'),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
          ListTile(
            title: const Text('Database Reset'),
            subtitle: const Text('Clear all questions, tests, and analytics'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _confirmReset(context),
          ),
          const Divider(),
          const ListTile(
            title: Text('Data Persistence'),
            subtitle: Text('Powered by IndexedDB (Browser Local Storage)'),
          ),
          const ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0 (Production Build)'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text('This will permanently delete all imported questions and your entire test history. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await sl<AppDatabase>().clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/dashboard');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database cleared successfully.')),
                );
              }
            },
            child: const Text('CLEAR EVERYTHING'),
          ),
        ],
      ),
    );
  }
}
