# Teilaufgabe Schüler Kovacs

\textauthor{Christian Kovacs}

## Theorie

### Zielsetzung der Anwendung

Im Rahmen dieser Diplomarbeit wird die Entwicklung einer mobilen, standortbasierten Schnitzeljagd-Applikation beschrieben, die speziell für den Einsatz an der HTL Leoben konzipiert ist. Die Anwendung dient als schulinterne Alternative zu einer bisher eingesetzten externen Lösung und verfolgt das Ziel, vollständige Kontrolle über den Funktionsumfang, die Datenhaltung sowie zukünftige Erweiterungen zu ermöglichen.

Ein zentrales Ziel der Anwendung besteht darin, organisatorische Abläufe der jährlich stattfindenden Schnitzeljagd für die ersten Klassen digital zu unterstützen und zu vereinfachen. Die Applikation soll dabei keine klassische Spiel- oder Rätsellogik enthalten, sondern primär als technisches Hilfsmittel zur Verwaltung von Stationen, Aufgabenfreigaben und Punktevergaben dienen.

Schülerinnen und Schüler nehmen in Teams an der Schnitzeljagd teil und bewegen sich physisch zwischen vordefinierten Stationen. Beim Erreichen einer Station wird in der Anwendung eine entsprechende Aufgabe sichtbar. Die erfolgreiche Absolvierung der Aufgabe wird jedoch nicht automatisch durch die App bewertet, sondern durch eine autorisierte Lehrperson bestätigt. Erst nach dieser Bestätigung wird der Fortschritt aktualisiert und die Punktevergabe durchgeführt.

Lehrpersonen übernehmen somit eine zentrale Kontrollfunktion im Ablauf der Schnitzeljagd. Sie haben die Möglichkeit, Stationen freizugeben, Aufgaben als erledigt zu markieren und den aktuellen Stand aller Teams einzusehen. Durch dieses Konzept wird ein realistischer, kontrollierbarer und pädagogisch sinnvoller Ablauf gewährleistet, ohne unnötige technische Komplexität in der App selbst zu erzeugen.

---

### Theoretische Grundlagen

#### Mobile Applikationen und plattformübergreifende Entwicklung

Die Entwicklung moderner mobiler Anwendungen erfolgt zunehmend plattformübergreifend. Ziel ist es, mit einer einzigen Codebasis Anwendungen für mehrere Betriebssysteme bereitzustellen, um Entwicklungszeit, Wartungsaufwand und Fehlerquellen zu reduzieren.

Für diese Diplomarbeit wurde das Framework **Flutter** gewählt, welches die Erstellung nativer Benutzeroberflächen für Android und iOS ermöglicht. Flutter basiert auf der Programmiersprache **Dart**, die speziell für performante UI-Anwendungen konzipiert wurde. Ein wesentlicher Vorteil von Dart ist die native Unterstützung asynchroner Programmierung, welche für mobile Anwendungen unerlässlich ist.

Asynchrone Abläufe sind insbesondere bei folgenden Komponenten notwendig:

- Kommunikation mit Cloud-Diensten (z. B. Firestore)
- Authentifizierungsvorgänge
- Standortermittlung über GPS
- Aktualisierung von Benutzer- und Fortschrittsdaten

Durch den Einsatz von Flutter kann zudem eine einheitliche Benutzererfahrung auf unterschiedlichen Endgeräten sichergestellt werden, was insbesondere bei schulischen Anwendungen mit heterogener Geräteausstattung von Vorteil ist.

---

#### Standortbasierte Dienste

Standortbasierte Dienste (Location-Based Services) nutzen Positionsdaten mobiler Endgeräte, die in der Regel über GPS, WLAN oder Mobilfunknetze ermittelt werden. Diese Daten ermöglichen es, Anwendungen kontextabhängig zu steuern und bestimmte Funktionen nur an festgelegten Orten bereitzustellen.

In der entwickelten Schnitzeljagd-Applikation dienen standortbasierte Dienste ausschließlich dazu, festzustellen, ob sich ein Team in der Nähe einer definierten Station befindet. Erst wenn diese Bedingung erfüllt ist, wird die zugehörige Aufgabe in der Anwendung sichtbar.

Eine automatische Bewertung oder Lösungserkennung findet bewusst nicht statt. Die Standortermittlung fungiert lediglich als Voraussetzung für die Aufgabenfreigabe und stellt sicher, dass Stationen physisch erreicht werden müssen.

Bei der Nutzung standortbasierter Dienste ergeben sich mehrere technische und organisatorische Herausforderungen:

- eingeschränkte Genauigkeit von GPS-Signalen, insbesondere in Gebäuden oder dicht bebauten Bereichen  
- erhöhter Energieverbrauch bei kontinuierlicher Standortabfrage  
- datenschutzrechtliche Anforderungen, insbesondere im schulischen Umfeld  

Aus diesen Gründen wird die Standortabfrage gezielt und sparsam eingesetzt und nur dann aktiviert, wenn sie für den Ablauf der Schnitzeljagd erforderlich ist.

---

#### NoSQL-Datenbanken und Cloud Firestore

