import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/endpoint.dart';

class HttpService {
  String? sessionId;
  String? accessToken;
  String? refreshToken;
  DateTime? accessTokenExpiry;

  Future<Map<String, dynamic>> login(String username, String password) async {
    String url = '${Endpoint.httpAddress}/api/v1/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print("Login response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['login_status'] == 'pending') {
          sessionId = jsonData['session_id'];
          print("OTP sent, session id: $sessionId");
          return jsonData;
        } else {
          print("Unexpected login status: ${jsonData['login_status']}");
        }
      } else {
        print("Login failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during login request: $e");
    }
    return {};
  }

  Future<bool> verifyOtp(int otp) async {
    if (sessionId == null) {
      print("Session ID is required");
      return false;
    }

    String url = '${Endpoint.httpAddress}/api/v1/verify_otp';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'session_id': sessionId!,
          'otp': otp,
        }),
      );

      print("OTP verification response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['login_status'] == 'success') {
          accessToken = jsonData['access_token'];
          refreshToken = jsonData['refresh_token'];
          accessTokenExpiry = DateTime.now().add(Duration(minutes: 30));
          print("OTP verification successful");
          return true;
        } else {
          print("Unexpected response: ${jsonData['login_status']}");
        }
      } else {
        print("OTP verification failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during OTP verification: $e");
    }
    return false;
  }

  Future<bool> refreshAccessToken() async {
    if (refreshToken == null) {
      print("Refresh token not available");
      return false;
    }

    String url = '${Endpoint.httpAddress}/api/v1/token/refresh/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken!,
        }),
      );

      print("Refresh token response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        accessToken = jsonData['access'];
        accessTokenExpiry = DateTime.now().add(Duration(minutes: 30));
        print("Access token refreshed successfully");
        return true;
      } else {
        print("Failed to refresh access token with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during access token refresh: $e");
    }
    return false;
  }

  bool isAccessTokenExpired() {
    if (accessTokenExpiry == null) return true;
    return DateTime.now().isAfter(accessTokenExpiry!);
  }
}
