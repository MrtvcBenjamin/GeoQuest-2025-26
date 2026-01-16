# Teilaufgabe Schüler Kovacs

\textauthor{Christian Kovacs}

---

## Theorie

### Zielsetzung der Anwendung

Im Rahmen dieser Diplomarbeit wird die Entwicklung einer mobilen, standortbasierten Schnitzeljagd-Applikation beschrieben, die speziell für den Einsatz an der HTL Leoben konzipiert wurde. Ziel ist es, eine bisher eingesetzte externe Anwendung vollständig abzulösen und durch eine schulinterne Lösung zu ersetzen, die den organisatorischen, technischen und datenschutzrechtlichen Anforderungen des Schulbetriebs gerecht wird.

Die Anwendung verfolgt das Ziel, den Ablauf der Schnitzeljagd technisch zu unterstützen, ohne den pädagogischen Charakter der Veranstaltung zu verfälschen. Aus diesem Grund wurde bewusst auf eine komplexe spielmechanische Logik verzichtet. Stattdessen basiert das System auf einer kontrollierten Freigabe von Stationen, bei der Lehrpersonen vor Ort den erfolgreichen Abschluss einer Aufgabe bestätigen. Dadurch bleibt die Verantwortung für Bewertung und Interaktion beim Lehrpersonal, während die Anwendung primär organisatorische und dokumentierende Aufgaben übernimmt.

---

### Theoretische Grundlagen

#### Mobile Applikationen und plattformübergreifende Entwicklung

Die Entwicklung moderner mobiler Anwendungen erfolgt zunehmend plattformübergreifend, um redundante Implementierungen für unterschiedliche Betriebssysteme zu vermeiden. Ziel dieser Vorgehensweise ist es, Entwicklungsaufwand, Wartungskosten sowie Fehleranfälligkeit zu reduzieren und gleichzeitig eine konsistente Benutzererfahrung sicherzustellen.

Für dieses Projekt wurde das Framework **Flutter** eingesetzt, welches die Erstellung nativer Anwendungen für Android und iOS auf Basis einer gemeinsamen Codebasis ermöglicht. Flutter basiert auf der Programmiersprache **Dart**, welche insbesondere durch ihre konsequente Unterstützung asynchroner Programmierung für mobile Anwendungen geeignet ist. Da Vorgänge wie Standortabfragen, Netzwerkkommunikation und Datenbankzugriffe inhärent asynchron sind, stellt Dart eine stabile Grundlage für eine reaktive und performante Benutzeroberfläche dar.

---

#### Standortbasierte Dienste

Standortbasierte Dienste stellen eine zentrale funktionale Grundlage der entwickelten Anwendung dar. Sie ermöglichen es, Aktionen in Abhängigkeit von der aktuellen Position eines mobilen Endgeräts auszulösen. Die Positionsbestimmung erfolgt dabei primär über GPS-Daten, ergänzt durch weitere Sensoren und Netzwerkinformationen.

Im Kontext der Schnitzeljagd-Applikation werden Standortdaten verwendet, um festzustellen, ob sich ein Team im räumlichen Umfeld einer Station befindet. Die eigentliche Freigabe der Aufgabe erfolgt jedoch nicht automatisch, sondern ausschließlich durch eine Lehrperson. Diese bewusste Entkopplung von Standorterkennung und Aufgabenbewertung stellt sicher, dass technische Ungenauigkeiten keinen Einfluss auf den Spielverlauf haben.

Bei der Konzeption wurden insbesondere folgende Herausforderungen berücksichtigt:

- eingeschränkte Genauigkeit von GPS-Messungen, insbesondere in urbaner Umgebung  
- erhöhter Energieverbrauch bei kontinuierlichen Standortabfragen  
- restriktive Berechtigungsmodelle moderner Betriebssysteme  
- datenschutzrechtliche Anforderungen im schulischen Umfeld  

---

#### NoSQL-Datenbanken und Cloud Firestore

Für die persistente Speicherung der Anwendungsdaten wurde **Cloud Firestore** als dokumentenbasierte NoSQL-Datenbank eingesetzt. Firestore verzichtet auf relationale Tabellenstrukturen und speichert Daten stattdessen in Collections und Dokumenten. Diese Architektur eignet sich besonders für mobile Anwendungen, bei denen flexible Datenmodelle und geringe Latenzen erforderlich sind.

