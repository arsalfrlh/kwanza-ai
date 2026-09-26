import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toko/models/ai_message.dart';
import 'package:toko/models/conversation.dart';
import 'package:toko/models/user.dart';
import 'package:toko/services/api_service.dart';
import 'package:toko/services/websocket_service.dart';

class ConversationViewmodel extends ChangeNotifier {
  final _apiService = ApiService();
  final _websocketService = WebsocketService();
  StreamSubscription? _subscription;
  bool isLoading = false;
  bool isAction = false;
  List<Conversation> conversationList = [];
  List<AiMessage> messageList = [];
  User? currentUser;
  int? conversationId;
  bool isTyping = false;
  String? toolName;

  Future<void> selectConversation(int? roomId)async{
    if(roomId != null && roomId == conversationId) return;
    messageList = [];
    notifyListeners();
    unsubscribeRoom();
    if(roomId == null){
      conversationId = null;
    }else{
      conversationId = roomId;
      await fetchMessage();
    }
    notifyListeners();
  }

  Future<void> fetchConversation()async{
    conversationList = await _apiService.getAllConversation();
    currentUser = await _apiService.getCurrentUser();
    notifyListeners();
  }

  Future<void> createConversation(String title)async{
    final response = await _apiService.createConversation(title);
    if(response['success'] == true){
      final conversation = Conversation.fromJson(response['data']);
      conversationId = conversation.id;
      conversationList.add(conversation);
      await fetchMessage();
    }
    notifyListeners();
  }

  Future<void> fetchMessage()async{
    isLoading = true;
    messageList = [];
    notifyListeners();
    if(conversationId != null){
      messageList = await _apiService.getAllMessage(conversationId!);
      await _websocketService.subscribeConversation(conversationId!);
      _subscription?.cancel();
      _subscription = _websocketService.websocketEvent.listen((event) => _handleEvent(event));
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String message, List<String> filePaths)async{
    isAction = true;
    notifyListeners();
    if(conversationId == null){
      await createConversation(message);
    }
    if(conversationId != null){
      await _apiService.sendMessage(conversationId!, message, filePaths);
    }
    isAction = false;
    notifyListeners();
  }

  void unsubscribeRoom(){
    _websocketService.unsubscribeConversation();
    conversationId = null;
    isAction = false;
    isLoading = false;
    isTyping = false;
    toolName = null;
    _subscription?.cancel;
    notifyListeners();
  }

  void _handleEvent(Map<String, dynamic> event){
    final type = event['type'];
    final data = Map<String, dynamic>.from(event['data']);

    if(type == "conversation"){
      _handleConversation(data);
    }else if(type == "streaming-ai"){
      _handleStreaming(data);
    }else if(type == "tool-calling"){
      _handleToolCalling(data);
    }
  }

  void _handleConversation(Map<String, dynamic> data){
    final action = data['action'];
    final message = AiMessage.fromJson(data['message']);

    if(action == "create"){
      if(message.role == "assistant"){
        final index = messageList.indexWhere((m) => m.id == null);
        if(index != -1){
          messageList[index] = message;
        }else{
          messageList.add(message);
        }
      }else{
        messageList.add(message);
      }
    }
    notifyListeners();
  }

  void _handleStreaming(Map<String, dynamic> data){
    if(!messageList.any((m) => m.id == null)){
      messageList.add(AiMessage(role: "assistant", message: "", documents: [], images: [], isStreaming: true));
    }
    final index = messageList.indexWhere((m) => m.id == null);
    if(index != -1){
      messageList[index].message += data['content'];
    }

    if(data['is_done'] == true){
      isTyping = false;
    }else{
      isTyping = true;
    }
    notifyListeners();
  }

  void _handleToolCalling(Map<String, dynamic> data){
    if(toolName == data['tool_name']) return;
    toolName = data['tool_name'];
    notifyListeners();
  }
}