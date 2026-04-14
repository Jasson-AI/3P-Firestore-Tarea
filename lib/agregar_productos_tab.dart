import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AgregarProductosTab extends StatefulWidget {
  /// Nombre del día al que pertenecen los productos (ej: "Lunes")
  final String diaNombre;
  final Color diaColor;

  const AgregarProductosTab({
    super.key,
    required this.diaNombre,
    required this.diaColor,
  });

  @override
  State<AgregarProductosTab> createState() => _AgregarProductosTabState();
}

class _AgregarProductosTabState extends State<AgregarProductosTab> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  bool _guardando = false;

  Future<void> _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final precio = double.tryParse(_precioController.text.trim()) ?? 0;

    if (nombre.isEmpty || precio <= 0) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
            message: 'Ingresa un nombre y un precio válido'),
      );
      return;
    }

    setState(() => _guardando = true);

    await FirebaseFirestore.instance.collection('productos').add({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'dia': widget.diaNombre,            // ← campo clave para filtrar por día
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    _nombreController.clear();
    _precioController.clear();
    _descripcionController.clear();

    setState(() => _guardando = false);

    if (!mounted) return;

    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(message: 'Producto ingresado correctamente'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del día
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.diaColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.diaColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: widget.diaColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Nuevo producto para el ${widget.diaNombre}',
                  style: TextStyle(
                    color: widget.diaColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Formulario
          Card(
            elevation: 4,
            shadowColor: Colors.black12,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del producto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre
                  TextField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Nombre del producto',
                      prefixIcon:
                          Icon(Icons.shopping_bag, color: widget.diaColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: widget.diaColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  TextField(
                    controller: _precioController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      prefixIcon:
                          Icon(Icons.attach_money, color: widget.diaColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: widget.diaColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextField(
                    controller: _descripcionController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Descripción (opcional)',
                      alignLabelWithHint: true,
                      prefixIcon:
                          Icon(Icons.description, color: widget.diaColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: widget.diaColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: Text(_guardando ? 'Guardando…' : 'Guardar producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.diaColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      onPressed: _guardando ? null : _guardarProducto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}