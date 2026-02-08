# Teilaufgabe Schüler Kovacs
\textauthor{Christian Kovacs}

## Theorie

Dieses Kapitel dient als theoretische Grundlage für die im weiteren Verlauf beschriebene praktische Umsetzung einer standortbasierten Schnitzeljagd-Applikation. Ziel ist es, auch Leserinnen und Lesern ohne vertiefte Kenntnisse im Bereich mobiler App-Entwicklung ein grundlegendes Verständnis der eingesetzten Technologien, Konzepte und Architekturentscheidungen zu vermitteln.

Die vorgestellten Inhalte bilden den notwendigen Kontext, um die praktischen Implementierungen nachvollziehen und bewerten zu können.

---

### 1. Grundlagen mobiler Applikationen

Mobile Applikationen sind Softwareprogramme, die speziell für den Einsatz auf mobilen Endgeräten wie Smartphones oder Tablets entwickelt werden. Sie unterscheiden sich von klassischen Desktop-Anwendungen insbesondere durch:

- eingeschränkte Hardware-Ressourcen (Akku, Rechenleistung)
- die Notwendigkeit energieeffizienter Programmierung
- den Umgang mit Sensoren (z. B. GPS, Kamera)
- wechselnde Netzwerkverbindungen
- asynchrone Abläufe

Insbesondere standortbasierte Anwendungen stellen hohe Anforderungen an Performance, Genauigkeit und Sicherheit, da sie kontinuierlich Sensordaten verarbeiten und oft personenbezogene Informationen speichern.

---

### 2. Flutter als Entwicklungsframework

Flutter ist ein von Google entwickeltes Open-Source-Framework zur plattformübergreifenden Entwicklung mobiler Applikationen. Mit einer einzigen Codebasis können Anwendungen für Android, iOS, Web und Desktop erstellt werden.

#### 2.1 Vorteile von Flutter

- **Plattformübergreifend:** Ein Code für mehrere Betriebssysteme
- **Hohe Performance:** Direkte Kompilierung zu nativen Maschinencode
- **Reaktive UI:** Benutzeroberflächen werden deklarativ beschrieben
- **Hot Reload:** Änderungen sind sofort sichtbar
- **Große Community:** Umfangreiche Dokumentation und Paketlandschaft

Die Programmiersprache Dart unterstützt asynchrone Programmierung durch `Future`, `async` und `await`, was für Netzwerk- und Standortabfragen essenziell ist.

---

### 3. Firebase als Backend-Plattform

Firebase ist eine Backend-as-a-Service-Plattform (BaaS), die eine Vielzahl von Diensten für mobile Anwendungen bereitstellt. In dieser Diplomarbeit werden insbesondere Firebase Authentication und Cloud Firestore verwendet.

---

### 3.1 Firebase Authentication

Firebase Authentication ermöglicht eine sichere Benutzerregistrierung und -anmeldung. Nach erfolgreicher Authentifizierung erhält jeder Benutzer eine eindeutige Kennung (UID).

Diese UID dient als zentrales Referenzelement für:
- Benutzerprofile
- Standortdaten
- Spielfortschritt

Vorteile:
- Keine eigene Passwortverwaltung notwendig
- Sichere Token-basierte Authentifizierung
- Unterstützung mehrerer Login-Methoden

---

### 3.2 Cloud Firestore

Cloud Firestore ist eine skalierbare NoSQL-Datenbank, die Daten in Form von Collections und Documents speichert.

#### Eigenschaften von Firestore:
- Dokumentenbasiertes Datenmodell
- Echtzeit-Synchronisation
- Offline-Unterstützung
- Flexible Datenstrukturen
- Integrierte Sicherheitsregeln

Firestore eignet sich besonders für mobile Anwendungen, da gezielte Datenabfragen mit geringer Latenz möglich sind.

---

### 4. NoSQL-Datenmodellierung

Im Gegensatz zu relationalen Datenbanken verwendet Firestore kein Tabellenmodell mit festen Beziehungen, sondern ein dokumentenorientiertes Schema.

