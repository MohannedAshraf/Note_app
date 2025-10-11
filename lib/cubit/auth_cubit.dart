import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app/helper/services/remote_config_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> init() async {
    try {
      final bool isForceUpdate =
          await RemoteConfigService.instance.isForceUpdateEnabled;
      if (isForceUpdate) {
        emit(ForceUpdateState());
      } else {
        emit(AuthInitial());
      }
    } catch (_) {
      emit(AuthFailure("Check your internet connection"));
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      await _googleSignIn.initialize();
      final user = await _googleSignIn.authenticate();
      final auth = user.authentication;
      if (auth.idToken == null) {
        emit(AuthFailure("Missing Google ID Token"));
        return;
      }
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      emit(AuthSuccess(userCredential.user!));
    } catch (_) {
      emit(AuthFailure("Check your internet connection"));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
      emit(AuthInitial());
    } catch (_) {
      emit(AuthFailure("Check your internet connection"));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthSuccess(userCredential.user!));
    } catch (_) {
      emit(AuthFailure("Check your internet connection"));
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthSuccess(userCredential.user!));
    } catch (_) {
      emit(AuthFailure("Check your internet connection"));
    }
  }
}
