import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'vlc_player_with_controls.dart';

class FullScreenVideoScreen extends StatefulWidget {
  final VlcPlayerController controller;

  FullScreenVideoScreen({required this.controller});

  @override
  State<FullScreenVideoScreen> createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
   @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);}
  @override
  Widget build(BuildContext context) {
   setState(() {
     
     // Inicia la reproducción automáticamente al abrir la pantalla
    widget.controller.play();
});  
    return Scaffold(
      body: Center(
        child: VlcPlayerWithControls(
          controller: widget.controller,
          onStopRecording: (recordPath) {
            // Maneja la grabación como lo hacías en _SingleTabState
          },
        ),
      ),
    );
  }
}