#### Zentrale Konzepte:
- **Collection:** Sammlung von Dokumenten
- **Document:** JSON-ähnliche Datenstruktur
- **Subcollection:** Verschachtelte Collection inner


## Praktische Arbeit

In diesem Kapitel wird die praktische Umsetzung der standortbasierten Schnitzeljagd-Applikation detailliert beschrieben. Ziel ist es, alle wesentlichen technischen Entscheidungen, Implementierungsschritte und Zusammenhänge so darzustellen, dass der gesamte Entwicklungsprozess auch ohne Einsicht in den Quellcode nachvollziehbar bleibt.

Der praktische Teil orientiert sich an den im Projekthandbuch definierten Anforderungen und baut direkt auf den im Theorieteil beschriebenen Grundlagen auf.

---

### 1. Gesamtarchitektur der Anwendung

Die Anwendung folgt einer klaren Trennung der Verantwortlichkeiten und ist modular aufgebaut. Die wichtigsten Komponenten sind:

- **UI-Schicht (Flutter Widgets)**  
  Darstellung der Benutzeroberfläche, Kartenansicht und Dialoge

- **Logik-Schicht**  
  Standortermittlung, Proximity-Erkennung, Spielfortschritt

- **Datenzugriffsschicht**  
  Firebase Authentication und Cloud Firestore

Diese Trennung erleichtert Wartung, Erweiterung und Fehlersuche.

---

### 2. Benutzerverwaltung

#### 2.1 Registrierung und Authentifizierung

Die Benutzerregistrierung erfolgt über Firebase Authentication. Jeder Benutzer meldet sich mit einer gültigen E-Mail-Adresse an und erhält nach erfolgreicher Anmeldung eine eindeutige Benutzer-ID (UID).

Diese UID wird in der gesamten Anwendung als primärer Identifikator verwendet.

---

#### 2.2 Speicherung des Benutzerprofils

Nach der Registrierung wird ein Benutzerprofil in der Firestore-Collection `Users` gespeichert.

**Datenmodell Users:**

- Collection: `Users`
- Dokument-ID: `UID`
- Felder:
  - `username`
  - `totalPoints`
  - `createdAt`

**Implementierung:**

```dart
Future<void> saveUserInDatabase(String username) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('Users')
      .doc(user.uid)
      .set({
        'username': username,
        'totalPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
}

---

### 2.3 Query- und Access-Pattern der Benutzerverwaltung

Für die Benutzerverwaltung wurden bewusst einfache und effiziente Zugriffsstrukturen gewählt, um sowohl Performance als auch Sicherheit zu gewährleisten.

#### Query Pattern

- Direkter Zugriff auf ein einzelnes Dokument über  
  `Users/{uid}`  
- Es handelt sich um einen sogenannten *Point Read*, der in Firestore besonders performant ist.

Dieses Query Pattern wird verwendet, sobald ein Benutzer nach der Anmeldung seine eigenen Profildaten lädt.

#### Access Pattern

- **Schreiben:**  
  Nur der authentifizierte Benutzer darf sein eigenes Dokument ändern.
- **Lesen:**  
  Das Lesen von Benutzerinformationen ist erlaubt, da beispielsweise Benutzernamen für Spielanzeigen benötigt werden.

Dieses Access Pattern wird durch Firestore Security Rules abgesichert.

---

## 3. Standortermittlung

### 3.1 Motivation und technische Umsetzung

Für eine standortbasierte Schnitzeljagd ist eine kontinuierliche Standortüberwachung erforderlich. Ein einmaliger Standortabruf wäre unzureichend, da Bewegungen in Echtzeit erkannt werden müssen, um das Erreichen von Stationen korrekt zu erfassen.

Aus diesem Grund wird ein Standort-Stream verwendet, der regelmäßig aktualisierte Positionsdaten liefert.

---

### 3.2 Starten des Standort-Streams

Der Standort-Stream wird mit speziell abgestimmten Parametern gestartet, um eine hohe Genauigkeit bei gleichzeitig kontrolliertem Ressourcenverbrauch zu gewährleisten.

```dart
const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  distanceFilter: 2,
);

