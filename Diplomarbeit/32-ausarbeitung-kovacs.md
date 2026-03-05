# Teilaufgabe Schüler Kovacs
\textauthor{Christian Kovacs}

## Theorie

Dieses Kapitel dient als theoretische Grundlage für die im weiteren Verlauf beschriebene praktische Umsetzung einer standortbasierten Schnitzeljagd-Applikation. Ziel ist es, auch Leserinnen und Lesern ohne vertiefte Kenntnisse im Bereich mobiler App-Entwicklung ein grundlegendes Verständnis der eingesetzten Technologien, Konzepte und Architekturentscheidungen zu vermitteln.

Die vorgestellten Inhalte bilden den notwendigen Kontext, um die praktischen Implementierungen nachvollziehen und bewerten zu können.

### 2 Grundlagen mobiler Anwendungen

#### 2.1 Eigenschaften mobiler Software

Mobile Anwendungen unterscheiden sich in mehreren Punkten von
klassischen Desktop‑Programmen. Während Desktop‑Programme meist auf
leistungsstarker Hardware laufen, müssen mobile Anwendungen mit deutlich
eingeschränkten Ressourcen arbeiten.

Typische Herausforderungen sind begrenzte Akkukapazität, geringere
Rechenleistung, instabile Internetverbindungen, unterschiedliche
Hardwareplattformen und der Zugriff auf Gerätesensoren.

Insbesondere standortbasierte Anwendungen müssen kontinuierlich
Positionsdaten verarbeiten. Diese Positionsdaten stammen aus
verschiedenen Quellen wie GPS, Mobilfunknetz oder WLAN‑Ortung. Die
Genauigkeit dieser Daten kann stark variieren, weshalb Anwendungen
Mechanismen implementieren müssen, um mit ungenauen Standortdaten
umgehen zu können.

------------------------------------------------------------------------

### 3 Systemarchitektur der Anwendung

#### 3.1 Gesamtüberblick

Die GeoQuest Anwendung basiert auf einer Client‑Server‑Architektur.
Dabei wird zwischen zwei Hauptkomponenten unterschieden.

Client: - Mobile App - Benutzeroberfläche - Standortermittlung -
Spiellogik

Backend: - Authentifizierung - Datenbank - Zugriffskontrolle -
Datenspeicherung

#### 3.2 Architekturdiagramm

``` mermaid
flowchart TD

User --> MobileApp
MobileApp --> FirebaseAuth
MobileApp --> FirestoreDB

FirebaseAuth --> GoogleCloud
FirestoreDB --> GoogleCloud

FirestoreDB --> Users
FirestoreDB --> Hunts
FirestoreDB --> PlayerLocation
FirestoreDB --> Teams
```

Dieses Architekturmodell bietet mehrere Vorteile. Dazu gehören eine
klare Trennung zwischen Frontend und Backend, eine hohe Skalierbarkeit
sowie eine einfache Wartbarkeit.

------------------------------------------------------------------------

### 4 Flutter als Entwicklungsplattform

Flutter ist ein Open‑Source Framework von Google zur Entwicklung
plattformübergreifender Anwendungen. Mit Flutter kann eine einzige
Codebasis verwendet werden, um Anwendungen für verschiedene Plattformen
zu erstellen. Dazu gehören Android, iOS, Web und Desktop. Dadurch
reduziert sich der Entwicklungsaufwand erheblich.

#### 4.2 Programmiersprache Dart

Flutter verwendet die Programmiersprache Dart. Dart ist eine
objektorientierte Programmiersprache mit Eigenschaften wie starker
Typisierung, Garbage Collection, asynchroner Programmierung und hoher
Performance.

Ein Beispiel für eine asynchrone Datenbankabfrage in Dart:

``` dart
Future<void> loadUser() async {
  final snapshot = await FirebaseFirestore.instance
      .collection("Users")
      .doc(userId)
      .get();
}
```

