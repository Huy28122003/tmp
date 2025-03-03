import 'package:flutter/material.dart';

class TestPhotoCollage extends StatefulWidget {
  const TestPhotoCollage({super.key});

  @override
  State<TestPhotoCollage> createState() => _TestPhotoCollageState();
}

class _TestPhotoCollageState extends State<TestPhotoCollage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/person.jpeg",
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
