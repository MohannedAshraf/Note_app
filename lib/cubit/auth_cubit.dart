import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());

      // Step 1: initialize (ممكن تعمله مره واحده في app startup)
      await _googleSignIn.initialize();

      // Step 2: Authenticate
      final user = await _googleSignIn.authenticate();

      // Step 3: get ID token
      final auth = user.authentication;
      if (auth.idToken == null) {
        emit(AuthFailure("Missing Google ID Token"));
        return;
      }

      // Step 4: Firebase Credential
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.idToken,
      );

      // Step 5: Firebase SignIn
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      emit(AuthSuccess(userCredential.user!));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure("Error signing out: $e"));
    }
  }
}
