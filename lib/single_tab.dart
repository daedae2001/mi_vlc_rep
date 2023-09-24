import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:path_provider/path_provider.dart';
import 'services/m3u_service.dart';
import 'video_data.dart';
import 'vlc_player_with_controls.dart';

class SingleTab extends StatefulWidget {
  @override
  _SingleTabState createState() => _SingleTabState();
}

class _SingleTabState extends State<SingleTab> {
  static const _networkCachingMs = 6000;
  static const _subtitlesFontSize = 30;
  static const _height = 560.0;

  final _key = GlobalKey<VlcPlayerWithControlsState>();

  late VlcPlayerController _controller;
  //
  List<VideoData> listVideos = [];
  int selectedVideoIndex = 0;
  bool isPullToRefreshActive = false; // Estado del gesto de deslizar hacia abajo

  Future<File> _loadVideoToFs() async {
    final videoData = await rootBundle.load('assets/trailer.mp4');
    final videoBytes = Uint8List.view(videoData.buffer);
    final dir = (await getTemporaryDirectory()).path;
    final temp = File('$dir/temp.file');
    temp.writeAsBytesSync(videoBytes);

    return temp;
  }

  @override
  void initState() {
    super.initState();

    // Inicialmente, no incluyas ninguna entrada fija en la lista de videos.
    // Solo se cargarán videos de la lista M3U después de llamar a _loadM3uEntries().

    selectedVideoIndex = 0;
    //
    _controller = VlcPlayerController.network(
      '', // Inicialmente, no se carga ningún video.
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(_networkCachingMs),
        ]),
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(_subtitlesFontSize),
          VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
          VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
          VlcSubtitleOptions.color(VlcSubtitleColor.navy),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );

    _controller.addOnInitListener(() async {
      await _controller.startRendererScanning();
    });
    _controller.addOnRendererEventListener((type, id, name) {
      print('OnRendererEventListener $type $id $name');
    });
    _loadM3uEntries();
  }

  Future<void> _loadM3uEntries() async {
    try {
      final m3uService = M3uService();
      final m3uEntries =
          await m3uService.parseM3u('https://daedae.fun/all.m3u');

      // Convertir las entradas de M3uEntry a VideoData y agregarlas a la lista
      final newVideos = m3uEntries.map((entry) {
        return VideoData(
          name: entry.nombre,
          url: entry.streamUrl, // Cambia 'path' a 'url'
          type: VideoType.network, // Puedes ajustar el tipo según tus necesidades
          logoUrl: entry.tvgLogo, // Usa la URL del logo del canal de la entrada M3U
        );
      }).toList();

      setState(() {
        if (!isPullToRefreshActive) {
          // Solo agregar videos a la lista si el gesto de deslizar hacia abajo no está activo
          listVideos.clear(); // Borrar la lista existente antes de agregar nuevos videos
          listVideos.addAll(newVideos);
        }
        isPullToRefreshActive = false; // Restablecer el estado del gesto de deslizar hacia abajo
      });
    } catch (e) {
      print('Error cargando entradas M3U: $e');
    }
  }

  Future<void> _handleRefresh() async {
    // Establecer el estado del gesto de deslizar hacia abajo como activo
    setState(() {
      isPullToRefreshActive = true;
    });
    // Recargar la lista de videos
    await _loadM3uEntries();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: _height,
              child: VlcPlayerWithControls(
                key: _key,
                controller: _controller,
                onStopRecording: (recordPath) {
                  setState(() {
                    listVideos.add(
                      VideoData(
                        name: 'Recorded Video',
                        url: recordPath, // Cambia 'path' a 'url'
                        type: VideoType.recorded,
                        logoUrl: '', // O proporciona una URL de logo si tienes una
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El archivo de vídeo grabado se ha añadido al final de la lista.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - _height,
            child: ListView.builder(
              itemCount: listVideos.length,
              itemBuilder: (BuildContext context, int index) {
                final video = listVideos[index];
                IconData iconData;
                switch (video.type) {
                  case VideoType.network:
                    iconData = Icons.cloud;
                    break;
                  case VideoType.file:
                    iconData = Icons.insert_drive_file;
                    break;
                  case VideoType.asset:
                    iconData = Icons.all_inbox;
                    break;
                  case VideoType.recorded:
                    iconData = Icons.videocam;
                    break;
                }

                return ListTile(
                  dense: true,
                  selected: selectedVideoIndex == index,
                  selectedTileColor: Colors.black54,
                  leading: FutureBuilder(
                    future: Future.delayed(Duration(seconds: 0), () => video.logoUrl),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Muestra un indicador de carga mientras se espera la imagen
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // Si ocurre un error al cargar la imagen, muestra la imagen genérica
                        return Image.asset(
                          'assets/sinlogotipo.jpg', // Ruta de la imagen genérica
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        );
                      } else {
                        // Muestra la imagen cargada desde la URL
                        return Image.network(
                          snapshot.data!, // Utiliza la URL del logo del canal
                          width: 40, // Ajusta el tamaño del logo según tus necesidades
                          height: 40,
                          fit: BoxFit.contain, // Ajusta el ajuste de la imagen según tus necesidades
                        );
                      }
                    },
                  ),
                  title: Text(
                    video.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          selectedVideoIndex == index ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () async {
                    await _controller.stopRecording();
                    switch (video.type) {
                      case VideoType.network:
                        await _controller.setMediaFromNetwork(
                          video.url, // Cambia 'path' a 'url'
                          hwAcc: HwAcc.full,
                        );
                        break;
                      case VideoType.file:
                        if (!mounted) break;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copying file to temporary storage...'),
                          ),
                        );
                        await Future<void>.delayed(const Duration(seconds: 1));
                        final tempVideo = await _loadVideoToFs();
                        await Future<void>.delayed(const Duration(seconds: 1));
                        if (!mounted) break;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Now trying to play...'),
                          ),
                        );
                        await Future<void>.delayed(const Duration(seconds: 1));
                        if (await tempVideo.exists()) {
                          await _controller.setMediaFromFile(tempVideo);
                        } else {
                          if (!mounted) break;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File load error.'),
                            ),
                          );
                        }
                        break;
                      case VideoType.asset:
                        await _controller.setMediaFromAsset(video.url); // Cambia 'path' a 'url'
                        break;
                      case VideoType.recorded:
                        final recordedFile = File(video.url); // Cambia 'path' a 'url'
                        await _controller.setMediaFromFile(recordedFile);
                        break;
                    }
                    setState(() {
                      selectedVideoIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller.stopRecording();
    await _controller.stopRendererScanning();
    await _controller.dispose();
  }
}
