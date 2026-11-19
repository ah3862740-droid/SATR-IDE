import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

void main() => runApp(const SatrApp());

const bg = Color(0xFF06130E), panel = Color(0xFF0C1D14), line = Color(0xFF1D402D);
const green = Color(0xFF43D995), muted = Color(0xFF91AA9A);

class SatrApp extends StatelessWidget {
  const SatrApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'SATR IDE',
    theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: green, surface: panel),
      appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: line)))),
    home: const Workspace());
}

class Workspace extends StatefulWidget {
  const Workspace({super.key});
  @override State<Workspace> createState() => _WorkspaceState();
}
class _WorkspaceState extends State<Workspace> {
  int tab = 0;
  final code = TextEditingController(text: 'اطبع("أهلاً بيك في SATR")\nخلي الاسم = "الحاكم"\nاطبع(الاسم)\n\nكرر 3:\n    اطبع("لغة الحاكم بتكبر كل يوم")');
  final output = StringBuffer();
  final terminal = Terminal(maxLines: 1000);
  final terminalController = TerminalController();
  String result = 'جاهز. اضغط تشغيل لتنفيذ مثال HAKEM.';
  final filename = TextEditingController(text: 'main.hak');

  void runHakem() {
    final vars = <String, String>{}; final out = <String>[];
    final lines = code.text.split('\n');
    try {
      for (var i=0; i<lines.length; i++) {
        final s=lines[i].trim();
        if (s.isEmpty || s.startsWith('#')) continue;
        final p=RegExp(r'^اطبع\((.*)\)$').firstMatch(s);
        if (p!=null) { out.add(_value(p.group(1)!,vars)); continue; }
        final v=RegExp(r'^خلي\s+([\w\u0600-\u06FF]+)\s*=\s*(.+)$').firstMatch(s);
        if (v!=null) { vars[v.group(1)!]=_value(v.group(2)!,vars); continue; }
        final r=RegExp(r'^كرر\s+(\d+)\s*:').firstMatch(s);
        if (r!=null) {
          final body=<String>[];
          while(i+1<lines.length && RegExp(r'^\s{4,}').hasMatch(lines[i+1])) { body.add(lines[++i].trim()); }
          for(var n=0;n<int.parse(r.group(1)!).clamp(0,100);n++) {
            for(final b in body) { final q=RegExp(r'^اطبع\((.*)\)$').firstMatch(b); if(q!=null) out.add(_value(q.group(1)!,vars)); }
          }
          continue;
        }
        throw FormatException('تعليمة غير مدعومة في السطر ${i+1}: $s');
      }
      setState(()=>result=out.join('\n').isEmpty?'تم التنفيذ بدون مخرجات.':out.join('\n'));
    } catch(e) { setState(()=>result='خطأ: $e'); }
  }
  String _value(String s, Map<String,String> vars) {
    s=s.trim(); if(vars.containsKey(s)) return vars[s]!;
    if((s.startsWith('"')&&s.endsWith('"'))||(s.startsWith("'")&&s.endsWith("'"))) return s.substring(1,s.length-1);
    return s;
  }
  Future<void> saveCode() async {
    // Portable baseline: export through the platform share/save workflow is a planned adapter.
    setState(()=>result='تم تجهيز ${filename.text}. للحفظ كملف على كل منصة نضيف منتقي الملفات في مرحلة التكامل.');
  }
  @override Widget build(BuildContext context) {
    final wide=MediaQuery.sizeOf(context).width>850;
    return Scaffold(
      appBar: AppBar(title: const Row(children:[Icon(Icons.terminal,color:green),SizedBox(width:10),Text('SATR',style:TextStyle(letterSpacing:5,fontWeight:FontWeight.bold)),SizedBox(width:10),Text('IDE',style:TextStyle(color:muted,fontSize:13))]),
        actions:[Padding(padding:const EdgeInsets.only(right:14),child:Center(child:Text('HAKEM 0.3',style:TextStyle(color:green))))]),
      body: Row(children:[
        if(wide) NavigationRail(backgroundColor:bg,selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
          destinations:const [NavigationRailDestination(icon:Icon(Icons.code),label:Text('المحرر')),NavigationRailDestination(icon:Icon(Icons.terminal),label:Text('الطرفية')),NavigationRailDestination(icon:Icon(Icons.school),label:Text('التعلّم')),NavigationRailDestination(icon:Icon(Icons.folder),label:Text('المشاريع'))]),
        Expanded(child: Column(children:[
          if(!wide) _mobileTabs(),
          Expanded(child: tab==0?_editor():tab==1?_terminal():tab==2?_learn():_projects())
        ]))
      ]));
  }
  Widget _mobileTabs()=>SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[
    _tabButton('المحرر',0,Icons.code),_tabButton('الطرفية',1,Icons.terminal),_tabButton('التعلّم',2,Icons.school),_tabButton('المشاريع',3,Icons.folder)
  ]));
  Widget _tabButton(String label,int i,IconData icon)=>TextButton.icon(onPressed:()=>setState(()=>tab=i),icon:Icon(icon,color:tab==i?green:muted),label:Text(label,style:TextStyle(color:tab==i?green:muted)));
  Widget _editor()=>Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    const Text('اكتب فكرتك وشغّلها',style:TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
    const Text('بيئة تطوير لغة الحاكم ومشروعاتك',style:TextStyle(color:muted)),
    const SizedBox(height:12),
    Row(children:[Expanded(child:TextField(controller:filename,decoration:const InputDecoration(prefixIcon:Icon(Icons.description),isDense:true))),const SizedBox(width:8),IconButton(onPressed:saveCode,icon:const Icon(Icons.save,color:green)),FilledButton.icon(onPressed:runHakem,icon:const Icon(Icons.play_arrow),label:const Text('تشغيل'))]),
    const SizedBox(height:10),
    Expanded(child:Container(decoration:BoxDecoration(color:panel,border:Border.all(color:line),borderRadius:BorderRadius.circular(16)),padding:const EdgeInsets.all(12),
      child:TextField(controller:code,maxLines:null,expands:true,keyboardType:TextInputType.multiline,style:const TextStyle(fontFamily:'monospace',fontSize:15,height:1.65,color:Color(0xFFD8F1E1)),decoration:const InputDecoration(border:InputBorder.none,hintText:'اكتب كود HAKEM هنا...',alignLabelWithHint:true)))),
    const SizedBox(height:10),
    Container(height:130,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:panel,border:Border.all(color:line),borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('النتيجة',style:TextStyle(color:green,fontWeight:FontWeight.bold)),const Divider(color:line),Expanded(child:SingleChildScrollView(child:Text(result,style:const TextStyle(fontFamily:'monospace'))))]))
  ]));
  Widget _terminal()=>Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    const Text('طرفية SATR',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
    const Text('طرفية نظام الكمبيوتر أوامر حقيقية على سطح المكتب؛ على الهاتف والطرفيات المقيدة نوفر وحدة أوامر داخلية.',style:TextStyle(color:muted)),
    const SizedBox(height:10),Expanded(child:Container(decoration:BoxDecoration(color:Colors.black,border:Border.all(color:line),borderRadius:BorderRadius.circular(14)),child:TerminalView(terminal,controller:terminalController))),
    const SizedBox(height:8),
    FilledButton(onPressed:()=>_writeTerminal('SATR: الطرفية التفاعلية جاهزة. دعم shell النظام سيُفعّل عبر موائمات المنصة.'),child:const Text('اختبار الطرفية'))
  ]));
  void _writeTerminal(String s){terminal.write('\r\n\x1b[32m$s\x1b[0m\r\n');}
  Widget _learn()=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('تعلّم لغة الحاكم',style:TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
    _lesson('١. الطباعة','اطبع("مرحباً بالعالم")'),
    _lesson('٢. المتغيرات','خلي الاسم = "الحاكم"\\nاطبع(الاسم)'),
    _lesson('٣. التكرار','كرر 3:\\n    اطبع("أهلاً")'),
    const Text('المفسّر المضمّن حاليًا تجريبي ويدعم الطباعة والمتغيرات والتكرار البسيط. الشروط والدوال والقوائم ستُضاف بعد ربط محرك HAKEM المرجعي.',style:TextStyle(color:muted,height:1.6))
  ]);
  Widget _lesson(String title,String sample)=>Card(color:panel,child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:green,fontWeight:FontWeight.bold)),const SizedBox(height:8),SelectableText(sample,style:const TextStyle(fontFamily:'monospace'))])));
  Widget _projects()=>const Center(child:Padding(padding:EdgeInsets.all(24),child:Text('مساحة المشاريع\\nقريبًا: إنشاء مشروع، فتح مجلد، إدارة الملفات وحفظها محليًا.',textAlign:TextAlign.center,style:TextStyle(fontSize:20,height:1.8))));
}
