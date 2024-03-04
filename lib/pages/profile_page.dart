import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:products_app/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit" + field, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                children: [
                  const SizedBox(height: 50),
                  Icon(
                    Icons.person,
                    size: 72,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text("My Details",
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(height: 20),
                  MyTextBox(
                    sectionName: "username",
                    text: userData["username"],
                    onPressed: () => editField("username"),
                  ),
                  MyTextBox(
                    sectionName: "bio",
                    text: userData["bio"],
                    onPressed: () => editField("bio"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text("My Posts",
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error" + snapshot.error.toString()));
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
