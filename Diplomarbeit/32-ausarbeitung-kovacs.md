# Teilaufgabe Schüler Kovacs
\textauthor{Christian Kovacs}

## Theorie

Dieses Kapitel bildet die theoretische Grundlage für die praktische Umsetzung des Backend-Teils einer standortbasierten Schnitzeljagd-Applikation. Die Darstellung ist so aufgebaut, dass auch Leserinnen und Leser ohne vertiefte Kenntnisse in der App-Entwicklung die zentralen Entscheidungen nachvollziehen können. Wo Fachbegriffe notwendig sind, werden sie eingeführt und anschließend konsistent verwendet. Der Schwerpunkt liegt dabei auf dem Zusammenhang zwischen Datenmodell, Zugriffsmustern, Sicherheitsregeln und Kostenkontrolle, weil diese vier Aspekte in einer serverlosen Architektur gemeinsam die Funktion eines klassischen Backends übernehmen.

### Grundlagen mobiler Applikationen

Mobile Applikationen sind Softwareprogramme, die speziell für mobile Endgeräte entwickelt werden. Sie unterscheiden sich von klassischen Desktop-Anwendungen insbesondere dadurch, dass sie mit begrenzten Ressourcen umgehen müssen und stark von Sensorik sowie Betriebssystemmechanismen beeinflusst werden. Bei standortbasierten Anwendungen kommt hinzu, dass Standortdaten Rückschlüsse auf Bewegungsprofile ermöglichen und dadurch einen besonders sensiblen Datenbereich darstellen. Aus diesem Grund ergeben sich Anforderungen an Datenminimierung, Zweckbindung und Zugriffskontrolle, die nicht als nachträgliche Erweiterung, sondern als Teil der Architektur verstanden werden müssen [@gdpr_2016_679] [@owasp_masvs_privacy_2026].

Die Standortbestimmung erfolgt in der Praxis über eine Kombination mehrerer Quellen. Umgangssprachlich wird häufig von GPS gesprochen, technisch ist damit meist GNSS gemeint. Zusätzlich können WLAN-Informationen und Mobilfunkdaten die Stabilität verbessern. Insbesondere in städtischen Gebieten oder bei Abschattungen treten Messfehler auf, die sich als Positionssprünge oder Streuung äußern. Für Anwendungen wie GeoQuest ist deshalb weniger eine theoretisch maximale Genauigkeit entscheidend, sondern ein robustes Verhalten gegenüber Messrauschen. In einem Spielkontext soll eine Messabweichung nicht dazu führen, dass Stationen fälschlich ausgelöst werden oder ein korrektes Erreichen nicht erkannt wird. Daraus folgt die Notwendigkeit, Distanzschwellen, Filter und Zustandslogik so zu wählen, dass sie die physikalisch unvermeidbare Ungenauigkeit im Alltag abfedern.

Ein weiterer zentraler Faktor ist der Energieverbrauch. Standorttracking gehört zu den energieintensiven Funktionen eines Smartphones. Hohe Genauigkeitsstufen und sehr häufige Updates erhöhen Akkuverbrauch und Rechenlast. Aus Backend-Perspektive kommt hinzu, dass häufige Standortupdates eine große Anzahl an Datenbankoperationen auslösen können, die bei Cloud-Diensten direkte Kosten verursachen. Damit wird Effizienz zu einem fachlichen Kriterium. Ein standortbasiertes System muss nicht nur korrekt, sondern auch ressourcenschonend entworfen werden, um eine praktikable Nutzung im Schulkontext zu ermöglichen.

Neben Energie und Genauigkeit beeinflussen Betriebssystemmechanismen die Nutzbarkeit. Moderne Betriebssysteme begrenzen Standortupdates im Hintergrund, um Akku zu sparen und Privatsphäre zu schützen. Android limitiert seit Android 8.0 die Häufigkeit von Standortupdates im Hintergrund deutlich [@android_background_location_limits_2024]. iOS unterscheidet Berechtigungen wie „When In Use“ und „Always“ und koppelt deren Vergabe an transparente Nutzerzustimmung [@apple_request_location_authorization_2026]. Für GeoQuest ist dies insofern relevant, als dass der Ablauf primär während aktiver Nutzung der App stattfindet und daher bewusst auf eine Minimierung von Hintergrundtracking ausgelegt werden kann. Dadurch wird nicht nur die technische Robustheit erhöht, sondern es wird auch eine datenschutzfreundlichere Grundannahme getroffen, weil die Verarbeitung des Standorts auf den tatsächlichen Spielzeitraum begrenzt bleibt.

