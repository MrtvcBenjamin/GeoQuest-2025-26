# Projekthandbuch
\textauthor{Muratovic}

## Entwicklungsplan

### Projektauftrag

Die HTL Leoben organisiert am Ende jedes Schuljahres eine Schnitzeljagd für die ersten Klassen. Bislang wurde dafür eine externe App eingesetzt, die jedoch nur eingeschränkte Anpassungsmöglichkeiten bietet und eine starke Abhängigkeit von Drittanbietern erzeugt.
Dies führt regelmäßig zu organisatorischen Problemen, eingeschränkter Flexibilität sowie einem fehlenden Einfluss auf technische Weiterentwicklungen.

Ziel des Projekts ist daher die Entwicklung einer eigenen, vollständig kontrollierbaren Anwendung, die speziell auf die Anforderungen der Schule zugeschnitten ist. Die App soll langfristig einsetzbar, flexibel erweiterbar und intuitiv bedienbar sein. Dadurch werden externe Abhängigkeiten reduziert, der Funktionsumfang kann jederzeit erweitert werden, und die Schule erhält eine nachhaltige Lösung für zukünftige Jahrgänge.


#### Projektziele

- Entwicklung einer funktionsfähigen, stabilen und benutzerfreundlichen Anwendung zur Durchführung der jährlichen Schnitzeljagd.
- Umsetzung einer modularen Architektur, die zukünftige Erweiterungen (z. B. neue Fragetypen, neue Spielmodi, Statistiken) ermöglicht.
- Bereitstellung eines Administrationsbereiches für Lehrende zur Erstellung, Bearbeitung und Verwaltung von Stationen sowie Aufgaben.
- Integration einer Kartenansicht, um Stationen geographisch darzustellen.
- Sicherstellung eines zuverlässigen Betriebs ohne Internetverbindung, sofern technisch möglich (z. B. Offline-Caching).
- Entwicklung einer Lösung, die langfristig unabhängig von externen Softwareanbietern betrieben werden kann.
- Bereitstellung einer klar dokumentierten Codebasis und Anwendung, damit zukünftiges Weiterentwickeln der App im Rahmen des Unterrichts möglich ist.

#### Nicht-Ziele bzw. nicht Inhalte

- Die App ist nicht als vollständig kommerzielles Produkt vorgesehen.
- Es wird keine komplexe Analyseplattform entwickelt, die tiefgehende Statistiken über mehrere Jahre hinweg sammelt.
- Eine Mehrspieler- oder Echtzeit-Online-Interaktion zwischen Teams ist nicht Teil des Grundumfangs.
- Die App ist nicht für eine Nutzung außerhalb der HTL Leoben vorgesehen.
- Eine vollständige Web-Version als Alternative zur Mobil-App ist nicht Projektbestandteil.

#### Projektnutzen

Der Hauptnutzen liegt darin, die jährliche Schnitzeljagd auf eine moderne, zuverlässige und schulinterne Lösung umzustellen.
Dies bietet folgende Vorteile:
- Unabhängigkeit von Drittanbietern – keine Lizenzkosten, keine externen Einschränkungen.
- Langfristige Wiederverwendbarkeit – die App kann über Jahre hinweg genutzt und erweitert werden.
- Flexibilität – Aufgaben, Stationen und Spielmodi können exakt an schulische Bedürfnisse angepasst werden.
- Technisches Lernprojekt – die Schüler sammeln Erfahrungen in Projektmanagement, Softwareentwicklung, App-Design und Betreuung eines realen Kunden.
- Verbesserte Durchführung der Schnitzeljagd ohne technische Hürden oder Ausfälle durch fremde Anbieter.

#### Projektauftraggeber/in

Projektauftraggeber ist Herr Klaus Kepplinger, der an der HTL Leoben für die Organisation der Schnitzeljagd der 1. Jahrgänge am Ende des Schuljahres verantwortlich ist.

#### Projekttermine

| Termin     | Inhalt                          |
|-----------:|:--------------------------------|
| 2025-10-09 | Einreichung DA in Portal                     |
| 2025-11-12 | Ertse DA Zwischenpräsentation                    |
| 2025-12-01 | 1. Zwischenstand an Betreuer präsentieren             |
| 2025-12-20 | 2. Zwischenstand an Betreuer präsentieren          |
| 2026-01-09 | Elek. Erstversion Abgabe an Betreuer        |
| 2026-02-26 | Zweite DA Zwischenpräsentation      |
| 2026-03-06 | DA Abgabe       |
| 2026-04-07 | Biblv. DA Abgabe      |
| 2026-04-13 | DA Präsentation     |

