import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:vls_my_1/video_data.dart';
import 'vlc_player_with_controls.dart';

class MultipleTab extends StatefulWidget {
  @override
  _MultipleTabState createState() => _MultipleTabState();
}

class _MultipleTabState extends State<MultipleTab> {
  static const _heightWithControls = 400.0;
  static const _heightWithoutControls = 300.0;

  List<VlcPlayerController> controllers = [];
  List<String> urls = [
    'http://190.83.60.34:1414/play/a040',
    'http://190.83.60.34:1414/play/a06n',
    'http://138.59.177.34:8000/play/a06s/index.m3u8'
  ];

  bool showPlayerControls = true;

  @override
  void initState() {
    super.initState();
    controllers = <VlcPlayerController>[];
    for (var i = 0; i < urls.length; i++) {
      final controller = VlcPlayerController.network(
        urls[i],
        hwAcc: HwAcc.full,
        autoPlay: false,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(2000),
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true),
          ]),
        ),
      );
      controllers.add(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: controllers.length,
      separatorBuilder: (_, index) {
        return const Divider(height: 5, thickness: 5, color: Colors.grey);
      },
      itemBuilder: (_, index) {
        return SizedBox(
          height:
              showPlayerControls ? _heightWithControls : _heightWithoutControls,
          child: VlcPlayerWithControls(
            controller: controllers[index],
            showControls: showPlayerControls,
            onStopRecording: (recordPath) {
              setState(() {
                var listVideos;
                listVideos.add(
                  VideoData(
                    name: 'Recorded Video',
                    path: recordPath,
                    type: VideoType.recorded,
                  ),
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'The recorded video file has been added to the end of list.',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    for (final controller in controllers) {
      await controller.stopRendererScanning();
      await controller.dispose();
    }
  }
}
