import 'package:flutter/material.dart';
import 'package:vls_my_1/models/m3u_linea_model.dart';
import 'package:vls_my_1/services/m3u_service.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M3U Viewer',
      home: M3uPage(),
    );
  }
}

class M3uPage extends StatefulWidget {
  @override
  _M3uPageState createState() => _M3uPageState();
}

class _M3uPageState extends State<M3uPage> {
  final parser = M3uService();
  late Future<List<M3uChanel>> m3uEntries;

  @override
  void initState() {
    super.initState();
    m3uEntries = parser.parseM3u('https://daedae.fun/all.m3u');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('M3U Viewer'),
      ),
      body: FutureBuilder<List<M3uChanel>>(
        future: m3uEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
            return Center(child: Text('No se encontraron datos.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final entry = snapshot.data?[index];

                // Verifica si tvgLogo es una URL válida antes de cargar la imagen
                Widget leadingWidget;
                if (Uri.tryParse(entry?.tvgLogo ?? '') != null) {
                  leadingWidget = Image.network(entry!.tvgLogo);
                } else {
                  // Si tvgLogo no es una URL válida, muestra una imagen de respaldo o deja en blanco
                  leadingWidget = Image.network('https://directorioindustrialfarmaceutico.com/images/logos/sin-logo.jpg');
                }

                return ListTile(
                  title: Text(entry!.tvgName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${entry.tvgId}'),
                      Text('Grupo: ${entry.groupTitle}'),
                      Text('Link: ${entry.streamUrl}'),
                    ],
                  ),
                  leading: leadingWidget,
                  onTap: () {
                    // Agrega aquí la lógica para manejar el toque en la entrada
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
