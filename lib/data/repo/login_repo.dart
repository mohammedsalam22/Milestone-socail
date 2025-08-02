import '../api/login_api.dart';
import '../model/user_model.dart';

class LoginRepo {
  final LoginApi _loginApi;

  LoginRepo(this._loginApi);

  Future<UserModel> login(String email, String password) async {
    return await _loginApi.login(email, password);
  }
}