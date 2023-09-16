import 'package:flutter/material.dart';
import 'multiple_tab.dart';
import 'single_tab.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  static const _tabCount = 2;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabCount,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Vlc Player Example'),
                  ),
        body: 
            SingleTab(),
         
        ),
   
    );
  }
}