Cloud Firestore ist eine dokumentenbasierte NoSQL-Datenbank, die speziell für den Einsatz in Cloud- und Mobile-Anwendungen entwickelt wurde. Im Gegensatz zu relationalen Datenbanksystemen basiert Firestore nicht auf Tabellen und Beziehungen, sondern auf **Collections** und **Dokumenten**, die hierarchisch organisiert sind.

Ein grundlegendes Entwurfsprinzip von Firestore lautet:

> **Die Struktur der Daten orientiert sich an den späteren Abfragen und nicht an einer formalen Normalisierung.**

Da Firestore keine komplexen Joins unterstützt, müssen Datenmodelle bereits in der Planungsphase so entworfen werden, dass alle relevanten Informationen effizient abgefragt werden können. Dieses Vorgehen wird als **Query-Driven Design** bezeichnet.

Im Rahmen dieses Projekts war es daher notwendig, typische Zugriffs- und Abfragemuster frühzeitig zu definieren, um eine performante und skalierbare Datenhaltung sicherzustellen.

---

### Query- und Access-Patterns

#### Access-Patterns

Access-Patterns definieren, welche Benutzergruppen unter welchen Bedingungen auf bestimmte Daten zugreifen dürfen. Sie bilden die Grundlage für Sicherheitskonzepte und Firestore Security Rules.

Für die Schnitzeljagd-Applikation wurden folgende Access-Patterns festgelegt:

- Schülerinnen und Schüler dürfen ausschließlich auf Daten ihres eigenen Teams zugreifen  
- Schreibzugriffe sind nur nach erfolgreicher Authentifizierung erlaubt  
- Standortdaten dürfen nur temporär und zweckgebunden verarbeitet werden  
- Lehrpersonen verfügen über erweiterte Rechte zur Stations- und Fortschrittsverwaltung  

Diese Zugriffsbeschränkungen verhindern unautorisierte Datenmanipulation und stellen sicher, dass sensible Informationen geschützt bleiben.

---

#### Query-Patterns

Query-Patterns beschreiben die regelmäßig benötigten Datenbankabfragen innerhalb der Anwendung. Für die entwickelte Applikation sind insbesondere folgende Abfragen relevant:

- direkter Zugriff auf ein Benutzer- oder Teamdokument anhand der UID  
- Aktualisierung des Punktestands nach Bestätigung einer Station  
- Abfrage des aktuellen Fortschritts aller Teams durch Lehrpersonen  
- Laden stationsbezogener Informationen abhängig vom Standort  

Da Cloud Firestore keine relationalen Verknüpfungen unterstützt, wurde eine bewusst flache Datenstruktur gewählt. Redundante Daten werden in Kauf genommen, um einfache und performante Abfragen zu ermöglichen, was insbesondere für mobile Endgeräte entscheidend ist.

---

## Praktische Arbeit

### Systemarchitektur und eingesetzte Technologien

#### Flutter

Flutter bildet die Basis der gesamten Applikation. Die Anwendung ist in logisch getrennte Funktionsbereiche untergliedert, darunter Benutzeranmeldung, Kartenansicht, Stationsübersicht und Fortschrittsdarstellung. Jeder dieser Bereiche wird durch eigenständige Widgets repräsentiert.

Diese modulare Struktur erhöht die Wartbarkeit des Codes und erleichtert zukünftige Erweiterungen, etwa die Ergänzung zusätzlicher Stationstypen oder Auswertungsfunktionen.

---

#### Firebase Authentication

Firebase Authentication wird zur sicheren Registrierung und Anmeldung der Benutzer eingesetzt. Nach erfolgreicher Authentifizierung wird jedem Benutzer eine eindeutige **User-ID (UID)** zugewiesen, die innerhalb des gesamten Systems als primärer Identifikator dient.

Diese UID wird konsequent für alle Datenbankoperationen verwendet und ermöglicht eine eindeutige Zuordnung zwischen Benutzerkonto und gespeicherten Daten. Dadurch kann die Zugriffskontrolle vollständig serverseitig durchgesetzt werden.

---

#### Cloud Firestore

Cloud Firestore dient als zentrale Datenbank der Anwendung. Gespeichert werden unter anderem:

- Benutzer- und Teaminformationen  
- Stations- und Aufgabenmetadaten  
- Fortschritts- und Punktedaten  

Durch den Einsatz einer NoSQL-Datenbank kann das Datenmodell flexibel erweitert werden, ohne bestehende Strukturen grundlegend anpassen zu müssen. Dies ist insbesondere im Hinblick auf zukünftige Erweiterungen der Schnitzeljagd von Bedeutung.

---

### Benutzerverwaltung

Nach erfolgreicher Registrierung wird für jeden Benutzer ein eigenes Dokument in der **Users-Collection** angelegt. Als Dokumenten-ID wird die von Firebase Authentication vergebene UID verwendet, wodurch eine konsistente Verknüpfung zwischen Authentifizierung und Datenhaltung entsteht.

Neben dem Benutzernamen werden initiale Werte wie der Punktestand sowie ein serverseitiger Zeitstempel gespeichert. Diese Daten bilden die Grundlage für die Fortschrittsverfolgung innerhalb der Schnitzeljagd.

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
