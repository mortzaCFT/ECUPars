import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:treenode/services/api/HttpService.dart';

class LoginController extends GetxController {
  var isLoggedIn = false.obs;
  var isOtpValid = false.obs;
  var sessionId = ''.obs;
  var isOtpSent = false.obs;

  final HttpService httpService = HttpService();
  final GetStorage storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    sessionId.value = storage.read('session_id') ?? '';
    isLoggedIn.value = storage.read('is_logged_in') ?? false;
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await httpService.login(username, password);
      if (response['login_status'] == 'pending') {
        sessionId.value = response['session_id'];
        isOtpSent.value = true;
        storage.write('session_id', sessionId.value);
      } else {
        isOtpSent.value = false;
      }
    } catch (e) {
      isOtpSent.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      bool result = await httpService.verifyOtp(int.parse(otp));
      if (result) {
        isLoggedIn.value = true;
        isOtpValid.value = true;
        storage.write('is_logged_in', true);
        storage.write('access_token', httpService.accessToken ?? '');
        storage.write('refresh_token', httpService.refreshToken ?? '');
        storage.write(
            'access_token_expiry', httpService.accessTokenExpiry?.toIso8601String() ?? '');
      } else {
        isOtpValid.value = false;
      }
    } catch (e) {
      isOtpValid.value = false;
    }
  }

  void logout() {
    storage.erase();
    isLoggedIn.value = false;
    isOtpValid.value = false;
    isOtpSent.value = false;
    sessionId.value = '';
  }

  bool isAccessTokenExpired() {
    final expiryString = storage.read('access_token_expiry');
    if (expiryString == null) return true;
    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  String? getAccessToken() => storage.read('access_token');
  String? getRefreshToken() => storage.read('refresh_token');

  //login screen components:
  var isUsernameValid = false.obs;
  var isPasswordValid = false.obs;

  void updateUsername(String username) {
    isUsernameValid.value = username.isNotEmpty;
  }

  void updatePassword(String password) {
    isPasswordValid.value = password.isNotEmpty;
  }

  bool isFormValid() {
    return isUsernameValid.value && isPasswordValid.value;
  }
}
