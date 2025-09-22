// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/cubit/note_cubit.dart';
import 'package:note_app/cubit/note_state.dart';
import 'package:note_app/helper/app_color.dart';
import 'package:note_app/helper/widgets/custom_button.dart';
import 'note_details_screen.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({
    super.key,
    required this.oldTitle,
    required this.description,
  });

  final String oldTitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final TextEditingController titleController = TextEditingController(
      text: oldTitle,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: description,
    );

    return BlocConsumer<NoteCubit, NoteState>(
      listener: (context, state) {
        if (state is NoteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Note updated successfully")),
          );

          final updatedTitle = titleController.text.trim();
          final updatedDescription = descriptionController.text.trim();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailsScreen(title: updatedTitle),
            ),
          );
        } else if (state is NoteFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Edit Note",
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Title",
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
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  minLines: 5,
                  decoration: InputDecoration(
                    hintText: "Details",
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
                CustomButton(
                  color: AppColor.button,
                  text: state is NoteLoading ? "Saving..." : "Save",
                  onPressed:
                      state is NoteLoading
                          ? () {}
                          : () {
                            final updatedTitle = titleController.text.trim();
                            final updatedDescription =
                                descriptionController.text.trim();

                            context.read<NoteCubit>().updateNote(
                              oldTitle: oldTitle,
                              newTitle:
                                  updatedTitle != oldTitle
                                      ? updatedTitle
                                      : null,
                              newDescription: updatedDescription,
                            );
                          },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
