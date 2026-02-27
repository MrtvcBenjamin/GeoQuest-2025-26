import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _locationAllowed = false;
  bool _notificationsAllowed = false;

  void _continueToApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/logo.png', height: 80),
              const SizedBox(height: 16),
              Text(
                'GeoQuest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                tr('Fast fertig!\nErlaube bitte folgende Berechtigungen:',
                    'Almost done!\nPlease allow the following permissions:'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.80),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on,
                      color: scheme.onSurface.withValues(alpha: 0.85)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tr('Standortzugriff\nBenötigt, um deine Position an Stationen zu überprüfen.',
                          'Location access\nRequired to verify your position at stations.'),
                      style:
                          TextStyle(color: scheme.onSurface.withValues(alpha: 0.85)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() => _locationAllowed = true);
                  },
                  child: Text(
                    tr('Standort erlauben', 'Allow location'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _locationAllowed
                      ? tr('Aktiviert', 'Enabled')
                      : tr('Noch nicht erlaubt', 'Not allowed yet'),
                  style: TextStyle(
                    color: _locationAllowed
                        ? Colors.green
                        : scheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notifications,
                      color: scheme.onSurface.withValues(alpha: 0.85)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tr('Benachrichtigungen\nDamit du über neue Aufgaben informiert wirst.',
                          'Notifications\nTo inform you about new tasks.'),
                      style:
                          TextStyle(color: scheme.onSurface.withValues(alpha: 0.85)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() => _notificationsAllowed = true);
                  },
                  child: Text(
                    tr('Benachrichtigungen erlauben', 'Allow notifications'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _notificationsAllowed
                      ? tr('Aktiviert', 'Enabled')
                      : tr('Noch nicht erlaubt', 'Not allowed yet'),
                  style: TextStyle(
                    color: _notificationsAllowed
                        ? Colors.green
                        : scheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _continueToApp,
                  child: Text(
                    tr('Zur App', 'Continue to app'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

