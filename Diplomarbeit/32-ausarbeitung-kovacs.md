# Teilaufgabe Schüler Kovacs
\textauthor{Christian Kovacs}

## Theorie

Dieses Kapitel bildet die theoretische Grundlage für die praktische Umsetzung des Backend-Teils einer standortbasierten Schnitzeljagd-Applikation. Die Darstellung ist so aufgebaut, dass auch Leserinnen und Leser ohne vertiefte Kenntnisse in der App-Entwicklung die zentralen Entscheidungen nachvollziehen können. Wo Fachbegriffe notwendig sind, werden sie eingeführt und anschließend konsistent verwendet. Der Schwerpunkt liegt dabei auf dem Zusammenspiel von Datenmodell, Zugriffsmustern, Sicherheitsmechanismen und Kostenkontrolle, weil diese Aspekte in einer serverlosen Architektur gemeinsam Aufgaben übernehmen, die in klassischen Systemen durch einen eigenen Backend-Server abgedeckt werden.

### Grundlagen mobiler Applikationen

Mobile Applikationen sind Softwareprogramme, die speziell für mobile Endgeräte entwickelt werden. Sie unterscheiden sich von klassischen Desktop-Anwendungen insbesondere dadurch, dass sie mit begrenzten Ressourcen umgehen müssen und stark von Sensorik sowie Betriebssystemmechanismen beeinflusst werden. Bei standortbasierten Anwendungen kommt hinzu, dass Standortdaten Rückschlüsse auf Bewegungsprofile zulassen können und daher als besonders sensibler Datenbereich einzustufen sind. Daraus ergeben sich Anforderungen an Datenminimierung, Zweckbindung und Zugriffskontrolle, die nicht als nachträgliche Erweiterung, sondern als Teil der Architektur verstanden werden müssen [@gdpr_2016_679] [@owasp_masvs_privacy_2026].

Die Standortbestimmung erfolgt in der Praxis über eine Kombination mehrerer Quellen. Umgangssprachlich wird häufig von GPS gesprochen, technisch ist damit meist GNSS gemeint. Zusätzlich können WLAN-Informationen und Mobilfunkdaten die Stabilität verbessern. Insbesondere in städtischen Gebieten oder bei Abschattungen treten Messfehler auf, die sich als Positionssprünge oder Streuung äußern. Für Anwendungen wie GeoQuest ist deshalb weniger eine theoretisch maximale Genauigkeit entscheidend, sondern ein robustes Verhalten gegenüber Messrauschen. In einem Spielkontext soll eine Messabweichung nicht dazu führen, dass Stationen fälschlich ausgelöst werden oder ein korrektes Erreichen nicht erkannt wird. Daraus folgt die Notwendigkeit, Distanzschwellen, Filter und Zustandslogik so zu wählen, dass sie die unvermeidbare Ungenauigkeit im Alltag abfedern.

Ein weiterer zentraler Faktor ist der Energieverbrauch. Standorttracking gehört zu den energieintensiven Funktionen eines Smartphones. Hohe Genauigkeitsstufen und sehr häufige Updates erhöhen Akkuverbrauch und Rechenlast. Aus Backend-Perspektive kommt hinzu, dass häufige Standortupdates eine große Anzahl an Datenbankoperationen auslösen können, die bei Cloud-Diensten direkte Kosten verursachen. Damit wird Effizienz zu einem fachlichen Kriterium. Ein standortbasiertes System muss nicht nur korrekt, sondern auch ressourcenschonend entworfen werden, um eine praktikable Nutzung im Schulkontext zu ermöglichen.

Neben Energie und Genauigkeit beeinflussen Betriebssystemmechanismen die Nutzbarkeit. Moderne Betriebssysteme begrenzen Standortupdates im Hintergrund, um Akku zu sparen und Privatsphäre zu schützen. Android limitiert seit Android 8.0 die Häufigkeit von Standortupdates im Hintergrund deutlich [@android_background_location_limits_2024]. iOS unterscheidet Berechtigungen wie „When In Use“ und „Always“ und koppelt deren Vergabe an transparente Nutzerzustimmung [@apple_request_location_authorization_2026]. Für GeoQuest ist dies insofern relevant, als dass der Ablauf primär während aktiver Nutzung der App stattfindet und daher bewusst auf eine Minimierung von Hintergrundtracking ausgelegt werden kann. Dadurch wird nicht nur die technische Robustheit erhöht, sondern es wird auch eine datenschutzfreundliche Grundannahme getroffen, weil die Verarbeitung des Standorts auf den tatsächlichen Spielzeitraum begrenzt bleibt.

### Werkzeuge, Programmiersprachen und Entwicklungsumgebung