### Flutter als Entwicklungsframework und Dart als Sprache

Flutter ist ein plattformübergreifendes Framework, das mit einer einzigen Codebasis Anwendungen für mehrere Zielplattformen ermöglicht. Für die Architektur ist relevant, dass Flutter ein deklaratives und reaktives UI-Modell verwendet. Die Benutzeroberfläche wird aus dem aktuellen Zustand der Anwendung abgeleitet und bei Zustandsänderungen neu aufgebaut. Diese Eigenschaft wirkt indirekt auf das Backend-Design, weil Datenmodelle, Zustandsübergänge und Datenzugriffe klar beschrieben werden müssen, damit UI und Persistenz konsistent bleiben [@flutter_arch_overview] [@flutter_app_arch_guide]. Die Flutter-Architekturleitlinien empfehlen zudem eine Schichtenstruktur, in der Datenzugriff über definierte Schnittstellen erfolgt. Für den Backend-Teil ist dabei entscheidend, dass sicherheits- und kostenrelevante Entscheidungen nicht unkontrolliert in UI-Code verteilt sind, sondern zentral umgesetzt werden [@flutter_app_arch_guide].

Dart unterstützt asynchrone Programmierung, die im Mobile-Kontext essenziell ist, weil Netzwerkzugriffe und Sensorabfragen nicht sofort abgeschlossen werden. In der praktischen Umsetzung treten zwei Konzepte besonders häufig auf. Futures repräsentieren ein einmaliges Ergebnis in der Zukunft, etwa das Laden eines Dokuments aus einer Datenbank. Streams repräsentieren eine Folge von Ereignissen, etwa fortlaufende Standortupdates oder Realtime-Listener auf Datenbankänderungen [@dart_async_await_2025] [@dart_using_streams_2025]. Diese Unterscheidung beeinflusst das Backend-Design, weil Abfragen von Stammdaten typischerweise als einzelne Ladevorgänge modelliert werden, während Standorttracking und Live-Updates den Charakter eines kontinuierlichen Datenstroms besitzen.

Für die Wartbarkeit ist im Dart-Ökosystem außerdem die statische Typisierung mit sound null safety relevant. Dart erzwingt, dass Typen standardmäßig nicht nullbar sind, wodurch ein großer Teil typischer Laufzeitfehler bereits zur Entwicklungszeit erkannt wird [@dart_null_safety_2026]. Gerade an Schnittstellen zwischen Datenbank und App ist dies bedeutsam, weil Daten aus einer NoSQL-Datenbank oft optional oder unvollständig sein können. Durch ein bewusstes Modellieren optionaler Felder und durch klare Konvertierungslogik wird verhindert, dass inkonsistente Daten unbemerkt in die Anwendungslogik gelangen.

Zusätzlich spielt das Paketmanagement eine zentrale Rolle. Flutter nutzt den pub-Paketmanager, und Abhängigkeiten werden in der pubspec.yaml dokumentiert. Pub löst dabei nicht nur direkte, sondern auch transitive Abhängigkeiten auf, was für reproduzierbare Builds und eine konsistente Toolchain wesentlich ist [@dart_pub_dependencies_2025]. Im Projekt ist dies insbesondere bei Firebase-Paketen relevant, weil API- und Verhaltenänderungen in Abhängigkeiten direkt auf Datenzugriff und Authentifizierung wirken können.

Hot Reload ist ein wichtiger Bestandteil des Flutter-Entwicklungsprozesses und beschleunigt Iterationen, weil Änderungen während der Entwicklung unmittelbar überprüfbar sind [@flutter_hot_reload]. Im Rahmen der Diplomarbeit beeinflusst das Vorgehen insbesondere bei Prototyping und Debugging, etwa bei der Kalibrierung von Distanzfiltern, beim Testen von Dialogzuständen oder beim schrittweisen Verfeinern von Datenzugriffsmustern.

