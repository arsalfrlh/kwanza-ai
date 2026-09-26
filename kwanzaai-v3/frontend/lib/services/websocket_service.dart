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
  final _streamContoller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get websocketEvent => _streamContoller.stream;
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _socketId;
  bool _isConnected = false;
  int? _conversationId;
  
  void connect(){
    if(_isConnected) return;
    final wsUrl = "ws://10.0.2.2:8080/app/yoja46pkbvl4yjb51g7q";
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

      if(data['event'] == "conversationUpdate"){
        final payload = jsonDecode(data['data']);
        _streamContoller.add({
          "type": "conversation",
          "data": payload
        });
      }

      if(data['event'] == "streamingUpdate"){
        final payload = jsonDecode(data['data']);
        _streamContoller.add({
          "type": "streaming-ai",
          "data": payload
        });
      }

      if(data['event'] == "toolUpdate"){
        final payload = jsonDecode(data['data']);
        _streamContoller.add({
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

  void _reconnect(){
    connect();
    Future.delayed(Duration(seconds: 5),()async{
      if(_conversationId != null){
        await subscribeConversation(_conversationId!);
      }
    });
  }

  Future<void> subscribeConversation(int conversationId)async{
    _conversationId = conversationId;
    final response = await _apiService.authBroadcasting(_socketId, "private-conversation-room-$conversationId");
    _channel?.sink.add(jsonEncode({
      "event": "pusher:subscribe",
      "data": {
        "channel": "private-conversation-room-$conversationId",
        "auth": response['auth']
      }
    }));
  }

  void unsubscribeConversation(){
    _channel?.sink.add(jsonEncode({
      "event": "pusher:unsubscribe",
      "data": {
        "channel": "private-conversation-room-$_conversationId"
      }
    }));
    _conversationId = null;
  }

  void disconnect(){
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _conversationId = null;
    _socketId = null;
  }
}