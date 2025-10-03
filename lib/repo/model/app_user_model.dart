class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  AppUser({required this.uid, this.name, this.email, this.photoUrl});

  // Convert Firestore document → AppUser
  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      uid: documentId,
      name: data['name'] as String?,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  // Convert AppUser → Map (for saving in Firestore)
  Map<String, dynamic> toMap() {
    return {"name": name, "email": email, "photoUrl": photoUrl};
  }
}
