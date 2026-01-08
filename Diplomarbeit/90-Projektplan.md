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
|:--------------:|:---:| :----------------|:--------------|
| Ungenaue Schätzungen (Kosten, Zeit) | 30% | Zeit- oder Budgetplan passt nicht -> Deadlines könnten verfehlt werden | Schätzungen im Team absprechen, eher großzügig planen |
| Unzureichend definierter Projektumfang / Anforderungen | 25% | Wir implementieren falsche oder zu viele Funktionen -> Nacharbeiten | Anforderungen klar dokumentieren, Fixpunkt mit Betreuern |
| Scope Creep (schleichende Erweiterung des Umfangs) | 20% | Projekt wächst über das geplante Maß -> Überforderung und Zeitprobleme | Änderungswünsche kontrollieren, nur bei Zustimmung einbauen |
| Lernkurven / fehlende Erfahrung mit Technologien | 35% | Verzögerungen durch Einarbeitung, mehr Fehler | Zeit für Learning einplanen, Tutorials & Dokumentation nutzen |
| Ressourcenmangel (Zeit, Team, Hardware) | 20% | Aufgaben können nicht rechtzeitig erledigt werden | Ressourcen früh planen, Zeitpuffer einbauen |
| Fehlende Kommunikation im Team / mit Stakeholdern | 25% | Missverständnisse, doppelte Arbeit, falsche Features | Regelmäßige Meetings, Aufgaben klar verteilen |
| Probleme bei technischer Integration / Architektur | 15% | App instabil oder inkompatibel, zusätzliche Arbeit nötig | Architektur früh prüfen, Prototypen & Tests machen |
| Unzureichende Testphase | 25% | Fehler werden spät entdeckt -> schlechte Nutzererfahrung | Testphase fix einplanen, Beta-Test durchführen |
| Geringe Nutzerakzeptanz (UI/UX zu komplex) | 20% | Anwendung wird nicht verstanden oder falsch genutzt | Nutzerfeedback früh einholen, einfache Bedienung sicherstellen |
| Verzögerungen beim Hard-/Software-Setup | 10% | Projektstart verzögert -> Zeitdruck | Entwicklungsumgebung früh einrichten, Backups & Alternativen planen |


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

## Registrierung & Login

### Kurzbeschreibung  
Als **Spieler** möchte ich mich mit meiner schulischen E-Mail-Adresse registrieren und anmelden können, um an einer Schnitzeljagd teilnehmen zu können.

### Trigger  
Der Spieler möchte an einer Schnitzeljagd teilnehmen und öffnet die App.

### Vorbedingung  
- Die App ist installiert  
- Eine Internetverbindung ist vorhanden  
- Der Spieler besitzt eine gültige schulische E-Mail-Adresse  

### Nachbedingung  
Der Spieler ist erfolgreich angemeldet und befindet sich auf der Startseite der App.

### Akteure  
- Spieler  

### Standardablauf  
Der Standardablauf wird durch die Akzeptanzkriterien beschrieben.

### Akzeptanzkriterien  
- **Given:** Ein Nutzer öffnet die App  
  **When:** Er klickt auf „Login“  
  **Then:** Wird er eingeloggt und zur Startseite weitergeleitet  

- **Given:** Der Nutzer gibt eine ungültige E-Mail oder ein falsches Passwort ein  
  **When:** Er klickt auf „Anmelden“  
  **Then:** Erhält er eine Fehlermeldung „Ungültige Anmeldedaten“  

- **Given:** Ein neuer Nutzer registriert sich  
  **When:** Er bestätigt die Registrierung  
  **Then:** Wird ein neuer Firestore-Eintrag unter `users` erstellt  

### Fehlersituationen  
- Ungültige Anmeldedaten  
- Abbruch des Login-Vorgangs  

### Systemzustand im Fehlerfall  
Der Nutzer bleibt ausgeloggt, es wird kein Benutzerkonto erstellt oder verändert.

### Conversation Points  
- E-Mail-Verifizierung notwendig?  
- Passwort-Richtlinien?  

---

## Karte & Standort

### Kurzbeschreibung  
Als **Spieler** möchte ich auf einer Karte meine Position und nahegelegene Aufgaben sehen, um zu wissen, wohin ich als Nächstes gehen soll.

### Trigger  
Der Spieler öffnet die Kartenansicht.

### Vorbedingung  
- Der Spieler ist angemeldet  
- Die Standortfreigabe ist erteilt  

### Nachbedingung  
Die aktuelle Position sowie Aufgaben in der Umgebung werden auf der Karte angezeigt.

### Akteure  
- Spieler  
- Standortdienst des mobilen Endgeräts  

### Standardablauf  
Der Standardablauf wird durch die Akzeptanzkriterien beschrieben.

### Akzeptanzkriterien  
- **Given:** Der Nutzer hat Standortfreigabe erteilt  
  **When:** Er öffnet die Karte  
  **Then:** Wird seine Position korrekt mit einem Marker angezeigt  

