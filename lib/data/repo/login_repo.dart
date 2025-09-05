import '../api/login_api.dart';
import '../model/user_model.dart';

class LoginRepo {
  final LoginApi _loginApi;

  LoginRepo(this._loginApi);

  Future<UserModel> login(String email, String password) async {
    return await _loginApi.login(email, password);
  }

  Future<void> logout() async {
    // Clear stored tokens and user data
    // This could be implemented to call a logout API endpoint
    // For now, we'll just return successfully
    return;
  }
}
