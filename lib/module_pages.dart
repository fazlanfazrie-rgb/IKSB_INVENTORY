import 'package:flutter/material.dart';

import 'core/database_service.dart';

class StoreModulePage extends StatelessWidget {
  const StoreModulePage({super.key, required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), leading: Icon(icon)),
      body: SafeArea(child: child),
    );
  }
}

class BinCardPage extends StatefulWidget {
  const BinCardPage({super.key});
  @override
  State<BinCardPage> createState() => _BinCardPageState();
}

class _BinCardPageState extends State<BinCardPage> {
  final _code = TextEditingController();
  Future<List<Map<String, Object?>>>? _future;

  @override
  void dispose() { _code.dispose(); super.dispose(); }

  Future<List<Map<String, Object?>>> _load() async {
    final code = _code.text.trim();
    if (code.isEmpty) return [];
    final db = await DatabaseService.database;
    return db.query('transactions', where: 'item_code = ?', whereArgs: [code], orderBy: 'date ASC, id ASC');
  }

  @override
  Widget build(BuildContext context) => StoreModulePage(
    title: 'Bin Card', icon: Icons.receipt_long,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(controller: _code, textInputAction: TextInputAction.search, onSubmitted: (_) => setState(() => _future = _load()), decoration: const InputDecoration(labelText: 'Item Code', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () => setState(() => _future = _load()), icon: const Icon(Icons.refresh), label: const Text('LOAD BIN CARD')),
        const SizedBox(height: 12),
        Expanded(child: _future == null ? const Center(child: Text('Enter an item code and load the ledger.')) : FutureBuilder<List<Map<String, Object?>>>(future: _future, builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = s.data ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }
          return ListView.builder(itemCount: rows.length, itemBuilder: (_, i) { final r = rows[i]; return Card(child: ListTile(title: Text('${r['date']} • ${r['tranx']}'), subtitle: Text('DOC ${r['doc_no'] ?? ''}  Charging ${r['charging'] ?? ''}'), trailing: Text('IN ${r['receive']}\nOUT ${r['issue']}', textAlign: TextAlign.right))); });
        })),
      ]),
    ),
  );
}

class StockTakePage extends StatelessWidget {
  const StockTakePage({super.key});
  @override
  Widget build(BuildContext context) => StoreModulePage(title: 'Stock Take', icon: Icons.fact_check, child: ListView(padding: const EdgeInsets.all(16), children: const [Card(child: ListTile(leading: Icon(Icons.inventory), title: Text('System Balance'), subtitle: Text('Calculated from the same SQLite transaction ledger.'))), Card(child: ListTile(leading: Icon(Icons.edit_note), title: Text('Physical Count'), subtitle: Text('Stock Take input and variance workflow is next parity gate.'))), Card(child: ListTile(leading: Icon(Icons.rule), title: Text('Variance / Status'), subtitle: Text('Physical − System → TALLY / OVER / SHORT.')))]));
}

class FuelPage extends StatelessWidget {
  const FuelPage({super.key});
  @override
  Widget build(BuildContext context) => const StoreModulePage(title: 'Fuel', icon: Icons.local_gas_station, child: _ModuleInfo(title: 'Fuel Control', text: 'Fuel module entry point is now connected. Charging and issue logic will use the native FuelEngine.'));
}

class FertilizerPage extends StatelessWidget {
  const FertilizerPage({super.key});
  @override
  Widget build(BuildContext context) => const StoreModulePage(title: 'Fertilizer', icon: Icons.eco, child: _ModuleInfo(title: 'Fertilizer Control', text: 'Fertilizer module entry point is now connected. Master, receive, weekly and balance logic remain under parity certification.'));
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) => const StoreModulePage(title: 'Reports', icon: Icons.assessment, child: _ModuleInfo(title: 'Reports', text: 'Receive, Issue, Bin Card, Stock Take and operational reports will be wired to their native engines.'));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => StoreModulePage(
    title: 'Settings',
    icon: Icons.settings,
    child: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: ListTile(leading: const Icon(Icons.dark_mode), title: const Text('Dark Mode'), subtitle: const Text('STOREPH3 is configured for dark mode by default.'), trailing: Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: null))),
      const Card(child: ListTile(leading: Icon(Icons.offline_bolt), title: Text('Offline SQLite'), subtitle: Text('Local-first database for store transactions.'))),
      const SizedBox(height: 12),
      const Card(child: Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NEXSTORE_360', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text('Smart Store & Estate Operations'),
        SizedBox(height: 18),
        Text('Created & Designed by', style: TextStyle(fontSize: 12)),
        SizedBox(height: 4),
        Text('FazLan_Yuns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('© 2026 FazLan_Yuns'),
      ]))),
    ]),
  );
}

class _ModuleInfo extends StatelessWidget {
  const _ModuleInfo({required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(text),
                const SizedBox(height: 20),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text('Parity integration in progress', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
