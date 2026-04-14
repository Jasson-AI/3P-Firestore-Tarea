import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListadoProductosTab extends StatelessWidget {
  // Nombre del día por el que se filtran los productos
  final String diaNombre;
  final Color diaColor;

  const ListadoProductosTab({
    super.key,
    required this.diaNombre,
    required this.diaColor,
  });

  void _editarProducto(
    BuildContext context,
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) {
    final nombreCtrl =
        TextEditingController(text: data['nombre']?.toString() ?? '');
    final descripcionCtrl =
        TextEditingController(text: data['descripcion']?.toString() ?? '');
    final precioCtrl =
        TextEditingController(text: data['precio']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.edit, color: diaColor),
            const SizedBox(width: 8),
            const Text('Editar producto'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nombreCtrl, 'Nombre', Icons.shopping_bag),
            const SizedBox(height: 12),
            _buildDialogField(precioCtrl, 'Precio', Icons.attach_money,
                type: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            _buildDialogField(descripcionCtrl, 'Descripción', Icons.description,
                maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: diaColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('productos')
                  .doc(doc.id)
                  .update({
                'nombre': nombreCtrl.text.trim(),
                'precio':
                    double.tryParse(precioCtrl.text.trim()) ?? data['precio'],
                'descripcion': descripcionCtrl.text.trim(),
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: diaColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }

  void _eliminarProducto(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar producto'),
          ],
        ),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('productos')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .where('dia', isEqualTo: diaNombre)   // ← filtro por día
          .orderBy('fechaRegistro', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Estados de carga / error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text('Error: ${snapshot.error}',
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: diaColor),
          );
        }

        final docs = snapshot.data!.docs;

        // Estado vacío
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 72, color: diaColor.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'Sin productos para el $diaNombre',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ve a la pestaña "Agregar" para registrar uno.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        // Lista de productos
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final nombre = data['nombre']?.toString() ?? '—';
            final precio = data['precio'];
            final descripcion = data['descripcion']?.toString() ?? '';

            return Card(
              elevation: 2,
              shadowColor: Colors.black12,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: diaColor.withOpacity(0.12),
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: diaColor, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 15, color: diaColor),
                        Text(
                          'L ${precio ?? 0}',
                          style: TextStyle(
                              color: diaColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: Icon(Icons.edit_outlined, color: diaColor),
                      onPressed: () => _editarProducto(context, doc, data),
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _eliminarProducto(context, doc.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}