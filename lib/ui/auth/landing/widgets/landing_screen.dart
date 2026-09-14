import 'package:flutter/material.dart';

// TODO: Replace both containers with the corresponding svg using Image.asset('assets/image_name.svg', fit: BoxFit.cover).
// TODO: Install flutter_svg package using flutter pub add flutter_svg
// TODO: Replace progress indicator with two sepated lines

//TODO: use mediaquery to addapt the size of the screen to the containers and the progress indicator

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    double width = screenSize.width;
    double height = screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1.0),
              ),
              color: Color(0xFF585992),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Container(
                  width: 300,
                  height: 160,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
          Container(
            width: width,
            height: height,
            margin: EdgeInsets.only(top: height / 2.8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(top: 40, right: 20, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 16,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF585992),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 255,
                    height: 255,
                    color: Colors.grey[200],
                  ),
                  Column(
                    children: const [
                      Text(
                        'Worried about your tasks?',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Manage them all in one place.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      fixedSize: Size(251, 40),
                      backgroundColor: Color(0xFF585992),
                    ),
                    child: Text('Get started'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