Bedeutung der Einstellungen:

accuracy: bestForNavigation
Maximale Genauigkeit für Bewegungen im Außenbereich.

distanceFilter: 2
Standort-Updates erfolgen erst nach einer Bewegung von mindestens zwei Metern.

### 3.3 Verwaltung des Standort-Streams

Zur sauberen Verwaltung des Standort-Streams wird eine StreamSubscription verwendet.

StreamSubscription<Position>? _positionStream;


Beim Verlassen der Kartenansicht wird der Stream ordnungsgemäß beendet:

@override
void dispose() {
  _positionStream?.cancel();
  super.dispose();
}


Dies verhindert unnötigen Akkuverbrauch sowie Speicherlecks.

---

## 4. Kartenintegration
### 4.1 Darstellung mit OpenStreetMap

Die Kartenansicht wird mit dem Paket flutter_map umgesetzt. Als Kartenquelle wird OpenStreetMap verwendet, da keine Lizenzkosten entstehen und keine Abhängigkeit von kommerziellen Anbietern besteht.

TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.app',
  tileProvider: NetworkTileProvider(),
)

### 4.2 Marker-Darstellung

Zur besseren Orientierung werden unterschiedliche Markerfarben verwendet:

Blauer Marker: Aktuelle Position des Spielers

Roter Marker: Aktive, noch nicht abgeschlossene Station

Grüner Marker: Bereits abgeschlossene Stationen

Diese visuelle Codierung verbessert die Benutzerfreundlichkeit erheblich.

## 5. Datenmodell und Firestore-Struktur
### 5.1 Users

Collection: Users
Dokument-ID: UID des Benutzers

Felder:

username

totalPoints

createdAt

### 5.2 Hunts und Stadions

Pfad: Hunts/{huntId}/Stadions

Felder:

stadionIndex

title

stadionLocation (GeoPoint)

Future<void> getAllStadionData(String huntId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("Hunts")
      .doc(huntId)
      .collection("Stadions")
      .orderBy("stadionIndex")
      .get();

  setState(() {
    allStadionData = snapshot.docs.map((doc) => doc.data()).toList();
  });
}

Query Pattern

Zugriff auf eine Subcollection

Sortierung nach stadionIndex

Dieses Pattern ermöglicht eine sequentielle Freischaltung der Stationen.

### 5.3 PlayerLocation

Collection: PlayerLocation
Dokument-ID: UID des Benutzers

Future<void> saveLocationInDatabase(LatLng? position) async {
  final user = FirebaseAuth.instance.currentUser;
  if (position == null || user == null) return;

  await FirebaseFirestore.instance
      .collection("PlayerLocation")
      .doc(user.uid)
      .set({
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      });
}

Access Pattern

Schreiben nur für authentifizierte Benutzer

Lesen optional für andere Spieler (Mehrspieler-Szenario)

## 6. Proximity-Erkennung (Stationslogik)
### 6.1 Distanzberechnung
double distanceInMeters = Geolocator.distanceBetween(
  myPosition!.latitude,
  myPosition!.longitude,
  targetGeo.latitude,
  targetGeo.longitude,
);

### 6.2 Radius-Logik
if (distanceInMeters < 50) {
  _showDiscoveryDialog(aktuellesZiel['title'] ?? "Stadion");
  saveLocationInDatabase(myPosition);
}


Der Radius von 50 Metern stellt einen praxisnahen Kompromiss zwischen Genauigkeit und Benutzerfreundlichkeit dar.

## 7. Fortschritt und Benutzerinteraktion

Beim Erreichen einer Station wird:

ein Dialog angezeigt,

der Standort-Stream pausiert,

der Fortschritt erhöht,

der Stream anschließend fortgesetzt.

_positionStream?.pause();
// Dialog anzeigen
_positionStream?.resume();

