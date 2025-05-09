//importacion de paquetes necesarios
import 'package:flutter/material.dart';
import 'package:control_de_gastos/db/db_helper.dart';
import 'package:control_de_gastos/models/gastos.dart';
import 'package:control_de_gastos/screens/new_gastos_screen.dart';
import 'package:control_de_gastos/widgets/gasto_card.dart';

// Pantalla principal de la aplicación *(HomeScreen {constructor})*
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


String formatDouble(double valor) {
  if (valor % 1 == 0) {
    return valor.toInt().toString();
  } else {
    return valor.toString();
  }
}


class _HomeScreenState extends State<HomeScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Gasto> _gastos = [];
  double _gastosFijos = 0;
  double _ingresosMensuales = 0;

  final TextEditingController _fijosController = TextEditingController();
  final TextEditingController _ingresosController = TextEditingController();

  // Método para inicializar la pantalla
  @override
  void initState() {
    super.initState();
    _cargarGastos();
    DBHelper.obtenerConfiguracion().then((valores) {
      setState(() {
      _ingresosController.text = formatDouble(valores['ingresos'] ?? 0.0);
      _fijosController.text = formatDouble(valores['gastosFijos'] ?? 0.0);
      
      _ingresosMensuales = valores['ingresos']!;
      _gastosFijos = valores['gastosFijos']!;

      });
    });
  }

  // Método para cargar los gastos desde la base de datos
  // y actualizar el estado de la pantalla
  Future<void> _cargarGastos() async {
    final gastos = await DBHelper.getGastos();
    setState(() {
      _gastos = gastos;
    });
  }

  // Método para calcular el total de gastos recientes
  // Se utiliza el método fold para sumar los montos de cada gasto
  double _calcularTotalGastosRecientes() {
    return _gastos.fold(0, (sum, item) => sum + item.monto);
  }

  // Método para calcular el posible ahorro
  // Se calcula restando los gastos fijos y el total de gastos recientes de los ingresos mensuales
  double _calcularAhorro() {
    return _ingresosMensuales - _gastosFijos - _calcularTotalGastosRecientes();
  }

  // Método para borrar todos los gastos de la base de datos
  // Se muestra un diálogo de confirmación antes de proceder a borrar
  void _borrarTodosGastos() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('¿Seguro que deseas borrar todos los gastos?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, borrar'),
              ),
            ],
          ),
    );


    if (confirmacion ?? false) {
      await DBHelper.deleteAllGastos();
      _cargarGastos();
    }
  }

  
  //interfaz de usuario de la pantalla principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Gastos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Gastos fijos
            TextField(
              controller: _fijosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Gastos Fijos'),
              onChanged: (val) {
                setState(() {
                  _gastosFijos = double.tryParse(val) ?? 0;
                });
              },
            ),

            // Ingresos mensuales
            TextField(
              controller: _ingresosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ingresos Mensuales',
              ),
              onChanged: (val) {
                setState(() {
                  _ingresosMensuales = double.tryParse(val) ?? 0;
                });
              },
            ),

            //Boton para guardar ingresos mensuales e gastos fijos
            const SizedBox(height: 10),
            ElevatedButton.icon(
              label: const Text('Guardar Ingresos y gastos'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              icon: const Icon(Icons.save),
              onPressed: () {
                final ingresos = double.tryParse(_ingresosController.text) ?? 0.0;
                final gastosFijos = double.tryParse(_fijosController.text) ?? 0.0;
                DBHelper.guardarConfiguracion(ingresos, gastosFijos);
              },
            ),

            // Posible Ahorro
            const Text(
              'Gastos Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Posible Ahorro: \$${_calcularAhorro().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),

            // Lista de gastos
            Expanded(
              child:
                  _gastos.isEmpty
                      ? const Center(child: Text('No hay gastos agregados.'))
                      : ListView.builder(
                        itemCount: _gastos.length,
                        itemBuilder: (context, index) {
                          return GastoCard(
                            gasto: _gastos[index],
                            onDeleted: () async {
                              await DBHelper.deleteGasto(_gastos[index].id!);
                              _cargarGastos();
                            },
                          );
                        },
                      ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Gasto'),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewGastosScreen(),
                        ),
                      );
                      _cargarGastos();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Borrar Todos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _borrarTodosGastos,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
