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
