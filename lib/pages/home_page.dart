import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:products_app/components/drawer.dart';
import 'package:products_app/components/product_post.dart';
import 'package:products_app/components/text_field.dart';
import 'package:products_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void createPost() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("Products").add({
        "UserEmail": currentUser.email,
        "Title": textController.text,
        "TimeStamp": Timestamp.now(),
        "Likes": [],
        "Dislikes": [],
      });
    }

    setState(() {
      textController.clear();
    });
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App"),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignout: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Products")
                      .orderBy("TimeStamp", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];
                          return ProductPost(
                            title: post['Title'],
                            user: post['UserEmail'],
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                            dislikes: List<String>.from(post['Dislikes'] ?? []),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text("Error: " + snapshot.error.toString()));
                    }
                    return const Center(child: CircularProgressIndicator());
                  }),
            ),

            // create post
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: "Post a prouct",
                      obscureText: false,
                    ),
                  ),
                  IconButton(
                    onPressed: createPost,
                    icon: const Icon(Icons.arrow_circle_up),
                  ),
                ],
              ),
            ),

            Text(
              "Logged in as: " + currentUser.email!,
            ),
          ],
        ),
      ),
    );
  }
}
