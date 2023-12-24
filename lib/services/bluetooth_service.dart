import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions({Function? onPermissionGranted}) async {
  if (await Permission.location.request().isGranted) {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      print('Permissões concedidas');
      if (onPermissionGranted != null) {
        onPermissionGranted();
      }
    } else {
      print('Permissões de Bluetooth necessárias');
    }
  } else {
    print('Permissão de localização negada');
  }
}