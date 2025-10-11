import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/cubit/auth_cubit.dart';
import 'package:note_app/cubit/auth_state.dart';
import 'package:note_app/helper/app_color.dart';
import 'package:note_app/view/force_update_screen.dart';
import 'package:note_app/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  void _checkUpdate() async {
    final cubit = context.read<AuthCubit>();
    await cubit.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ForceUpdateState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ForceUpdateScreen()),
            );
          } else if (state is AuthFailure || state is AuthInitial) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notes, size: 80, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                "Note App",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColor.detailsColor,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: AppColor.detailsColor),
            ],
          ),
        ),
      ),
    );
  }
}