- **Given:** Aufgaben befinden sich in der Nähe  
  **When:** Die Karte geladen wird  
  **Then:** Werden Marker für Aufgaben innerhalb eines 500 m Radius angezeigt  

- **Given:** Der Nutzer lehnt die Standortfreigabe ab  
  **When:** Er öffnet die Karte  
  **Then:** Wird eine Hinweismeldung angezeigt („Standortzugriff erforderlich“)  

- **Given:** Der Nutzer bewegt sich  
  **When:** Seine Position ändert sich  
  **Then:** Aktualisiert sich der Positionsmarker in Echtzeit  

### Fehlersituationen  
- Standortzugriff verweigert  
- Ungenaue oder fehlende Standortdaten  

### Systemzustand im Fehlerfall  
Die Karte wird ohne Positionsdaten angezeigt, Aufgabenmarker werden nicht geladen.

### Conversation Points  
- Echtzeit-Updates oder periodische Standortabfrage?  
- Filter für Aufgabenradius?  
- Karten-Styling (Standard, Dark Mode)?  

---

## Standortbasierte Aufgaben

### Kurzbeschreibung  
Als **Spieler** möchte ich automatisch Aufgaben erhalten, sobald ich mich einem Checkpoint nähere, um interaktiv an der Schnitzeljagd teilnehmen zu können.

### Trigger  
Der Spieler betritt den definierten Umkreis eines Checkpoints.

### Vorbedingung  
- Der Spieler ist angemeldet  
- Eine aktive Schnitzeljagd ist gestartet  
- Standortberechtigung ist erteilt  

### Nachbedingung  
Die Aufgabe wird angezeigt und kann bearbeitet werden.

### Akteure  
- Spieler  
- GPS-/Standortsystem  

### Standardablauf  
Der Standardablauf wird durch die Akzeptanzkriterien beschrieben.

### Akzeptanzkriterien  
- **Given:** Der Spieler befindet sich in einer aktiven Schnitzeljagd  
  **When:** Er betritt den definierten Umkreis eines Checkpoints  
  **Then:** Wird die zugehörige Aufgabe automatisch angezeigt  

- **Given:** Ein Spieler hat eine Aufgabe bereits erledigt  
  **When:** Er betritt erneut den Checkpoint-Radius  
  **Then:** Erscheint keine neue Aufgabe, optional ein Hinweis „Checkpoint bereits abgeschlossen“  

- **Given:** Eine Aufgabe wird ausgelöst  
  **When:** Sie öffnet sich  
  **Then:** Wird sie in einem rein visuellen Format angezeigt  

- **Given:** Der Spieler hat keine Standortberechtigung erteilt  
  **When:** Er startet die Runde  
  **Then:** Er erhält einen klaren Hinweis inklusive Möglichkeit zur Freigabe  

- **Given:** Der Standort ist ungenau  
  **When:** Der Spieler bewegt sich nahe des Radius  
  **Then:** Wird die Aufgabe nur einmal ausgelöst  

### Fehlersituationen  
- Ungenaue Standortdaten  
- Mehrfache Standortupdates  

### Systemzustand im Fehlerfall  
Der Aufgabenstatus bleibt unverändert, keine doppelte Auslösung erfolgt.

### Conversation Points  
- Optimale Radiusgröße  
- GPS-Update-Intervall  
- Speicherung des Aufgabenstatus  

---

## Aufgaben & Fortschritt

### Kurzbeschreibung  
Als **Spieler** möchte ich meinen Fortschritt und meine erreichten Punkte sehen, um meine Leistung nachvollziehen zu können.

### Trigger  
Der Spieler öffnet die Fortschrittsansicht.

### Vorbedingung  
- Der Spieler ist angemeldet  

### Nachbedingung  
Der aktuelle Fortschritt und die Gesamtpunkte werden angezeigt.

### Akteure  
- Spieler  

### Standardablauf  
Der Standardablauf wird durch die Akzeptanzkriterien beschrieben.

### Akzeptanzkriterien  
- **Given:** Der Spieler hat mindestens eine Aufgabe abgeschlossen  
  **When:** Er öffnet die Fortschrittsseite  
  **Then:** Sieht er erledigte und offene Aufgaben getrennt  

- **Given:** Aufgaben besitzen unterschiedliche Punktwerte  
  **When:** Aufgaben abgeschlossen werden  
  **Then:** Wird die Gesamtsumme korrekt berechnet  

- **Given:** Der Spieler aktualisiert die Seite  
  **When:** Neue Aufgaben erledigt wurden  
  **Then:** Aktualisiert sich der Fortschrittsbalken  

- **Given:** Alle Aufgaben wurden erledigt  
  **When:** Die Fortschrittsseite geöffnet wird  
  **Then:** Wird „Schnitzeljagd abgeschlossen“ angezeigt  

### Fehlersituationen  
- Fortschrittsdaten nicht verfügbar  

### Systemzustand im Fehlerfall  
Der letzte bekannte Fortschritt bleibt erhalten.

/newpage
