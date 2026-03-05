# Teilaufgabe Schüler Kovacs
\textauthor{Christian Kovacs}

## Theorie

Dieses Kapitel dient als theoretische Grundlage für die im weiteren Verlauf beschriebene praktische Umsetzung einer standortbasierten Schnitzeljagd-Applikation. Ziel ist es, auch Leserinnen und Lesern ohne vertiefte Kenntnisse im Bereich mobiler App-Entwicklung ein grundlegendes Verständnis der eingesetzten Technologien, Konzepte und Architekturentscheidungen zu vermitteln. Die vorgestellten Inhalte bilden den notwendigen Kontext, um die praktischen Implementierungen nachvollziehen und bewerten zu können.

### 1. Grundlagen mobiler Applikationen

Mobile Applikationen sind Softwareprogramme, die speziell für den Einsatz auf mobilen Endgeräten wie Smartphones oder Tablets entwickelt werden. Sie unterscheiden sich von klassischen Desktop-Anwendungen insbesondere durch eingeschränkte Hardware-Ressourcen (Akku, Rechenleistung), die Notwendigkeit energieeffizienter Programmierung, den Umgang mit Sensoren (z. B. GPS, Kamera), wechselnde Netzwerkverbindungen und asynchrone Abläufe.

Insbesondere standortbasierte Anwendungen stellen hohe Anforderungen an Performance, Genauigkeit und Sicherheit, da sie kontinuierlich Sensordaten verarbeiten und oft personenbezogene Informationen speichern. Standortdaten gelten in der Praxis als besonders sensibel, weil sie Rückschlüsse auf Bewegungsprofile zulassen. Daraus ergeben sich erhöhte Anforderungen an Datensparsamkeit, Zugriffskontrolle und nachvollziehbare Sicherheitsmechanismen.

#### 1.1 Standortbestimmung und Messfehler

In der Alltagssprache wird häufig von „GPS“ gesprochen, technisch handelt es sich meist um GNSS (Global Navigation Satellite Systems). Smartphones kombinieren mehrere Quellen, um eine möglichst stabile Position zu liefern. Dazu gehören Satellitensignale, Mobilfunkzellen, WLAN-Informationen sowie Sensorfusion (z. B. Beschleunigungs- und Gyrosensor). In dicht bebauten Bereichen oder bei Abschattung (Gebäude, Wald) kann die Genauigkeit schwanken. Die Folge sind Positionen, die „springen“ oder sich trotz Stillstand leicht verändern.

Für GeoQuest ist daher weniger die theoretisch exakteste Position entscheidend, sondern ein robustes Systemverhalten: Stationen werden innerhalb eines toleranten Radius freigeschaltet, und das System reduziert unnötige Updates, die nur durch Messrauschen entstehen.

#### 1.2 Energieverbrauch und Effizienz

Kontinuierliches Standorttracking zählt zu den energieintensivsten Funktionen mobiler Geräte. Hohe Genauigkeit führt zu höherem Akkuverbrauch, weil Sensoren häufiger aktiv sind. Zusätzlich können Netzwerkverkehr und Datenbankzugriffe entstehen, wenn Positionen gespeichert werden. Aus diesem Grund setzen mobile Anwendungen Filtermechanismen ein. Ein typischer Mechanismus ist ein Distanzfilter: Updates werden nur dann als relevant behandelt, wenn sich der Nutzer um mindestens eine bestimmte Distanz bewegt hat. Dadurch werden Rechenlast, Akkuverbrauch und Backend-Kosten reduziert.

### 2. Flutter als Entwicklungsframework

Flutter ist ein von Google entwickeltes Open-Source-Framework zur plattformübergreifenden Entwicklung mobiler Applikationen. Mit einer einzigen Codebasis können Anwendungen für Android, iOS, Web und Desktop erstellt werden.

#### 2.1 Vorteile von Flutter

