# Teilaufgabe Schüler Kovacs

\textauthor{Christian Kovacs}

---

## Theorie

### Zielsetzung der Anwendung

Im Rahmen dieser Diplomarbeit wird die Entwicklung einer mobilen, standortbasierten Schnitzeljagd-Applikation beschrieben, die speziell auf die Anforderungen der HTL Leoben zugeschnitten ist. Ziel ist es, eine schulinterne Lösung zu schaffen, welche die bisher eingesetzte externe Anwendung ersetzt und eine vollständige Kontrolle über Funktionalität, Datenhaltung und Weiterentwicklung ermöglicht.

Die Anwendung soll eine intuitive Teilnahme an der Schnitzeljagd ermöglichen, indem Benutzer authentifiziert werden, Aufgaben standortabhängig freigeschaltet werden und der Fortschritt transparent dargestellt wird. Gleichzeitig sollen Lehrpersonen die Möglichkeit erhalten, Stationen kontrolliert freizugeben und den Spielablauf zu überwachen.

---

### Theoretische Grundlagen

#### Mobile Applikationen und plattformübergreifende Entwicklung

Moderne mobile Anwendungen werden zunehmend plattformübergreifend entwickelt, um Entwicklungsaufwand und Wartungskosten zu reduzieren. Frameworks wie **Flutter** ermöglichen es, mit einer einzigen Codebasis Anwendungen für Android und iOS zu erstellen. Die Programmiersprache **Dart** bietet dabei native Unterstützung für asynchrone Programmierung, welche insbesondere für Netzwerkzugriffe, Standortermittlung und Cloud-Dienste erforderlich ist.

---

#### Standortbasierte Dienste

Standortbasierte Anwendungen nutzen GPS-Daten mobiler Endgeräte, um kontextabhängige Funktionen bereitzustellen. Typische Anwendungsfälle sind Kartenansichten, Navigation oder – wie in diesem Projekt – das automatische Auslösen von Aufgaben beim Betreten eines definierten geografischen Bereichs.

Wesentliche Herausforderungen standortbasierter Systeme sind:

- Ungenauigkeiten bei GPS-Messungen  
- Energieverbrauch durch häufige Standortupdates  
- Datenschutz und Zugriffsbeschränkungen  

---

#### NoSQL-Datenbanken und Firestore

Cloud Firestore ist eine dokumentenbasierte NoSQL-Datenbank, welche sich besonders für mobile Anwendungen eignet. Im Gegensatz zu relationalen Datenbanken basiert Firestore auf Collections und Dokumenten und verzichtet auf komplexe Joins.

Ein zentrales Prinzip bei Firestore ist:

> **Daten werden nach den späteren Abfragen strukturiert (Query-Driven Design).**

Daraus ergeben sich die Konzepte der **Query Patterns** und **Access Patterns**, welche bereits in der Entwurfsphase definiert werden müssen.

---

### Query- und Access-Patterns

#### Access-Patterns

Access-Patterns beschreiben, **wer welche Daten lesen oder schreiben darf**.  
Für die entwickelte Schnitzeljagd-Applikation wurden folgende Zugriffsmuster definiert:

- Benutzer dürfen ausschließlich auf **ihr eigenes Benutzerprofil** zugreifen  
- Schreibzugriffe sind nur nach **erfolgreicher Authentifizierung** erlaubt  
- Standortdaten dürfen nur von angemeldeten Benutzern gespeichert werden  
- Lehrerspezifische Aktionen (z. B. Stationsfreigabe) erfolgen kontrolliert  

Diese Access-Patterns bilden die Grundlage für:

- die Wahl der Dokumenten-IDs  
- die Trennung der Collections  
- die Definition der Firestore Security Rules  

---

#### Query-Patterns

Query-Patterns beschreiben, **welche Abfragen regelmäßig durchgeführt werden**:

- Direktzugriff auf ein Benutzerprofil über die UID  
- Schreiben neuer Standortdatensätze  
- Lesen des aktuellen Fortschritts eines Spielers  
- Anzeige aller Aufgaben in der Nähe eines Standorts  

Da Firestore keine Joins unterstützt, wurde auf eine flache, klar strukturierte Datenhaltung gesetzt, um performante und einfache Abfragen zu ermöglichen.

---

## Praktische Arbeit

### Systemarchitektur und eingesetzte Technologien

#### Flutter

Flutter wurde als Entwicklungsframework gewählt, da es eine plattformübergreifende Entwicklung ermöglicht und eine moderne UI-Gestaltung unterstützt. Die modulare Widget-Struktur erleichtert die Umsetzung der unterschiedlichen Anwendungsfälle (Login, Karte, Aufgaben, Fortschritt).

---

#### Firebase Authentication

Firebase Authentication übernimmt die Registrierung und Anmeldung der Benutzer. Jeder Benutzer erhält eine eindeutige UID, welche als Schlüssel für alle weiteren Datenbankoperationen verwendet wird. Dadurch ist eine eindeutige Zuordnung zwischen Authentifizierung und gespeicherten Daten gewährleistet.

---

#### Cloud Firestore

Cloud Firestore dient als zentrale Datenbank zur Speicherung von:

- Benutzerprofilen  
- Standortdaten  
- Aufgaben- und Fortschrittsinformationen  

Die Verwendung einer NoSQL-Datenbank erlaubt eine flexible Erweiterung des Datenmodells, etwa für zusätzliche Spielmodi oder Statistiken.

---

### Benutzerverwaltung

Nach erfolgreicher Registrierung wird für jeden Benutzer ein eigenes Dokument in der _Users_-Collection angelegt. Die UID aus Firebase Authentication wird dabei als Dokumenten-ID verwendet.

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
