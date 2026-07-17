import 'dart:async';
import 'dart:convert';

import 'package:toko/services/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketService {
  static final _instance = WebsocketService._internal();
  factory WebsocketService(){
    return _instance;
  }
  WebsocketService._internal();

  final _apiService = ApiService();
  final _streamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get websocketEvent => _streamController.stream;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _socketId;
  bool _isConnected = false;
  int? _chatRoomId;

  void connect(){
    if(_isConnected) return;
    final wsUrl = "ws://10.0.2.2:8080/app/64gyhmwfyqqro8ragyzr";
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _subscription = _channel?.stream.listen((event){
      final data = jsonDecode(event);
      print("Data Event: $data");

      if(data['event'] == "pusher:connection_established"){
        _isConnected = true;
        final socketData = jsonDecode(data['data']);
        _socketId = socketData['socket_id'];
      }

      if(data['event'] == "pusher:ping"){
        _channel?.sink.add(jsonEncode({
          "event": "pusher:pong",
          "data": {}
        }));
      }

      if(data['event'] == "pusher_internal:subscription_succeeded"){
        print("Berhasil Subscribe: ${data['channel']}");
      }

      if(data['event'] == "chatUpdate"){
        final payload = jsonDecode(data['data']);
        _streamController.add({
          "type": "message",
          "data": payload
        });
      }

      if(data['event'] == "aiResponse"){
        final payload = jsonDecode(data['data']);
        _streamController.add({
          "type": "response-ai",
          "data": payload
        });
      }

      if(data['event'] == "toolsUpdate"){
        final payload = jsonDecode(data['data']);
        _streamController.add({
          "type": "tool-calling",
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

  void _reconnect()async{
    connect();
    Future.delayed(Duration(seconds: 3), ()async{
      if(_chatRoomId != null){
        await subscribeRoom(_chatRoomId!);
      }
    });
  }

  Future<void> subscribeRoom(int chatRoomId)async{
    _chatRoomId = chatRoomId;
    final response = await _apiService.authBroadcast(_socketId, "private-chat-room-$chatRoomId");
    _channel?.sink.add(jsonEncode({
      "event": "pusher:subscribe",
      "data": {
        "channel": "private-chat-room-$chatRoomId",
        "auth": response['auth']
      }
    }));
  }

  void unsubscribeRoom(){
    if(_chatRoomId != null){
      _channel?.sink.add(jsonEncode({
        "event": "pusher:unsubscribe",
        "data": {
          "channel": "private-chat-room-$_chatRoomId",
        }
      }));
    }
    _chatRoomId = null;
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