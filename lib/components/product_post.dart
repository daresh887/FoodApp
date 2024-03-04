import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:products_app/components/comment.dart';
import 'package:products_app/components/comment_button.dart';
import 'package:products_app/components/delete_button.dart';
import 'package:products_app/components/like_button.dart';
import 'package:products_app/helper/helper_methods.dart';

class ProductPost extends StatefulWidget {
  final String title;
  final String user;
  final String postId;
  final List<String> likes;
  final List<String> dislikes;
  const ProductPost({
    super.key,
    required this.title,
    required this.user,
    required this.postId,
    required this.likes,
    required this.dislikes,
  });

  @override
  State<ProductPost> createState() => _ProductPostState();
}

class _ProductPostState extends State<ProductPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  bool isDisliked = false;

  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    bool prevDisliked = isDisliked;
    setState(() {
      isLiked = !isLiked;
      isDisliked = false;
    });

    // acces the document in firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("Products").doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
      if (prevDisliked) {
        postRef.update({
          'Dislikes': FieldValue.arrayRemove([currentUser.email])
        });
      }
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void toggleDislike() {
    bool prevLiked = isLiked;
    setState(() {
      isDisliked = !isDisliked;
      isLiked = false;
    });

    // acces the document in firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("Products").doc(widget.postId);

    if (isDisliked) {
      postRef.update({
        'Dislikes': FieldValue.arrayUnion([currentUser.email])
      });
      if (prevLiked) {
        postRef.update({
          'Likes': FieldValue.arrayRemove([currentUser.email])
        });
      }
    } else {
      postRef.update({
        'Dislikes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("Products")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentBy": currentUser.email,
      "CommentTime": Timestamp.now(),
    });
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Write a comment"),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _commentTextController.clear();
              },
              child: Text("Cancel")),
          TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                Navigator.pop(context);
                _commentTextController.clear();
              },
              child: Text("Post")),
        ],
      ),
    );
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Post"),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
              onPressed: () async {
                // delete comments
                final commentDocs = await FirebaseFirestore.instance
                    .collection("Products")
                    .doc(widget.postId)
                    .collection("Comments")
                    .get();

                for (var doc in commentDocs.docs) {
                  await FirebaseFirestore.instance
                      .collection("Products")
                      .doc(widget.postId)
                      .collection("Comments")
                      .doc(doc.id)
                      .delete();
                }

                // delete post
                FirebaseFirestore.instance
                    .collection("Products")
                    .doc(widget.postId)
                    .delete()
                    .then((value) => print("post deleted"))
                    .catchError((error) =>
                        print("Error when deleting post: " + error.toString()));

                Navigator.pop(context);
              },
              child: Text("Delete")),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.only(top: 25, left: 25, right: 25),
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user,
                        style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 10),
                    Text(widget.title),
                  ],
                ),
                if (widget.user == currentUser.email)
                  DeleteButton(onTap: deletePost),
              ],
            ),
            const SizedBox(width: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Like / Dislike buttons
                Column(
                  children: [
                    LikeButton(
                      isLiked: isLiked,
                      isDisliked: isDisliked,
                      onTapLike: toggleLike,
                      onTapDislike: toggleDislike,
                    ),
                    const SizedBox(height: 10),
                    Text(
                        (widget.likes.length - widget.dislikes.length)
                            .toString(),
                        style: TextStyle(
                          color: Colors.grey,
                        )),
                  ],
                ),

                const SizedBox(width: 10),

                // Comment button
                Column(
                  children: [
                    CommentButton(onTap: showCommentDialog),
                    const SizedBox(height: 10),

                    // Comment count
                    Text('0',
                        style: TextStyle(
                          color: Colors.grey,
                        )),
                  ],
                ),
              ],
            ),

            // comments
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Products")
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    final commentData = doc.data() as Map<String, dynamic>;

                    return Comment(
                      text: commentData["CommentText"],
                      user: commentData["CommentBy"],
                      time: formatDate(commentData["CommentTime"]),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
