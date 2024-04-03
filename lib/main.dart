import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class Vivencia {
  String titulo = "";
  String fecha = "";
  String descripcion = "";
  String foto = "";

  Vivencia({
    required this.titulo,
    required this.fecha,
    required this.descripcion,
    required this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'fecha': fecha,
      'descripcion': descripcion,
      'foto': foto,
    };
  }

  Vivencia.fromJson(Map<String, dynamic> json)
      : titulo = json['titulo'],
        fecha = json['fecha'],
        descripcion = json['descripcion'],
        foto = json['foto'];
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parcial 2'),
      ),
      drawer: DrawerWidget(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fotos/911.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text('Registros'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VivenciaScreen(),
              ));
            },
          ),
          ListTile(
            title: Text('Lista'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ListaScreen(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class VivenciaScreen extends StatefulWidget {
  @override
  _VivenciaScreenState createState() => _VivenciaScreenState();
}

class _VivenciaScreenState extends State<VivenciaScreen> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  String? fotoPath;

  Future<void> selectFoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          fotoPath = result.files.first.path;
        });
      }
    } catch (e) {
      // Handle any errors when picking a photo.
    }
  }

  Future<void> guardarVivencia(Vivencia vivencia) async {
    final prefs = await SharedPreferences.getInstance();
    final vivencias = prefs.getStringList('vivencias') ?? [];
    vivencias.add(json.encode(vivencia.toMap()));
    await prefs.setStringList('vivencias', vivencias);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo Registro')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/fotos/911.png"), // Cambia "assets/background.jpg" por la ruta de tu imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: tituloController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: fechaController,
                decoration: InputDecoration(labelText: 'Fecha'),
              ),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: selectFoto,
                child: Text('Seleccionar Foto'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final vivencia = Vivencia(
                    titulo: tituloController.text,
                    fecha: fechaController.text,
                    descripcion: descripcionController.text,
                    foto: fotoPath ?? '',
                  );

                  guardarVivencia(vivencia);
                },
                child: Text('Guardar Datos'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListaScreen extends StatefulWidget {
  @override
  _ListaScreenState createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  Future<List<Vivencia>> obtenerVivencias() async {
    final prefs = await SharedPreferences.getInstance();
    final vivenciasData = prefs.getStringList('vivencias') ?? [];
    final vivencias = vivenciasData.map((data) {
      final vivenciaMap = json.decode(data);
      return Vivencia.fromJson(vivenciaMap);
    }).toList();
    return vivencias;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Datos'),
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fotos/911.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder(
          future: obtenerVivencias(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final vivencias = snapshot.data as List<Vivencia>;
              return ListView.builder(
                itemCount: vivencias.length,
                itemBuilder: (context, index) {
                  final vivencia = vivencias[index];
                  return ListTile(
                    title: Text(vivencia.titulo),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DetalleVivenciaScreen(vivencia),
                      ));
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class DetalleVivenciaScreen extends StatelessWidget {
  final Vivencia vivencia;

  DetalleVivenciaScreen(this.vivencia);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de Registros')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (vivencia.foto.isNotEmpty)
                Image.file(
                  File(vivencia.foto),
                  width: 200,
                  height: 200,
                ),
              SizedBox(height: 10),
              Text('Fecha: ${vivencia.fecha}'),
              SizedBox(height: 10),
              Text('Título: ${vivencia.titulo}'),
              SizedBox(height: 10),
              Text('Descripción: ${vivencia.descripcion}'),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