- Plattformübergreifend: Ein Code für mehrere Betriebssysteme
- Hohe Performance: Direkte Kompilierung zu nativen Maschinencode
- Reaktive UI: Benutzeroberflächen werden deklarativ beschrieben
- Hot Reload: Änderungen sind sofort sichtbar
- Große Community: Umfangreiche Dokumentation und Paketlandschaft

Die Programmiersprache Dart unterstützt asynchrone Programmierung durch `Future`, `async` und `await`, was für Netzwerk- und Standortabfragen essenziell ist.

#### 2.2 Technischer Hintergrund: Dart, Futures und Streams

Dart verwendet ein Event-Loop-Prinzip. Damit bleibt die Benutzeroberfläche responsiv, auch wenn Netzwerkzugriffe oder Sensorabfragen laufen. Ein Future steht für ein einmaliges Ergebnis in der Zukunft (z. B. „Dokument aus Firestore laden“). Ein Stream steht für eine Folge von Ereignissen (z. B. Standortupdates). GeoQuest nutzt Streams, weil Standortdaten nicht einmalig, sondern fortlaufend anfallen. Dadurch ist das Programmiermodell klar: Der Code reagiert auf neue Events, statt aktiv ständig nach neuen Daten zu fragen.

### 3. Firebase als Backend-Plattform

Firebase ist eine Backend-as-a-Service-Plattform (BaaS), die eine Vielzahl von Diensten für mobile Anwendungen bereitstellt. In dieser Diplomarbeit werden insbesondere Firebase Authentication und Cloud Firestore verwendet.

Ein BaaS-Ansatz verschiebt typische Serveraufgaben in einen verwalteten Cloud-Dienst. Das reduziert Administrationsaufwand (Serverbetrieb, Updates, Skalierung) und erlaubt, sich stärker auf die Anwendungslogik zu konzentrieren. Gleichzeitig verschiebt sich Verantwortung in Richtung Konfiguration und Sicherheitsregeln: Security Rules ersetzen in vielen Fällen klassische serverseitige Zugriffskontrollen.

#### 3.1 Firebase Authentication

Firebase Authentication ermöglicht eine sichere Benutzerregistrierung und -anmeldung. Nach erfolgreicher Authentifizierung erhält jeder Benutzer eine eindeutige Kennung (UID). Diese UID dient als zentrales Referenzelement für Benutzerprofile, Standortdaten und Spielfortschritt.

Vorteile:
- Keine eigene Passwortverwaltung notwendig
- Sichere Token-basierte Authentifizierung
- Unterstützung mehrerer Login-Methoden

Technisch basiert Firebase Authentication auf Tokens (ID Tokens, meist JWT). Beim Zugriff auf Firestore wird serverseitig geprüft, ob das Token gültig ist. In den Security Rules ist die Identität dann über `request.auth.uid` verfügbar. Damit kann Firestore ohne eigenen Server sicher entscheiden, ob ein Zugriff erlaubt ist.

#### 3.2 Cloud Firestore

Cloud Firestore ist eine skalierbare NoSQL-Datenbank, die Daten in Form von Collections und Documents speichert.

Eigenschaften von Firestore:
- Dokumentenbasiertes Datenmodell
- Echtzeit-Synchronisation
- Offline-Unterstützung
- Flexible Datenstrukturen
- Integrierte Sicherheitsregeln

Firestore eignet sich besonders für mobile Anwendungen, da gezielte Datenabfragen mit geringer Latenz möglich sind. Zusätzlich bietet Firestore einen lokalen Cache, wodurch Daten auch bei kurzzeitig schlechter Verbindung verfügbar bleiben. Wichtig ist dabei: Der Cache ersetzt nicht die serverseitige Sicherheitsprüfung. Security Rules werden serverseitig angewandt, bevor Writes final akzeptiert werden.

### 4. NoSQL-Datenmodellierung

Im Gegensatz zu relationalen Datenbanken verwendet Firestore kein Tabellenmodell mit festen Beziehungen, sondern ein dokumentenorientiertes Schema.

