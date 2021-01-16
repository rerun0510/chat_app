import 'package:flutter/material.dart';

class WidgetUtil {
  /// ユーザーのアイコン
  Widget userImage(String imageURL, double size) {
    return Container(
      padding: EdgeInsets.all(2),
      child: ClipOval(
        child: Container(
          color: Colors.white,
          child: imageURL != ''
              ? Image.network(
                  imageURL,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, object, stackTrace) {
                    return Icon(Icons.account_circle, size: size);
                  },
                )
              : Icon(Icons.account_circle, size: size),
        ),
      ),
    );
  }
}