Ein zentrales Entwurfsprinzip von Firestore lautet:

> **Die Datenstruktur folgt den Abfragen, nicht umgekehrt.**

Da Firestore keine komplexen Joins unterstützt, müssen Datenstrukturen bereits in der Entwurfsphase anhand der späteren Zugriffs- und Abfragemuster geplant werden. Dieses sogenannte *Query-Driven Design* bildet die Grundlage für performante und skalierbare Anwendungen.

---

### Query- und Access-Patterns

#### Access-Patterns

Access-Patterns definieren die zulässigen Zugriffe auf gespeicherte Daten und bilden die Grundlage für die Umsetzung von Sicherheitsmechanismen. Für die Schnitzeljagd-Applikation wurden folgende Zugriffsmuster festgelegt:

- Benutzer dürfen ausschließlich auf ihr eigenes Benutzerprofil zugreifen  
- Schreibzugriffe sind nur nach erfolgreicher Authentifizierung erlaubt  
- Standortdaten dürfen nur von angemeldeten Benutzern erfasst werden  
- Lehrerspezifische Aktionen sind logisch und strukturell vom Benutzerzugriff getrennt  

Diese Access-Patterns beeinflussen unmittelbar:

- die Wahl der Dokumenten-IDs  
- die Struktur der Collections  
- die Definition der Firestore Security Rules  

Durch diese klare Trennung wird verhindert, dass Benutzer unautorisierte Änderungen am Spielverlauf oder an fremden Daten vornehmen können.

---

#### Query-Patterns

Query-Patterns beschreiben die regelmäßig ausgeführten Abfragen innerhalb der Anwendung. Für das vorliegende Projekt wurden unter anderem folgende Abfragen identifiziert:

- direkter Zugriff auf Benutzerprofile über die eindeutige UID  
- Speicherung und Aktualisierung von Standortinformationen  
- Abfrage des aktuellen Spielfortschritts eines Teams  
- Ermittlung der einer Station zugeordneten Aufgaben  

Um diese Abfragen effizient ausführen zu können, wurde eine flache und redundanzarme Datenstruktur gewählt. Diese Entscheidung reduziert die Anzahl notwendiger Lesezugriffe und trägt maßgeblich zur Performance der Anwendung bei.

---

## Praktische Arbeit

### Systemarchitektur und eingesetzte Technologien

#### Flutter

Flutter bildet die technische Grundlage der Benutzeroberfläche. Die Anwendung ist in klar abgegrenzte Widgets unterteilt, die jeweils einen spezifischen Funktionsbereich abbilden. Dazu zählen unter anderem die Benutzeranmeldung, die Kartenansicht, die Anzeige des Fortschritts sowie administrative Funktionen für Lehrpersonen.

Diese modulare Struktur ermöglicht eine saubere Trennung von Zuständigkeiten und erleichtert sowohl die Wartung als auch zukünftige Erweiterungen der Anwendung.

---

#### Firebase Authentication

Die Benutzerverwaltung erfolgt über **Firebase Authentication**. Jeder Benutzer erhält nach erfolgreicher Registrierung eine eindeutige User-ID (UID), die systemweit als primärer Identifikator verwendet wird. Diese UID dient als verbindendes Element zwischen Authentifizierungsdienst und Datenbank und stellt sicher, dass sämtliche gespeicherten Daten eindeutig einem Benutzer zugeordnet sind.

---

#### Cloud Firestore

Cloud Firestore dient als zentrale Datenhaltung der Anwendung. Gespeichert werden unter anderem:

- Benutzerprofile  
- standortbezogene Informationen  
- Aufgaben- und Fortschrittsdaten  

Die gewählte Datenbanklösung ermöglicht eine flexible Anpassung des Datenmodells und unterstützt die langfristige Wartbarkeit der Anwendung.

---

### Benutzerverwaltung

Nach erfolgreicher Registrierung wird automatisch ein Benutzerprofil in der **Users-Collection** angelegt. Die UID aus Firebase Authentication wird dabei als Dokumenten-ID verwendet, wodurch eine direkte und eindeutige Zuordnung gewährleistet ist.

Neben dem Benutzernamen werden initiale Werte wie der Punktestand sowie ein serverseitiger Zeitstempel gespeichert, um spätere Auswertungen und Erweiterungen zu ermöglichen.

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