------------------------------------------------------------------------

### 5 Backend‑as‑a‑Service Architektur

Bei klassischen Webanwendungen wird ein eigener Server betrieben. Dieser
Server übernimmt Aufgaben wie API‑Bereitstellung, Authentifizierung,
Datenbankzugriffe und Lastverteilung. Solche Systeme werden häufig mit
Technologien wie Spring Boot, Node.js oder Django entwickelt.

Backend‑as‑a‑Service Plattformen übernehmen diese Aufgaben automatisch.
Bekannte Plattformen sind Firebase, Supabase oder AWS Amplify. In diesem
Projekt wurde Firebase verwendet.

------------------------------------------------------------------------

### 6 Firebase Plattform

Firebase ist eine Cloudplattform von Google. Sie stellt verschiedene
Dienste zur Verfügung, darunter Authentication, Firestore Database,
Cloud Functions, Storage und Analytics.

Für dieses Projekt wurden hauptsächlich zwei Dienste verwendet: -
Firebase Authentication - Cloud Firestore

------------------------------------------------------------------------

### 7 Firebase Authentication

Firebase Authentication ermöglicht eine sichere Anmeldung von Benutzern.
Jeder Benutzer erhält eine eindeutige UID, die als Identifikator in der
Datenbank verwendet wird.

``` mermaid
sequenceDiagram

User->>App: Login
App->>FirebaseAuth: Auth Request
FirebaseAuth-->>App: ID Token
App->>Firestore: Zugriff mit Token
```

Der Token bestätigt die Identität des Benutzers.

------------------------------------------------------------------------

### 8 Cloud Firestore

Firestore ist eine dokumentenbasierte NoSQL‑Datenbank. Daten werden in
Collections, Documents und Subcollections gespeichert.

#### Firestore Datenbankdiagramm

``` mermaid
erDiagram

USERS {
string uid
string username
number totalPoints
timestamp createdAt
}

HUNTS {
string huntId
string title
string description
number durationMinutes
number totalStations
string status
}

STATIONS {
number stationIndex
string title
geopoint location
}

PLAYERLOCATION {
string uid
geopoint location
timestamp timestamp
}

USERS ||--o{ PLAYERLOCATION : has
HUNTS ||--o{ STATIONS : contains
```

------------------------------------------------------------------------

### 9 Datenmodell

Users Collection: `Users/{uid}`

Felder: - username - totalPoints - createdAt

Hunts Collection: `Hunts/{huntId}`

Stations Subcollection: `Hunts/{huntId}/Stations`

PlayerLocation Collection: `PlayerLocation/{uid}`

------------------------------------------------------------------------

## Praktische Arbeit

### 10 Standortverarbeitung

Standortdaten werden mit der Bibliothek Geolocator ermittelt.

``` dart
accuracy: LocationAccuracy.bestForNavigation
distanceFilter: 10
```

Der Parameter distanceFilter stellt sicher, dass neue Standortdaten nur
gespeichert werden, wenn sich der Benutzer mindestens zehn Meter bewegt
hat. Dadurch werden Datenbankkosten, Netzwerktraffic und Akkuverbrauch
reduziert.

------------------------------------------------------------------------

### 11 Proximity‑Erkennung

Die Distanz zwischen Spieler und Zielstation wird mit folgender Methode
berechnet.

``` dart
Geolocator.distanceBetween()
```

Wenn der Spieler einen Radius von fünfzig Metern unterschreitet, wird
die Station als erreicht gewertet.

------------------------------------------------------------------------

### 12 Sicherheitskonzept

Firestore verwendet deklarative Sicherheitsregeln.

``` javascript
match /Users/{userId} {

allow read: if true;

allow write: if request.auth != null
             && request.auth.uid == userId;
}
```

#### Standortdaten

``` javascript
match /PlayerLocation/{docId} {

allow read: if request.auth != null;

allow write: if request.auth != null
}
```

