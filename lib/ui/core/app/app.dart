import 'package:flutter/material.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juggle',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Hello, World!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
