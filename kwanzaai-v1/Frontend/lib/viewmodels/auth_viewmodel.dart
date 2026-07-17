import 'package:flutter/material.dart';
import 'package:toko/services/api_service.dart';
import 'package:toko/services/websocket_service.dart';

class AuthViewmodel extends ChangeNotifier {
  final _apiService = ApiService();
  final _websocketService = WebsocketService();
  bool isLoading = false;
  String? message;

  Future<bool> login(String email, String password)async{
    isLoading = true;
    message = null;
    notifyListeners();
    final response = await _apiService.login(email, password);
    isLoading = false;
    message = response['message'];
    if(response['success'] == true){
      initwebsocket();
    }
    notifyListeners();
    return(response['success'] as bool);
  }

  Future<bool> register(String name, String email, String password)async{
    isLoading = true;
    message = null;
    notifyListeners();
    final response = await _apiService.register(name, email, password);
    isLoading = false;
    message = response['message'];
    if(response['success'] == true){
      initwebsocket();
    }
    notifyListeners();
    return(response['success'] as bool);
  }

  Future<void> logout()async{
    _websocketService.disconnect();
    await _apiService.logout();
  }

  void initwebsocket(){
    _websocketService.connect();
  }
}