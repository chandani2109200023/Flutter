@JS()
import 'package:js/js.dart';

// JavaScript interop for requesting notification permission
@JS()
external void requestNotificationPermission(Function callback);

// JavaScript interop for geolocation
@JS()
external void getCurrentPosition(Function callback);
