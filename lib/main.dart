// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/cubit/auth_cubit.dart';
import 'package:note_app/firebase_options.dart';
import 'package:note_app/helper/firebase/firestore.dart';
import 'package:note_app/cubit/note_cubit.dart';
import 'package:note_app/helper/services/remote_config_service.dart';
import 'package:note_app/view/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final config = RemoteConfigService.instance;
  await config.init();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print("User granted permission: ${settings.authorizationStatus}");

  final fcmToken = await messaging.getToken();
  print("FCM Token: $fcmToken");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Data: ${message.data}");
    if (message.notification != null) {
      print("Title: ${message.notification!.title}");
      print("Body: ${message.notification!.body}");
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NoteCubit(FirestoreService())),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
