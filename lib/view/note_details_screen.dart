// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_app/helper/app_color.dart';
import 'edit_screen.dart';
import 'package:note_app/helper/firebase/firestore.dart';

class NoteDetailsScreen extends StatelessWidget {
  const NoteDetailsScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Note Details",
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
        actions: [
          IconButton(
            onPressed: () async {
              final snapshot = await firestore.getNotes().firstWhere(
                (snap) => true,
              );
              final noteDoc = snapshot.docs.firstWhere(
                (doc) => doc.id == title,
              );
              final currentDescription = noteDoc["description"] ?? "";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EditScreen(
                        oldTitle: title,
                        description: currentDescription,
                      ),
                ),
              );
            },
            icon: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("Notes")
                .doc(title)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Note not found"));
          }

          final noteData = snapshot.data!;
          final description = noteData["description"] ?? "";
          final Timestamp? timestamp = noteData["createdAt"];
          final DateTime? createdAt = timestamp?.toDate();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noteData.id,
                  style: TextStyle(
                    color: AppColor.mainColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColor.mainColor,
                  ),
                  maxLines: null,
                  softWrap: true,
                ),
                SizedBox(height: size.height * 0.02),
                if (createdAt != null)
                  Text(
                    "Created At: ${createdAt.toLocal().toString().split('.').first}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColor.detailsColor,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