Zentrale Konzepte:
- Collection: Sammlung von Dokumenten
- Document: JSON-ähnliche Datenstruktur
- Subcollection: Verschachtelte Collection innerhalb eines Dokuments

#### 4.1 Query-driven Data Modeling

Ein wichtiger Unterschied zu relationalen Datenbanken ist, dass Firestore keine Joins wie in SQL unterstützt. Daraus folgt: Das Datenmodell wird stark nach den Abfragen gestaltet, die die Anwendung tatsächlich benötigt. Dieses Prinzip wird als query-driven data modeling bezeichnet. Für GeoQuest bedeutet das, dass häufig genutzte Zugriffe als „einfache“ Reads gestaltet sind (Point Reads oder wenige Collection Queries), um Latenz und Kosten gering zu halten.

#### 4.2 Transaktionen und atomare Updates

Firestore unterstützt Transaktionen und Batched Writes. Transaktionen sind relevant, wenn mehrere Dokumente konsistent geändert werden müssen (z. B. Punkte und Fortschritt). Batched Writes erlauben mehrere Writes als Paket. Für eine spätere Härtung gegen Manipulation wäre es sinnvoll, Punkteupdates serverseitig zu validieren (z. B. via Cloud Functions). In der aktuellen Projektphase bleibt die Struktur aber so gewählt, dass eine solche Erweiterung möglich ist, ohne das komplette Datenmodell umzubauen.

## Praktische Arbeit

In diesem Kapitel wird die praktische Umsetzung der standortbasierten Schnitzeljagd-Applikation detailliert beschrieben. Ziel ist es, alle wesentlichen technischen Entscheidungen, Implementierungsschritte und Zusammenhänge so darzustellen, dass der gesamte Entwicklungsprozess auch ohne Einsicht in den Quellcode nachvollziehbar bleibt.

Der praktische Teil orientiert sich an den im Projekthandbuch definierten Anforderungen und baut direkt auf den im Theorieteil beschriebenen Grundlagen auf.

### 1. Gesamtarchitektur der Anwendung

Die Anwendung folgt einer klaren Trennung der Verantwortlichkeiten und ist modular aufgebaut. Die wichtigsten Komponenten sind:

- UI-Schicht (Flutter Widgets): Darstellung der Benutzeroberfläche, Kartenansicht und Dialoge
- Logik-Schicht: Standortermittlung, Proximity-Erkennung, Spielfortschritt
- Datenzugriffsschicht: Firebase Authentication und Cloud Firestore

Diese Trennung erleichtert Wartung, Erweiterung und Fehlersuche. Aus Backend-Sicht ist besonders relevant, dass die Datenzugriffsschicht klar gekapselt ist, damit Sicherheitsregeln, Query-Patterns und Kostenkontrolle konsistent umgesetzt werden können.

### 2. Benutzerverwaltung

#### 2.1 Registrierung und Authentifizierung

Die Benutzerregistrierung erfolgt über Firebase Authentication. Jeder Benutzer meldet sich mit einer gültigen E-Mail-Adresse an und erhält nach erfolgreicher Anmeldung eine eindeutige Benutzer-ID (UID). Diese UID wird in der gesamten Anwendung als primärer Identifikator verwendet.

#### 2.2 Speicherung des Benutzerprofils

Nach der Registrierung wird ein Benutzerprofil in der Firestore-Collection `Users` gespeichert.

Datenmodell `Users`:
- Collection: `Users`
- Dokument-ID: `UID`
- Felder:
  - `username`
  - `totalPoints`
  - `createdAt`