## 8. Sicherheitskonzept
### 8.1 Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /Users/{userId} {
      allow write: if request.auth != null && request.auth.uid == userId;
      allow read;
    }

    match /PlayerLocation/{docId} {
      allow write: if request.auth != null;
      allow read: if request.auth != null;
    }
  }
}


Diese Regeln stellen sicher, dass Benutzer ausschließlich ihre eigenen Daten verändern können und Standortdaten nur für authentifizierte Nutzer zugänglich sind.

## 9. Erweiterte Standortlogik und kontinuierliches Tracking

### 9.1 Motivation für kontinuierliches Tracking

In klassischen Kartenanwendungen reicht es häufig aus, den Standort eines Benutzers einmalig zu erfassen. Für eine standortbasierte Schnitzeljagd ist dieses Vorgehen jedoch nicht ausreichend. Spieler bewegen sich kontinuierlich im Gelände, und das System muss in der Lage sein, diese Bewegungen zuverlässig und zeitnah zu erkennen.

Ein kontinuierliches Standort-Tracking ermöglicht:

- das automatische Erkennen des Erreichens einer Station
- die Vermeidung manueller Aktionen durch den Benutzer
- eine realistische und immersive Spielerfahrung
- die Grundlage für Anti-Cheat-Mechanismen

---

### 9.2 Initialisierung der Standortlogik

Die Standortlogik wird beim Start der Kartenansicht initialisiert. Dabei ist wichtig, dass zuerst alle notwendigen Spieldaten geladen werden, bevor das Tracking beginnt.

