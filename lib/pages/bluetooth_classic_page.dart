import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../services/bluetooth_service.dart';

class BluetoothClassicPage extends StatefulWidget {
  const BluetoothClassicPage({super.key});

  @override
  _BluetoothClassicPageState createState() => _BluetoothClassicPageState();
}

class _BluetoothClassicPageState extends State<BluetoothClassicPage> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDiscoveryResult> _devicesList = [];
  bool _isScanning = false;
  BluetoothConnection? _connection;
  bool _isConnected = false;
  String _lastReceivedData = '';
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    requestPermissions(onPermissionGranted: _getPairedDevices);
  }

  void _getPairedDevices() async {
    var bluetoothState = await _bluetooth.state;
    if (bluetoothState == BluetoothState.STATE_ON) {
      try {
        var devices = await _bluetooth.getBondedDevices();
        setState(() {
          _devicesList = devices.map((d) => BluetoothDiscoveryResult(device: d)).toList();
        });
      } on Exception {
        // Tratar exceções aqui
      }
    } else if (bluetoothState == BluetoothState.STATE_OFF) {
      await _bluetooth.requestEnable();
      _getPairedDevices();
    }
  }

  // void _startScan() async {
  //   var bluetoothState = await _bluetooth.state;
  //
  //   if (bluetoothState == BluetoothState.STATE_ON) {
  //     setState(() {
  //       _devicesList = [];
  //       _isScanning = true;
  //     });
  //
  //     _bluetooth.startDiscovery().listen((r) {
  //       setState(() => _devicesList.add(r));
  //     }).onDone(() => setState(() => _isScanning = false));
  //   } else {
  //     await _bluetooth.requestEnable();
  //     _startScan();
  //   }
  // }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      var connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        _isConnected = true;
        _connectedDevice = device;
      });
      connection.input!.listen(_onDataReceived).onDone(() {
        if (_isConnected) {
          _disconnect();
        }
      });
    } catch (e) {
      print("Erro ao conectar: $e");
    }
  }

  void _onDataReceived(Uint8List data) {
    setState(() {
      print(String.fromCharCodes(data));
      print(data.buffer.asByteData().getInt32(0));
      _lastReceivedData = String.fromCharCodes(data);
    });
  }

  void _disconnect() async {
    await _connection?.close();
    setState(() {
      _isConnected = false;
      _connectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Classic')),
      body: Column(
        children: [
          if (_isConnected && _connectedDevice != null)
            Column(
              children: [
                ListTile(
                  title: Text(_connectedDevice!.name ?? "Unknown device"),
                  subtitle: Text('Conectado'),
                  trailing: ElevatedButton(
                    onPressed: _disconnect,
                    child: const Text('Desconectar'),
                  ),
                ),
                Text('Último dado recebido: $_lastReceivedData'),
              ],
            ),
          if (!_isConnected)
            Expanded(
              child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (context, index) {
                  var result = _devicesList[index];
                  return ListTile(
                    title: Text(result.device.name ?? "Unknown device"),
                    subtitle: Text(result.device.address.toString()),
                    onTap: () => _connect(result.device),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
