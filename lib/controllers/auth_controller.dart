import '../models/auth_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final AuthModel _authModel = AuthModel();

  Future<bool> login(String email, String password) async {
    User? user = await _authModel.login(email, password);
    return user != null;
  }

  Future<bool> signUp(String email, String password) async {
    User? user = await _authModel.signUp(email, password);
    return user != null;
  }
}
