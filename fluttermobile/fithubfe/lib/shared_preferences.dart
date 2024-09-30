import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveAuthToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}
