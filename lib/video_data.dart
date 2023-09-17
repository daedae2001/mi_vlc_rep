class VideoData {
  final String name;
  final String url;
  final VideoType type;
  final String logoUrl;

  VideoData({
    required this.name,
    required this.url,
    required this.type,
    required this.logoUrl,
  });
}

enum VideoType {
  asset,
  file,
  network,
  recorded,
}
