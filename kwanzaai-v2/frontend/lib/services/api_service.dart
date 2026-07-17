import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko/models/chat_room.dart';
import 'package:toko/models/message.dart';
import 'package:toko/models/user.dart';

class ApiService {
  final dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8000/api",
    sendTimeout: Duration(seconds: 300),
    connectTimeout: Duration(seconds: 300),
    receiveTimeout: Duration(seconds: 300)
  ));

  ApiService(){
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async{
        final key = await SharedPreferences.getInstance();
        final token = key.getString("token");

        if(token != null){
          options.headers['Authorization'] = "Bearer $token";
        }
        handler.next(options);
      },
    ));
  }

  Future<User> getUser()async{
    try{
      final response = await dio.get("/user");
      return User.fromJson(response.data);
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password)async{
    try{
      final response = await dio.post("/login", data: {
        "email": email,
        "password": password
      });

      if(response.statusCode == 200 && response.data['success'] == true){
        final key = await SharedPreferences.getInstance();
        await key.setString("token", response.data['data']['token']);
        await key.setBool('statusLogin', true);
      }

      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message'].toString() ?? "Terjadi kesalahan"
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password)async{
    try{
      final response = await dio.post("/register", data: {
        "name": name,
        "email": email,
        "password": password
      });

      if(response.statusCode == 201 && response.data['success'] == true){
        final key = await SharedPreferences.getInstance();
        await key.setString("token", response.data['data']['token']);
        await key.setBool('statusLogin', true);
      }

      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message'].toString() ?? "Terjadi kesalahan"
      };
    }
  }

  Future<Map<String, dynamic>> authBroadcast(String? socketId, String? channelName)async{
    try{
      final response = await dio.post("/broadcasting/auth", data: {
        "channel_name": channelName,
        "socket_id": socketId
      });

      return response.data;
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<List<ChatRoom>> getAllChatRoom()async{
    try{
      final response = await dio.get("/message");
      return (response.data['data'] as List).map((item) => ChatRoom.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> createChatRoom(String title)async{
    try{
      final response = await dio.put("/message/$title");
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message'].toString() ?? "Terjadi kesalahan"
      };
    }
  }

  Future<List<Message>> getAllMessage(int chatRoomId)async{
    try{
      final response = await dio.get("/message/$chatRoomId");
      return (response.data['data'] as List).map((item) => Message.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> sendMessage(int chatRoomId, String message, List<String> documentPaths, List<String> imagePaths)async{
    try{
      List<MultipartFile> documentFiles = [];
      List<MultipartFile> imageFiles = [];
      if(documentPaths.isNotEmpty){
        for(var document in documentPaths){
          documentFiles.add(await MultipartFile.fromFile(document));
        }
      }
      if(imagePaths.isNotEmpty){
        for(var image in imagePaths){
          imageFiles.add(await MultipartFile.fromFile(image));
        }
      }

      final request = FormData.fromMap({
        "chat_room_id": chatRoomId,
        "message": message,
        if(documentPaths.isNotEmpty)
        "documents[]": documentFiles,
        if(imagePaths.isNotEmpty)
        "images[]": imageFiles
      });
      final response = await dio.post("/message", data: request);
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message'].toString() ?? "Terjadi kesalahan"
      };
    }
  }
}