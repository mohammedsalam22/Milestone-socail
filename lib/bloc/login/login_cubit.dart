import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/login_repo.dart';
import '../../data/model/user_model.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await _loginRepo.login(email, password);

      // Save student data to SharedPreferences
      await user.saveStudentData();

      emit(LoginSuccess(user));
    } catch (e) {
      print(e);
      emit(
        LoginFailure(
          'Failed to login. Please check your credentials and try again.',
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _loginRepo.logout();

      // Clear student data from SharedPreferences
      await UserModel.clearStudentData();

      emit(LoginInitial());
    } catch (e) {
      print(e);
      emit(LoginFailure('Failed to logout. Please try again.'));
    }
  }
}
