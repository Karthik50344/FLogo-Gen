import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfo {
  DeviceInfo._();

  static String version = "1.0.0";
  static String buildNumber = "1";

  static Future<void> loadDeviceInfo() async{
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version.toString();
      buildNumber = info.buildNumber.toString();
    }catch(e, stack){
      debugPrint("Error in loadDeviceInfo: $e. \n Stack Trace: $stack");
    }
  }
}