```dart
@override
void initState() {
  super.initState();
  _loadMyLocation();
  _initData();
}
Die Methode _initData() übernimmt dabei eine koordinierende Rolle:

Future<void> _initData() async {
  await getAllStadionData("xISAk6mXjjEpDUHYyxZi");
  await _startLocationTracking();

  if (mounted) {
    setState(() => isLoading = false);
  }
}
Dieses Vorgehen stellt sicher, dass:

alle Zielpunkte bekannt sind

Standortdaten nicht ins Leere verarbeitet werden

keine unnötigen Berechnungen stattfinden

### 9.3 Starten des Standort-Streams
Der Standort-Stream wird mit hoher Genauigkeit und kleinem Distanzfilter gestartet, um eine präzise Bewegungserkennung zu ermöglichen.

const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  distanceFilter: 2,
);
Begründung der Parameterwahl:

Hohe Genauigkeit ist notwendig, um kurze Distanzen zuverlässig zu messen

Der Distanzfilter reduziert unnötige Updates im Stillstand

Der Akkuverbrauch bleibt kontrollierbar

### 9.4 Verarbeitung von Standort-Updates
Jede neue Positionsmeldung wird verarbeitet, der interne Zustand aktualisiert und anschließend geprüft, ob eine Station erreicht wurde.

_positionStream = Geolocator.getPositionStream(
  locationSettings: locationSettings,
).listen((Position pos) {
  if (mounted) {
    setState(() {
      myPosition = LatLng(pos.latitude, pos.longitude);
    });
    _checkProximity();
  }
});
Diese Architektur erlaubt eine klare Trennung zwischen:

Datenerfassung

Zustandsverwaltung

Spiellogik

## 10. Proximity-Erkennung und Stationslogik
### 10.1 Grundprinzip der Proximity-Erkennung
Die Proximity-Erkennung basiert auf der Berechnung der Luftlinie zwischen der aktuellen Spielerposition und der Zielstation. Firestore speichert die Koordinaten als GeoPoint, welche zur Laufzeit in Distanzen umgerechnet werden.

double distanceInMeters = Geolocator.distanceBetween(
  myPosition!.latitude,
  myPosition!.longitude,
  targetGeo.latitude,
  targetGeo.longitude,
);
### 10.2 Radius-basierte Freischaltung
Sobald sich der Spieler innerhalb eines definierten Radius befindet, wird die Station als erreicht gewertet.

if (distanceInMeters < 50) {
  _showDiscoveryDialog(aktuellesZiel['title'] ?? "Stadion");
  saveLocationInDatabase(myPosition);
}
Der Radius von 50 Metern wurde bewusst gewählt:

GPS-Signale unterliegen natürlichen Schwankungen

Gebäude und Gelände beeinflussen die Genauigkeit

Ein zu kleiner Radius würde zu Frustration führen

### 10.3 Fortschrittsverwaltung
Der Fortschritt wird sequenziell verwaltet. Nur die nächste Station kann freigeschaltet werden, vorherige gelten als abgeschlossen.

setState(() {
  currentStadionIndex++;
});
Dieses Vorgehen verhindert:

das Überspringen von Stationen

ungewollte Mehrfachauslösungen

inkonsistente Spielzustände

## 11. Benutzerinteraktion und Dialogsteuerung
### 11.1 Anzeige des Entdeckungsdialogs
Beim Erreichen einer Station wird ein Dialog angezeigt, der den Erfolg visuell bestätigt.

void _showDiscoveryDialog(String name) {
  _positionStream?.pause();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Icon(Icons.emoji_events, color: Colors.yellow, size: 50),
      content: Text("Glückwunsch! Du hast das $name erreicht!"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              currentStadionIndex++;
            });
            _positionStream?.resume();
          },
          child: const Text("Okay"),
        ),
      ],
    ),
  );
}
### 11.2 Pausieren und Fortsetzen des Standort-Streams
Während der Dialog angezeigt wird, wird der Standort-Stream pausiert:

_positionStream?.pause();
Nach Bestätigung wird das Tracking fortgesetzt:

_positionStream?.resume();
Dies verhindert Mehrfachauslösungen und reduziert unnötige Rechenlast.

## 12. Speicherung von Standortdaten
### 12.1 Zweck der Standortpersistenz
Die Speicherung von Standortdaten dient mehreren Zwecken:

Debugging während der Entwicklung

Analyse von Spielverläufen

Grundlage für spätere Erweiterungen (Statistiken, Heatmaps)

### 12.2 Implementierung der Speicherung
Future<void> saveLocationInDatabase(LatLng? position) async {
  final user = FirebaseAuth.instance.currentUser;
  if (position == null || user == null) return;

  await FirebaseFirestore.instance
      .collection("PlayerLocation")
      .doc(user.uid)
      .set({
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      });
}
Die Speicherung erfolgt ausschließlich:

nach erfolgreicher Standortermittlung

bei authentifiziertem Benutzer

##13. Query- und Access-Pattern im Gesamtsystem
### 13.1 Benutzerbezogene Zugriffe
Query Pattern:

Direkter Zugriff über Users/{uid}

Access Pattern:

Schreiben nur für den eigenen Benutzer

Lesen für Anzeigezwecke erlaubt

### 13.2 Stationsdaten
Query Pattern:

Subcollection-Zugriff

Sortierung nach stadionIndex

Dieses Pattern ermöglicht eine klare Spielreihenfolge.

### 13.3 Standortdaten
Query Pattern:

Direkter Zugriff auf PlayerLocation/{uid}

Access Pattern:

Schreiben nur für authentifizierte Benutzer

Optionales Lesen für Mehrspieler-Ansichten

## 14. Fehlerbehandlung und Robustheit
### 14.1 Typische Fehlerquellen
Standortdienst deaktiviert

Fehlende Berechtigungen

Ungenaue GPS-Daten

Netzwerkunterbrechungen

### 14.2 Defensive Programmierung
Das System überprüft konsequent alle kritischen Zustände:

if (position == null || user == null) return;
Dadurch werden Laufzeitfehler vermieden und die Stabilität erhöht.

## 15. Wartbarkeit und Erweiterbarkeit
Die entwickelte Architektur ist modular aufgebaut und erlaubt:

Erweiterung um neue Spielmodi

Integration zusätzlicher Kartenlayer

Erweiterung um Anti-Cheat-Mechanismen

Nutzung historischer Standortdaten

Durch die klare Trennung von:

UI

Standortlogik

Datenpersistenz

Sicherheitsregeln

bleibt das System auch bei wachsendem Funktionsumfang wartbar.
