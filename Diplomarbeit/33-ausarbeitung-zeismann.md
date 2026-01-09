# Teilaufgabe Schüler Zeismann
\textauthor{Tobias Zeismann}

## Theorie

Dieses Kapitel wird oft auch als _Literaturrecherche_ bezeichnet. Da gehört alles rein was der __normale__ Leser braucht um den praktischen Ansatz zu verstehen. Das bedeutet Sie brauchen einen roten Faden !

Das sind z.B: allgemeine Definitionen, Beschreibung von fachspezifischen Vorgehensweisen, Frameworks, Theorie zu verwendeten Algorithmen, besondere Umstände, ...

## Praktische Arbeit

1. Einordnung des Frontends im Gesamtprojekt

Im Rahmen der Diplomarbeit wird eine mobile Schnitzeljagd-App mit dem Namen GeoQuest entwickelt. Ziel der Anwendung ist es, Nutzerinnen und Nutzer spielerisch durch die Stadt Leoben zu führen. Dabei werden reale Orte besucht, an denen Aufgaben gelöst und Informationen abgerufen werden.
Das Projekt wird im Team umgesetzt und besteht aus mehreren technischen Komponenten. Meine Aufgabe innerhalb des Projekts ist die Konzeption und Umsetzung des Frontends der Anwendung.

Das Frontend bildet die Schnittstelle zwischen Benutzer und System. Es ist verantwortlich für die Darstellung der Inhalte, die Benutzerführung sowie für die Interaktion mit Backend-Diensten wie Authentifizierung, Standortabfragen und Datenbankzugriffen.

2. Wahl der Technologien für das Frontend

Für die Umsetzung des Frontends wurde das Framework Flutter gewählt. Flutter ermöglicht die Entwicklung plattformübergreifender mobiler Anwendungen auf Basis einer einzigen Codebasis. Dadurch kann die App sowohl auf Android- als auch auf iOS-Geräten betrieben werden, ohne den Code doppelt schreiben zu müssen.

Die Programmiersprache Dart, die von Flutter verwendet wird, eignet sich besonders gut für reaktive Benutzeroberflächen. Änderungen am Zustand der Anwendung führen automatisch zu einer Aktualisierung der Benutzeroberfläche, was für interaktive Apps wie GeoQuest essenziell ist.

Als Entwicklungsumgebung wird Android Studio eingesetzt, da dieses eine sehr gute Integration für Flutter, Emulatoren und Debugging bietet.

3. Architektur und Struktur des Frontends

Eine klare Projektstruktur ist besonders wichtig, um den Code übersichtlich, wartbar und teamfähig zu halten. Daher wurde das Frontend in mehrere logisch getrennte Bereiche unterteilt.

Der zentrale Einstiegspunkt der App befindet sich in der Datei main.dart. Von dort aus wird die gesamte Anwendung gestartet und die Navigation zwischen den einzelnen Screens gesteuert.

Die Benutzeroberfläche ist in sogenannte Screens gegliedert, wobei jeder Screen eine eigenständige Ansicht der App darstellt, z. B. Ladebildschirm, Onboarding, Login oder Kartenansicht. Wiederverwendbare UI-Elemente werden in eigene Widgets ausgelagert, um Redundanzen zu vermeiden und ein einheitliches Design zu gewährleisten.

Diese modulare Struktur erleichtert sowohl die Zusammenarbeit im Team als auch spätere Erweiterungen der App.

4. Benutzerführung und App-Ablauf

Ein zentrales Ziel bei der Entwicklung des Frontends ist eine klare und verständliche Benutzerführung. Die App folgt daher einer fest definierten Reihenfolge beim Start:

Lade- bzw. Splash-Screen

Onboarding-Screens

Berechtigungsabfragen

Anmelde-Screen

Hauptfunktionalitäten der App

Durch diese Abfolge wird sichergestellt, dass neue Benutzer zuerst verstehen, wie die App funktioniert, bevor sie sich anmelden oder spielen können.

5. Lade- und Startbildschirm

Beim Start der Anwendung wird ein Ladebildschirm angezeigt. Dieser erfüllt mehrere Aufgaben:

visuelle Rückmeldung beim App-Start

professioneller erster Eindruck

Vorbereitung von Initialisierungen im Hintergrund

Der Ladeindikator wurde bewusst angepasst und nicht als Standard-Flutter-Element belassen. Statt eines einfachen Kreises wird ein gepunkteter Ladeindikator verwendet, der farblich neutral (schwarz) gestaltet ist. Zusätzlich wird das Logo der App eingeblendet, um den Wiedererkennungswert zu erhöhen.

