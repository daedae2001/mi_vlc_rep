class VideoData {
  final String name;
  final String path;
  final VideoType type;

  VideoData({
    required this.name,
    required this.path,
    required this.type,
  });
}

enum VideoType {
  asset,
  file,
  network,
  recorded,
}
