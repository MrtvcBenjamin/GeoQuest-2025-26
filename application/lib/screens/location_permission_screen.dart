import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _locationGranted = false;
  bool _notificationGranted = false;

  // ---------- LOCATION ----------
  Future<void> _checkAndRequestLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte aktiviere den Standortdienst.'),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Standort ist dauerhaft verweigert. '
                'Bitte in den App-Einstellungen erlauben.',
          ),
        ),
      );
      return;
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() => _locationGranted = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Standort aktiviert ✅')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Standortberechtigung wird benötigt.'),
        ),
      );
    }
  }

  // ---------- NOTIFICATIONS ----------
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied || status.isRestricted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        setState(() => _notificationGranted = true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benachrichtigungen aktiviert ✅')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bitte Benachrichtigungen in den App-Einstellungen aktivieren.',
          ),
        ),
      );
    } else if (status.isGranted) {
      setState(() => _notificationGranted = true);
    }
  }

  void _continue() {
    if (_locationGranted) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte zuerst den Standort erlauben.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/logo.png',
                height: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Fast fertig!',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Erlaube bitte folgende Berechtigungen:',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _PermissionTile(
                icon: Icons.location_on_outlined,
                title: 'Standortzugriff',
                description:
                'Benötigt, um deine Position an Stationen zu überprüfen.',
                buttonText:
                _locationGranted ? 'Aktiviert' : 'Standort erlauben',
                buttonColor:
                _locationGranted ? Colors.green : Colors.blueAccent,
                onPressed: _locationGranted ? null : _checkAndRequestLocation,
              ),
              const SizedBox(height: 16),
              _PermissionTile(
                icon: Icons.notifications_outlined,
                title: 'Benachrichtigungen',
                description:
                'Damit wir dich über neue Aufgaben informieren können.',
                buttonText: _notificationGranted
                    ? 'Aktiviert'
                    : 'Benachrichtigungen erlauben',
                buttonColor:
                _notificationGranted ? Colors.green : Colors.grey.shade300,
                textColor:
                _notificationGranted ? Colors.white : Colors.black87,
                onPressed:
                _notificationGranted ? null : _requestNotificationPermission,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue to App'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonColor;
  final Color? textColor;
  final VoidCallback? onPressed;

  const _PermissionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor ?? Colors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
