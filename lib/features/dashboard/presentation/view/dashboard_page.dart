import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../injection/injection_container.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Test? _ongoingTest;

  @override
  void initState() {
    super.initState();
    _checkOngoingTest();
  }

  Future<void> _checkOngoingTest() async {
    final db = sl<AppDatabase>();
    final test = await (db.select(db.tests)..where((t) => t.status.equals('ongoing'))..limit(1)).getSingleOrNull();
    if (mounted) setState(() => _ongoingTest = test);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings')),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_ongoingTest != null) _buildOngoingBanner(),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                _buildMenuCard(context, 'Import Questions', Icons.upload_file, Colors.blue, '/import'),
                _buildMenuCard(context, 'Question Bank', Icons.library_books, Colors.purple, '/bank'),
                _buildMenuCard(context, 'Create Test', Icons.add_task, Colors.green, '/create-test'),
                _buildMenuCard(context, 'Test History', Icons.history, Colors.orange, '/history'),
                _buildMenuCard(context, 'Analytics', Icons.analytics, Colors.teal, '/analytics'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Unfinished Test Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Test: ${_ongoingTest!.name}'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/exam/${_ongoingTest!.id}'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('RESUME TEST'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(route).then((_) => _checkOngoingTest()),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