: Projektterminübersicht


#### Projektkosten

Aufgrund der rein digitalen Natur unserer Diplomarbeit fielen keine nennenswerte Kosten im Laufe dieser Diplomarbeit an.

#### Projektrisiken

| Risiko         | EW  | Auswirkungen     | Maßnahmen     |
|---|---|---|---|
| Ungenaue Schätzungen (Kosten, Zeit) | 30% | Zeit- oder Budgetplan passt nicht → Deadlines könnten verfehlt werden | Schätzungen im Team absprechen, eher großzügig planen |
| Unzureichend definierter Projektumfang / Anforderungen | 25% | Wir implementieren falsche oder zu viele Funktionen → Nacharbeiten | Anforderungen klar dokumentieren, Fixpunkt mit Betreuern |
| Scope Creep (schleichende Erweiterung des Umfangs) | 20% | Projekt wächst über das geplante Maß → Überforderung und Zeitprobleme | Änderungswünsche kontrollieren, nur bei Zustimmung einbauen |
| Lernkurven / fehlende Erfahrung mit Technologien | 35% | Verzögerungen durch Einarbeitung, mehr Fehler | Zeit für Learning einplanen, Tutorials & Dokumentation nutzen |
| Ressourcenmangel (Zeit, Team, Hardware) | 20% | Aufgaben können nicht rechtzeitig erledigt werden | Ressourcen früh planen, Zeitpuffer einbauen |
| Fehlende Kommunikation im Team / mit Stakeholdern | 25% | Missverständnisse, doppelte Arbeit, falsche Features | Regelmäßige Meetings, Aufgaben klar verteilen |
| Probleme bei technischer Integration / Architektur | 15% | App instabil oder inkompatibel, zusätzliche Arbeit nötig | Architektur früh prüfen, Prototypen & Tests machen |
| Unzureichende Testphase | 25% | Fehler werden spät entdeckt → schlechte Nutzererfahrung | Testphase fix einplanen, Beta-Test durchführen |
| Geringe Nutzerakzeptanz (UI/UX zu komplex) | 20% | Anwendung wird nicht verstanden oder falsch genutzt | Nutzerfeedback früh einholen, einfache Bedienung sicherstellen |
| Verzögerungen beim Hard-/Software-Setup | 10% | Projektstart verzögert → Zeitdruck | Entwicklungsumgebung früh einrichten, Backups & Alternativen planen |


: Projektrisiken

### Projektorganisation

#### Projektbeteiligte

| Vorname     | Nachname     | Organisation | Kontaktinfos      |
|:------------|:-------------|:-------------|:------------------|
| Benjamin    | Muratovic  | HTL Leoben   | 211witb17@o365.htl-leoben.at  |
| Klaus       | Kepplinger      | HTL Leoben     | klaus.kepplinger@htl-leoben.at    |
| Andreas       | Weichbold      | HTL Leoben     | andreas.weichbold@htl-leoben.at    |

: Projektbeteiligte

#### Projektrollen

| Projektrolle           | Rollenbeschreibung     | Name              |
|------------------------|------------------------|-------------------|
| Projektleiter | Verantwortlicher für Einhaltung des Projektrahmens | Benjamin Muratovic |
| Auftraggeber | Auftraggeber der internen Diplomarbeit | K. Kepplinger |
| Betreuer | Schulischer Betreuer | A. Weichbold |

: Projektrollen

### Vorgehen bei Änderungen

- Änderungen an Anforderungen oder Meilensteinen werden zuerst im Projektteam besprochen.
- Der Projektleiter dokumentiert die Änderung im Änderungsprotokoll.
- Die angepassten Inhalte werden im Projekthandbuch und Backlog aktualisiert.
- Jede Änderung wird in den nächsten Meetings kurz vorgestellt.

## Meilensteine

Der Begriff taucht im Projektmanagement sehr häufig auf. Meilensteine sind wichtige Punkte im Projektverlauf. Oft werden sie auch als Prüfpunkte bezeichnet.

Generell kann ein Meilenstein ein Ereignis sein, an dem

* etwas abgeschlossen ist,
* etwas begonnen wird oder
* über die weitere Vorgehensweise entschieden wird

Meilensteine werden meist am Ende von Projektphasen definiert. Auch innerhalb von Phasen kann es zusätzliche Meilensteine geben.

Meilensteine verlaufen nie über eine Zeitdauer. Nie. Sie sind lediglich Entscheidungspunkte

Hier ein Beispiel wie die Meilensteine im Fall einer aussehen können

### 2025-09-20: Projektvorbereitung abgeschlossen - Projektstart

