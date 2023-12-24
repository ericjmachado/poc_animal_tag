import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/bluetooth_service.dart';

class BLEPage extends StatefulWidget {
  const BLEPage({super.key});

  @override
  _BLEPageState createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResults = [];
  BluetoothDevice? selectedDevice;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }


  void scanForDevices() {
    setState(() {
      isScanning = true;
      scanResults = [];
    });

    flutterBlue.startScan(timeout: const Duration(seconds: 30));

    var subscription = flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    flutterBlue.stopScan().then((_) {
      subscription.cancel();
      setState(() {
        isScanning = false;
      });
    });
  }


  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      selectedDevice = device;
    });
    discoverServices(device);
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        var value = await characteristic.read();
        print('Dados do dispositivo: $value');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter BLE Demo'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : scanForDevices,
            child: Text(isScanning ? 'Escaneando...' : 'Escanear'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(scanResults[index].device.name ?? "Unknown device"),
                  subtitle: Text(scanResults[index].device.id.toString()),
                  onTap: () => connectToDevice(scanResults[index].device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}