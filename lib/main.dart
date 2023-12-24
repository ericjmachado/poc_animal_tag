import 'package:flutter/material.dart';
import 'package:poc_animal_tag/pages/ble_page.dart';
import 'package:poc_animal_tag/pages/bluetooth_classic_page.dart'; // Substitua pelo caminho correto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedDrawerIndex = 0;

  void _onSelectItem(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    Navigator.of(context).pop(); // Fecha o Drawer
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _selectedDrawerIndex == 0
        ? const BluetoothClassicPage() // Substitua pela sua página Bluetooth Classic
        : const BLEPage(); // Substitua pela sua página BLE

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Bluetooth Demo')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Bluetooth Options'),
            ),
            ListTile(
              title: const Text('Bluetooth Classic'),
              selected: _selectedDrawerIndex == 0,
              onTap: () => _onSelectItem(0),
            ),
            ListTile(
              title: const Text('BLE'),
              selected: _selectedDrawerIndex == 1,
              onTap: () => _onSelectItem(1),
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}