Implementierung:
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
```

Ein wichtiger Punkt aus Backend-Perspektive ist, dass `createdAt` serverseitig gesetzt wird. Dadurch kann der Client keine beliebigen Zeitstempel „fälschen“. Solche serverseitigen Werte sind ein einfaches, aber wirksames Mittel gegen Manipulation.

#### 2.3 Query- und Access-Pattern der Benutzerverwaltung

Für die Benutzerverwaltung wurden bewusst einfache und effiziente Zugriffsstrukturen gewählt, um sowohl Performance als auch Sicherheit zu gewährleisten.

Query Pattern:
- Direkter Zugriff auf ein einzelnes Dokument über `Users/{uid}`
- Point Read, in Firestore besonders performant

Access Pattern:
- Schreiben: nur der authentifizierte Benutzer darf sein eigenes Dokument ändern
- Lesen: Benutzerinformationen dürfen gelesen werden (z. B. für Anzeigenamen)

Dieses Access Pattern wird durch Firestore Security Rules abgesichert.

### 3. Standortermittlung

#### 3.1 Motivation und technische Umsetzung

Für eine standortbasierte Schnitzeljagd ist kontinuierliche Standortüberwachung erforderlich. Ein einmaliger Standortabruf wäre unzureichend, da Bewegungen in Echtzeit erkannt werden müssen, um das Erreichen von Stationen korrekt zu erfassen. Daher wird ein Standort-Stream verwendet, der regelmäßig aktualisierte Positionsdaten liefert.

Aus Backend-Sicht entsteht dadurch eine Kostenfrage: Wenn jeder Standortpunkt gespeichert würde, würden viele Writes entstehen. Deshalb wird die Speicherung nicht zeitbasiert, sondern bewegungsbasiert begrenzt.

#### 3.2 Starten des Standort-Streams

Der Standort-Stream wird mit abgestimmten Parametern gestartet. Im finalen Design wird ein Distanzfilter verwendet, der Updates nur nach relevanter Bewegung verarbeitet. Dadurch werden Kosten und Akkuverbrauch reduziert.

```dart
const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  distanceFilter: 10,
);
```

Bedeutung:
- `bestForNavigation`: hohe Genauigkeit, sinnvoll im Außenbereich
- `distanceFilter: 10`: Updates erst nach mindestens zehn Metern Bewegung

#### 3.3 Verwaltung des Standort-Streams

Zur sauberen Verwaltung des Streams wird eine StreamSubscription verwendet. Beim Verlassen der Ansicht wird der Stream beendet, um Akkuverbrauch und Speicherlecks zu vermeiden.

```dart
StreamSubscription<Position>? _positionStream;

