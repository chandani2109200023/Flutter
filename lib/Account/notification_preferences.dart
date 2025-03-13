import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesPage extends StatefulWidget {
  @override
  _NotificationPreferencesPageState createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool pushNotifications = true;
  bool orderUpdates = true;
  bool promotionalOffers = false;
  bool accountAlerts = true;
  bool deliveryReminders = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = prefs.getBool('pushNotifications') ?? true;
      orderUpdates = prefs.getBool('orderUpdates') ?? true;
      promotionalOffers = prefs.getBool('promotionalOffers') ?? false;
      accountAlerts = prefs.getBool('accountAlerts') ?? true;
      deliveryReminders = prefs.getBool('deliveryReminders') ?? true;
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Widget _buildSwitch(
      String title, String key, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      value: value,
      onChanged: (newValue) {
        setState(() {
          onChanged(newValue);
          _savePreference(key, newValue);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification Preferences")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSwitch("Enable Push Notifications", "pushNotifications",
              pushNotifications, (val) => pushNotifications = val),
          Divider(),
          _buildSwitch("Order Updates", "orderUpdates", orderUpdates,
              (val) => orderUpdates = val),
          _buildSwitch("Promotional Offers", "promotionalOffers",
              promotionalOffers, (val) => promotionalOffers = val),
          _buildSwitch("Account Alerts", "accountAlerts", accountAlerts,
              (val) => accountAlerts = val),
          _buildSwitch("Delivery Reminders", "deliveryReminders",
              deliveryReminders, (val) => deliveryReminders = val),
          Divider(),
          _buildSwitch("Enable Sound", "soundEnabled", soundEnabled,
              (val) => soundEnabled = val),
          _buildSwitch("Enable Vibration", "vibrationEnabled", vibrationEnabled,
              (val) => vibrationEnabled = val),
        ],
      ),
    );
  }
}