### Firebase als Backend-Plattform

Firebase ist eine Backend-as-a-Service-Plattform, die typische Backend-Funktionen als Cloud-Dienst bereitstellt. In GeoQuest werden insbesondere Firebase Authentication und Cloud Firestore genutzt. Der BaaS-Ansatz reduziert den Aufwand für Infrastruktur, weil kein eigener Server betrieben werden muss. Gleichzeitig bedeutet serverlos nicht, dass keine Serverlogik existiert, sondern dass Autorisierung und Datenvalidierung in großen Teilen durch Security Rules und Managed Services abgebildet werden [@firebase_rules_get_started]. Daraus folgt, dass korrekt formulierte Sicherheitsregeln, konsistente Dokumentpfade und ein kostenbewusstes Zugriffsmuster zentrale Bestandteile des Backend-Designs sind.

Ein Vorteil von Firestore ist die starke Konsistenz von Reads. Standardmäßig liefern Reads den neuesten Datenstand, der alle bis zum Start des Reads abgeschlossenen Writes berücksichtigt [@firestore_understand_reads_writes_scale_2026]. Zusätzlich unterstützt Firestore Realtime-Listener. Firebase beschreibt für Realtime-Abfragen ein Konsistenzverhalten, bei dem Updates in der Reihenfolge der Commit-Operationen verarbeitet werden und damit ein nachvollziehbarer Änderungsfluss entsteht [@firestore_realtime_queries_scale_2026]. Für GeoQuest ist dies relevant, weil Spielzustände und Fortschrittsanzeigen davon profitieren, wenn Änderungen konsistent beim Client ankommen, ohne dass zusätzliche Synchronisationslogik implementiert werden muss.

#### Firebase Authentication

Firebase Authentication ermöglicht Registrierung und Login. Nach erfolgreicher Anmeldung erhält jeder Benutzer eine eindeutige UID. Diese UID ist in der Architektur ein zentrales Element, weil sie als stabile Referenz für Benutzerprofile und benutzerspezifische Daten dient. In Security Rules steht die Authentifizierungsinformation als Variable zur Verfügung. Firebase beschreibt, dass request.auth unter anderem uid und Token-Informationen enthält, wodurch Regeln identitätsbasiert formuliert werden können [@firebase_rules_and_auth_2026]. Für GeoQuest ist dies besonders hilfreich, weil Zugriffskontrolle über Dokumentpfade wie Users/{uid} oder PlayerLocation/{uid} präzise und ohne zusätzliche Suchabfragen umgesetzt werden kann.

Darüber hinaus eröffnet Authentication die Möglichkeit, Rollenmodelle über Custom Claims zu realisieren. Auch wenn in GeoQuest zunächst ein bewusst schlankes Rollenmodell gewählt wurde, bleibt die Architektur prinzipiell erweiterbar. Über Custom Claims könnten in späteren Versionen beispielsweise Lehrkräfte oder Administratoren privilegierte Schreibrechte für Inhalte wie Hunts und Stationen erhalten, ohne dass diese Rechte in der App selbst hartkodiert werden müssen [@firebase_rules_and_auth_2026]. Die klare Trennung zwischen Authentifizierung und Autorisierung entspricht auch typischen mobilen Sicherheitsanforderungen im OWASP-MASVS-Kontext [@owasp_masvs_auth_2026].

#### Cloud Firestore

Cloud Firestore ist eine dokumentenbasierte NoSQL-Datenbank. Daten werden in Collections organisiert, die Dokumente enthalten, und Dokumente können wiederum Subcollections besitzen [@firestore_data_model]. Dieses Modell erlaubt flexible Strukturen, erfordert aber eine bewusste Planung, weil es keine klassischen Joins wie in relationalen Datenbanken gibt. Stattdessen wird das Datenmodell häufig nach den Abfragen gestaltet, die tatsächlich benötigt werden. Firebase beschreibt hierfür query-orientierte Modellierungsansätze, bei denen typische Screens mit wenigen Reads versorgt werden, was Latenz und Kosten reduziert [@firestore_data_model].