Der Backend-Teil der Anwendung besteht im Projektkontext nicht nur aus einer Datenbankkonfiguration, sondern aus einer Werkzeugkette, die Entwicklung, Testbarkeit und reproduzierbaren Betrieb ermöglicht. Für die App-Entwicklung werden Flutter SDK und Dart SDK verwendet. Dart ist als Sprache statisch typisiert und unterstützt sound null safety, wodurch ein großer Teil typischer Laufzeitfehler bereits während der Entwicklung vermieden werden kann [@dart_null_safety_2026]. Flutter nutzt den Paketmanager pub; Abhängigkeiten werden in der pubspec.yaml beschrieben, und pub löst neben direkten auch transitive Abhängigkeiten auf. Diese Eigenschaften sind für den Backend-Teil relevant, weil Firebase- und Firestore-APIs über Packages eingebunden werden und Versionsänderungen direkten Einfluss auf Datenzugriff und Authentifizierung haben können [@dart_pub_dependencies_2025].

Für die Firebase-Integration werden in der Praxis typischerweise zwei Ebenen unterschieden. Einerseits erfolgt die Konfiguration der Firebase-Apps je Plattform, andererseits wird die Verbindung zur Runtime über firebase_core initialisiert. Firebase empfiehlt für Flutter die Nutzung der FlutterFire CLI, die Plattformkonfigurationen aus dem Firebase-Projekt ausliest und daraus eine firebase_options.dart generiert, die im Code für die Initialisierung verwendet wird [@firebase_flutter_setup_2026] [@flutterfire_cli_2026]. Dadurch wird die Konfiguration reproduzierbar und lässt sich über Versionskontrolle nachvollziehen.

Für lokale Tests und Sicherheitsvalidierung ist die Firebase Local Emulator Suite wesentlich. Sie wird über die Firebase CLI eingerichtet und ermöglicht es, Firestore, Authentication und weitere Dienste lokal auszuführen, um Security Rules und Zugriffsmuster zu testen, ohne produktive Ressourcen zu gefährden [@firebase_emulator_suite_2026] [@firebase_emulator_install_config_2026] [@firebase_cli_reference_2026]. Da Unit Tests für Security Rules über JavaScript/Node.js ausgeführt werden, ist Node.js als Laufzeitumgebung ein weiterer Bestandteil der Toolchain [@firebase_rules_unit_tests_2026]. Die Verwendung von YAML und JSON als Konfigurationsformate ist in diesem Kontext funktional begründet, weil Abhängigkeiten, Emulator-Konfiguration und Indexdefinitionen damit deklarativ beschrieben werden können, wodurch die Backend-Konfiguration in Artefakte überführt wird, die sich prüfen, versionieren und deployen lassen.

### Flutter als Entwicklungsframework und Dart als Sprache

Flutter ist ein plattformübergreifendes Framework, das mit einer einzigen Codebasis Anwendungen für mehrere Zielplattformen ermöglicht. Für die Architektur ist relevant, dass Flutter ein deklaratives und reaktives UI-Modell verwendet. Die Benutzeroberfläche wird aus dem aktuellen Zustand der Anwendung abgeleitet und bei Zustandsänderungen neu aufgebaut. Diese Eigenschaft wirkt indirekt auf das Backend-Design, weil Datenmodelle, Zustandsübergänge und Datenzugriffe klar beschrieben werden müssen, damit UI und Persistenz konsistent bleiben [@flutter_arch_overview_2025] [@flutter_app_arch_guide_2026]. Flutter empfiehlt dafür eine Schichtenstruktur, in der Datenzugriff über definierte Schnittstellen erfolgt. Für den Backend-Teil ist dabei entscheidend, dass sicherheits- und kostenrelevante Entscheidungen nicht unkontrolliert in UI-Code verteilt sind, sondern zentral umgesetzt werden [@flutter_app_arch_guide_2026].

Dart unterstützt asynchrone Programmierung, die im Mobile-Kontext essenziell ist, weil Netzwerkzugriffe und Sensorabfragen nicht sofort abgeschlossen werden. Futures repräsentieren ein einmaliges Ergebnis in der Zukunft, etwa das Laden eines Dokuments aus einer Datenbank. Streams repräsentieren eine Folge von Ereignissen, etwa fortlaufende Standortupdates oder Realtime-Listener auf Datenbankänderungen [@dart_async_await_2025] [@dart_using_streams_2025]. Diese Unterscheidung beeinflusst das Backend-Design, weil Abfragen von Stammdaten typischerweise als einzelne Ladevorgänge modelliert werden, während Standorttracking und Live-Updates den Charakter eines kontinuierlichen Datenstroms besitzen.

Hot Reload ist ein wichtiger Bestandteil des Flutter-Entwicklungsprozesses und beschleunigt Iterationen, weil Änderungen während der Entwicklung unmittelbar überprüfbar sind [@flutter_hot_reload_2026]. Im Rahmen der Diplomarbeit beeinflusst das Vorgehen insbesondere bei Prototyping und Debugging, etwa bei der Kalibrierung von Distanzfiltern, beim Testen von Dialogzuständen oder beim schrittweisen Verfeinern von Datenzugriffsmustern.

### Firebase als Backend-Plattform

