import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Imagen extends StatefulWidget {
  const Imagen({super.key});

  @override
  State<Imagen> createState() => _ImagenState();
}

class _ImagenState extends State<Imagen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imagen;

  Future<void> _elegirDesde(ImageSource origen) async {
    //obteniendo la imagen
    final XFile? archivo = await _picker.pickImage(
      source: origen, // seleccionando de donde captura la imagen. O galeria o camara
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (!mounted) return;
    if (archivo != null) {
      setState(() => _imagen = archivo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _elegirDesde(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _elegirDesde(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Cámara'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: _imagen == null
                  ? Text(
                      'Toca Galería o Cámara',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder(
                        key: ValueKey(_imagen!.path),
                        future: _imagen!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError || snapshot.data == null) {
                            return const Text('No se pudo mostrar la imagen');
                          }
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
