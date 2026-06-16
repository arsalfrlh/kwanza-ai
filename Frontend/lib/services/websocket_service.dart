import 'dart:async';
import 'dart:convert';

import 'package:toko/services/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketService {
  static final WebsocketService _instance = WebsocketService._internal();
  factory WebsocketService(){
    return _instance;
  }
  WebsocketService._internal();

  final _apiService = ApiService();
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _streamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get streamEvent => _streamController.stream;
  bool _isConnected = false;
  String? socketId;
  int? _chatRoomId;

  void connect(){
    if(_isConnected) return;
    final wsUrl = "ws://192.168.0.104:8080/app/rpn6wtrxr5pitlysuhoa";
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _subscription = _channel?.stream.listen((event){
      final data = jsonDecode(event);
      print("Data Event: $data");

      if(data['event'] == "pusher:connection_established"){
        _isConnected = true;
        final socketData = jsonDecode(data['data']);
        socketId = socketData['socket_id'];
      }

      if(data['event'] == "pusher:ping"){
        _channel?.sink.add(jsonEncode({
          "event": "pusher:pong",
          "data": {}
        }));
      }

      if(data['event'] == "pusher_internal:subscription_succeeded"){
        print("Berhasil Connect");
      }

      if(data['event'] == "chatUpdate"){
        final payload = jsonDecode(data['data']);
        _streamController.add({
          "type": "message",
          "data": payload
        });
      }

      if(data['event'] == "chatAiUpdate"){
        final payload = jsonDecode(data['data']);
        _streamController.add({
          "type": "ai-response",
          "data": payload
        });
      }
    },
    onDone: () {
      _isConnected = false;
      _reconnect();
    },
    onError: (e){
      _isConnected = false;
      _reconnect();
    });
  }

  Future<void>subscribeRoom(int chatRoomId)async{
    _chatRoomId = chatRoomId;
    final response = await _apiService.authBroadcast("private-chat-room-$chatRoomId", socketId);
    _channel?.sink.add(jsonEncode({
      "event": "pusher:subscribe",
      "data": {
        "channel": "private-chat-room-$chatRoomId",
        "auth": response['auth']
      }
    }));
  }

  Future<void>unsubscribeRoom(int chatRoomId)async{
    _channel?.sink.add(jsonEncode({
      "event": "pusher:unsubscribe",
      "data": {
        "channel": "private-chat-room-$chatRoomId",
      }
    }));
    _chatRoomId = null;
  }

  void _reconnect()async{
    connect();
    Future.delayed(Duration(seconds: 5), ()async{
      if(_chatRoomId != null){
        await subscribeRoom(_chatRoomId!);
      }
    });
  }

  void disconnect(){
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _chatRoomId = null;
  }
}