@override
void dispose() {
  _positionStream?.cancel();
  super.dispose();
}
```

### 4. Kartenintegration

#### 4.1 Darstellung mit OpenStreetMap

Die Kartenansicht wird mit dem Paket `flutter_map` umgesetzt. Als Kartenquelle wird OpenStreetMap verwendet, da keine Lizenzkosten entstehen und keine Abhängigkeit von kommerziellen Anbietern besteht.

```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.app',
  tileProvider: NetworkTileProvider(),
)
```

#### 4.2 Marker-Darstellung

Zur besseren Orientierung werden unterschiedliche Markerfarben verwendet. Diese Darstellung hängt direkt mit dem Datenzustand (Fortschritt) zusammen und muss daher mit der Fortschrittslogik konsistent sein.

### 5. Datenmodell und Firestore-Struktur

#### 5.1 `Users`

- Collection: `Users`
- Dokument-ID: UID des Benutzers
- Felder: `username`, `totalPoints`, `createdAt`

#### 5.2 `Hunts` und `Stadions`

- Pfad: `Hunts/{huntId}/Stadions`
- Felder: `stadionIndex`, `title`, `stadionLocation` (GeoPoint)

```dart
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
```

Query Pattern:
- Zugriff auf Subcollection
- Sortierung nach `stadionIndex`

Diese Struktur ermöglicht eine sequentielle Freischaltung der Stationen und sorgt dafür, dass Änderungen an Stationen zentral im Backend vorgenommen werden können.

#### 5.3 `PlayerLocation`

- Collection: `PlayerLocation`
- Dokument-ID: UID des Benutzers

```dart
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
```

Dieses Modell speichert bewusst nur die letzte Position. Damit bleibt die Datenbank klein, die Kosten bleiben gering, und es werden weniger sensible Bewegungsdaten gesammelt.

### 6. Proximity-Erkennung (Stationslogik)

Die Proximity-Erkennung wird nur einmal vollständig erklärt, um doppelte Beschreibungen zu vermeiden. Alle späteren Stellen beziehen sich auf diesen Abschnitt.

#### 6.1 Distanzberechnung

```dart
double distanceInMeters = Geolocator.distanceBetween(
  myPosition!.latitude,
  myPosition!.longitude,
  targetGeo.latitude,
  targetGeo.longitude,
);
```

#### 6.2 Radius-Logik

```dart
if (distanceInMeters < 50) {
  _showDiscoveryDialog(aktuellesZiel['title'] ?? "Stadion");
  saveLocationInDatabase(myPosition);
}
```

Der Radius von 50 Metern stellt einen praxisnahen Kompromiss zwischen Genauigkeit und Benutzerfreundlichkeit dar. Der Radius berücksichtigt typische GPS-Ungenauigkeiten, ohne das Spielprinzip zu verwässern.

### 7. Fortschritt und Benutzerinteraktion

Beim Erreichen einer Station wird der Standort-Stream pausiert, um Mehrfachauslösungen zu verhindern. Nach der Bestätigung wird der Fortschritt erhöht und der Stream fortgesetzt.

```dart
_positionStream?.pause();
// Dialog anzeigen
_positionStream?.resume();
```

Dieses Muster reduziert außerdem unnötige Rechenlast während des Dialogs.

### 8. Sicherheitskonzept

#### 8.1 Firestore Security Rules

```txt
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
```

Diese Regeln stellen sicher, dass Benutzer ausschließlich ihre eigenen Daten verändern können und Standortdaten nur für authentifizierte Nutzer zugänglich sind.

#### 8.2 Erweiterung: Prinzipien sicherer Rules

Security Rules sollten nicht nur Zugriffe erlauben/verbieten, sondern im Idealfall auch Daten validieren. Für produktive Systeme wären zusätzliche Prüfungen sinnvoll, etwa Längenbeschränkungen für Benutzernamen oder Einschränkungen bei Punktänderungen. Für die Diplomarbeit wurde der Fokus auf ein verständliches, korrektes Grundmodell gelegt, das sich schrittweise erweitern lässt.

### 9. Erweiterte Standortlogik und kontinuierliches Tracking (konsolidiert)

In der ursprünglichen Textfassung wurden Tracking-Initialisierung und Proximity-Erkennung mehrfach beschrieben. In dieser Ausarbeitung werden diese Themen konsolidiert, damit sie nicht doppelt vorkommen.

Die Standortlogik wird beim Start der Kartenansicht initialisiert. Dabei ist wichtig, dass zuerst die Stationsdaten geladen werden. Erst danach startet das Tracking, damit Standortupdates nicht verarbeitet werden, bevor Zielpunkte vorhanden sind.

```dart
@override
void initState() {
  super.initState();
  _loadMyLocation();
  _initData();
}