- Projektauftrag, Ziele und Nicht-Ziele sind definiert und dokumentiert
- Projektorganisation (Rollen, Beteiligte, Betreuer) ist festgelegt
- Grober Projektplan inklusive Meilensteine liegt vor

### 2025-09-30: Anforderungsanalyse & Konzept

- Fachliche und technische Anforderungen sind vollständig erhoben und dokumentiert
- Grobes System- und Anwendungskonzept (Architektur, Plattform, Technologien) ist erstellt
- Zentrale Anwendungsfälle (Use Cases) sind definiert

### 2025-10-20: UI-Prototyp & Grundstruktur

- UI-Prototyp ist erstellt
- Grundlegende Projektstruktur (z. B. App-Gerüst, Navigation) ist implementiert
- Erste Screens (Start, Login, Übersicht) sind sichtbar 

### 2025-11-11: Zwischenpräsentation

- Aktueller Projektstand wird präsentiert und erklärt
- UI-Prototyp und erste Funktionen werden demonstriert
- Feedback von Betreuern und Auftraggeber wird aufgenommen
      
### 2025-11-30: Implementierung GPS- & Aufgabenlogik

- GPS-Funktion zur Standortbestimmung ist implementiert
- Aufgaben/Stationen können ortsabhängig freigeschaltet werden
- Grundlegende Spiellogik (Reihenfolge, Punkte, Status) funktioniert

### 2025-12-20: Anti-Schummel-System & Erweiterungen

- Maßnahmen gegen Standort-Manipulation sind implementiert (z. B. Plausibilitätsprüfungen)
- Erweiterungen der Aufgabenlogik (z. B. Zeitlimits, Versuche) sind umgesetzt
- Fehler- und Sonderfälle werden behandelt

### 2026-01-09: Erstversion der App

- Alle geplanten Kernfunktionen sind implementiert
- Die App ist durchgängig nutzbar (von Start bis Ende der Schnitzeljagd)
- Erste interne Tests wurden durchgeführt

### 2026-02-15: Systemtests & Feinschliff

- Umfassende Tests (Funktion, Usability, Stabilität) sind durchgeführt
- Gefundene Fehler wurden behoben
- Benutzerführung und Design wurden optimiert

### 2026-03-06: Endabgabe

- Finale Version der App ist fertiggestellt und stabil
- Projektdokumentation (Diplomarbeit) ist vollständig und korrekt
- Abgabekriterien der HTL Leoben sind erfüllt


## Anwendungsfälle

Damit man auch versteht wer mit welchem Anwendungsfall agiert bietet es sich an hier eine Übersichtsgrafik zu erstellen:

![Übersicht Anwendungsfälle](img/anwendungsfalldiagramm.png){width=60%}

\newpage

### Anwendungsfallname - Just in case, gonna keep it here
Anwendungsfälle haben einen eindeutigen Namen aus dem man auf den Inhalt des Anwendungsfalls schließen kann. Wenn Sie agil arbeiten dann stellt ein Anwendungsfall eine UserStory dar welche im Backlog liegt und im Laufe des Projekts (in einem Sprint) abgearbeitet wird.

#### Kurzbeschreibung
Hier erfolgt eine kurze Beschreibung, was im Anwendungsfall passiert. Kurz bedeutet, dass es zwei oder drei Zeilen sind, selten mehr.
      
#### Trigger
Der fachliche Grund bzw. die Gründe dafür, dass dieser Anwendungsfall ausgeführt 

#### Vorbedingung
Alle Bedingungen, die erfüllt sein müssen, damit dieser Anwendungsfall ausgeführt werden kann. Gibt es keine Vorbedingungen, so steht hier "keine".
      
#### Nachbedingung
Der Zustand, der nach einem erfolgreichen Durchlauf des Anwendungsfalls erwartet wird.

#### Akteure
Akteure sind beteiligte Personen oder Systeme außerhalb (!) des beschriebenen Systems. Z. B. Anwender, angemeldeter Anwender, Kunde, System, Abrechnungsprozess.

#### Standardablauf
Hier wird das typische Szenario dargestellt, das leicht zu verstehen oder der am häufigsten vorkommende Fall ist. An seinem Ende steht die Zielerreichung des Primärakteurs. Die Ablaufschritte werden nummeriert und meist in strukturierter Sprache beschrieben. Ablaufpläne können jedoch ebenfalls benutzt werden, wenn es angebracht erscheint. Mittels der UML können diese Ablaufschritte in Aktivitätsdiagrammen oder Anwendungsfall-orientierten Sequenzdiagrammen dargestellt werden.