Firebase ist eine Backend-as-a-Service-Plattform, die typische Backend-Funktionen als Cloud-Dienst bereitstellt. In GeoQuest werden insbesondere Firebase Authentication und Cloud Firestore genutzt. Der BaaS-Ansatz reduziert den Aufwand für Infrastruktur, weil kein eigener Server betrieben werden muss. Gleichzeitig bedeutet serverlos nicht, dass keine Serverlogik existiert, sondern dass Autorisierung und Datenvalidierung in großen Teilen durch Security Rules und Managed Services abgebildet werden [@firebase_rules_get_started_2026]. Daraus folgt, dass korrekt formulierte Sicherheitsregeln, konsistente Dokumentpfade und ein kostenbewusstes Zugriffsmuster zentrale Bestandteile des Backend-Designs sind.

Ein Vorteil von Firestore ist die starke Konsistenz von Reads. Standardmäßig liefern Reads den neuesten Datenstand, der alle bis zum Start des Reads abgeschlossenen Writes berücksichtigt [@firestore_understand_reads_writes_scale_2026]. Zusätzlich unterstützt Firestore Realtime-Listener. Firebase beschreibt für Realtime-Abfragen ein Konsistenzverhalten, bei dem Updates in der Reihenfolge der Commit-Operationen verarbeitet werden und damit ein nachvollziehbarer Änderungsfluss entsteht [@firestore_realtime_queries_scale_2026]. Für GeoQuest ist dies relevant, weil Spielzustände und Fortschrittsanzeigen davon profitieren, wenn Änderungen konsistent beim Client ankommen, ohne dass zusätzliche Synchronisationslogik implementiert werden muss.

#### Firebase Authentication

Firebase Authentication ermöglicht Registrierung und Login. Nach erfolgreicher Anmeldung erhält jeder Benutzer eine eindeutige UID. Diese UID ist in der Architektur ein zentrales Element, weil sie als stabile Referenz für Benutzerprofile und benutzerspezifische Daten dient. In Security Rules steht die Authentifizierungsinformation als Variable zur Verfügung. Firebase beschreibt, dass request.auth unter anderem uid und Token-Informationen enthält, wodurch Regeln identitätsbasiert formuliert werden können [@firebase_rules_and_auth_2026]. Für GeoQuest ist dies besonders hilfreich, weil Zugriffskontrolle über Dokumentpfade wie Users/{uid} oder PlayerLocation/{uid} präzise und ohne zusätzliche Suchabfragen umgesetzt werden kann.

Darüber hinaus eröffnet Authentication die Möglichkeit, Rollenmodelle über Custom Claims zu realisieren. Auch wenn in GeoQuest zunächst ein bewusst schlankes Rollenmodell gewählt wurde, bleibt die Architektur prinzipiell erweiterbar. Über Custom Claims könnten in späteren Versionen beispielsweise Lehrkräfte oder Administratoren privilegierte Schreibrechte für Inhalte wie Hunts und Stationen erhalten, ohne dass diese Rechte in der App selbst hartkodiert werden müssen [@firebase_rules_and_auth_2026]. Die klare Trennung zwischen Authentifizierung und Autorisierung entspricht auch typischen mobilen Sicherheitsanforderungen im OWASP-MASVS-Kontext [@owasp_masvs_auth_2026].

#### Cloud Firestore

Cloud Firestore ist eine dokumentenbasierte NoSQL-Datenbank. Daten werden in Collections organisiert, die Dokumente enthalten, und Dokumente können wiederum Subcollections besitzen [@firestore_data_model_2026]. Dieses Modell erlaubt flexible Strukturen, erfordert aber eine bewusste Planung, weil es keine klassischen Joins wie in relationalen Datenbanken gibt. Stattdessen wird das Datenmodell häufig nach den Abfragen gestaltet, die tatsächlich benötigt werden. Firebase beschreibt hierfür query-orientierte Modellierungsansätze, bei denen typische Screens mit wenigen Reads versorgt werden, was Latenz und Kosten reduziert [@firestore_data_model_2026].

Für konsistente Änderungen über mehrere Dokumente stellt Firestore Transaktionen und Batched Writes bereit. Diese Mechanismen ermöglichen atomare Operationen, bei denen entweder alle Schritte erfolgreich sind oder keine Änderung angewendet wird [@firestore_transactions_2026]. Aus Backend-Sicht ist dies dann entscheidend, wenn Integritätsanforderungen bestehen, etwa beim Aktualisieren von Punkteständen oder beim Markieren einer Station als erreicht.

Ein weiterer zentraler Aspekt ist die Indexierung. Firestore nutzt automatische Single-Field-Indizes und für komplexere Abfragen zusammengesetzte Indizes. Firebase dokumentiert, dass fehlende Indizes bei bestimmten Abfragen als Fehler sichtbar werden und dann gezielt ergänzt werden können. Zudem lassen sich Indexdefinitionen als Datei verwalten und über die Firebase CLI deployen, wodurch Indexe und Rules als versionierbare Backend-Konfiguration behandelt werden können [@firestore_indexing_2026] [@firebase_manage_rules_deploy_2026].

