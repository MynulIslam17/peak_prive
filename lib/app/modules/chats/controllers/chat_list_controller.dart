import 'package:get/get.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/modules/chats/models/chat_list_model.dart';
import '../../../core/constants/api_urls.dart';
import '../../../data/services/network_caller.dart';
import '../../../data/services/socket/socket_service.dart';

class ChatListController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  List<ChatListModel> _chatList = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChatListModel> get chatList => _chatList;

  @override
  void onInit() {
    super.onInit();
    fetchChatList();
  }

  Future<void> fetchChatList() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrls.allChatList);

      if (response.isSuccess) {
        _chatList = ChatListModel.fromRestJson(response.body!);
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load chats';
      }
    } finally {
      _isLoading = false;
      update();
    }
  }

  // AuthController  will call after socket service ready
  void setSocketListener() {
    if (!Get.isRegistered<SocketService>()) return;

    Get.find<SocketService>().helper.onChatListUpdated = (data) {
      _chatList = ChatListModel.fromSocketJson(data);
      update();
    };
  }
}