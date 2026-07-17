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
  List<ChatRoom> chatRoomList = [];
  List<Message> messageList = [];
  User? currentUser;
  int? chatRoomId;
  StreamSubscription? _streamData;
  bool isTyping = false;

  Future<void> selectedRoom(int? roomId)async{
    if(roomId == null){
      if(chatRoomId != null){
        _websocketService.unsubscribeRoom(chatRoomId!);
      }
      messageList = [];
      chatRoomId = null;
    }else{
      if(chatRoomId != null && chatRoomId != roomId){
        _websocketService.unsubscribeRoom(chatRoomId!);
      }
      chatRoomId = roomId;
      await fetchMessage();
    }
    notifyListeners();
  }

  Future<void> fetchChatRoom()async{
    currentUser = await _apiService.currentUser();
    chatRoomList = await _apiService.getAllChatRoom();
    notifyListeners();
  }

  Future<void> createNewRoom(String roomName)async{
    messageList = [];
    notifyListeners();
    final response = await _apiService.createNewRoom(roomName);
    if(response['success'] == true){
      chatRoomList.add(ChatRoom.fromJson(response['data']));
      chatRoomId = response['data']['id'];
      await fetchMessage();
    }
    notifyListeners();
  }

  Future<void> fetchMessage()async{
    isLoading = true;
    messageList = [];
    notifyListeners();
    if(chatRoomId != null){
      messageList = await _apiService.getAllMessage(chatRoomId!);
      _streamData?.cancel();
      await _websocketService.subscribeRoom(chatRoomId!);
      _streamData = _websocketService.streamEvent.listen((data){
        if(data['type'] == "message"){
          _handleMessage(Map<String, dynamic>.from(data['data']));
        }else if(data['type'] == "ai-response"){
          _handleResponseAi(Map<String, dynamic>.from(data['data']));
        }
      });
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String message)async{
    isAction = true;
    notifyListeners();
    if(chatRoomId == null){
      await createNewRoom(message);
    }
    if(chatRoomId != null){
      await _apiService.sendMessage(chatRoomId!, message);
    }
    isAction = false;
    notifyListeners();
  }

  void _handleMessage(Map<String, dynamic> data){
    final message = Message.fromJson(data['message']);
    if(message.role == "user"){
      final index = messageList.indexWhere((m) => m.id == message.id);
      if(index != -1){
        messageList[index] = message;
      }else{
        messageList.add(message);
      }
    }else if(message.role == "assistant"){
      final index = messageList.indexWhere((m) => m.id == 0);
      if(index != -1){
        messageList[index] = message;
      }
    }
    notifyListeners();
  }

  void _handleResponseAi(Map<String, dynamic> data){
    if(!messageList.any((m) => m.id == 0)){
      isTyping = true;
      messageList.add(Message(id: 0, role: "assistant", message: "", user: null, isStreaming: true));
    }
    final index = messageList.indexWhere((m) => m.id == 0);
    if(index != -1){
      messageList[index].message += data['chunk']; 
        if(data['is_done'] == true){
          isTyping = false;
          messageList[index].isStreaming = false;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if(chatRoomId != null){
      _websocketService.unsubscribeRoom(chatRoomId!);
    }
    _streamData?.cancel();
    super.dispose();
  }
}