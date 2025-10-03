import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/cubit/auth_cubit.dart';
import 'package:note_app/cubit/auth_state.dart';
import 'package:note_app/view/add_note_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Google Login")),
        body: Center(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AuthSuccess) {
                // ✅ بعد تسجيل الدخول يروح للـ AddNoteScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNoteScreen()),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const CircularProgressIndicator();
              } else if (state is AuthSuccess) {
                return const SizedBox(); // مش هيظهر حاجة لأننا عملنا Navigate
              }
              return ElevatedButton(
                onPressed: () {
                  context.read<AuthCubit>().signInWithGoogle();
                },
                child: const Text("Sign in with Google"),
              );
            },
          ),
        ),
      ),
    );
  }
}