6. Onboarding-Konzept

Die Onboarding-Screens dienen dazu, neue Benutzer schrittweise an die App heranzuführen. Sie erklären:

den Zweck der App

den Ablauf der Schnitzeljagd

die Bedeutung von Standort und Benachrichtigungen

Gestalterisch wurden die Inhalte bewusst zentriert und mit größerer Schrift umgesetzt, um einen leeren oder überladenen Eindruck zu vermeiden.
Die Onboarding-Phase findet vor dem Login statt, damit Benutzer die App kennenlernen können, ohne sich sofort registrieren zu müssen.

7. Authentifizierung und Benutzerkonten

Nach dem Onboarding erfolgt die Anmeldung. Für die Authentifizierung wird Firebase Authentication verwendet. Firebase bietet eine sichere und skalierbare Lösung zur Benutzerverwaltung und ist besonders gut in mobile Anwendungen integrierbar.

Im Frontend wurden folgende Anmeldearten vorgesehen:

Anmeldung mit Google-Konto

Anmeldung mit E-Mail und Passwort

Diese Varianten decken einen Großteil der Zielgruppe ab und ermöglichen einen einfachen Einstieg in die App. Weitere Anmeldeoptionen können später problemlos ergänzt werden.

Ohne Anmeldung ist der Zugriff auf spielrelevante Funktionen nicht möglich, da Fortschritte, Standorte und Spielstände benutzerbezogen gespeichert werden müssen.

8. Berechtigungsmanagement (Standort und Benachrichtigungen)

Da GeoQuest eine ortsbasierte Anwendung ist, spielt der Zugriff auf Standortdaten eine zentrale Rolle. Aus diesem Grund wurde ein verpflichtender Berechtigungsprozess implementiert.

Standortberechtigung

Die App überprüft zunächst, ob Standortdienste am Gerät aktiviert sind. Falls nicht, wird der Benutzer aufgefordert, diese zu aktivieren. Anschließend wird die Standortberechtigung abgefragt. Ohne erteilte Standortfreigabe kann die App nicht verwendet werden.

Benachrichtigungen

Benachrichtigungen werden benötigt, um Benutzer über Spielereignisse oder Hinweise zu informieren. Insbesondere auf neueren Android-Versionen ist dafür eine explizite Freigabe notwendig. Auch diese Berechtigung wird aktiv abgefragt und ist Teil des App-Flows.

Das Berechtigungsmanagement stellt sicher, dass alle für das Spiel notwendigen Funktionen technisch verfügbar sind.

9. Kartenintegration und Standortdarstellung

Zur Darstellung der Spielstationen wird OpenStreetMap verwendet. Die Kartenintegration erfolgt über das Flutter-Paket flutter_map. Dieses erlaubt eine flexible Darstellung von Kartenkacheln sowie das Platzieren von Markern.

Im Frontend werden:

eine interaktive Karte angezeigt

feste Marker (z. B. Stationen) dargestellt

der aktuelle Standort des Benutzers visualisiert

Sobald der Standort ermittelt wurde, wird die Karte entsprechend aktualisiert. Dies schafft eine direkte Verbindung zwischen realer Umgebung und digitalem Spiel.

10. Speicherung von Standortdaten

Um spielrelevante Daten langfristig nutzen zu können, werden Standortinformationen in einer Cloud-Datenbank gespeichert. Dafür wird Firebase Firestore verwendet.

Im Frontend wird der Standort nur dann gespeichert, wenn:

ein Benutzer angemeldet ist

gültige Standortdaten vorliegen

Die Koordinaten werden in einem geeigneten Datenformat abgelegt, sodass sie später für Spielmechaniken, Auswertungen oder Statistiken genutzt werden können.

11. Versionsverwaltung und Teamarbeit

Die Zusammenarbeit im Team erfolgt über GitHub. Änderungen am Frontend werden regelmäßig versioniert und in das gemeinsame Repository übertragen. Dabei kommen grundlegende Konzepte der Versionsverwaltung zum Einsatz:

Commits zur Dokumentation von Änderungen

Push und Pull zur Synchronisation

Merges zum Zusammenführen paralleler Arbeiten

Konflikte, die durch gleichzeitige Änderungen entstehen, werden bewusst gelöst, um die Stabilität des Projekts zu gewährleisten.

 Mit etwas Fließtext. Mit etwas Fließtext. Mit etwas Fließtext. Mit etwas Fließtext. Mit etwas Fließtext. Mit etwas Fließtext. Mit etwas Fließtext. Mit etwas Fließtext.