Future<void> _initData() async {
  await getAllStadionData("xISAk6mXjjEpDUHYyxZi");
  await _startLocationTracking();

  if (mounted) {
    setState(() => isLoading = false);
  }
}
```

Die Verarbeitung erfolgt im Listener. Dabei wird die Position aktualisiert und anschließend die Proximity-Prüfung ausgeführt (siehe Abschnitt 6).

```dart
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
```

### 10. Fehlerbehandlung und Robustheit

Typische Fehlerquellen sind deaktivierter Standortdienst, fehlende Berechtigungen, ungenaue GPS-Daten und Netzwerkunterbrechungen. Defensive Programmierung reduziert Abstürze und sorgt für ein stabiles Systemverhalten.

```dart
if (position == null || user == null) return;
```

### 11. Firestore Query- und Access-Patterns (Erweiterung ohne Wiederholung)

Bei Firestore ist eine saubere Planung der Zugriffsmuster entscheidend, da komplexe Joins nicht verfügbar sind. GeoQuest folgt daher einem query-driven data modeling: Das Datenmodell ist so aufgebaut, dass häufige Zugriffe wenige, einfache Queries benötigen.

Point Reads:
- `Users/{uid}`
- `PlayerLocation/{uid}`

Collection Query:
- `Hunts/{huntId}/Stadions` mit `orderBy("stadionIndex")`

Diese Muster sind effizient, weil sie geringe Latenz und geringe Kosten verursachen. Zusätzlich sind sie leicht mit Security Rules abzusichern.

### 12. Kosten- und Skalierungsbetrachtung (Erweiterung)

Firestore berechnet Kosten pro Leseoperation, Schreiboperation und Datenübertragung. Daher ist die Reduktion unnötiger Writes ein zentraler Punkt. Die Entscheidung, Standortupdates nur bei relevanter Bewegung zu speichern (Distanzfilter 10 Meter), reduziert Writes deutlich.

Skalierungsrisiken entstehen häufig durch Hot Documents, wenn viele Nutzer gleichzeitig in dasselbe Dokument schreiben. GeoQuest reduziert dieses Problem, weil Benutzer primär in ihre eigenen Dokumente schreiben. Dadurch verteilt sich die Last auf viele Dokumente.

### 13. Anti-Cheat Mechanismen (Erweiterung)

Standortbasierte Spiele sind anfällig für Manipulation (GPS Spoofing, Emulatoren, manuelle API Requests). Clientseitige Prüfungen können nur Hürden darstellen, nicht absolute Sicherheit. Eine mögliche Erweiterung wäre serverseitige Validierung über Cloud Functions, bei der Punkte und Fortschritt erst nach Prüfung geschrieben werden.

Im Rahmen der Diplomarbeit ist wichtig, diese Grenze transparent zu machen: Ohne serverseitige Validierung bleibt ein Restrisiko, aber durch Security Rules und Kosten-/Update-Limits wird die Manipulation erschwert und das System bleibt stabil.

### 14. Warum Firebase statt eigener Server (wissenschaftliche Einordnung)

Firebase reduziert Infrastrukturaufwand und bietet automatische Skalierung sowie integrierte Authentifizierung. Ein eigener Server (z. B. Spring Boot) bietet zwar volle Kontrolle und klassische relationale Datenmodelle, bringt aber höheren Aufwand für Betrieb, Updates, Security und Skalierung mit sich. Für ein Schulprojekt mit begrenzter Zeit ist Firebase daher eine geeignete Wahl, weil die Implementierung auf die fachlichen Ziele fokussiert werden kann.

### 15. Datenschutz und Datensparsamkeit (Erweiterung)

Standortdaten sind sensibel. GeoQuest speichert daher nur die letzte Position und vermeidet eine komplette Verlaufshistorie. Dadurch werden Datenschutzrisiken reduziert. Für produktive Systeme wären zusätzliche Maßnahmen sinnvoll, etwa ein transparenter Datenschutzhinweis und optional deaktivierbare Standortpersistenz, sofern dies mit dem Spielkonzept vereinbar ist.

### 16. Teststrategie (Erweiterung)

Für Firebase ist die Emulator Suite ein wichtiger Bestandteil, um Firestore und Security Rules lokal zu testen. Gerade bei Security Rules können kleine Fehler große Auswirkungen haben. Deshalb ist ein systematisches Testen der wichtigsten Zugriffsszenarien notwendig, etwa: eigener User darf schreiben, fremder User darf nicht schreiben, nicht eingeloggter User darf nicht schreiben. Auch Standortlogik kann mit simulierten Koordinaten getestet werden, um Proximity-Erkennung zuverlässig zu prüfen.
