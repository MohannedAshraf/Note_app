import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/helper/app_color.dart';
import 'package:note_app/cubit/note_cubit.dart';
import 'package:note_app/cubit/note_state.dart';
import 'package:note_app/helper/firebase/firestore.dart';
import 'package:note_app/view/note_details_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteCubit(FirestoreService()),
      child: BlocConsumer<NoteCubit, NoteState>(
        listener: (context, state) {
          if (state is NoteFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<NoteCubit>();

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Notes List",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColor.mainColor,
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: cubit.getNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No notes found"));
                }

                final notes = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final title = note.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 0,
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColor.mainColor,
                        ),
                      ),
                      subtitle: Text(
                        note["description"] ?? "",
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.detailsColor,
                          fontSize: 14,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          cubit.deleteNote(title);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailsScreen(title: title),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
