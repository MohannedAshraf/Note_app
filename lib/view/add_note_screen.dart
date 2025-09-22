import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/helper/app_color.dart';
import 'package:note_app/helper/firebase/firestore.dart';
import 'package:note_app/helper/widgets/custom_button.dart';
import 'package:note_app/cubit/note_cubit.dart';
import 'package:note_app/cubit/note_state.dart';
import 'package:note_app/view/note_list_screen.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleController = TextEditingController();
    final detailsController = TextEditingController();

    return BlocProvider(
      create: (_) => NoteCubit(FirestoreService()),
      child: BlocConsumer<NoteCubit, NoteState>(
        listener: (context, state) {
          if (state is NoteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(milliseconds: 1000),
                content: Text("Note saved successfully"),
              ),
            );
            titleController.clear();
            detailsController.clear();
          } else if (state is NoteFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: ${state.error}")));
          }
        },
        builder: (context, state) {
          final cubit = context.read<NoteCubit>();

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Create Note",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColor.mainColor,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Note Title",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.mainColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Enter note title",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: AppColor.detailsColor,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColor.mainColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  Text(
                    "Content",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.mainColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  TextFormField(
                    controller: detailsController,
                    maxLines: 5,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText: "Enter note content",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: AppColor.detailsColor,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColor.mainColor,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  state is NoteLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: AppColor.mainColor,
                        ),
                      )
                      : CustomButton(
                        color: AppColor.button,
                        text: "Save Note",
                        onPressed: () {
                          final title = titleController.text.trim();
                          final description = detailsController.text.trim();

                          if (title.isNotEmpty && description.isNotEmpty) {
                            cubit.addNote(
                              title: title,
                              description: description,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                              ),
                            );
                          }
                        },
                      ),
                  const SizedBox(height: 12),

                  // View Notes Button
                  CustomButton(
                    color: Colors.white,
                    text: "View Notes",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NoteListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
