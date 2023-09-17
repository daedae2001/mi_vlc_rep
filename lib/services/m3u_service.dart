import 'package:http/http.dart' as http;

import '../models/m3u_linea_model.dart';

class M3uService {
  static const defaultLogoUrl =
      'https://directorioindustrialfarmaceutico.com/images/logos/sin-logo.jpg';

  Future<List<M3uChanel>> parseM3u(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      final entries = <M3uChanel>[];
      M3uChanel? currentEntry;

      final regexExtInf = RegExp(r'^#EXTINF:(.*?)(?:,|$)');
      final regexTvgId = RegExp(r'tvg-id="(.*?)"');
      final regexTvgName = RegExp(r'tvg-name="(.*?)"');
      final regexTvgLogo = RegExp(r'tvg-logo="(.*?)"');
      final regexGroupTitle = RegExp(r'group-title="(.*?)"');

      for (final line in lines) {
        if (line.startsWith('#EXTINF:')) {
          final extInfMatch = regexExtInf.firstMatch(line);
          final info = extInfMatch?.group(1) ?? '';
          final tvgIdMatch = regexTvgId.firstMatch(info);
          final tvgNameMatch = regexTvgName.firstMatch(info);
          final tvgLogoMatch = regexTvgLogo.firstMatch(info);
          final groupTitleMatch = regexGroupTitle.firstMatch(info);

          final tvgId = tvgIdMatch?.group(1) ?? '';
          final tvgName = tvgNameMatch?.group(1) ?? '';
          final tvgLogo = tvgLogoMatch?.group(1) ?? '';
          final groupTitle = groupTitleMatch?.group(1) ?? '';

          // Utilizar split para extraer el campo 'nombre'
          final infoParts = line.split(',');
          final nombre = infoParts.length > 1 ? infoParts[1].trim() : '';

          // Verificar si la URL del logo está vacía o no es válida, y usar la URL de respaldo en ese caso
          final logoUrl = tvgLogo.isNotEmpty && Uri.tryParse(tvgLogo) != null
              ? tvgLogo
              : defaultLogoUrl;


          final tvgIdFilled = tvgId.isEmpty ? nombre : tvgId;
          final tvgNameFilled = tvgName.isEmpty ? nombre : tvgName;

          currentEntry = M3uChanel(
            tvgId: tvgIdFilled,
            tvgName: tvgNameFilled,
            tvgLogo: logoUrl,
            groupTitle: groupTitle,
            nombre: nombre,
          );
        } else if (line.isNotEmpty) {
          if (currentEntry != null) {
            currentEntry.streamUrl = line;
            entries.add(currentEntry);
            currentEntry = null;
          }
        }
      }

      return entries;
    } else {
      throw Exception('Error al cargar el archivo M3U');
    }
  }
}