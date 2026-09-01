import 'package:flutter/material.dart';
import 'core/database_service.dart';
import 'module_pages.dart';

const _forest = Color(0xFF082D18);
const _plantation = Color(0xFF123F24);
const _leaf = Color(0xFF2E7D32);
const _lime = Color(0xFFB7D66A);

void main() => runApp(const TranXStoreApp());

class TranXStoreApp extends StatelessWidget {
  const TranXStoreApp({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: _leaf, brightness: Brightness.dark);
    return MaterialApp(title: 'TranX_Store', debugShowCheckedModeBanner: false, themeMode: ThemeMode.dark, theme: ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: _forest), home: const DashboardPage());
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  int _index = 0;
  final _pages = const [_DashboardView(), _InventoryView(), _TransactionView(type: 'IN'), _TransactionView(type: 'OUT'), _MoreView()];
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TranX_Store', style: TextStyle(fontWeight: FontWeight.w800)), Text('PLANTATION INVENTORY', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: _lime))]), actions: const [Padding(padding: EdgeInsets.only(right: 14), child: Icon(Icons.eco_outlined))]),
    body: _pages[_index],
    bottomNavigationBar: NavigationBar(selectedIndex: _index, onDestinationSelected: (v) => setState(() => _index = v), destinations: const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Stock'),
      NavigationDestination(icon: Icon(Icons.south_west), label: 'Receive'),
      NavigationDestination(icon: Icon(Icons.north_east), label: 'Issue'),
      NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
    ]),
  );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
    Container(height: 190, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_forest, _plantation]), boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Colors.black54)]), child: Stack(children: [
      Positioned(right: -25, top: -30, child: Icon(Icons.park, size: 180, color: Colors.white.withValues(alpha: .07))),
      Positioned(left: 20, top: 18, child: Icon(Icons.wb_sunny_outlined, size: 34, color: _lime.withValues(alpha: .85))),
      const Padding(padding: EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('ESTATE STORE', style: TextStyle(color: _lime, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        SizedBox(height: 5), Text('Inventory Controller', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        SizedBox(height: 9), Row(children: [Icon(Icons.wifi_off, size: 15, color: _lime), SizedBox(width: 6), Text('OFFLINE • LOCAL SQLITE', style: TextStyle(fontSize: 11, color: _lime, fontWeight: FontWeight.bold))]),
      ])),
    ]),
    const SizedBox(height: 16),
    const Wrap(spacing: 10, runSpacing: 10, children: [
      _Metric(title: 'STOCK ITEMS', value: '—', icon: Icons.inventory_2),
      _Metric(title: 'RECEIVE TODAY', value: '—', icon: Icons.south_west),
      _Metric(title: 'ISSUE TODAY', value: '—', icon: Icons.north_east),
      _Metric(title: 'FUEL TODAY', value: '—', icon: Icons.local_gas_station),
    ]),
    const SizedBox(height: 18),
    const Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    const _QuickGrid(),
    const SizedBox(height: 18),
    const Card(child: ListTile(leading: Icon(Icons.shield_outlined, color: _lime), title: Text('Offline & Secure'), subtitle: Text('Transactions stay in the local SQLite database.'))),
    const Card(child: ListTile(leading: Icon(Icons.rule, color: _lime), title: Text('Stock Control'), subtitle: Text('CF → IN → OUT • negative issue blocked by engine.'))),
  ]);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value, required this.icon});
  final String title, value; final IconData icon;
  @override Widget build(BuildContext context) => SizedBox(width: 165, child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: _lime, size: 23), const SizedBox(height: 9), Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))]))));
}
class _QuickGrid extends StatelessWidget {
  const _QuickGrid();
  @override Widget build(BuildContext context) => GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.08, children: const [
    _Quick(icon: Icons.south_west, label: 'Receive'), _Quick(icon: Icons.north_east, label: 'Issue'), _Quick(icon: Icons.inventory_2, label: 'Inventory'),
    _Quick(icon: Icons.receipt_long, label: 'Bin Card'), _Quick(icon: Icons.fact_check, label: 'Stock Take'), _Quick(icon: Icons.assessment, label: 'Reports'),
  ]);
}
class _Quick extends StatelessWidget {
  const _Quick({required this.icon, required this.label}); final IconData icon; final String label;
  @override Widget build(BuildContext context) => Card(child: InkWell(onTap: () {}, borderRadius: BorderRadius.circular(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: _lime, size: 27), const SizedBox(height: 7), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))])));
}
class _InventoryView extends StatefulWidget { const _InventoryView(); @override State<_InventoryView> createState() => _InventoryViewState(); }
class _InventoryViewState extends State<_InventoryView> {
  late Future<List<Map<String,Object?>>> _future;
  @override void initState(){super.initState();_future=DatabaseService.inventory();}
  @override Widget build(BuildContext context)=>FutureBuilder<List<Map<String,Object?>>>(future:_future,builder:(context,snapshot){if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());final rows=snapshot.data??const [];return ListView(padding:const EdgeInsets.all(16),children:[const Text('Inventory',style:TextStyle(fontSize:25,fontWeight:FontWeight.w800)),const SizedBox(height:12),const TextField(decoration:InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search item code or name',border:OutlineInputBorder())),const SizedBox(height:12),if(rows.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(20),child:Text('No items loaded yet. Import the approved master data before live use.')))else ...rows.map((r)=>Card(child:ListTile(leading:const Icon(Icons.inventory_2,color:_lime),title:Text('${r['item_code']} • ${r['item_name']}'),subtitle:Text('${r['uom']}'),trailing:Text('${r['balance']}',style:const TextStyle(fontWeight:FontWeight.bold)))))]);});
}
class _TransactionView extends StatefulWidget { const _TransactionView({required this.type}); final String type; @override State<_TransactionView> createState()=>_TransactionViewState(); }
class _TransactionViewState extends State<_TransactionView>{
  final _item=TextEditingController(),_qty=TextEditingController(),_doc=TextEditingController(),_charging=TextEditingController(),_remark=TextEditingController(); String _message='';
  @override void dispose(){_item.dispose();_qty.dispose();_doc.dispose();_charging.dispose();_remark.dispose();super.dispose();}
  Future<void> _save()async{final quantity=double.tryParse(_qty.text.trim());if(_item.text.trim().isEmpty||quantity==null||quantity<=0){setState(()=>_message='Enter a valid item code and quantity.');return;}try{await DatabaseService.insertTransaction(date:DateTime.now().toIso8601String().substring(0,10),itemCode:_item.text.trim(),tranx:widget.type,receive:widget.type=='IN'?quantity:0,issue:widget.type=='OUT'?quantity:0,opening:0,docNo:_doc.text.trim(),charging:_charging.text.trim(),remark:_remark.text.trim());if(mounted){setState(()=>_message='${widget.type=='IN'?'Receive':'Issue'} saved successfully.');_qty.clear();}}catch(e){if(mounted)setState(()=>_message=e.toString());}}
  @override Widget build(BuildContext context){final isReceive=widget.type=='IN';return ListView(padding:const EdgeInsets.all(16),children:[Text(isReceive?'Receive Stock':'Issue Stock',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800)),const SizedBox(height:6),Text(isReceive?'Record goods received into the estate store.':'Record stock issued to operations.'),const SizedBox(height:18),TextField(controller:_item,decoration:const InputDecoration(labelText:'Item Code',prefixIcon:Icon(Icons.inventory_2),border:OutlineInputBorder())),const SizedBox(height:12),TextField(controller:_qty,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:isReceive?'Quantity Receive':'Quantity Issue',prefixIcon:const Icon(Icons.scale),border:const OutlineInputBorder())),const SizedBox(height:12),TextField(controller:_doc,decoration:const InputDecoration(labelText:'Document No',prefixIcon:Icon(Icons.description_outlined),border:OutlineInputBorder())),const SizedBox(height:12),TextField(controller:_charging,decoration:const InputDecoration(labelText:'Charging / Location',prefixIcon:Icon(Icons.place_outlined),border:OutlineInputBorder())),const SizedBox(height:12),TextField(controller:_remark,maxLines:3,decoration:const InputDecoration(labelText:'Remark',border:OutlineInputBorder())),const SizedBox(height:16),FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save),label:Text('SAVE ${isReceive?'RECEIVE':'ISSUE'}')),if(_message.isNotEmpty)...[const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(_message)))]]);}
}
class _MoreView extends StatelessWidget { const _MoreView(); void _open(BuildContext c,Widget p)=>Navigator.of(c).push(MaterialPageRoute(builder:(_)=>p)); @override Widget build(BuildContext context)=>ListView(children:[const Padding(padding:EdgeInsets.fromLTRB(16,18,16,8),child:Text('Modules',style:TextStyle(fontSize:25,fontWeight:FontWeight.w800))),ListTile(leading:const Icon(Icons.receipt_long,color:_lime),title:const Text('Bin Card'),trailing:const Icon(Icons.chevron_right),onTap:()=>_open(context,const BinCardPage())),ListTile(leading:const Icon(Icons.fact_check,color:_lime),title:const Text('Stock Take'),trailing:const Icon(Icons.chevron_right),onTap:()=>_open(context,const StockTakePage())),ListTile(leading:const Icon(Icons.local_gas_station,color:_lime),title:const Text('Fuel'),trailing:const Icon(Icons.chevron_right),onTap:()=>_open(context,const FuelPage())),ListTile(leading:const Icon(Icons.eco,color:_lime),title:const Text('Fertilizer'),trailing:const Icon(Icons.chevron_right),onTap:()=>_open(context,const FertilizerPage())),ListTile(leading:const Icon(Icons.assessment,color:_lime),title:const Text('Reports'),trailing:const Icon(Icons.chevron_right),onTap:()=>_open(context,const ReportsPage())),ListTile(leading:const Icon(Icons.settings,color:_lime),title:const Text('Settings'),trailing:const Icon(Icons.chevron_right),onTap:()=>_open(context,const SettingsPage()))]); }