Für konsistente Änderungen über mehrere Dokumente stellt Firestore Transaktionen und Batched Writes bereit. Diese Mechanismen ermöglichen atomare Operationen, bei denen entweder alle Schritte erfolgreich sind oder keine Änderung angewendet wird [@firestore_transactions]. Aus Backend-Sicht ist dies dann entscheidend, wenn Integritätsanforderungen bestehen, etwa beim Aktualisieren von Punkteständen oder beim Markieren einer Station als erreicht.

Ein weiterer zentraler Aspekt ist die Indexierung. Firestore nutzt automatische Single-Field-Indizes und für komplexere Abfragen zusammengesetzte Indizes. Firebase dokumentiert, dass fehlende Indizes bei bestimmten Abfragen als Fehler sichtbar werden und dann gezielt ergänzt werden können [@firestore_indexing_2026] [@firestore_index_overview_2026]. Für die Praxis bedeutet dies, dass Datenmodell, Zugriffsmuster und Indexkonfiguration gemeinsam geplant werden müssen, weil die Query-Form direkt bestimmt, welche Indexstrukturen erforderlich sind.

### Abgrenzung und Zielsetzung des Backend-Umfangs

Diese Teilaufgabe betrachtet das Backend als Kombination aus Datenmodell, Zugriffsmustern, Sicherheitsregeln und kostenbewusster Datenpersistenz. Im Fokus stehen die Verwaltung von Benutzerprofilen, Spielinhalten wie Schnitzeljagden und Stationen sowie die kontrollierte Speicherung von Standortdaten. Nicht Gegenstand dieser Teilaufgabe sind ein eigener API-Server, komplexe Serverlogik mit Cloud Functions oder ein vollständiges Anti-Cheat-System mit serverseitiger Distanzvalidierung, da dies den zeitlichen Rahmen eines Schulprojekts überschreiten würde. Die Architektur wird jedoch so beschrieben, dass spätere Erweiterungen möglich bleiben, insbesondere durch konsistente Dokumentpfade, zentralisierten Datenzugriff und eine Rules-Struktur, die mit Rollenmodellen erweitert werden kann.

## Praktische Arbeit

Der praktische Teil beschreibt die konkrete Umsetzung des Backends in GeoQuest. Ziel ist es, die Implementierung so zu dokumentieren, dass sie nachvollziehbar bleibt und die wichtigsten Designentscheidungen begründet werden. Die Darstellung konzentriert sich auf backend-relevante Aspekte wie Datenmodell, Zugriffskontrolle, Zugriffsmuster sowie Maßnahmen zur Kosten- und Risikoentwicklung.

### Vorgehensmodell und Traceability der Artefakte

Die Umsetzung erfolgte iterativ. Aus Anforderungen wurden zunächst fachliche Entitäten abgeleitet, anschließend wurden Zugriffsmuster entworfen und erst danach die konkrete Speicherung in Firestore umgesetzt. Diese Reihenfolge ist im NoSQL-Kontext besonders wichtig, weil die Datenstruktur stark von den benötigten Queries abhängt. Aus den Anforderungen ergeben sich Entitäten wie Benutzer, Hunt, Station, Fortschritt und Position. Aus diesen Entitäten entsteht ein Datenmodell, aus dem wiederum Security Rules und konkrete Zugriffsmuster abgeleitet werden. Diese werden schließlich in der App über zentralisierte Datenzugriffsfunktionen realisiert.

Für die Qualitätssicherung ist entscheidend, dass Security Rules nicht nur als Konfiguration verstanden werden, sondern als testbare Spezifikation von Zugriffserwartungen. Firebase beschreibt explizit, dass Rules über die Local Emulator Suite und Unit Tests validiert werden können, bevor sie produktiv eingesetzt werden [@firebase_rules_unit_tests_2026] [@firebase_rules_emulator_test]. Dadurch werden Sicherheitsannahmen als wiederholbare Testfälle formuliert, statt ausschließlich über manuelle Tests in der App implizit zu bleiben.

### Gesamtarchitektur der Anwendung aus Backend-Sicht

