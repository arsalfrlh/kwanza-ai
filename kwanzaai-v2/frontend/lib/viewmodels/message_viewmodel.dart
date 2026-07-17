import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toko/models/chat_room.dart';
import 'package:toko/models/message.dart';
import 'package:toko/models/user.dart';
import 'package:toko/services/api_service.dart';
import 'package:toko/services/websocket_service.dart';

class MessageViewmodel extends ChangeNotifier {
  final _apiService = ApiService();
  final _websocketService = WebsocketService();
  bool isLoading = false;
  bool isAction = false;
  int? chatRoomId;
  StreamSubscription? _subscription;
  List<ChatRoom> chatRoomList = [];
  List<Message> messageList = [];
  String? toolName;
  bool isTyping = false;
  User? currentUser;

  Future<void> selectedRoom(int? roomId)async{
    if(roomId == null){
      _websocketService.unsubscribeRoom();
      messageList = [];
      chatRoomId = null;
    }else{
      if(chatRoomId != null && chatRoomId != roomId){
        _websocketService.unsubscribeRoom();
      }
      chatRoomId = roomId;
      await fetchMessage();
    }
    notifyListeners();
  }

  Future<void> fetchChatRoom()async{
    currentUser = await _apiService.getUser();
    chatRoomList = await _apiService.getAllChatRoom();
    notifyListeners();
  }

  Future<void> createChatRoom(String title)async{
    messageList = [];
    notifyListeners();
    final response = await _apiService.createChatRoom(title);
    if(response['success'] == true){
      chatRoomList.add(ChatRoom.fromJson(response['data']));
      chatRoomId = response['data']['id'];
      await fetchMessage();
    }
    notifyListeners();
  }

  Future<void> fetchMessage()async{
    messageList = [];
    isLoading = true;
    notifyListeners();
    if(chatRoomId != null){
      messageList = await _apiService.getAllMessage(chatRoomId!);
      await _websocketService.subscribeRoom(chatRoomId!);
      _subscription?.cancel();
      _subscription = _websocketService.websocketEvent.listen((event) => _handleEvent(event));
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String message, List<String> documentPaths, List<String> imagePaths)async{
    isAction = true;
    notifyListeners();
    if(chatRoomId == null){
      await createChatRoom(message);
    }
    if(chatRoomId != null){
      await _apiService.sendMessage(chatRoomId!, message, documentPaths, imagePaths);
    }
    isAction = false;
    notifyListeners();
  }

  void _handleEvent(Map<String, dynamic> event){
    final data = event['data'];
    final type = event['type'];

    if(type == "response-ai"){
      _handleResponseAI(Map<String, dynamic>.from(data));
    }else if(type == "tool-calling"){
      _handleToolCalling(Map<String, dynamic>.from(data));
    }else if(type == "message"){
      _handleMessage(Map<String, dynamic>.from(data));
    }
  }

  void _handleResponseAI(Map<String, dynamic> data){
    if(!messageList.any((m) => m.id == 0)){
      isTyping = true;
      messageList.add(Message(id: 0, role: "assistant", message: "", isStreaming: true));
    }

    final index = messageList.indexWhere((m) => m.id == 0);
    if(index != -1){
      messageList[index].message += data['chunk'];
      if(data['done'] == true){
        isTyping = false;
        messageList[index].isStreaming = false;
      }
    }
    notifyListeners();
  }

  void _handleToolCalling(Map<String, dynamic> data){
    toolName = data['tool_name'];
    notifyListeners();
  }

  void _handleMessage(Map<String, dynamic> data){
    final action = data['action'];
    final message = Message.fromJson(data['message']);

    if(action == "create"){
      if(message.role == "assistant"){
        final index = messageList.indexWhere((m) => m.id == 0);
        if(index != -1){
          messageList[index] = message;
        }
      }else{
        messageList.add(message);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    chatRoomId = null;
    _websocketService.unsubscribeRoom();
    _subscription?.cancel();
    super.dispose();
  }
}