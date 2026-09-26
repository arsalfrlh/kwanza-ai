import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko/models/ai_message.dart';
import 'package:toko/models/conversation.dart';
import 'package:toko/models/user.dart';

class ApiService {
  final dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8000/api",
    sendTimeout: Duration(seconds: 600),
    connectTimeout: Duration(seconds: 600),
    receiveTimeout: Duration(seconds: 600)
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

  Future<Map<String, dynamic>> login(String email, String password)async{
    try{
      final response = await dio.post("/login", data: {
        "email": email,
        "password": password
      });

      if(response.statusCode == 200 && response.data['success'] == true){
        final key = await SharedPreferences.getInstance();
        await key.setString("token", response.data['data']['token']);
        await key.setBool("statusLogin", true);
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
        await key.setBool("statusLogin", true);
      }
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message'].toString() ?? "Terjadi kesalahan"
      };
    }
  }

  Future<Map<String, dynamic>> authBroadcasting(String? socketId, String channelName)async{
    try{
      final response = await dio.post("/broadcasting/auth", data: {
        "socket_id": socketId,
        "channel_name": channelName
      });

      return response.data;
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<User> getCurrentUser()async{
    try{
      final response = await dio.get("/user");
      return User.fromJson(response.data);
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<List<Conversation>> getAllConversation()async{
    try{
      final response = await dio.get("/conversation");
      return(response.data['data'] as List).map((item) => Conversation.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> createConversation(String title)async{
    try{
      final response = await dio.put("/conversation/$title");
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message'].toString() ?? "Terjadi kesalahan"
      };
    }
  }

  Future<List<AiMessage>> getAllMessage(int conversationId)async{
    try{
      final response = await dio.get("/conversation/$conversationId");
      return(response.data['data'] as List).map((item) => AiMessage.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> sendMessage(int conversationId, String message, List<String> filePaths)async{
    try{
      List<MultipartFile> uploadFiles = [];
      for(var file in filePaths){
        uploadFiles.add(await MultipartFile.fromFile(file));
      }
      final request = FormData.fromMap({
        "conversation_id": conversationId,
        "message": message,
        if(filePaths.isNotEmpty)
        "uploaded_files[]": uploadFiles
      });

      final response = await dio.post("/conversation", data: request);
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message'].toString() ?? 'Terjadi kesalahan'
      };
    }
  }
}