#### Fehlersituationen
Dies sind Szenarien, die sich außerhalb des Standardablaufs auch bei der (versuchten) Zielerreichung des Anwendungsfalls ereignen können. Sie werden meistens als konditionale Verzweigungen der normalen Ablaufschritte dargestellt. An ihrem Ende steht ein Misserfolg, die Zielerreichung des Primärakteurs oder eine Rückkehr zum Standardablauf.

#### Systemzustand im Fehlerfall
Der Zustand, der nach einem erfolglosen Durchlauf des Anwendungsfalls erwartet wird.


\newpage

### Registrierung & Login

#### Kurzbeschreibung
Als **Spieler** möchte ich mich per E-Mail oder Gastzugang anmelden können um an einer Schnitzeljagd teilnehmen zu können. -> Nutzer sollen sich registrieren oder als Gast schnell beitreten können, um sofort loszulegen.

#### Akzeptanzkriterien
- Given: Ein Nutzer öffnet die App
- When: Er klickt auf „Login“ oder „Als Gast fortfahren“
- Then: Wird er eingeloggt und zur Startseite weitergeleitet

+ Given: Der Nutzer gibt eine ungültige E-Mail oder ein falsches Passwort ein
+ When: Er klickt auf „Anmelden“
+ Then: Erhält er eine Fehlermeldung „Ungültige Anmeldedaten“

- Given: Der Nutzer wählt den Gastmodus
- When: Er beendet und erneut öffnet die App
- Then: Bleibt seine Sitzung aktiv, solange sie nicht manuell beendet wird

+ Given: Ein neuer Nutzer registriert sich
+ When: Er bestätigt die Registrierung
+ Then: Wird ein neuer Firestore-Eintrag unter users erstellt

#### Conversation Points
- Gastmodus temporär oder persistent speichern?
- E-Mail-Verifizierung notwendig?
- Passwort-Richtlinien?

\newpage

### Karte & Standort

#### Kurzbeschreibung
Als **Spieler** möchte ich auf einer Karte meine Position und nahegelegene Aufgaben sehen um zu wissen, wohin ich als Nächstes gehen soll. -> Die Kartenansicht zeigt die aktuelle Position des Spielers und Aufgaben in der Umgebung.

#### Akzeptanzkriterien
+ Given: Der Nutzer hat Standortfreigabe erteilt
+ When: Er öffnet die Karte
+ Then: Wird seine Position korrekt mit einem Marker angezeigt

- Given: Aufgaben befinden sich in der Nähe
- When: Die Karte geladen wird
- Then: Werden Marker für Aufgaben innerhalb eines 500 m Radius angezeigt

+ Given: Der Nutzer lehnt die Standortfreigabe ab
+ When: Er öffnet die Karte
+ Then: Wird eine Hinweismeldung angezeigt („Standortzugriff erforderlich“)

- Given: Der Nutzer bewegt sich
- When: Seine Position ändert sich
- Then: Aktualisiert sich der Positionsmarker in Echtzeit

#### Conversation Points
- Echtzeit-Updates über location-Package oder periodische Abfrage?
- Filter für Aufgabenradius?
- Map-Styling (Standard, Satellit, Dark Mode)?

\newpage

### Standortbasierte Aufgaben

#### Kurzbeschreibung
Als **Spieler** möchte ich automatisch Aufgaben erhalten, sobald ich mich einem Checkpoint nähere um ohne QR-Codes interaktiv und visuell an der Schnitzeljagd teilnehmen zu können. -> Ein Checkpoint löst eine Aufgabe aus, sobald der Spieler den vordefinierten Radius betritt.

#### Akzeptanzkriterien
- Given: Der Spieler befindet sich in einer aktiven Schnitzeljagd
- When: Er betritt den definierten Umkreis eines Checkpoints
- Then: Wird die zugehörige Aufgabe automatisch auf dem Bildschirm angezeigt

+ Given: Ein Spieler hat eine Aufgabe bereits erledigt
+ When: Er betritt erneut den Checkpoint-Radius
+ Then: Erscheint keine neue Aufgabe – stattdessen optional ein Hinweis „Checkpoint bereits abgeschlossen“

- Given: Eine Aufgabe wird ausgelöst
- When: Sie öffnet sich
- Then: Wird sie in einem rein visuellen Format angezeigt (z. B.: Bild, Animation, Icons, Slider, Buttons etc.)

+ Given: Der Spieler hat der App keine Standortberechtigung erteilt
+ When: Er startet die Runde
+ Then: Er erhält einen klaren Hinweis, dass der Standort benötigt wird, inkl. Button zum Erlauben