Die Anwendung folgt einer Trennung zwischen Benutzeroberfläche, Anwendungslogik und Datenzugriff. Aus Backend-Perspektive ist entscheidend, dass Datenzugriffe zentralisiert werden, damit Sicherheits- und Kostenentscheidungen konsistent umgesetzt werden. Die App kommuniziert direkt mit Firebase Authentication und Firestore. Dadurch entfällt ein eigener Server, und Autorisierung sowie Teile der Validierung werden über Firestore Security Rules abgebildet [@firebase_rules_get_started]. Für den Diplomarbeitskontext ist relevant, dass diese Lösung den Infrastrukturbetrieb reduziert, jedoch eine präzise Konfiguration erfordert, weil Fehlkonfigurationen unmittelbare Auswirkungen auf Datenschutz und Integrität haben können.

Um den Datenzugriff konsistent zu halten, wurde im Projekt ein Repository-ähnliches Muster verwendet, bei dem Firestore-Zugriffe in einer separaten Klasse gebündelt werden. Das Listing zeigt exemplarisch, wie ein einzelner Zugriffspunkt für das Laden von Stationen als Future modelliert wird, während Live-Updates in Firestore als Stream abgebildet werden können.

```dart
class HuntRepository {
  HuntRepository(this._db);
  final FirebaseFirestore _db;

  Future<List<Map<String, dynamic>>> loadStations(String huntId) async {
    final snapshot = await _db
        .collection('Hunts')
        .doc(huntId)
        .collection('Stations')
        .orderBy('stationIndex')
        .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserProfile(String uid) {
    return _db.collection('Users').doc(uid).snapshots();
  }
}
```

### Toolchain, Reproduzierbarkeit und lokale Validierung

Für die Reproduzierbarkeit ist im Softwarekontext wesentlich, dass die Toolchain konsistent ist. Flutter-Projekte binden Abhängigkeiten über pub ein, wodurch verwendete Paketversionen dokumentierbar sind. Für das Backend bedeutet dies insbesondere, dass Firebase-Pakete und Firestore-APIs in definierten Versionen vorliegen müssen, um Laufzeitunterschiede und Inkonsistenzen zu vermeiden. Das folgende Listing zeigt einen typischen Auszug der pubspec.yaml, in dem der Dart-SDK-Bereich und die verwendeten Firebase-Pakete festgelegt werden.

```yaml
environment:
  sdk: ">=3.2.0 <4.0.0"

dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
```

