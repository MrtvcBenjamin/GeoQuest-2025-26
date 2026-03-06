# GeoQuest Production Hardening

## 1) E-Mail-Zustellung (Spam/Verzögerung) stabilisieren
- In Firebase Authentication eine benutzerdefinierte Absenderdomain verwenden.
- DNS korrekt konfigurieren: `SPF`, `DKIM`, `DMARC` (Alignment mit der Absenderdomain).
- In Microsoft 365 (Schule) den Absender bzw. die Domain auf Allowlist setzen.
- Defender/Exchange Quarantäne und Anti-Phishing-Policies prüfen.
- E-Mail-Templates kurz und neutral halten, keine "spammy" Formulierungen, keine unnötigen Links.

Hinweis:
- Die App kann Spam-Filter und Mail-Laufzeiten nicht vollständig clientseitig steuern.
- Die im UI eingebauten Hinweise (Spam-Ordner, mögliche Verzögerung bei Schul-Mails) bleiben wichtig.

## 2) Firestore-Regeln serverseitig härten
- Zugriff strikt auf eigene User-Daten begrenzen.
- Schreibzugriffe auf Punkte-/Ranking-Felder nur über vertrauenswürdigen Backend-Pfad erlauben.
- Admin-Pfade explizit rollenbasiert einschränken.
- Regeln mit Emulator-Tests verifizieren.

Beispiel-Regeln liegen in [firestore.rules](/c:/Users/tobia/Documents/GitHub/GeoQuest-2025-26/application/firestore.rules).

## 3) Kritische Logik in Cloud Functions verlagern
- Punktevergabe und Abschluss-Logik serverseitig validieren.
- Client sendet nur Ereignis (z. B. Station abgeschlossen), Server berechnet finale Punktänderung.
- Ungültige Übergänge (falsche Station, mehrfaches Scoring) serverseitig blockieren.

## 4) Monitoring in Produktion
- Firebase Crashlytics aktivieren.
- Analytics-Dashboard für Kernereignisse beobachten:
  - Login/Signup Fehlerquote
  - QR-Scan Erfolgsquote
  - Abschlussrate pro Station
  - Anti-Cheat-Block-Häufigkeit

## 5) Betriebscheck vor Release
- `flutter analyze` ohne Fehler.
- Widget- und Integration-Tests grün.
- Ein kompletter End-to-End-Durchlauf mit echten Firebase-Daten.

