import 'package:flutter/material.dart';
import 'package:vls_my_1/services/m3u_service.dart';
import 'single_tab.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  static const _tabCount = 2;
  @override
  void initState() {
    run;
    super.initState();
  }

  void run() async {
    const m3uUrl = 'https://daedae.fun/all.m3u';
    final parser = M3uService();
    final entries = await parser.parseM3u(m3uUrl);

    // Ahora puedes trabajar con las entradas M3uEntry
    for (final entry in entries) {
      print('TvgId: ${entry.tvgId}');
      print('TvgName: ${entry.tvgName}');
      print('TvgLogo: ${entry.tvgLogo}');
      print('GroupTitle: ${entry.groupTitle}');
      print('StreamUrl: ${entry.streamUrl}');
      print('------------------------');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabCount,
      child: Scaffold(
        
        body: SingleTab(),
      ),
    );
  }
}