Cloud Firestore unterstützt außerdem Offline-Persistenz, bei der relevante Daten lokal gecacht werden. Dadurch können Apps auch bei instabiler Verbindung lesen, schreiben und Abfragen ausführen, während lokale Änderungen bei erneuter Verbindung synchronisiert werden [@firestore_enable_offline_2026]. Für GeoQuest ist das praxisrelevant, weil Schulumgebungen und Außenbereiche nicht immer zuverlässige Netzabdeckung bieten und die App dadurch robuster eingesetzt werden kann.

## Praktische Arbeit

Der praktische Teil beschreibt die konkrete Umsetzung des Backends in GeoQuest. Ziel ist es, die Implementierung so zu dokumentieren, dass sie nachvollziehbar bleibt und zentrale Designentscheidungen begründet werden. Die Darstellung konzentriert sich auf backend-relevante Aspekte wie Datenmodell, Zugriffskontrolle, Zugriffsmuster, Testbarkeit sowie Maßnahmen zur Kosten- und Risikoentwicklung.

### Vorgehensmodell und Traceability der Artefakte

Die Umsetzung erfolgte iterativ. Aus Anforderungen wurden zunächst fachliche Entitäten abgeleitet, anschließend wurden Zugriffsmuster entworfen und erst danach die konkrete Speicherung in Firestore umgesetzt. Diese Reihenfolge ist im NoSQL-Kontext besonders wichtig, weil die Datenstruktur stark von den benötigten Queries abhängt. Aus den Anforderungen ergeben sich Entitäten wie Benutzer, Hunt, Station, Fortschritt und Position. Aus diesen Entitäten entsteht ein Datenmodell, aus dem wiederum Security Rules und konkrete Zugriffsmuster abgeleitet werden. Diese werden schließlich in der App über zentralisierte Datenzugriffsfunktionen realisiert. Damit entsteht eine nachvollziehbare Artefaktkette von fachlicher Anforderung über Struktur und Regeln bis zur Implementierung.

Für die Qualitätssicherung ist entscheidend, dass Security Rules nicht nur als Konfiguration verstanden werden, sondern als testbare Spezifikation von Zugriffserwartungen. Firebase beschreibt, dass Rules über die Local Emulator Suite und Unit Tests validiert werden können, bevor sie produktiv eingesetzt werden [@firebase_rules_unit_tests_2026] [@firebase_rules_emulator_test_2026]. Dadurch werden Sicherheitsannahmen als wiederholbare Testfälle formuliert, statt ausschließlich über manuelle Tests in der App implizit zu bleiben.

### Toolchain, Projektkonfiguration und Reproduzierbarkeit

Damit das Backend-Verhalten reproduzierbar bleibt, müssen sowohl Code als auch Konfigurationen konsistent sein. Auf App-Seite werden Abhängigkeiten und SDK-Bereiche in der pubspec.yaml festgelegt. Zusätzlich entstehen Konfigurationsartefakte für Firebase, etwa eine firebase.json, Firestore Rules-Dateien und eine Datei für Indexdefinitionen. Für Flutter empfiehlt Firebase, die Projektkonfiguration über die FlutterFire CLI zu erzeugen, wodurch eine firebase_options.dart entsteht, die die plattformspezifischen Parameter kapselt und im Code in Firebase.initializeApp eingebunden wird [@firebase_flutter_setup_2026] [@flutterfire_cli_2026].

~~~{caption="pubspec.yaml: SDK- und Firebase-Abhängigkeiten" .yaml}
environment:
  sdk: ">=3.2.0 <4.0.0"

dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
~~~

Für lokale Validierung wurde die Firebase Local Emulator Suite eingesetzt. Sie wird über die Firebase CLI installiert und ermöglicht es, Firestore, Auth und eine UI lokal zu starten. Dadurch kann das Team Security Rules testen, ohne produktive Daten zu gefährden, und es lassen sich Fehlkonfigurationen früh erkennen [@firebase_emulator_suite_2026] [@firebase_emulator_install_config_2026] [@firebase_cli_reference_2026].

~~~{caption="firebase.json: Emulator-Konfiguration" .json}
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
~~~

Ein weiterer Aspekt der Reproduzierbarkeit ist der kontrollierte Rollout von Konfigurationsänderungen. Firebase beschreibt, dass Rules und Indexe über lokale Dateien verwaltet und mit der CLI deployt werden können. Der zentrale Vorteil liegt darin, dass lokale Dateien die im Projekt gültige Wahrheit darstellen und Deployments nachvollziehbar werden, anstatt Änderungen ausschließlich in Web-UIs vorzunehmen [@firebase_manage_rules_deploy_2026] [@firestore_indexing_2026].

### Datenmodell im Detail

Das Datenmodell wurde so entworfen, dass es den Spielablauf abbildet und zugleich effiziente Reads in der App ermöglicht. Die Daten lassen sich in zwei Kategorien einteilen. Statische Inhalte umfassen Schnitzeljagden und Stationen, die für viele Benutzer identisch sind. Benutzerspezifische Daten umfassen Profile, Fortschritt und Standortinformationen. Diese Trennung unterstützt Datenschutz und Wartbarkeit, weil personenbezogene Daten klar von allgemeinen Inhalten getrennt bleiben [@gdpr_2016_679] [@firestore_data_model_2026].

Ein Hunt-Dokument enthält Metadaten, die für Auswahl und Anzeige relevant sind. Stationen werden als Subcollection unter einer Hunt geführt, wodurch der fachliche Zusammenhang strukturell abgebildet wird. Der Fortschritt wird benutzerspezifisch gespeichert, sodass sich Änderungen am Spielzustand nicht mit Stammdaten vermischen. Die nachfolgenden JSON-Beispiele dienen als strukturelle Referenz und sind bewusst minimal gehalten.

~~~{caption="JSON-Struktur: Hunt-Dokument" .json}
{
  "Hunts/huntA": {
    "title": "HTL Leoben Tour",
    "description": "Einführung in Gebäude und Bereiche",
    "isActive": true,
    "createdAt": "serverTimestamp"
  }
}
~~~

~~~{caption="JSON-Struktur: Station-Dokument" .json}
{
  "Hunts/huntA/Stations/station01": {
    "stationIndex": 1,
    "name": "Eingang",
    "taskText": "Finde das Info-Board.",
    "location": { "lat": 47.377, "lng": 15.094 },
    "points": 10
  }
}
~~~

~~~{caption="JSON-Struktur: Benutzerprofil" .json}
{
  "Users/uid123": {
    "username": "Max",
    "totalPoints": 30,
    "createdAt": "serverTimestamp"
  }
}
~~~

~~~{caption="JSON-Struktur: Fortschrittsdokument" .json}
{
  "Progress/uid123/Hunts/huntA": {
    "currentStationIndex": 2,
    "updatedAt": "serverTimestamp"
  }
}
~~~

~~~{caption="JSON-Struktur: PlayerLocation-Dokument" .json}
{
  "PlayerLocation/uid123": {
    "location": { "lat": 47.377, "lng": 15.094 },
    "timestamp": "serverTimestamp"
  }
}
~~~

Diese Struktur unterstützt typische App-Screens. Eine Hunt-Auswahl lädt Hunt-Metadaten. Der Spielscreen lädt Stationen einer Hunt. Fortschritt wird benutzerbezogen abgefragt und aktualisiert. Standortdaten werden als letzter bekannter Wert gespeichert, wodurch eine Verlaufshistorie vermieden wird und Kosten sowie Datenschutzrisiko sinken.

### Denormalisierung, Query-driven Modeling und Konsistenz

Firestore ist eine NoSQL-Datenbank, bei der Abfragen ohne Joins geplant werden müssen. Daraus folgt häufig eine query-orientierte Modellierung, bei der Daten so abgelegt werden, dass sie mit wenigen Reads geladen werden können [@firestore_data_model_2026]. In der Praxis bedeutet dies, dass bestimmte Informationen bewusst dupliziert werden können, um zusätzliche Abfragen zu vermeiden. Beispielsweise kann ein Station-Dokument Felder enthalten, die für die Darstellung unmittelbar benötigt werden, ohne dass mehrere Dokumente nachgeladen werden müssen.

Diese Denormalisierung hat eine klare Gegenleistung. Duplizierte Daten können inkonsistent werden, wenn sie nicht gemeinsam aktualisiert werden. Firestore stellt für konsistente Mehrfachupdates Batched Writes bereit, bei denen mehrere Schreiboperationen zusammen ausgeführt werden [@firestore_transactions_2026]. Das folgende Listing zeigt beispielhaft, wie eine Änderung an einem Hunt-Titel, der zusätzlich in Stationen gespeichert wird, per Batch auf mehrere Dokumente übertragen werden kann.

~~~{caption="Batched Write: Hunt-Titel konsistent aktualisieren" .dart}
Future<void> updateHuntTitleEverywhere({
  required FirebaseFirestore db,
  required String huntId,
  required String newTitle,
}) async {
  final batch = db.batch();

  final huntRef = db.collection('Hunts').doc(huntId);
  batch.update(huntRef, {'title': newTitle});

  final stationsSnap = await huntRef.collection('Stations').get();
  for (final doc in stationsSnap.docs) {
    batch.update(doc.reference, {'huntTitle': newTitle});
  }

  await batch.commit();
}
~~~

In GeoQuest wurde Denormalisierung gezielt begrenzt und vor allem dort eingesetzt, wo sie einen klaren Vorteil für Latenz und Kosten bringt. Wo möglich, bleibt eine eindeutige Quelle der Wahrheit erhalten, und zusätzliche Felder dienen der Darstellung oder der Query-Unterstützung.

### Abfragen, Collection Group Queries und Pagination

Stationen werden primär pro Hunt geladen. Für bestimmte Auswertungen kann es jedoch sinnvoll sein, über alle Stationen hinweg zu suchen, etwa bei Qualitätsprüfung, Admin-Ansichten oder Inhaltsvalidierung. Firestore unterstützt dafür Collection Group Queries, die über alle Subcollections mit demselben Namen hinweg abfragen können [@firestore_get_data_2026] [@firestore_queries_2026]. Solche Abfragen erfordern in der Regel passende Indexe, weshalb die Indexverwaltung Teil der Backend-Konfiguration ist [@firestore_indexing_2026].

Das folgende Listing zeigt eine Collection Group Query, die alle Stationen einer Hunt über das Feld huntId aggregiert.

~~~{caption="Collection Group Query: Stationen einer Hunt" .dart}
Query<Map<String, dynamic>> stationsOfHuntAcrossDb({
  required FirebaseFirestore db,
  required String huntId,
}) {
  return db
      .collectionGroup('Stations')
      .where('huntId', isEqualTo: huntId)
      .orderBy('stationIndex');
}
~~~

Für mobile Anwendungen ist Pagination relevant, weil große Datenmengen nicht in einem Schritt geladen werden sollen. Firestore unterstützt hierfür limit und Cursor-basierte Pagination über startAfterDocument oder startAt, wodurch fortlaufendes Nachladen möglich wird [@firestore_queries_2026].

~~~{caption="Pagination mit Cursor für Stationsdaten" .dart}
Future<(List<QueryDocumentSnapshot<Map<String, dynamic>>>, QueryDocumentSnapshot<Map<String, dynamic>>?)>
loadStationsPage({
  required FirebaseFirestore db,
  required String huntId,
  QueryDocumentSnapshot<Map<String, dynamic>>? cursor,
  int pageSize = 20,
}) async {
  var q = db
      .collection('Hunts')
      .doc(huntId)
      .collection('Stations')
      .orderBy('stationIndex')
      .limit(pageSize);

  if (cursor != null) {
    q = q.startAfterDocument(cursor);
  }

  final snap = await q.get();
  final docs = snap.docs;
  final nextCursor = docs.isNotEmpty ? docs.last : null;
  return (docs, nextCursor);
}
~~~

### Offline-Persistenz und Synchronisationsverhalten

Firestore unterstützt Offline-Persistenz, indem Daten, die aktiv verwendet werden, lokal gecacht werden. Laut Firebase können Apps damit auch offline lesen, schreiben, auf Daten lauschen und Abfragen durchführen; lokale Änderungen werden nach Wiederverbindung synchronisiert [@firestore_enable_offline_2026]. Für GeoQuest ist das praxisrelevant, weil Spielabläufe nicht durch kurzfristige Netzprobleme unterbrochen werden sollen.

Für bestimmte Situationen ist es hilfreich, die Datenquelle bewusst zu wählen. In FlutterFire können GetOptions verwendet werden, um Reads aus dem Cache zu erzwingen oder den Server zu bevorzugen. Das folgende Listing zeigt beispielhaft einen Read, der explizit aus dem Cache erfolgt, um Offline-Verhalten reproduzierbar testen zu können.

~~~{caption="Offline-Read aus Firestore-Cache" .dart}
Future<Map<String, dynamic>?> loadUserFromCache({
  required FirebaseFirestore db,
  required String uid,
}) async {
  final snap = await db
      .collection('Users')
      .doc(uid)
      .get(const GetOptions(source: Source.cache));

  return snap.data();
}
~~~

Offline-Fähigkeit löst jedoch nicht alle Konflikte automatisch. Wenn mehrere Geräte denselben Zustand ändern, kann es zu konkurrierenden Writes kommen. Für kritische Updates, etwa Punkte oder Fortschritt, ist deshalb eine atomare Update-Logik sinnvoll, die Inkonsistenzen reduziert. Firestore-Transaktionen sind hierfür ein geeignetes Werkzeug, weil sie Reads und Writes innerhalb einer Operation konsistent bündeln [@firestore_transactions_2026].

### Benutzerverwaltung und Zugriffsmuster

Die Benutzerverwaltung basiert auf Firebase Authentication und einer ergänzenden Speicherung eines Benutzerprofils in Firestore. Jedes Benutzerprofil wird als eigenes Dokument abgelegt, dessen Dokument-ID der UID entspricht. Dadurch entsteht ein direkter Zugriffspfad, der sowohl performanz- als auch sicherheitsrelevant ist, weil Security Rules ohne zusätzliche Suche auf request.auth.uid prüfen können [@firebase_rules_and_auth_2026].

~~~{caption="Benutzerprofil in Firestore anlegen" .dart}
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
~~~

### Stationsfortschritt und atomare Updates

Für den Fortschritt ist aus Backend-Sicht wichtig, dass Zustandsänderungen konsistent erfolgen. Wird eine Station als erreicht markiert und gleichzeitig ein Punktestand erhöht, entsteht ein Integritätsbedarf. Firestore stellt hierfür Transaktionen bereit [@firestore_transactions_2026].

~~~{caption="Transaktion: Station abschließen und Punkte vergeben" .dart}
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
~~~

### Sicherheitskonzept mit Firestore Security Rules

Security Rules sind in einer serverlosen Architektur der zentrale Mechanismus zur Zugriffskontrolle. Jede Datenbankoperation wird serverseitig gegen Regeln geprüft, bevor sie ausgeführt wird [@firebase_rules_get_started_2026]. Firebase beschreibt, dass jede Anfrage gegen die Rules evaluiert wird und bei Ablehnung vollständig fehlschlägt [@firebase_rules_emulator_test_2026]. Zusätzlich dokumentiert Firebase, dass Rules neben Authentifizierung auch Datenvalidierung abbilden können, etwa über Typprüfungen, Feldbeschränkungen und Wertebereiche [@firebase_rules_conditions_2026].

Ein Designziel war, Rules so zu formulieren, dass sie möglichst wenig zusätzliche Dokumentreads benötigen. Dokumentbasierte Zugriffsfunktionen wie exists(), get() oder getAfter() sind pro Anfrage limitiert, und Reads zur Rule-Evaluation können kostenrelevant sein [@firestore_quotas_2026] [@firestore_pricing_firebase_2026]. Daraus folgt, dass Autorisierung primär über Pfade und Auth-Kontext erfolgen sollte und Querabhängigkeiten minimiert werden.

~~~{caption="Firestore Security Rules für GeoQuest" .txt}
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return signedIn() && request.auth.uid == userId;
    }

    match /Users/{userId} {
      allow read: if true;
      allow create: if isOwner(userId)
        && request.resource.data.keys().hasOnly(['username','totalPoints','createdAt'])
        && request.resource.data.username is string
        && request.resource.data.totalPoints is int
        && request.resource.data.totalPoints == 0;

      allow update: if isOwner(userId)
        && request.resource.data.keys().hasOnly(['username','totalPoints','createdAt'])
        && request.resource.data.username is string
        && request.resource.data.totalPoints is int
        && request.resource.data.totalPoints >= resource.data.totalPoints;
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
      allow read, write: if isOwner(userId);
    }
  }
}
~~~

### Rollenmodell über Custom Claims

Firebase beschreibt Custom Claims als Mechanismus, um Rolleninformationen in Tokens abzubilden, die anschließend in Security Rules geprüft werden können [@firebase_rules_and_auth_2026]. Damit kann beispielsweise eine Lehrkraft als Administrator markiert werden, ohne dass die App selbst rollenbasierte Logik implementieren muss.

~~~{caption="Custom Claims setzen (Admin-Rolle)" .javascript}
import admin from "firebase-admin";

admin.initializeApp();

async function setAdmin(uid) {
  await admin.auth().setCustomUserClaims(uid, { admin: true });
}

await setAdmin("teacherUid");
~~~

### Missbrauchsschutz durch Firebase App Check

Firebase stellt mit App Check einen Mechanismus bereit, der eingehenden Traffic attestieren lässt und so verhindert, dass nicht legitime Clients auf Firebase-Ressourcen zugreifen [@firebase_app_check_2026]. Für GeoQuest ist App Check insbesondere als präventive Maßnahme relevant, um Missbrauch zu reduzieren, der zu unerwarteten Kosten oder zu Datenmanipulation führen könnte. App Check ersetzt keine Security Rules, sondern ergänzt sie.

### Qualitätssicherung durch Emulatoren und Unit Tests

Firebase beschreibt Unit Tests für Security Rules als Bestandteil eines zuverlässigen Entwicklungsprozesses. Tests werden lokal gegen Emulatoren ausgeführt und prüfen erlaubte sowie unerlaubte Zugriffe reproduzierbar [@firebase_rules_unit_tests_2026]. Die Unit-Testing-Bibliothek nutzt JavaScript/Node.js und ergänzt damit den Flutter/Dart-Teil des Projekts um eine testbare Sicherheits- und Backend-Konfiguration.

~~~{caption="Unit Tests für Firestore Security Rules" .javascript}
import { initializeTestEnvironment, assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import fs from "node:fs";

const testEnv = await initializeTestEnvironment({
  projectId: "demo-geoquest",
  firestore: { rules: fs.readFileSync("firestore.rules", "utf8") }
});

const alice = testEnv.authenticatedContext("aliceUid").firestore();
const bob = testEnv.authenticatedContext("bobUid").firestore();
const adminCtx = testEnv.authenticatedContext("teacherUid", { admin: true }).firestore();

await assertFails(
  bob.collection("PlayerLocation").doc("aliceUid").set({ timestamp: Date.now() })
);

await assertFails(
  alice.collection("Hunts").doc("huntA").set({ title: "Hack" })
);

await assertSucceeds(
  adminCtx.collection("Hunts").doc("huntA").set({ title: "HTL Tour" })
);
~~~

### Deployment, Versionierung und Betrieb

Firebase beschreibt die Verwaltung und den Deployment-Prozess für Security Rules und weist darauf hin, dass Deployments per CLI lokale Regeln als maßgebliche Quelle verwenden und dabei vorhandene Regeln in der Konsole überschreiben können [@firebase_manage_rules_deploy_2026]. Für Indexe beschreibt Firebase, dass Deployments über firebase deploy mit einem --only-Filter möglich sind [@firestore_indexing_2026].

~~~{caption="Firebase CLI Deployment-Befehle" .bash}
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only firestore
~~~

### Kostenmodell, Monitoring und Budgetierung

Cloud Firestore ist nutzungsbasiert abgerechnet. Firebase dokumentiert, dass Kosten primär pro Read, Write und Delete sowie für Bandbreite und Storage anfallen und dass Indexe zusätzliche Kostenkomponenten besitzen können [@firestore_pricing_firebase_2026]. Ein zentraler Kostentreiber sind häufige Writes und Realtime-Listener, da jede relevante Änderung zusätzliche Dokumentzugriffe verursachen kann. In GeoQuest wurde deshalb Standortpersistenz bewusst reduziert und auf den jeweils letzten Standort beschränkt, um Write-Frequenz und Datenmenge zu begrenzen.

Google Cloud Billing unterstützt Budgets und Budget-Alerts, die Ausgaben gegen definierte Schwellen überwachen und Benachrichtigungen auslösen können [@cloud_billing_budgets_2026]. Firebase beschreibt zudem Ansätze für fortgeschrittene Alert-Logik, bei der Budget- oder Billing-Events programmatisch weiterverarbeitet werden können [@firebase_advanced_billing_alerts_2026].

### Datenlebenszyklus, Löschung und Export

Firestore unterstützt Time-to-Live-Policies, mit denen Dokumente anhand eines Ablaufzeitpunkts automatisiert gelöscht werden können [@firestore_ttl_2026]. Für administrative Anforderungen kann außerdem ein Export- und Importmechanismus relevant sein. Firebase beschreibt einen verwalteten Export- und Importdienst für Firestore, der über Google Cloud und gcloud genutzt wird und Daten in Cloud Storage ablegt [@firestore_export_import_2023].

### Anti-Cheat als bewusste Abgrenzung mit Ausblick

GeoQuest ist eine standortbasierte Anwendung, deren Spielmechanik grundsätzlich durch clientseitige Manipulation beeinflusst werden kann, etwa durch gefälschte Standortdaten oder modifizierte App-Clients. In dieser Arbeit wird kein vollständiges Anti-Cheat-System umgesetzt, weil dies den Rahmen des Schulprojekts überschreiten würde. Aus Backend-Sicht ist dennoch relevant, mögliche Erweiterungsrichtungen zu benennen. Ein serverseitiger Ansatz könnte Plausibilitätsprüfungen über Zeit und Distanz durchführen oder Fortschrittsereignisse serverseitig validieren. In Firebase-Kontext wären dafür Cloud Functions eine mögliche Erweiterung, um serverseitige Logik einzuführen, ohne einen klassischen Backend-Server dauerhaft betreiben zu müssen. Im aktuellen Projektstand liegt der Schwerpunkt auf konsistenter Datenhaltung, restriktiven Rules, testbarer Konfiguration und einem Rollenmodell, das Schreibrechte auf Inhalte kontrolliert.

### Praxisfall als End-to-End-Nachweis

Ein Benutzer meldet sich an und erhält eine UID. Danach lädt die App die Stationen einer ausgewählten Schnitzeljagd und beginnt, Standortupdates zu verarbeiten. Die App erkennt anhand eines Distanzschwellwerts, ob eine Station erreicht wurde. Wird eine Station erreicht, wird der Fortschritt im benutzerspezifischen Zustand aktualisiert und ein Punktestand erhöht. Gleichzeitig kann der letzte Standort kontrolliert persistiert werden, wobei die Persistenz durch Bewegungsfilter begrenzt ist. Jede Operation wird serverseitig durch Security Rules geprüft. Unzulässige Schreibzugriffe, etwa auf fremde Benutzerpfade oder auf administrative Inhalte, werden abgelehnt, wodurch ein konsistenter Schutzmechanismus entsteht [@firebase_rules_emulator_test_2026].

Dieser Ablauf führt die zentralen Backend-Entscheidungen zusammen. UID-basierte Dokumentpfade ermöglichen identitätsgebundene Autorisierung, ein query-orientiertes Datenmodell unterstützt effiziente Reads, Denormalisierung wird kontrolliert eingesetzt und über Batch-Operationen konsistent gehalten, Bewegungsfilter reduzieren Writes und damit Kosten, und Security Rules sichern Zugriff und Datenintegrität ab. Dadurch ist die Backend-Architektur als nachvollziehbare Antwort auf Anforderungen an Datenschutz, Kostenkontrolle und Robustheit dokumentiert.
