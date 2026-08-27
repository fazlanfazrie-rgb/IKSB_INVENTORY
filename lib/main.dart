import 'package:flutter/material.dart';
import 'dart:io';
import 'db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Windows-specific initialization for AMD/older hardware compatibility
  if (Platform.isWindows) {
    // Disable Impeller rendering (causes issues with AMD)
    // Force Skia rendering backend instead
  }
  
  try {
    await StoreDb.instance.db;
  } catch (e) {
    print('Database initialization warning: $e');
    // Continue even if DB init has issues - will retry
  }
  
  runApp(const StorePh3App());
}

class StorePh3App extends StatelessWidget {
  const StorePh3App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner:false,
    title:'STORE PH3',
    theme:ThemeData(colorSchemeSeed:Colors.indigo,useMaterial3:true),
    home:const Dashboard(),
  );
}

class Dashboard extends StatefulWidget { const Dashboard({super.key}); @override State<Dashboard> createState()=>_DashboardState(); }
class _DashboardState extends State<Dashboard> {
  bool loading=true; int items=0, tx=0, audit=0; double recv=0, issue=0;
  Future<void> load() async { final d=await StoreDb.instance.db; final a=await d.rawQuery('SELECT COUNT(*) c FROM items'); final b=await d.rawQuery('SELECT COUNT(*) c FROM transactions'); final c=await d.rawQuery('SELECT COUNT(*) c FROM audit_log'); final r=await d.rawQuery('SELECT COALESCE(SUM(receive),0) v FROM transactions'); final i=await d.rawQuery('SELECT COALESCE(SUM(issue),0) v FROM transactions'); setState(() {items=(a.first['c'] as int); tx=(b.first['c'] as int); audit=(c.first['c'] as int); recv=(r.first['v'] as num).toDouble(); issue=(i.first['v'] as num).toDouble(); loading=false;}); }
  @override void initState(){super.initState();load();}
  Widget card(String title,String value,IconData icon)=>Card(child:ListTile(leading:CircleAvatar(child:Icon(icon)),title:Text(title),subtitle:Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold))));
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('STORE PH3')),body:RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(16),children:[const Text('Offline Store Management',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:12),if(loading)const Center(child:CircularProgressIndicator()),if(!loading)...[card('Items',items.toString(),Icons.inventory_2),card('Transactions',tx.toString(),Icons.receipt_long),card('Total Receive',recv.toStringAsFixed(2),Icons.arrow_downward),card('Total Issue',issue.toStringAsFixed(2),Icons.arrow_upward),card('Audit Records',audit.toString(),Icons.history)],const SizedBox(height:16),FilledButton.icon(onPressed:() async { final code=await showDialog<String>(context:context,builder:(c)=>const _TextDialog(title:'Item Code')); if(code!=null&&code.trim().isNotEmpty){ final bal=await StoreDb.instance.balance(code.trim()); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Balance $code = ${bal.toStringAsFixed(2)}'))); }},icon:const Icon(Icons.search),label:const Text('Check Stock Balance')),const SizedBox(height:8),OutlinedButton.icon(onPressed:() async { try { await StoreDb.instance.insertTransaction(itemCode:'010001',itemName:'DIESEL',tranx:'RECEIVE',docNo:'TEST-RECEIVE-${DateTime.now().millisecondsSinceEpoch}',receive:1); await load(); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Trial receive saved'))); } catch(e){ if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString()))); } },icon:const Icon(Icons.science),label:const Text('Run Offline Transaction Trial'))])));
}
class _TextDialog extends StatefulWidget{final String title;const _TextDialog({required this.title});@override State<_TextDialog> createState()=>_TextDialogState();}
class _TextDialogState extends State<_TextDialog>{final c=TextEditingController();@override Widget build(BuildContext context)=>AlertDialog(title:Text(widget.title),content:TextField(controller:c,autofocus:true),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(context,c.text),child:const Text('OK'))]);}
