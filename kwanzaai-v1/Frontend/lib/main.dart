import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko/viewmodels/auth_viewmodel.dart';
import 'package:toko/viewmodels/message_viewmodel.dart';
import 'package:toko/views/auth/login_view.dart';
import 'package:toko/views/message/chat_view.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final key = await SharedPreferences.getInstance();
  final status = key.getBool('statusLogin') ?? false;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthViewmodel()),
    ChangeNotifierProvider(create: (_) => MessageViewmodel())
  ], child: MyApp(status: status,),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.status});
  final bool status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: status ? ChatView() : LoginView(),
    );
  }
}

//php artisan serve --host=0.0.0.0 --port=8000
// {'Content-Type': 'application/json'}
// http://192.168.1.245:8000
//192.168.1.245 cek dengan ipconfig di cmd
//http://10.0.2.2:8000/api khusus emulator

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }