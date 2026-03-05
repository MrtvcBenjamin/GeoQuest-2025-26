# Überarbeitete Ausarbeitung und Quellen

## A) Vollständiger überarbeiteter Text

```md
# Teilaufgabe Schüler Kovacs
\textauthor{Christian Kovacs}

## Theorie

Dieses Kapitel bildet die theoretische Grundlage für die praktische Umsetzung des Backend-Teils einer standortbasierten Schnitzeljagd-Applikation. Der Text ist so aufgebaut, dass auch Leserinnen und Leser ohne vertiefte Kenntnisse in der App-Entwicklung die zentralen Entscheidungen nachvollziehen können. Wo Fachbegriffe notwendig sind, werden sie eingeführt und anschließend konsistent verwendet.

### 1. Grundlagen mobiler Applikationen

Mobile Applikationen sind Softwareprogramme, die speziell für mobile Endgeräte entwickelt werden. Sie unterscheiden sich von klassischen Desktop-Anwendungen vor allem dadurch, dass sie mit begrenzten Ressourcen umgehen müssen und stark von Sensorik sowie Betriebssystemmechanismen beeinflusst werden. Gerade bei standortbasierten Anwendungen ist nicht nur die technische Umsetzung relevant, sondern auch der korrekte Umgang mit sensiblen Daten, weil Standortinformationen Rückschlüsse auf Bewegungsprofile zulassen können. In diesem Kontext sind Datensparsamkeit und Zugriffskontrolle nicht „Zusatzfeatures“, sondern fachliche Anforderungen, die bereits in der Architektur berücksichtigt werden müssen [@gdpr_2016_679].

Die Standortbestimmung erfolgt in der Praxis über eine Kombination mehrerer Quellen. Umgangssprachlich wird häufig von GPS gesprochen, technisch ist meist GNSS gemeint. Zusätzlich können WLAN-Informationen und Mobilfunkdaten die Stabilität verbessern. In städtischen Gebieten oder bei Abschattungen kommt es zu Messfehlern, die sich als Positionssprünge oder Streuung äußern. Für Anwendungen wie GeoQuest ist deshalb weniger eine theoretisch maximale Genauigkeit entscheidend, sondern ein robustes Verhalten gegenüber Messrauschen, das den Spielablauf nicht verfälscht.

Ein weiterer zentraler Faktor ist der Energieverbrauch. Standorttracking gehört zu den energieintensiven Funktionen eines Smartphones. Hohe Genauigkeitsstufen und sehr häufige Updates erhöhen Akkuverbrauch und Rechenlast. Für die Backend-Perspektive kommt hinzu, dass häufige Standortupdates zu einer großen Anzahl an Datenbankoperationen führen können, die bei Cloud-Diensten direkte Kosten verursachen. Daraus folgt, dass ein standortbasiertes System nicht nur funktional, sondern auch effizient entworfen werden muss.

### 2. Flutter als Entwicklungsframework und Dart als Sprache

Flutter ist ein plattformübergreifendes Framework, das mit einer einzigen Codebasis Anwendungen für mehrere Zielplattformen ermöglicht. Für die Architektur ist relevant, dass Flutter ein reaktives UI-Modell verwendet: Die Benutzeroberfläche wird aus dem aktuellen Zustand der Anwendung abgeleitet und bei Zustandsänderungen neu aufgebaut. Diese Eigenschaft beeinflusst indirekt das Backend-Design, weil Datenmodelle und Zustandsübergänge klar beschrieben werden müssen, damit UI und Datenzugriff konsistent bleiben [@flutter_arch_overview] [@flutter_app_arch_guide].

Dart unterstützt asynchrone Programmierung, die im Mobile-Kontext essenziell ist, weil Netzwerkzugriffe und Sensorabfragen nicht sofort abgeschlossen werden. In der Praxis treten zwei Konzepte besonders häufig auf. Futures repräsentieren ein einmaliges Ergebnis in der Zukunft, etwa das Laden eines Dokuments aus einer Datenbank. Streams repräsentieren eine Folge von Ereignissen, etwa fortlaufende Standortupdates. Die Unterscheidung ist nicht nur eine Sprachdetailsfrage, sondern beeinflusst die Implementierung: Standorttracking ist als Stream modelliert, während das Laden von Stammdaten häufig über Futures erfolgt.

Hot Reload ist ein wichtiger Bestandteil des Flutter-Entwicklungsprozesses und beschleunigt Iterationen, weil Änderungen während der Entwicklung schnell überprüfbar werden [@flutter_hot_reload]. Für eine Diplomarbeit ist dies insofern relevant, als dass es das Vorgehen bei Prototyping und Debugging beeinflusst, etwa bei der Abstimmung von Distanzfiltern oder Dialoglogik.

### 3. Firebase als Backend-Plattform

Firebase ist eine Backend-as-a-Service-Plattform, die typische Backend-Funktionen als Cloud-Dienst bereitstellt. In GeoQuest werden insbesondere Firebase Authentication und Cloud Firestore genutzt. Der BaaS-Ansatz reduziert den Aufwand für Infrastruktur, weil kein eigener Server betrieben werden muss. Gleichzeitig bedeutet „serverlos“ nicht, dass keine Serverlogik existiert, sondern dass Autorisierung und Datenvalidierung in großen Teilen durch Security Rules und Managed Services abgebildet werden [@firebase_rules_get_started].

#### 3.1 Firebase Authentication

Firebase Authentication ermöglicht Registrierung und Login. Nach erfolgreicher Anmeldung erhält jeder Benutzer eine eindeutige UID. Diese UID ist in der Architektur ein zentrales Element, weil sie als stabile Referenz für Benutzerprofile und benutzerspezifische Daten dient. Technisch basiert die Zugriffskette auf Tokens, die vom System geprüft werden. Firestore kann dadurch Anfragen identitätsbasiert auswerten und in Security Rules über request.auth Informationen wie die UID bereitstellen [@firebase_rules_get_started]. Die Tokenprüfung ist für den Client transparent, aber konzeptionell wichtig, weil sie den Unterschied zwischen „nur lokal sichtbar“ und „serverseitig autorisiert“ definiert.

#### 3.2 Cloud Firestore

Cloud Firestore ist eine dokumentenbasierte NoSQL-Datenbank. Daten werden in Collections organisiert, die Dokumente enthalten, und Dokumente können wiederum Subcollections besitzen. Dieses Modell erlaubt flexible Strukturen, erfordert aber eine bewusste Planung, weil es keine klassischen Joins wie in relationalen Datenbanken gibt. Stattdessen wird das Datenmodell häufig nach den Abfragen gestaltet, die tatsächlich benötigt werden. Diese Vorgehensweise wird als query-driven data modeling beschrieben und ist im Mobile-Kontext sinnvoll, weil typische Screens klar definierte Daten benötigen, die in wenigen Abfragen geladen werden sollen [@firestore_data_model].

Für konsistente Änderungen über mehrere Dokumente stellt Firestore Transaktionen und Batched Writes bereit. Diese Mechanismen sind relevant, wenn Integritätsanforderungen bestehen, etwa beim manipulationsarmen Aktualisieren von Punkteständen [@firestore_transactions]. Auch wenn in GeoQuest viele Abläufe clientseitig umgesetzt sind, beeinflusst das Wissen um diese Mechanismen die spätere Erweiterbarkeit.

### 4. Abgrenzung und Zielsetzung des Backend-Umfangs

Diese Teilaufgabe betrachtet das Backend als Kombination aus Datenmodell, Zugriffsmustern, Sicherheitsregeln und kostenbewusster Datenpersistenz. Im Fokus stehen die Verwaltung von Benutzerprofilen, Spielinhalten (Schnitzeljagden und Stationen) sowie die kontrollierte Speicherung von Standortdaten. Nicht Gegenstand dieser Teilaufgabe sind ein eigener API-Server, komplexe Serverlogik mit Cloud Functions oder ein vollständiges Anti-Cheat-System mit serverseitiger Distanzvalidierung, da dies den zeitlichen Rahmen des Schulprojekts überschreiten würde. Die Architektur wird jedoch so beschrieben, dass eine spätere Erweiterung in diese Richtung möglich bleibt, insbesondere durch klare Zuständigkeiten und konsistente Zugriffsmuster.

## Praktische Arbeit

Der praktische Teil beschreibt die konkrete Umsetzung des Backends in GeoQuest. Ziel ist es, die Implementierung so zu dokumentieren, dass sie nachvollziehbar bleibt und die wichtigsten Designentscheidungen begründet werden. Die Darstellung konzentriert sich auf die Backend-relevanten Aspekte, also Datenmodell, Zugriffskontrolle, Zugriffsmuster sowie Maßnahmen zur Kosten- und Risikoentwicklung.

### 1. Vorgehensmodell und Traceability der Artefakte

Die Umsetzung erfolgte iterativ. Aus Anforderungen wurden zunächst grobe Datenobjekte abgeleitet, anschließend wurden Zugriffsmuster entworfen und erst danach die konkrete Speicherung in Firestore umgesetzt. Diese Reihenfolge ist im NoSQL-Kontext besonders wichtig, weil die Datenstruktur stark von den benötigten Queries abhängt. Die Artefaktkette lässt sich im Projekt wie folgt nachvollziehen: Anforderungen definieren benötigte Entitäten (Benutzer, Hunt, Station, Position), daraus entsteht das Datenmodell, daraus ergeben sich Security Rules und Zugriffsmuster, und diese werden schließlich in der App über definierte Datenzugriffsfunktionen realisiert. Die Tests konzentrieren sich darauf, dass die Rules die beabsichtigten Zugriffe erlauben und unzulässige blockieren [@firebase_rules_emulator_test].

### 2. Gesamtarchitektur der Anwendung aus Backend-Sicht

Die Anwendung folgt einer klaren Trennung zwischen Benutzeroberfläche, Anwendungslogik und Datenzugriff. Aus Backend-Perspektive ist entscheidend, dass Datenzugriffe zentralisiert werden, damit Sicherheits- und Kostenregeln konsistent umgesetzt werden. Die App kommuniziert direkt mit Firebase Authentication und Firestore. Dadurch entfällt ein eigener Server, und die Autorisierung wird über Firestore Security Rules abgebildet. Für Diplomarbeitskontext ist relevant, dass diese Lösung den Infrastrukturbetrieb reduziert, jedoch eine präzise Konfiguration erfordert, weil Fehlkonfigurationen unmittelbare Auswirkungen auf Datenschutz und Integrität haben können [@firebase_rules_get_started].

### 3. Toolchain, Reproduzierbarkeit und Build-Stabilität

Für die Reproduzierbarkeit ist im Softwarekontext wichtig, dass die Toolchain konsistent ist. Flutter-Projekte binden Abhängigkeiten über pub ein, wodurch feste Versionen dokumentierbar sind. Für das Backend bedeutet dies, dass verwendete Firebase-Pakete und Firestore-APIs in definierten Versionen vorliegen müssen, um Laufzeitunterschiede und Inkonsistenzen zu vermeiden. Zusätzlich wurde die Firebase Emulator Suite als lokales Testwerkzeug genutzt, um Rules-Änderungen reproduzierbar zu validieren, bevor sie in eine produktive Umgebung gelangen [@firebase_emulator_setup] [@firebase_rules_emulator_test]. Dieses Vorgehen reduziert das Risiko, dass die Datenbank in der Entwicklung versehentlich zu offen konfiguriert wird.

### 4. Benutzerverwaltung

Die Benutzerverwaltung basiert auf Firebase Authentication und einer ergänzenden Speicherung eines Benutzerprofils in Firestore. Jedes Benutzerprofil wird als eigenes Dokument abgelegt, dessen Dokument-ID der UID entspricht. Dadurch entsteht ein direkter Zugriffspfad, der sowohl performanz- als auch sicherheitsrelevant ist, weil Security Rules ohne zusätzliche Suche auf request.auth.uid prüfen können.

Die Speicherung enthält einen Anzeigenamen, einen Punktestand und einen serverseitigen Erstellungszeitpunkt. Der serverseitige Zeitstempel ist ein bewusstes Design, um Manipulationen durch clientseitig gesetzte Werte zu reduzieren. Aus wissenschaftlicher Sicht ist hier wichtig, dass nicht behauptet wird, Manipulation sei unmöglich, sondern dass konkrete Kontrollpunkte im System identifiziert und angemessen behandelt werden.

Ein minimales Codebeispiel ist für die Nachvollziehbarkeit sinnvoll, weil es zeigt, wie UID-basierte Dokumentpfade umgesetzt werden:

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

Das Zugriffsmuster ist ein Point Read beziehungsweise ein gezielter Write auf Users/{uid}. Dieses Muster ist effizient, weil Firestore Dokumente direkt über ihren Pfad adressiert. Für die spätere Skalierung ist zudem relevant, dass Schreiblast über viele Benutzer verteilt ist, statt auf ein einzelnes Dokument zu konzentrieren.

### 5. Verwaltung von Schnitzeljagden und Stationen

Schnitzeljagden werden als Dokumente in einer Hunt-Collection abgelegt. Die Stationen werden als Subcollection unter einem Hunt gespeichert. Diese Struktur spiegelt die fachliche Zugehörigkeit wider und vermeidet, dass Stationen verschiedener Hunts vermischt werden. Die App lädt Stationen für eine konkrete Schnitzeljagd und sortiert diese über einen Index. Dadurch kann die Reihenfolge zentral im Backend gepflegt werden, ohne dass eine neue App-Version erforderlich ist, wenn Stationen geändert werden.

Das Laden der Stationen erfolgt über eine Collection Query auf Hunts/{huntId}/Stations, kombiniert mit einer Sortierung. Für Firestore ist dies ein typisches Zugriffsmuster, das durch Indizes unterstützt wird [@firestore_data_model]. Ein kurzes Codebeispiel ist hier gerechtfertigt, weil es das zentrale Query-Pattern demonstriert:

```dart
final snapshot = await FirebaseFirestore.instance
    .collection("Hunts")
    .doc(huntId)
    .collection("Stadions")
    .orderBy("stadionIndex")
    .get();
```

### 6. Speicherung von Standortdaten und Kostenkontrolle

Die Speicherung von Standortdaten ist sowohl technisch als auch organisatorisch sensibel. Technisch muss die App den Standort fortlaufend aktualisieren, organisatorisch soll die Menge gespeicherter Daten minimiert werden, um Kosten und Datenschutzrisiken zu reduzieren. Firestore berechnet Kosten pro Lese- und Schreiboperation sowie für Datenübertragung [@firestore_billing_example] [@firestore_pricing]. Zusätzlich existieren Quotas und Limits, die insbesondere für Entwicklungs- und Free-Tier-Szenarien relevant sind [@firestore_quotas]. Daraus folgt die Entscheidung, Standortupdates nicht zeitbasiert, sondern bewegungsbasiert zu speichern.

Im Projekt wird ein Distanzfilter genutzt, der Updates erst ab einer Bewegung von etwa zehn Metern als relevant betrachtet. Zusätzlich wird nicht eine vollständige Verlaufshistorie gespeichert, sondern nur die letzte bekannte Position pro Benutzer. Dieses Modell reduziert die Anzahl der Dokumente und damit langfristig auch die Verwaltungs- und Datenschutzkomplexität. Der serverseitige Zeitstempel dient dazu, das Ereignis zeitlich einzuordnen, ohne dass der Client den Wert selbst setzen muss.

Ein minimales Beispiel für die Speicherung der letzten Position ist für die Reproduzierbarkeit hilfreich:

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

### 7. Proximity-Erkennung und Stationsfortschritt

Die Proximity-Erkennung ist die fachliche Kernlogik der Schnitzeljagd. Sie bestimmt, ob sich ein Spieler nahe genug an einer Station befindet, um diese als erreicht zu markieren. Die Distanz wird als Luftlinie zwischen aktueller Position und Zielkoordinate berechnet. Da GNSS-Daten in der Praxis schwanken, wird ein Radius verwendet, der Spielbarkeit und Robustheit vereint. Im Projekt wurde ein Radius von etwa fünfzig Metern gewählt, weil dieser Wert typische Ungenauigkeiten abfedert, ohne das Spielprinzip zu verlieren.

Für die Distanzberechnung reicht ein einziges, kurzes Codefragment aus, um die Funktionsweise zu verdeutlichen:

```dart
double distanceInMeters = Geolocator.distanceBetween(
  myPosition.latitude,
  myPosition.longitude,
  targetGeo.latitude,
  targetGeo.longitude,
);
```

Wird der Schwellwert unterschritten, wird die Station als erreicht behandelt und der Fortschritt erhöht. Um Mehrfachauslösungen zu vermeiden, wird während der Dialoganzeige die Verarbeitung der Standortupdates pausiert. Dieses Vorgehen ist nicht nur funktional, sondern reduziert auch unnötige Rechenlast.

### 8. Sicherheitskonzept mit Firestore Security Rules

Security Rules sind in einer serverlosen Architektur der zentrale Mechanismus zur Zugriffskontrolle. Jede Datenbankoperation wird serverseitig gegen die Regeln geprüft, bevor sie ausgeführt wird. Damit bildet die Rules-Schicht einen Kernteil des Backends und ersetzt in vielen Punkten klassische serverseitige Autorisierungslogik [@firebase_rules_get_started] [@firebase_rules_conditions].

Für GeoQuest gilt als Grundprinzip, dass Benutzer nur ihre eigenen Profildaten verändern dürfen. Standortdaten werden als sensibel betrachtet und sind nur für authentifizierte Nutzer zugänglich. Ein minimales Rules-Beispiel verdeutlicht dieses Least-Privilege-Prinzip:

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /Users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /PlayerLocation/{docId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Für eine wissenschaftliche Darstellung ist entscheidend, dass Regeln nicht nur als „Schalter“ betrachtet werden. Rules können zusätzlich Datenvalidierung durchführen, etwa Längen- und Typprüfungen oder constraints auf Felder. Solche Bedingungen werden in Firestore über allow-Expressions formuliert, die sowohl Authentifizierung als auch Dateninhalte prüfen können [@firebase_rules_conditions]. Für GeoQuest wurde der Fokus zunächst auf korrektes Identitäts- und Pfadmodell gelegt, weil dies die Grundlage für spätere, feinere Validierung ist.

### 9. Qualitätssicherung und Evaluationslogik

Die Frage, wann eine Implementierung als „fertig“ gilt, muss im Softwarekontext operationalisiert werden. In diesem Projekt wurde Backend-Funktionalität als erfüllt betrachtet, wenn die folgenden Eigenschaften nachweisbar sind: Benutzer können sich anmelden und ein Profil wird gespeichert, Stationen können aus Firestore geladen werden, Standortdaten werden kontrolliert persistiert und Sicherheitsregeln verhindern unzulässige Schreibzugriffe. Die Überprüfung erfolgt nicht nur durch manuelle Tests in der App, sondern durch das gezielte Testen der Security Rules mit Emulator- und Simulator-Werkzeugen, weil gerade Rules-Fehler schwerwiegende Sicherheitsfolgen haben können [@firebase_rules_emulator_test].

Zusätzlich wurde bei der Sicherheitsbetrachtung ein praxisnaher Referenzrahmen herangezogen. OWASP MASVS beschreibt Anforderungen an mobile Anwendungen, insbesondere in Bezug auf Authentifizierung, Autorisierung und Datenschutz. Für GeoQuest ist dieser Rahmen hilfreich, um die relevanten Kategorien zu strukturieren, ohne ein vollständiges Penetration-Testing zu behaupten [@owasp_masvs].

### 10. Risiken, Blocker und präventive Maßnahmen

Das zentrale Kostenrisiko bei Firestore entsteht durch eine hohe Anzahl an Reads und Writes. Daher wurden Standortupdates begrenzt und es wird nur die letzte Position gespeichert. Zusätzlich ist zu berücksichtigen, dass Security Rules selbst Kosten verursachen können, weil Regelprüfungen zusätzliche Reads auslösen können, wenn die Regel Logik Daten aus anderen Dokumenten liest [@firestore_billing_example]. Deshalb wurde das Rollenmodell im Projekt bewusst einfach gehalten und administrative Abfragen in Rules nur dort vorgesehen, wo sie zwingend erforderlich sind.

Ein technisches Risiko ist die Ungenauigkeit der Standortdaten, die zu falschen Auslösungen führen kann. Hier wirkt der Radius als Puffer, und die Dialoglogik verhindert Mehrfachauslösungen. Ein organisatorisches Risiko ist eine Fehlkonfiguration der Rules. Diese Gefahr wird durch Emulator-gestützte Tests reduziert, die sowohl erlaubte als auch unerlaubte Zugriffe abprüfen [@firebase_rules_emulator_test].

Ein datenschutzbezogenes Risiko liegt in der Verarbeitung von Standortdaten. Als präventive Maßnahme wurde Datenminimierung umgesetzt, indem nur die letzte Position gespeichert wird. Diese Maßnahme ist mit dem Grundprinzip der Zweckbindung und Datenminimierung vereinbar, wie es in der DSGVO als Leitlinie angelegt ist [@gdpr_2016_679].

### 11. Praxisfall: Ablauf einer Station als End-to-End-Nachweis

Ein praxisnaher Ablauf verdeutlicht die Wechselwirkung zwischen Client und Backend. Ein Benutzer meldet sich an und erhält eine UID. Anschließend lädt die App die Stationen einer ausgewählten Schnitzeljagd aus der Subcollection. Während der Benutzer sich bewegt, erhält die App Standortupdates. Sobald die Distanz zu einer Station unter den Schwellwert fällt, wird die Station als erreicht erkannt. Der Fortschritt wird lokal erhöht, und die letzte Position kann persistiert werden. Jede dieser Operationen wird serverseitig durch Security Rules geprüft. Damit ergibt sich ein konsistenter End-to-End-Fluss, der die zentralen Backend-Entscheidungen zusammenführt: UID-basierte Dokumentpfade, query-driven Datenstruktur, kostenbewusste Writes und regelbasierte Zugriffskontrolle.
```

## B) BibTeX-Einträge für literatur.bib

```bibtex
@online{flutter_arch_overview,
  title        = {Flutter architectural overview},
  organization = {Flutter Documentation},
  url          = {https://docs.flutter.dev/resources/architectural-overview},
  urldate      = {2026-03-05}
}

@online{flutter_app_arch_guide,
  title        = {Guide to app architecture},
  organization = {Flutter Documentation},
  url          = {https://docs.flutter.dev/app-architecture/guide},
  urldate      = {2026-03-05}
}

@online{flutter_hot_reload,
  title        = {Hot reload},
  organization = {Flutter Documentation},
  url          = {https://docs.flutter.dev/tools/hot-reload},
  urldate      = {2026-03-05}
}

@online{firebase_rules_get_started,
  title        = {Get started with Cloud Firestore Security Rules},
  organization = {Firebase Documentation},
  url          = {https://firebase.google.com/docs/firestore/security/get-started},
  urldate      = {2026-03-05}
}

@online{firebase_rules_conditions,
  title        = {Writing conditions for Cloud Firestore Security Rules},
  organization = {Firebase Documentation},
  url          = {https://firebase.google.com/docs/firestore/security/rules-conditions},
  urldate      = {2026-03-05}
}

@online{firebase_rules_emulator_test,
  title        = {Test your Cloud Firestore Security Rules},
  organization = {Firebase Documentation},
  url          = {https://firebase.google.com/docs/firestore/security/test-rules-emulator},
  urldate      = {2026-03-05}
}

@online{firebase_emulator_setup,
  title        = {Set up the Local Emulator Suite},
  organization = {Firebase Documentation},
  url          = {https://firebase.google.com/docs/rules/emulator-setup},
  urldate      = {2026-03-05}
}

@online{firestore_data_model,
  title        = {Cloud Firestore Data model},
  organization = {Firebase Documentation},
  url          = {https://firebase.google.com/docs/firestore/data-model},
  urldate      = {2026-03-05}
}

@online{firestore_transactions,
  title        = {Transactions and batched writes},
  organization = {Firebase Documentation},
  url          = {https://firebase.google.com/docs/firestore/manage-data/transactions},
  urldate      = {2026-03-05}
}

@online{firestore_quotas,
  title        = {Usage and limits},
  organization = {Firebase Documentation},
  url          = {https://firebase.google.com/docs/firestore/quotas},
  urldate      = {2026-03-05}
}

@online{firestore_billing_example,
  title        = {Billing example},
  organization = {Google Cloud Documentation},
  url          = {https://docs.cloud.google.com/firestore/native/docs/billing-example},
  urldate      = {2026-03-05}
}

@online{firestore_pricing,
  title        = {Firestore pricing},
  organization = {Google Cloud},
  url          = {https://cloud.google.com/firestore/pricing},
  urldate      = {2026-03-05}
}

@online{owasp_masvs,
  title        = {OWASP Mobile Application Security Verification Standard (MASVS)},
  organization = {OWASP},
  url          = {https://mas.owasp.org/MASVS/},
  urldate      = {2026-03-05}
}

@online{gdpr_2016_679,
  title        = {Verordnung (EU) 2016/679 (Datenschutz-Grundverordnung)},
  organization = {EUR-Lex},
  url          = {https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=de},
  urldate      = {2026-03-05}
}
```
