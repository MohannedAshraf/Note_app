import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/firebase_options.dart';
import 'package:note_app/helper/firebase/firestore.dart';
import 'package:note_app/view/add_note_screen.dart';
import 'package:note_app/cubit/note_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => NoteCubit(FirestoreService()))],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AddNoteScreen(),
      ),
    );
  }
}