- Given: Der Standort ist ungenau (GPS-Jitter)
- When: Der Spieler bewegt sich in der Nähe des Radius
- Then: Wird die Aufgabe nur einmal ausgelöst und der Radius wird gedrosselt (Debounce-Schutz)

#### Conversation Points
- Optimale Radiusgröße (10–25 m je nach Genauigkeit?)
- GPS-Update-Intervall (z. B. alle 1–2 Sekunden)
- Schutz vor mehrfacher Auslösung durch "cooldown" oder "completed flag"
- Visuelle UI-Komponenten für Aufgaben
- Speicherung: „aufgabe_abgeschlossen = true“ in Firestore oder Local Cache
- Latenz durch Standortabfragen (Mobile OS Optimierung)

\newpage

### Aufgaben & Fortschritt

#### Kurzbeschreibung
Als **Spieler** möchte ich meinen Fortschritt und meine erreichten Punkte sehen um meine Leistung im Spiel nachvollziehen zu können. -> Spieler sollen sehen, welche Aufgaben erledigt und welche noch offen sind, inklusive Punkteübersicht.

#### Akzeptanzkriterien
+ Given: Spieler hat mindestens eine Aufgabe abgeschlossen
+ When: Er öffnet die Fortschrittsseite
+ Then: Sieht er erledigte und offene Aufgaben getrennt aufgelistet

- Given: Aufgaben besitzen unterschiedliche Punktwerte
- When: Spieler erledigt mehrere Aufgaben
- Then: Wird die Gesamtsumme korrekt berechnet

+ Given: Der Spieler aktualisiert die Seite
+ When: Neue Aufgaben als erledigt markiert wurden
+ Then: Aktualisiert sich der Fortschrittsbalken dynamisch

- Given: Der Spieler hat alle Aufgaben abgeschlossen
- When: Er öffnet die Fortschrittsseite
- Then: Sieht er „Schnitzeljagd abgeschlossen“ und die Gesamtsumme

#### Conversation Points
- Punktesystem fix oder pro Aufgabe definierbar?
- Darstellung als Liste, Karte oder Fortschrittsbalken?
- Speicherung des Fortschritts in Echtzeit oder beim Abschluss?

\newpage

### Teams & Wettbewerb

#### Kurzbeschreibung
Als **Lehrer** möchte ich Teams erstellen und Teilnehmer zuordnen um die Ergebnisse am Ende vergleichen zu können. -> Teams sind Sammlungen von Spielern, deren Punkte gemeinsam gezählt werden.

#### Akzeptanzkriterien
+ Given: Organisator erstellt ein Team
+ When: Er gibt Teamname und Teilnehmer ein
+ Then: Wird das Team in Firestore gespeichert

- Given: Spieler tritt einem Team bei
- When: Er wählt den Teamcode oder Namen aus
- Then: Wird er als Mitglied hinzugefügt

+ Given: Mehrere Teams existieren
+ When: Spielerpunkte aktualisiert werden
+ Then: Wird der Gesamtpunktestand automatisch neu berechnet

- Given: Organisator löscht ein Team
- When: Das Team entfernt wird
- Then: Werden dessen Punkte ebenfalls entfernt

#### Conversation Points
- Beitritt via Code, QR oder Auswahlmenü?
- Adminrechte für Lehrer in der App oder extern über Firebase?
- Maximale Teamgröße?

\newpage

### Spielende & Auswertung

#### Kurzbeschreibung
Als **Lehrer** möchte ich am Ende der Schnitzeljagd ein Ranking der Teams sehen um die Gewinner zu ermitteln. -> Nach Ende des Spiels werden alle Punktestände zusammengefasst und in einem Ranking dargestellt.

#### Akzeptanzkriterien
+ Given: Alle Teams haben Aufgaben abgeschlossen
+ When: Das Spiel wird beendet
+ Then: Wird ein Ranking nach Punktestand angezeigt

- Given: Zwei Teams haben denselben Punktestand
- When: Ranking wird generiert
- Then: Wird ein Gleichstand entsprechend markiert

+ Given: Ein Team verlässt das Spiel vorzeitig
+ When: Spielende eintritt
+ Then: Wird es als „nicht abgeschlossen“ markiert

- Given: Das Spiel wird manuell beendet
- When: Der Organisator klickt „Schnitzeljagd beenden“
- Then: Wird kein weiterer Fortschritt mehr gespeichert

#### Conversation Points
- Sortierlogik (Punkte, Zeit, Bonusaufgaben)?
- Exportmöglichkeit als CSV oder Screenshot?
- Automatisches vs. manuelles Beenden?
