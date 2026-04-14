import 'package:flutter/material.dart';
import 'package:lista_productos/agregar_productos_tab.dart';
import 'package:lista_productos/listar_productos_tab.dart';

/// Pantalla de un día específico.
/// Contiene dos pestañas: listado de productos y agregar producto,
/// ambas filtradas por [diaNombre].
class DiaScreen extends StatelessWidget {
  final String diaNombre;
  final Color diaColor;

  const DiaScreen({
    super.key,
    required this.diaNombre,
    required this.diaColor,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: diaColor,
          foregroundColor: Colors.white,
          title: Text(
            diaNombre,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(icon: Icon(Icons.list_alt), text: 'Productos'),
              Tab(icon: Icon(Icons.add_box), text: 'Agregar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListadoProductosTab(diaNombre: diaNombre, diaColor: diaColor),
            AgregarProductosTab(diaNombre: diaNombre, diaColor: diaColor),
          ],
        ),
      ),
    );
  }
}