Zusätzlich wurde die Firebase Local Emulator Suite als lokales Testwerkzeug genutzt, um Änderungen an Security Rules reproduzierbar zu validieren, bevor sie in eine produktive Umgebung gelangen [@firebase_emulator_suite_2026] [@firebase_emulator_install_config_2026]. Firebase dokumentiert, dass die Emulator Suite über die Firebase CLI installiert und konfiguriert wird und dass Security Rules im Emulator geladen werden können, um die tatsächliche Zugriffskontrolle der mobilen oder Web-SDKs zu testen [@firebase_cli_reference_2026] [@firebase_rules_emulator_test]. Das folgende Listing zeigt einen minimalen Auszug einer firebase.json-Konfiguration, in der Rules-Dateien und Emulator-Ports definiert werden.

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "emulators": {
    "firestore": { "port": 8080 },
    "auth": { "port": 9099 },
    "ui": { "enabled": true, "port": 4000 }
  }
}
```

### Datenmodell, Indexierung und versionierbare Konfiguration

Im Projekt wurde das Datenmodell so gewählt, dass es einerseits den Spielablauf abbildet und andererseits effiziente Reads in der App ermöglicht. Inhalte wie Hunts und Stationen sind als fachliche Stammdaten organisiert, während benutzerspezifische Daten wie Profile, Fortschritt und Standort über UID-basierte Dokumentpfade adressiert werden. Diese Trennung ist sowohl aus Datenschutzsicht als auch aus Wartbarkeitssicht relevant, weil dadurch personenbezogene Daten klar von öffentlich oder halböffentlich lesbaren Inhalten getrennt bleiben [@gdpr_2016_679].

Da Firestore-Performance und Query-Fähigkeit von Indexstrukturen abhängen, ist die Indexkonfiguration ein Teil des Backend-Artefakts. Firebase dokumentiert das Indexformat und beschreibt, dass Indexdefinitionen in einer Datei abgelegt und über die CLI deployt werden können [@firestore_indexing_2026]. Das folgende Listing zeigt einen exemplarischen zusammengesetzten Index, der eine Sortierung in Kombination mit einem Filter unterstützt.

```json
{
  "indexes": [
    {
      "collectionGroup": "Stations",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "huntId", "order": "ASCENDING" },
        { "fieldPath": "stationIndex", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

### Benutzerverwaltung

Die Benutzerverwaltung basiert auf Firebase Authentication und einer ergänzenden Speicherung eines Benutzerprofils in Firestore. Jedes Benutzerprofil wird als eigenes Dokument abgelegt, dessen Dokument-ID der UID entspricht. Dadurch entsteht ein direkter Zugriffspfad, der sowohl performanz- als auch sicherheitsrelevant ist, weil Security Rules ohne zusätzliche Suche auf request.auth.uid prüfen können [@firebase_rules_and_auth_2026].

Im Benutzerprofil werden ein Anzeigename, ein Punktestand und ein serverseitiger Erstellungszeitpunkt gespeichert. Der serverseitige Zeitstempel ist ein bewusstes Design, um Manipulationen durch clientseitig gesetzte Werte zu reduzieren. Das folgende Listing zeigt einen minimalen Schreibvorgang, bei dem der UID-basierte Dokumentpfad genutzt und der Erstellungszeitpunkt über serverTimestamp erzeugt wird.

```dart
Future<void> createUserProfile({
  required FirebaseFirestore db,
  required String uid,
  required String username,
}) async {
  await db.collection('Users').doc(uid).set({
    'username': username,
    'totalPoints': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

### Verwaltung von Schnitzeljagden und Stationen

Schnitzeljagden werden als Dokumente in einer Hunts-Collection abgelegt. Stationen werden als Unterstruktur unter einer konkreten Schnitzeljagd gespeichert. Stationen werden über ein Indexfeld sortiert, sodass die Reihenfolge zentral gepflegt werden kann.

Das Laden der Stationen erfolgt über Abfragen, die Filter und Sortierungen kombinieren können. Firestore unterstützt hierfür einfache und zusammengesetzte Queries [@firestore_queries_2026]. Das folgende Listing zeigt das zentrale Query-Pattern zum Laden der Stationen einer Hunt in sortierter Reihenfolge.

```dart
Future<QuerySnapshot<Map<String, dynamic>>> loadStationsQuery({
  required FirebaseFirestore db,
  required String huntId,
}) {
  return db
      .collection('Hunts')
      .doc(huntId)
      .collection('Stations')
      .orderBy('stationIndex')
      .get();
}
```

### Speicherung von Standortdaten, Datenschutz und Kostenkontrolle

Die Speicherung von Standortdaten ist sowohl technisch als auch organisatorisch sensibel. Firebase dokumentiert, dass für Firestore Kosten pro Read, Write, Delete sowie für Bandbreite und Storage anfallen und dass Reads zur Auswertung von Security Rules kostenrelevant sein können [@firestore_pricing] [@firestore_billing_example]. Daraus folgt, dass Standorttracking nicht nur als Sensorproblem, sondern als Kombination aus Sensorik, Persistenz und Kostenmodell zu betrachten ist.

Im Projekt wurde ein Distanzfilter verwendet, der Updates erst ab einer Bewegung von etwa zehn Metern als relevant betrachtet. Zusätzlich wird keine vollständige Verlaufshistorie gespeichert, sondern nur die letzte bekannte Position pro Benutzer. Dieses Modell reduziert die Anzahl der Dokumente und die Anzahl der Writes und ist mit dem Grundsatz der Datenminimierung vereinbar [@gdpr_2016_679] [@owasp_masvs_privacy_2026].

Für die langfristige Datenhaltung ist zudem eine Löschstrategie relevant. Firestore unterstützt Time-to-Live-Policies, mit denen Dokumente anhand eines Ablaufzeitpunkts automatisiert gelöscht werden können [@firestore_ttl_2026].

### Proximity-Erkennung und Stationsfortschritt

Für den Fortschritt ist aus Backend-Sicht wichtig, dass Zustandsänderungen konsistent erfolgen. Wird eine Station als erreicht markiert und gleichzeitig ein Punktestand erhöht, entsteht ein Integritätsbedarf, weil eine teilweise Aktualisierung inkonsistente Zustände erzeugen kann. Firestore stellt hierfür Transaktionen bereit [@firestore_transactions]. Das folgende Listing zeigt eine typische Transaktion, die die erreichte Station speichert und den Punktestand atomar erhöht.

```dart
Future<void> completeStation({
  required FirebaseFirestore db,
  required String uid,
  required String huntId,
  required String stationId,
  required int points,
}) async {
  final userRef = db.collection('Users').doc(uid);
  final progressRef = db
      .collection('Progress')
      .doc(uid)
      .collection('Hunts')
      .doc(huntId)
      .collection('ReachedStations')
      .doc(stationId);

  await db.runTransaction((tx) async {
    final userSnap = await tx.get(userRef);
    final current = (userSnap.data()?['totalPoints'] as int?) ?? 0;

    tx.set(progressRef, {
      'reachedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    tx.update(userRef, {
      'totalPoints': current + points,
    });
  });
}
```

### Sicherheitskonzept mit Firestore Security Rules

Security Rules sind in einer serverlosen Architektur der zentrale Mechanismus zur Zugriffskontrolle. Jede Datenbankoperation wird serverseitig gegen Regeln geprüft, bevor sie ausgeführt wird [@firebase_rules_get_started]. Firebase beschreibt, dass jede Anfrage gegen die Rules evaluiert wird und bei Ablehnung vollständig fehlschlägt [@firebase_rules_emulator_test]. Zusätzlich dokumentiert Firebase, dass Bedingungen neben Authentifizierung auch Datenvalidierung abbilden können [@firebase_rules_conditions].

Aus Kosten- und Skalierungssicht ist relevant, dass dokumentbasierte Zugriffsfunktionen in Rules wie exists(), get() oder getAfter() pro Anfrage limitiert sind und dass Reads zur Rule-Evaluation kostenrelevant sein können [@firestore_quotas] [@firestore_pricing]. Daraus folgt, dass Rules möglichst wenig Querabhängigkeiten erzeugen sollten und Autorisierung primär über Pfade und Auth-Kontext erfolgen sollte.

Das folgende Listing zeigt ein minimales Rule-Schema, das UID-basierte Writes erlaubt, öffentliche Inhalte getrennt behandelt und Beispielvalidierungen andeutet.

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() {
      return request.auth != null;
    }

    match /Users/{userId} {
      allow read: if true;
      allow write: if signedIn() && request.auth.uid == userId
        && request.resource.data.keys().hasOnly(['username','totalPoints','createdAt'])
        && request.resource.data.username is string;
    }

    match /Hunts/{huntId} {
      allow read: if true;
      allow write: if signedIn() && request.auth.token.admin == true;
      match /Stations/{stationId} {
        allow read: if true;
        allow write: if signedIn() && request.auth.token.admin == true;
      }
    }

    match /PlayerLocation/{userId} {
      allow read, write: if signedIn() && request.auth.uid == userId;
    }
  }
}
```

### Qualitätssicherung und Evaluationslogik

Firebase beschreibt die Möglichkeit, Rules im Emulator gezielt zu testen und Unit Tests zu formulieren [@firebase_rules_unit_tests_2026] [@firebase_rules_emulator_test]. Das folgende Listing zeigt ein kompaktes Beispiel für einen Unit Test, der im Emulator prüft, dass ein Benutzer nur sein eigenes Profil schreiben kann [@firebase_rules_unit_tests_2026] [@firebase_cli_reference_2026].

```javascript
import { initializeTestEnvironment, assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import fs from "node:fs";

const testEnv = await initializeTestEnvironment({
  projectId: "demo-geoquest",
  firestore: { rules: fs.readFileSync("firestore.rules", "utf8") }
});

const alice = testEnv.authenticatedContext("aliceUid").firestore();
const bob = testEnv.authenticatedContext("bobUid").firestore();

await assertSucceeds(alice.collection("Users").doc("aliceUid").set({ username: "Alice", totalPoints: 0 }));
await assertFails(bob.collection("Users").doc("aliceUid").set({ username: "Eve", totalPoints: 999 }));
```

Zusätzlich wurde OWASP MASVS als Referenzrahmen herangezogen, um Authentifizierung, Autorisierung und Datenschutz systematisch zu reflektieren, ohne ein vollständiges Security Audit zu behaupten [@owasp_masvs_2026] [@owasp_masvs_auth_2026] [@owasp_masvs_privacy_2026].

### Kostenmodell, Monitoring und Skalierungsaspekte

Firebase dokumentiert, dass Kosten in Firestore primär pro Dokumentoperation anfallen und dass auch Indexreads sowie Reads zur Auswertung von Security Rules Kosten verursachen können [@firestore_pricing] [@firestore_billing_example]. Für GeoQuest war dies insbesondere bei Standortupdates relevant, weshalb Updates gefiltert und die Persistenz auf den jeweils letzten Standort reduziert wurde. Zusätzlich spielt Bandbreite eine Rolle, da die Antwortgröße in die Berechnung einfließt [@firestore_pricing]. Daraus folgt, dass Dokumente nicht unnötig groß werden sollen und dass Abfragen so gestaltet werden müssen, dass sie nur die tatsächlich benötigten Datenpfade berühren.

### Risiken, Blocker und präventive Maßnahmen

Die wesentlichen Risiken lassen sich in Kosten-, Sicherheits- und Qualitätsrisiken einteilen. Kostenrisiken entstehen durch hohe Read- und Write-Frequenzen sowie durch umfangreiche Dokumente. Diese Risiken wurden durch Reduktion der Standortwrites, durch ein klares Datenmodell und durch die Vermeidung unnötiger Querreads in Rules adressiert. Sicherheitsrisiken entstehen insbesondere durch Fehlkonfiguration der Security Rules oder durch zu breite Lesezugriffe auf personenbezogene Daten. Diese Risiken wurden durch UID-gebundene Pfade und durch emulatorgestützte Tests reduziert [@firebase_rules_emulator_test].

Technische Risiken ergeben sich aus der Ungenauigkeit der Standortdaten, die zu falschen Auslösungen führen kann. Zusätzlich sind mobile Plattformrestriktionen zu berücksichtigen, etwa Hintergrundlimits bei Standortupdates. GeoQuest ist bewusst auf aktive Nutzung ausgelegt, wodurch diese Restriktionen weniger stark ins Gewicht fallen [@android_background_location_limits_2024].

Ein datenschutzbezogenes Risiko liegt in der Verarbeitung von Standortdaten. Als präventive Maßnahme wurde Datenminimierung umgesetzt, indem nur die letzte Position gespeichert wird. Dies ist mit dem Grundsatz der Datenminimierung und Zweckbindung vereinbar [@gdpr_2016_679] [@owasp_masvs_privacy_2026].

### Praxisfall: Ablauf einer Station als End-to-End-Nachweis

Ein Benutzer meldet sich an und erhält eine UID. Anschließend lädt die App die Stationen einer ausgewählten Schnitzeljagd. Während der Benutzer sich bewegt, erhält die App Standortupdates. Sobald die Distanz zu einer Station unter den Schwellwert fällt, wird die Station als erreicht erkannt. Der Fortschritt wird im benutzerspezifischen Zustand aktualisiert, und die letzte Position wird kontrolliert persistiert. Jede dieser Operationen wird serverseitig durch Security Rules geprüft. Bei einem fehlerhaften Zugriff, etwa einem Schreibversuch auf fremde Benutzerpfade, wird die Anfrage vollständig abgelehnt [@firebase_rules_emulator_test].

Dieser End-to-End-Fluss führt die zentralen Backend-Entscheidungen zusammen. UID-basierte Dokumentpfade ermöglichen identitätsgebundene Autorisierung, ein query-orientiertes Datenmodell unterstützt effiziente Reads, Bewegungsfilter reduzieren Writes und damit Kosten, und Security Rules sichern Zugriff und Datenintegrität ab. Damit ist die Backend-Architektur als nachvollziehbare Antwort auf Anforderungen an Datenschutz, Kostenkontrolle und Robustheit dokumentiert.
