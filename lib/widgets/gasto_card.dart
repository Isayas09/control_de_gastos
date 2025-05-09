// Aqui importamos dependencias necesarias
// y el modelo de Gastos
import 'package:flutter/material.dart';
import 'package:control_de_gastos/models/gastos.dart';
import 'package:intl/intl.dart';

//Widget para mostrar cada gasto en la lista
//Este widget es un StatefulWidget porque tiene un estado interno (_expandido)
//Recibe un objeto Gasto y una función onDeleted como parámetros
// La función onDeleted se llama cuando se elimina un gasto
class GastoCard extends StatefulWidget {
  final Gasto gasto;
  final VoidCallback onDeleted;

  const GastoCard({super.key, required this.gasto, required this.onDeleted});

  @override
  State<GastoCard> createState() => _GastoCardState();
}

// Función para obtener el color según la categoría del gasto
Color obtenerColorPorCategoria(String categoria) {
  switch (categoria) {
    case 'Gasto fijo':
      return Colors.green.shade100;
    case 'Ingreso mensual':
      return Colors.green.shade200;
    case 'Posible ahorro':
      return Colors.blue.shade100;
    default:
      return Colors.grey.shade200;
  }
}

// Función para obtener el icono según la categoría del gasto
Widget iconoPorCategoria(String categoria) {
  switch (categoria) {
    case 'Gasto fijo':
      return Icon(Icons.receipt_long, color: Colors.green[700]);
    case 'Ingreso mensual':
      return Icon(Icons.attach_money, color: Colors.green[800]);
    case 'Posible ahorro':
      return Icon(Icons.savings, color: Colors.blue[700]);
    default:
      return Icon(Icons.category, color: Colors.grey);
  }
}

// Clase interna para manejar el estado del widget GastoCard
//_expandido es un booleano que indica si la tarjeta está expandida o no
class _GastoCardState extends State<GastoCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: obtenerColorPorCategoria(widget.gasto.categoria),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: iconoPorCategoria(widget.gasto.categoria),
        onTap: () {
          setState(() {
            _expandido = !_expandido;
          });
        },
        title: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Línea principal con descripción y monto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.gasto.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${widget.gasto.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmacion = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Eliminar gasto'),
                                  content: const Text(
                                    '¿Estás seguro de que deseas eliminar este gasto?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmacion == true) {
                            widget.onDeleted();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Información expandida
              if (_expandido) const SizedBox(height: 8),
              if (_expandido)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría: ${widget.gasto.categoria}'),
                    Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.gasto.fecha))}',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
