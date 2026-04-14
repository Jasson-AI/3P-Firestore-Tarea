import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:lista_productos/dia_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final token = await messaging.getToken();
  print('Token: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    Get.snackbar(
      message.notification!.title!,
      message.notification!.body!,
      colorText: Colors.black,
      backgroundColor: Colors.white,
      icon: const Icon(Icons.notifications, color: Colors.green),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Productos por Día',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Lista de los 7 días con su nombre, ícono y color representativo
  static const List<Map<String, dynamic>> _dias = [
    {'nombre': 'Lunes',     'icono': Icons.looks_one,     'color': Color(0xFF1565C0)},
    {'nombre': 'Martes',    'icono': Icons.looks_two,     'color': Color(0xFF6A1B9A)},
    {'nombre': 'Miércoles', 'icono': Icons.looks_3,       'color': Color(0xFF00695C)},
    {'nombre': 'Jueves',    'icono': Icons.looks_4,       'color': Color(0xFFE65100)},
    {'nombre': 'Viernes',   'icono': Icons.looks_5,       'color': Color(0xFFC62828)},
    {'nombre': 'Sábado',    'icono': Icons.looks_6,       'color': Color(0xFF4E342E)},
    {'nombre': 'Domingo',   'icono': Icons.star,          'color': Color(0xFF37474F)},
  ];

  // Devuelve el índice (0=lunes … 6=domingo) del día actual
  int get _diaHoyIndex {
    final weekday = DateTime.now().weekday;
    return weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    final hoyIndex = _diaHoyIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Productos por Día',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner del día actual
          Container(
            width: double.infinity,
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                const Icon(Icons.today, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Hoy es ${_dias[hoyIndex]['nombre']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Subtítulo
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Selecciona un día',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A237E),
              ),
            ),
          ),

          // Grid de días
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: _dias.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final dia = _dias[index];
                  final esHoy = index == hoyIndex;

                  return _DiaCard(
                    nombre: dia['nombre'] as String,
                    icono: dia['icono'] as IconData,
                    color: dia['color'] as Color,
                    esHoy: esHoy,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiaScreen(
                            diaNombre: dia['nombre'] as String,
                            diaColor: dia['color'] as Color,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaCard extends StatelessWidget {
  final String nombre;
  final IconData icono;
  final Color color;
  final bool esHoy;
  final VoidCallback onTap;

  const _DiaCard({
    required this.nombre,
    required this.icono,
    required this.color,
    required this.esHoy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: esHoy
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: Stack(
          children: [
            // Círculo decorativo de fondo
            Positioned(
              bottom: -10,
              right: -10,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icono, color: Colors.white, size: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (esHoy)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Hoy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}