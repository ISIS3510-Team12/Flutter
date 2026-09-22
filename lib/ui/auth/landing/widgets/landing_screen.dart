import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

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
                SvgPicture.asset(
                  'assets/juggle_logo_light.svg',
                  fit: BoxFit.contain,
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
              margin: EdgeInsets.only(top: 35, right: 20, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: height <= 914 ? 12 : 30,
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
                    child: SvgPicture.asset(
                      'assets/landing_icon.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Worried about your tasks?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Manage them all in one place.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                  FilledButton(
                    onPressed: () => context.go('/signup'),
                    style: FilledButton.styleFrom(
                      fixedSize: Size(251, 40),
                      backgroundColor: theme.primaryColor,
                    ),
                    child: Text(
                      'Get started',
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: Colors.white,
                      ),
                    ),
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
