import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final bool isDisliked;
  void Function()? onTapLike;
  void Function()? onTapDislike;
  LikeButton(
      {super.key,
      required this.isLiked,
      required this.isDisliked,
      required this.onTapLike,
      required this.onTapDislike});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTapLike,
          child: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            color: isLiked ? Colors.blueAccent : Colors.grey,
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: onTapDislike,
          child: Icon(
            isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
            color: isDisliked ? Colors.blueAccent : Colors.grey,
          ),
        ),
      ],
    );
  }
}
