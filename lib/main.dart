import 'package:flutter/material.dart';

import 'core/database_service.dart';
import 'module_pages.dart';

void main() => runApp(const StorePh3App());

class StorePh3App extends StatelessWidget {
  const StorePh3App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'STOREPH3',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.green),
        themeMode: ThemeMode.dark,
        home: const DashboardPage(),
      );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;
  final _pages = const [_DashboardView(), _InventoryView(), _TransactionView(type: 'IN'), _TransactionView(type: 'OUT'), _MoreView()];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('STOREPH3'), actions: const [Icon(Icons.notifications_none)]),
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
            NavigationDestination(icon: Icon(Icons.download_outlined), label: 'Receive'),
            NavigationDestination(icon: Icon(Icons.upload_outlined), label: 'Issue'),
            NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
          ],
        ),
      );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Offline inventory control'),
          SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _Metric(title: 'STOCK ITEMS', value: '—', icon: Icons.inventory_2),
            _Metric(title: 'RECEIVE TODAY', value: '—', icon: Icons.download),
            _Metric(title: 'ISSUE TODAY', value: '—', icon: Icons.upload),
            _Metric(title: 'FUEL TODAY', value: '—', icon: Icons.local_gas_station),
          ]),
          SizedBox(height: 16),
          Card(child: ListTile(leading: Icon(Icons.shield_outlined), title: Text('Offline-first database'), subtitle: Text('Transactions are stored locally in SQLite.'))),
          Card(child: ListTile(leading: Icon(Icons.fact_check_outlined), title: Text('Inventory rules'), subtitle: Text('CF → IN → OUT • no negative issue stock'))),
        ],
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(width: 165, child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 22), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]))));
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();
  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  late Future<List<Map<String, Object?>>> _future;
  @override
  void initState() { super.initState(); _future = DatabaseService.inventory(); }
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, Object?>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? const [];
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search item code or name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            if (rows.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('No items loaded yet. Import the approved master data before live use.')))
            else ...rows.map((row) => ListTile(title: Text('${row['item_code']} • ${row['item_name']}'), subtitle: Text('${row['uom']}'), trailing: Text('${row['balance']}'))),
          ]);
        },
      );
}

class _TransactionView extends StatefulWidget {
  const _TransactionView({required this.type});
  final String type;
  @override
  State<_TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<_TransactionView> {
  final _item = TextEditingController();
  final _qty = TextEditingController();
  final _doc = TextEditingController();
  final _charging = TextEditingController();
  final _remark = TextEditingController();
  String _message = '';
  @override
  void dispose() { _item.dispose(); _qty.dispose(); _doc.dispose(); _charging.dispose(); _remark.dispose(); super.dispose(); }
  Future<void> _save() async {
    final quantity = double.tryParse(_qty.text.trim());
    if (_item.text.trim().isEmpty || quantity == null || quantity <= 0) { setState(() => _message = 'Enter a valid item code and quantity.'); return; }
    try {
      await DatabaseService.insertTransaction(date: DateTime.now().toIso8601String().substring(0, 10), itemCode: _item.text.trim(), tranx: widget.type, receive: widget.type == 'IN' ? quantity : 0, issue: widget.type == 'OUT' ? quantity : 0, opening: 0, docNo: _doc.text.trim(), charging: _charging.text.trim(), remark: _remark.text.trim());
      if (mounted) { setState(() => _message = '${widget.type == 'IN' ? 'Receive' : 'Issue'} saved successfully.'); _qty.clear(); }
    } catch (error) { if (mounted) setState(() => _message = error.toString()); }
  }
  @override
  Widget build(BuildContext context) {
    final isReceive = widget.type == 'IN';
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(isReceive ? 'Receive' : 'Issue', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextField(controller: _item, decoration: const InputDecoration(labelText: 'Item Code', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _qty, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: isReceive ? 'Quantity Receive' : 'Quantity Issue', border: const OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _doc, decoration: const InputDecoration(labelText: 'Document No', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _charging, decoration: const InputDecoration(labelText: 'Charging', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _remark, decoration: const InputDecoration(labelText: 'Remark', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: Text('SAVE ${isReceive ? 'RECEIVE' : 'ISSUE'}')),
      if (_message.isNotEmpty) ...[const SizedBox(height: 12), Text(_message)],
    ]);
  }
}

class _MoreView extends StatelessWidget {
  const _MoreView();
  void _open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  @override
  Widget build(BuildContext context) => ListView(children: [
        ListTile(leading: const Icon(Icons.receipt_long), title: const Text('Bin Card'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(context, const BinCardPage())),
        ListTile(leading: const Icon(Icons.fact_check), title: const Text('Stock Take'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(context, const StockTakePage())),
        ListTile(leading: const Icon(Icons.local_gas_station), title: const Text('Fuel'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(context, const FuelPage())),
        ListTile(leading: const Icon(Icons.eco), title: const Text('Fertilizer'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(context, const FertilizerPage())),
        ListTile(leading: const Icon(Icons.assessment), title: const Text('Reports'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(context, const ReportsPage())),
        ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(context, const SettingsPage())),
      ]);
}
