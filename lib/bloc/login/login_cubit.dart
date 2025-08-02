import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await _loginRepo.login(email, password);
      emit(LoginSuccess(user));
    } catch (e) {
      print(e);
      emit(LoginFailure('Failed to login. Please check your credentials and try again.'));
    }
  }
}