Administratoren können Hunts erstellen oder bearbeiten.

``` javascript
function isAdmin() {
 return get(/databases/$(database)/documents/Users/$(request.auth.uid)).data.role == "admin";
}
```

------------------------------------------------------------------------

### 13 Anti‑Cheat Mechanismen

Standortbasierte Spiele sind anfällig für Manipulation. Typische
Manipulationsmethoden sind GPS‑Spoofing, Emulatoren oder manuelle
API‑Requests. Mögliche Gegenmaßnahmen sind Plausibilitätsprüfungen der
Geschwindigkeit, Mindestabstände zwischen Updates und serverseitige
Validierung.

------------------------------------------------------------------------

### 14 Skalierbarkeit

Firebase skaliert automatisch. Auch bei zehntausend Spielern
gleichzeitig verteilt Firestore die Anfragen über mehrere Server.
Dadurch entstehen keine Performanceprobleme.

------------------------------------------------------------------------

### 15 Kostenoptimierung

Firestore berechnet Kosten pro Leseoperation, Schreiboperation und
Datenübertragung. Optimierungen im Projekt sind Standortupdates nur alle
zehn Meter, gezielte Dokumentzugriffe und das Vermeiden unnötiger
Streams.

------------------------------------------------------------------------

### 16 Warum Firebase statt Spring Boot

Eine alternative Architektur wäre ein eigener Server mit Spring Boot
gewesen. Spring Boot bietet volle Kontrolle über das Backend,
relationale Datenbanken und komplexe Geschäftslogik. Gleichzeitig
erfordert es jedoch Serveradministration, eigene Skalierung und einen
höheren Entwicklungsaufwand.

Firebase bietet hingegen eine vollständig verwaltete Infrastruktur mit
automatischer Skalierung und integrierter Authentifizierung. Für ein
Schulprojekt mit begrenzter Entwicklungszeit stellte Firebase daher eine
besonders geeignete Lösung dar.

------------------------------------------------------------------------

### 17 Firestore Query‑ und Access‑Patterns

Bei der Entwicklung mit Cloud Firestore spielt die Gestaltung der
Datenzugriffe eine entscheidende Rolle. Da Firestore keine Join‑Abfragen
unterstützt, muss das Datenmodell bereits im Voraus so entworfen werden,
dass häufig benötigte Abfragen effizient durchgeführt werden können.

Dieses Konzept wird als Query‑driven Data Modeling bezeichnet. Dabei
wird die Datenbankstruktur nach den tatsächlichen Zugriffsmustern der
Anwendung gestaltet.

#### Point Reads

``` dart
final snapshot = await FirebaseFirestore.instance
    .collection("Users")
    .doc(user.uid)
    .get();
```

Point Reads werden im Projekt verwendet für das Laden von
Benutzerprofilen, Standortdaten und spezifischen Spielinformationen.

#### Collection Queries

``` dart
final snapshot = await FirebaseFirestore.instance
    .collection("Hunts")
    .doc(huntId)
    .collection("Stations")
    .orderBy("stationIndex")
    .get();
```

Diese Abfrage lädt alle Stationen einer Schnitzeljagd und sortiert sie
nach ihrem Index.

#### Realtime Updates

``` dart
FirebaseFirestore.instance
.collection("Hunts")
.snapshots()
.listen((snapshot) {
  // Änderungen werden automatisch empfangen
});
```

Realtime Updates ermöglichen zukünftige Erweiterungen wie
Multiplayer‑Funktionen.

------------------------------------------------------------------------

### Auswertung der Ergebnisse

  Daten            Zugriffsmethode
  ---------------- ---------------------
  Benutzerprofil   Point Read
  Stationsdaten    Subcollection Query
  Standortdaten    Point Read

Die entwickelte Datenbankarchitektur ermöglicht schnelle Datenzugriffe,
geringe Betriebskosten und eine hohe Skalierbarkeit.
