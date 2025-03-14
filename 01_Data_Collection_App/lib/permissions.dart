import 'package:permission_handler/permission_handler.dart';

void requestStoragePermission() async {
  var status = await Permission.storage.status;
  print('Current storage permission status: $status');  // Log current status
  if (!status.isGranted) {
    print('Requesting storage permission');
    status = await Permission.storage.request();
    print('New storage permission status: $status');  // Log updated status
  }
  //return status.isGranted;
}