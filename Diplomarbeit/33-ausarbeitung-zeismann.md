# Teilaufgabe Schüler Zeismann
\textauthor{Tobias Zeismann}

## Praktische Arbeit

### Einordnung der Teilaufgabe

Im Gesamtprojekt GeoQuest war ich für die Frontend-Entwicklung verantwortlich. Ziel war eine mobile Anwendung, die eine schulische Schnitzeljagd technisch zuverlässig abbildet und dabei für unterschiedliche Nutzergruppen verständlich bleibt. Das Frontend sollte deshalb nicht nur gut aussehen, sondern im Alltag wirklich stabil funktionieren: klare Benutzerführung für Erstnutzer, stabile Verarbeitung von GPS- und Firestore-Daten, faire Spielmechanik (Anti-Cheat, Standortprüfung, Zeitbonus), robuste Fehlerrückmeldung, modulare Erweiterbarkeit für Folgeversionen.

Die inhaltliche Herausforderung war, dass in GeoQuest laufend neue Ereignisse eintreffen: Positionsupdates, Zeitabläufe, Session-Status, Firestore-Schreibvorgänge und Nutzeraktionen auf mehreren Screens. Die Oberfläche ist damit nicht nur Darstellungsfläche, sondern Teil der eigentlichen Spiellogik.

### Zielsetzung und Abnahmekriterien

Für die Frontend-Teilaufgabe wurden vor der Implementierung konkrete Abnahmekriterien definiert. Ein Frontend galt nur dann als fertig, wenn die zentralen Kernpfade unter realistischen Bedingungen funktionieren. Dazu zählen ein stabiler App-Start mit Splash, Onboarding und Rollenwahl, die Registrierung und Anmeldung mit E-Mail und Passwort, der Spielstart über Dashboard und Route mit einer stabilen Live-Karte, die Freischaltung von Aufgaben nur im Stationsradius oder per QR-Code, eine Punktevergabe mit Zeitbonus samt dauerhaft gespeichertem Fortschritt und Ranking im Progress-Tab sowie eine Admin-Karte zur Live-Beobachtung einzelner Spieler.

Die Qualität wurde zusätzlich über nicht-funktionale Kriterien abgesichert: kurze Reaktionszeiten, nachvollziehbare Fehlermeldungen, konsistente Navigation und saubere Trennung zwischen UI, Zustandslogik und Datenzugriff.

### Projektkontext und technischer Rahmen

Die App wurde mit Flutter und Dart umgesetzt. Flutter erlaubt eine gemeinsame Codebasis für mehrere Plattformen und passt gut zu einem UI-lastigen Projekt mit vielen Zustandsänderungen [@flutterDocs]. Der Einstiegspunkt liegt in application/lib/main.dart. Dort werden Firebase und App-Einstellungen initialisiert, bevor die UI startet: Firebase.initializeApp(...) lädt die Plattformkonfiguration, auf Web wird Persistence.LOCAL aktiviert, AppSettings.load() lädt Theme, Sprache, Login-Modus und Onboarding-Status.

Als Backend-Dienste wurden Firebase Authentication und Cloud Firestore eingesetzt [@firebaseAuthDocs; @firestoreDocs]. Die Kartenansicht basiert auf OpenStreetMap-Daten über flutter_map [@flutterMapDocs; @openstreetmapCopyright]. Die Standortdaten kommen über geolocator [@geolocatorPkg]. Die Flutter-Dokumentation fasst den technischen Kern dieses Vorgehens prägnant zusammen: "Build apps for any screen." [@flutterWebsite]. Damit ist eine gemeinsame UI-Codebasis mit konsistentem Verhalten gemeint.

### Entwicklungsumgebung und Arbeitsprozess

Die Entwicklung erfolgte im Team über Git-Branches mit regelmäßigen Merges. Für das Frontend war ein enger Integrationsrhythmus wichtig, weil viele Funktionen über mehrere Dateien hinweg zusammenspielen. Besonders eng gekoppelt sind dabei die globalen Einstellungen, die Auth-Screens, die Home-Navigation, die Kartenlogik sowie Progress- und Admin-Auswertung.

Zusätzlich wurden frühe Funktionsstände auf echten Geräten geprüft, da GPS- und Netzverhalten im Emulator nur eingeschränkt die Realität abbilden. Der Testansatz kombinierte daher: schnelle Iteration im Simulator, Feldtests für Standort- und Bewegungslogik, Integrationstest für App-Boot (integration_test/app_flow_test.dart).

### Aufbau der Frontend-Architektur

Die Architektur trennt die App in wenige klare Schichten. Dazu gehören der Start- und Auth-Flow mit Splash, Onboarding, Rollenwahl, Login und Registrierung, der Spiel-Flow mit Dashboard, Karte und Bewertungslogik, der Meta-Flow mit Progress, Menü, Datenschutz, Impressum und Einstellungen sowie ein Admin-Flow mit Live-Karte für Lehrkräfte.

Wesentliche Bausteine sind AppSettings für dauerhaft gespeicherte UI- und Session-Einstellungen, AppNav für globale Navigation und Sperrzustände, GameState als reaktiver Spielfeld-Zustand sowie die Firestore-Collections Users, PlayerLocation, Hunts und Hunts/{huntId}/Stadions.

Der Vorteil dieser Trennung ist, dass die Map-Logik unabhängig vom Login-Layout weiterentwickelt werden kann und umgekehrt.

### Splash-Screen und intelligentes Routing

Der Splash-Screen (splash_screen.dart) ist nicht nur visuell, sondern logisch relevant. Nach einer kurzen Initialphase (1,5 Sekunden) wird der nächste Zielscreen anhand dreier Zustände bestimmt: Ist bereits ein User eingeloggt?, Ist Onboarding bereits abgeschlossen?, War der zuletzt gespeicherte Modus Spieler oder Admin?.

Je nach Zustand navigiert der Code direkt zu HomeScreen, AdminMapScreen, OnboardingFlow oder RoleSelectScreen. Dadurch entsteht ein deterministischer Startprozess ohne Sackgassen.

### Onboarding als UX-Filter vor der Anmeldung

Das Onboarding (onboarding_flow.dart) besteht aus vier klaren Seiten: Einführung in das Spielprinzip, Erklärung der zufälligen Stationsreihenfolge, Erklärung des Aufgabenformats, Fairness-Regeln (Standortnähe, Geschwindigkeitsprüfung).

Jede Seite besitzt genau eine Primäraktion (Weiter bzw. Los gehts!). Die lineare Struktur verhindert Überforderung beim Erstkontakt. Nach dem letzten Schritt wird onboarding_done in den Einstellungen gespeichert.

Dieses Muster folgt dem UX-Prinzip "Progressive Disclosure": nur die Informationen zeigen, die für den nächsten Schritt notwendig sind [@normanDesign].

### Rollenwahl und Benutzergruppen

role_select_screen.dart trennt den Einstieg in zwei Pfade: Admin: Anmeldung nur mit freigegebener Lehrkräfte-E-Mail, Spieler: Registrierung oder Login für Teilnehmende.

Die Rollenwahl wird nicht nur visuell dargestellt, sondern in AppSettings.loginMode persistiert. Dadurch kann der Splash-Screen bei erneutem App-Start korrekt zurück in den letzten Modus navigieren.

### Authentifizierung und Kontolebenszyklus

Der Auth-Bereich besteht aus mehreren Screens: SignInEmailScreen für den Einstieg mit E-Mail, CreateAccountScreen für Registrierung, LoginScreen für Anmeldung, ChangePasswordScreen für Passwort-Reset.

#### Registrierung

In CreateAccountScreen werden Username, E-Mail und Passwort validiert: Username-RegEx: ^[A-Za-z0-9._-]{3,24}$, E-Mail-RegEx für Basisformat, Passwortlänge mindestens 6 Zeichen.

Danach erfolgt: Prüfung auf eindeutigen Username (Users.UsernameLower), Anlage des Firebase-Auth-Kontos, Versand einer Verifizierungs-E-Mail, Schreiben des Benutzerprofils in Users/{uid}.

Ohne verifizierte E-Mail wird im Login kein dauerhafter Einstieg zugelassen. Dieser Mechanismus reduziert Fake-Accounts und sorgt im Schulbetrieb für mehr Übersicht [@firebaseAuthDocs].

#### Anmeldung

LoginScreen unterstützt Username- und E-Mail-Login. Bei Username-Login wird zuerst die E-Mail aus Firestore aufgelöst. Zusätzlich gibt es einen Legacy-Fallback mit der Domain geoquest.local für ältere Testkonten.

Fehler werden benutzerorientiert behandelt (z. B. "Keine Internetverbindung" statt roher SDK-Fehlercodes). Das erhöht die Nutzbarkeit deutlich.

#### Admin-Freigabe

Die Klasse admin_access.dart enthält freigegebene Admin-E-Mails und Logik zur Namensnormalisierung. Nach erfolgreichem Firebase-Login prüft die App, ob die E-Mail in der Admin-Liste liegt. Bei negativem Ergebnis wird die Sitzung sofort beendet.

Damit wird ein zweistufiges Modell umgesetzt: technische Authentifizierung durch Firebase, zusätzliche Freigabe in der App durch App-Regeln.

### Home-Shell und Tab-Architektur

home_screen.dart bildet die zentrale Spiel-Shell mit vier Tabs: Dashboard, Karte, Fortschritt, Menü.

Technisch wurde IndexedStack verwendet, damit Tab-Zustände erhalten bleiben. Das vermeidet unnötige Neuinitialisierung beim Wechsel.

Eine wichtige Besonderheit ist der globale Sperrmechanismus: Wenn AppNav.mapBlocked aktiv ist (Anti-Cheat-Sperre), wird der Benutzer automatisch auf den Karten-Tab zurückgeführt. So kann die Sperrlogik nicht durch Tab-Wechsel umgangen werden.

Im aktuellen Projektstand wurde außerdem die feste Hunt-ID entfernt. Die App ermittelt die Hunt dynamisch aus den gespeicherten Benutzerdaten und nutzt nur dann einen Fallback, wenn dort keine Zuordnung vorliegt. Damit funktioniert derselbe Build verlässlich mit unterschiedlichen Datenständen in Firebase.

### Dashboard-Flow: Hunt-Start und nächste Route

Der Dashboard-Pfad besteht aus: StartHuntScreen als Einstieg mit Spielkontext und Zeitbonus-Hinweis sowie StartRouteScreen mit nächster Station und Distanz.

In StartRouteScreen werden Daten aus Firestore und GameState zusammengeführt. Im aktuellen Stand stehen dort vor allem die nächste Station und die Distanz im Fokus. Die Gesamtzeit wird nur am Abschlussbildschirm angezeigt.

Beim ersten Start ruft der Button GameState.startHunt() auf und aktiviert AppNav.stationActive. Danach wird direkt auf die Karte gewechselt.

### Reaktiver Kern über GameState

game_state.dart ist der zentrale Datenvermittler zwischen Firestore und UI.

Wichtige ValueNotifier: huntStarted, nextStationName, nextStationDistanceMeters, nextStationPoints, remainingTime.

Datenquellen: Hunts/{huntId} (z. B. durationMinutes), Hunts/{huntId}/Stadions (Titel, Punkte, Standort), PlayerLocation/{uid} (aktuelle Position, Index, Startzeit), Users/{uid} (persönliche Reihenfolge, Fortschritt).

#### Deterministische Stationsreihenfolge

Um Menschenansammlungen an einzelnen Stationen zu reduzieren, wird für jeden Benutzer eine reproduzierbare, aber individuelle Reihenfolge berechnet. Dazu werden Stations-IDs mit einem Seed aus uid:huntId geshuffelt und in Users.StationOrderByHunt gespeichert.

Diese Lösung erfüllt zwei Ziele gleichzeitig: faire Verteilung im Gelände, stabile Reihenfolge über App-Neustarts hinweg.

### Kartenansicht als zentrale Spielfläche

Die Kartenansicht ist in map_tab.dart implementiert und umfasst über 1200 Zeilen, weil dort mehrere komplexe Anforderungen zusammenlaufen: Live-Position, Distanzberechnung zur nächsten Station, Radiusprüfung, QR-Freischaltung, Anti-Cheat, Zeitlogik, Punktevergabe, Fortschrittsspeicherung.

Die Karte basiert auf flutter_map mit OSM-Tiles. Zusätzlich wird ein MapController eingesetzt, um den initialen Kartenausschnitt dynamisch zu setzen: nur Spielerposition, wenn keine aktive Station, Bounds-Spieler-zu-Station, wenn eine Station aktiv ist.

### Standortstream und Berechtigungslogik

_startLocationStream() prüft vor dem Start: Sind Standortdienste aktiv?, Liegen Berechtigungen vor?.

Dann startet Geolocator.getPositionStream(...) mit: hoher Genauigkeit (best), distanceFilter: 2 Meter.

Bei jedem Standortupdate passieren drei Dinge: UI-Zustand aktualisieren, Position gedrosselt in Firestore schreiben (_dbWriteCooldown = 10s), Spielregeln prüfen (Radius, Geschwindigkeit, Zeitschätzung).

Diese Drosselung reduziert Firestore-Last und Stromverbrauch deutlich [@firestoreDocs].

### Radiusprüfung und Aufgabenfreigabe

Eine Aufgabe darf nur gelöst werden, wenn der Benutzer die Station erreicht hat oder den passenden QR-Code scannt. Für die räumliche Prüfung wird der Abstand Spieler-zu-Station berechnet und gegen den Schwellwert verglichen:

_stationRadiusMeters = 15.

Wird der Radius unterschritten, wechselt der UI-Zustand auf MapUiState.inRadius, und der Button "Zur Aufgabenbewertung" wird freigeschaltet.

Dieser Radius ist ein praxisbasierter Kompromiss: zu klein führt bei GPS-Schwankungen zu Frust, zu groß reduziert Fairness.

### QR-Validierung als zweiter Freischaltkanal

In manchen Situationen (GPS drift, ungünstige Umgebung) reicht Radius allein nicht aus. Deshalb wurde eine QR-Freischaltung ergänzt. Im aktuellen Stand sind 12 Stationen vorgesehen, davon 6 reine QR-Stationen und 6 Lehrerstationen mit Passwort und Bewertung. QrScanScreen scannt über mobile_scanner, der erkannte Wert wird normalisiert (trim + lowercase), Vergleich mit erwartetem Stationscode.

Bei Erfolg setzt die App _qrUnlockedForStation = true, wodurch die Aufgabenbewertung ebenfalls gestartet werden kann.

### Anti-Cheat-Mechanik (Geschwindigkeit)

Ein zentrales Qualitätsziel war Fairness. Die App erkennt zu schnelle Bewegung und behandelt diese in Eskalationsstufen: Warnschwelle: 15 km/h (_speedWarnThresholdMps), Mindestdauer der Überschreitung: 3 Sekunden, Warnungs-Cooldown: 12 Sekunden, nach 3 Warnungen: 5 Minuten Sperre (_blockSeconds = 300).

Zusätzlich filtert _isLikelyLocationJump(...) unplausible GPS-Sprünge (z. B. hohe Genauigkeitsfehler), damit keine falschen Cheating-Detektionen ausgelöst werden.

Bei Sperre passiert Folgendes: AppNav.mapBlocked = true, Abzug von 2 Punkten in Firestore, Countdown-Dialog mit verbleibender Sperrzeit, nach Ablauf Entsperrdialog und Rückkehr in Normalzustand.

Diese Umsetzung macht Regeln transparent und verhindert gleichzeitige Ausnutzung durch Navigationstricks.

### Zeitmodell und Bonuspunkte

Während einer aktiven Station berechnet die App eine verbleibende Richtzeit. Diese basiert auf Distanz und einem Puffer (5/7/10 Minuten abhängig von Streckenlänge). Das Ergebnis wird auf volle Minuten gerundet und als Countdown angezeigt.

Beim Abschließen einer Station wird entschieden: inTime == true -> Zeitbonus +2.0 Punkte, sonst kein Bonus.

Neben Gesamtpunkten werden stationsweise Details gespeichert: TeacherPointsByStation, TimeBonusByStation, TimeSecondsByStation.

Damit ist die Bewertung später nachvollziehbar und auswertbar.

### Aufgabenbewertung und Punktepersistenz

Die fachliche Bewertung erfolgt über QuizIntroScreen und QuizScreen: Lehrperson trägt Punkte von 0.0 bis 10.0 ein, Werte werden validiert (maximal eine Nachkommastelle), Rückgabe der Punktzahl an MapTab.

_awardPointsForCurrentStadion(...) führt dann eine Firestore-Transaktion aus. Dadurch werden gleichzeitige Konflikte bei parallelen Updates vermieden [@firestoreDocs]. Aktualisiert werden u. a.: Points, TeacherPointsTotal, TimeBonusPoints, SolvedCount, CompletedStadions, TotalTimeSeconds und TotalTimeText.

Anschließend speichert _saveProgress(...) den neuen Stationsindex in PlayerLocation und Users.CurrentStadionIndexByHunt.

### Fortschrittsanzeige und Ranking

progress_tab.dart liest alle User-Dokumente aus Users und erstellt ein Ranking: primär sortiert nach Punkten, sekundär nach gelösten Aufgaben.

Zusätzlich werden angezeigt: eigene Gesamtpunkte, Zeitbonusanteil, gelöste Aufgaben, Gesamtzeit.

Die Kombination aus persönlichem Fortschritt und Leaderboard wirkt motivierend, solange die Rangliste stabil und nachvollziehbar bleibt [@nielsen1994].

### Admin-Karte für Lehrkräfte

admin_map_screen.dart ist ein eigener Frontend-Modus und zeigt Live-Positionen aller aktiven Spieler.

Funktionen: Stream auf Users und PlayerLocation, Filterung von Admin-Konten, Marker pro Spieler, Suchfeld nach Name/E-Mail, Detailsheet mit nächster Station und Stationsanzahl, Fokus-Funktion auf gewählten Spieler.

Für die Anzeige der nächsten Station werden entweder die persönliche Reihenfolge (StationOrderByHunt) oder die allgemeine Hunt-Reihenfolge verwendet. Diese Logik stellt sicher, dass die Admin-Ansicht mit dem tatsächlichen Spielverlauf übereinstimmt.

### Menü, Einstellungen und rechtliche Screens

menu_tab.dart kapselt den Meta-Bereich: Einstellungen (Theme + Sprache), Datenschutz, Impressum, Logout.

Die Einstellungen nutzen AppSettings und sind dauerhaft gespeichert. Unterstützt werden Deutsch/Englisch sowie Hell/Dunkel-Modus.

Der Datenschutz-Screen erklärt verständlich: welche Daten verarbeitet werden, zu welchem Zweck, wie lange gespeichert wird, welche Rechte Nutzer haben.

Damit wird Datenschutz nicht nur formal, sondern als Teil der UX umgesetzt [@gdpr].

### Internationalisierung und Sprachumschaltung

Die App besitzt zwei Ebenen der Mehrsprachigkeit: globale Flutter-Lokalisierung in main.dart (supportedLocales), projektinterne Kurzfunktion tr(de, en) für schnelle Textumschaltung.

Zusätzlich existieren ARB-Dateien (app_de.arb, app_en.arb). Die Sprachauswahl wird in SharedPreferences gespeichert, sodass der Nutzer nach Neustart in der gewählten Sprache bleibt.

### Fehlerbehandlung und Recovery-Strategien

Aus den Feldtests ergaben sich typische Fehlerbilder: GPS ausgeschaltet, Permission verweigert, instabile Internetverbindung, auslaufende Session, verzögerte Firestore-Antworten.

Die Frontend-Strategie arbeitet mit drei Ebenen: Prävention: Vorabprüfungen und Guard-Logik, Kommunikation: klare Hinweise statt technischer Rohtexte, Recovery: Retry-Buttons, sichere Rücksprünge, erneute Berechtigungsabfrage.

Ein konkretes Beispiel ist MapTab: Kann die Stationenliste nicht geladen werden, bleibt die Oberfläche bedienbar und bietet "Erneut versuchen" anstatt eines stillen Abbruchs.

### Performance-Entscheidungen

Mehrere Maßnahmen wurden bewusst für mobile Performance eingebaut: Firestore-Write-Throttling der Standortdaten (10 Sekunden), Vermeidung unnötiger Rebuilds durch gezielte setState-Blöcke, kontrolliertes Start/Stop von Standortstreams beim Tabwechsel, Abbruch und Cleanup von Timern/Subscriptions in dispose().

Gerade bei Kartenanwendungen ist diese Disziplin wichtig, weil häufige Rebuilds und permanente Streams sonst direkt auf Akku und UI-Flüssigkeit schlagen [@flutterPerf].

### Sicherheits- und Datenschutzaspekte der Implementierung

Sicherheitsrelevante Punkte im Frontend: keine sensiblen Klartextdaten lokal persistieren, Zugriff auf Spielzustand an Auth-Session koppeln, Admin-Routen nur mit zusätzlicher E-Mail-Autorisierung, reduzierte Fehlermeldungen ohne interne Systemdetails.

Datenschutzrelevant ist vor allem die Standortverarbeitung. Diese wird funktional begründet (Stationserkennung/Fairness) und auf den Spielkontext begrenzt. Das entspricht dem Prinzip der Datenminimierung [@gdpr].

### Teststrategie und Qualitätssicherung

Die QS bestand aus drei Bausteinen, nämlich manuellen End-to-End-Tests auf Emulator und realen Geräten, Wiederholungstests für kritische Flows wie Login, Karte und Fortschritt sowie einem Integrationstest für App-Start und Sichtbarkeit zentraler UI-Elemente.

Typische Testfälle waren die Registrierung mit E-Mail-Verifizierung, der Start einer Hunt mit individueller Reihenfolge, die Freischaltung nur per Radius oder QR, die Anti-Cheat-Sperre mit korrektem Countdown sowie die transaktionssichere Speicherung von Punkten und Zeitbonus.

Zusätzlich wurden Dark-/Light-Mode und Deutsch/Englisch visuell geprüft, um abgeschnittene Texte und Kontrastprobleme früh zu erkennen.

### Vergleich von Ziel und Ergebnis

Die ursprünglichen Frontend-Ziele wurden im Wesentlichen erreicht. Der Einstieg ist geführt, die Login- und Session-Logik arbeitet stabil, der Map-Flow mit Radius, QR und Lehrerstationen ist umgesetzt, ebenso die faire Spielmechanik mit Sanktionen sowie Fortschritt, Ranking und Admin-Monitoring.

Offene Verbesserungsfelder bleiben vor allem mehr automatisierte Widget- und Golden-Tests, eine feinere Offline-Strategie und eine stärkere Entkopplung der großen Map-Logik in kleinere Subkomponenten.

### Reflexion der praktischen Umsetzung

Die größte technische Erkenntnis war, dass bei standortbasierten Apps nicht eine einzelne Funktion über Erfolg entscheidet, sondern das Zusammenspiel vieler kleiner Schutzmechanismen. Besonders wichtig waren: defensive GPS-Verarbeitung, robuste Zustandsübergänge, transaktionssichere Punktevergabe, klare Nutzerkommunikation in Fehlersituationen.

Ein zweiter zentraler Punkt war die Wartbarkeit. Große Dateien wie map_tab.dart funktionieren funktional, erhöhen aber auf Dauer Review- und Änderungsaufwand. Für Folgeversionen ist eine stärkere modulare Zerlegung sinnvoll.

### Ergebnis der praktischen Teilaufgabe

Die Frontend-Teilaufgabe liefert ein funktionsfähiges und in realen Tests belastbares System. Benutzer werden von der ersten App-Öffnung bis zum Abschluss von Stationen geführt, erhalten klare Rückmeldungen und sehen ihren Fortschritt transparent. Lehrkräfte erhalten mit der Admin-Karte einen guten Überblick über den Live-Betrieb.

Aus technischer Sicht ist die Umsetzung nicht nur ein Prototyp, sondern eine solide Basis für weitere nächste Schritte wie neue Spielmodi, komplexere Aufgabenformate oder detaillierte Auswertungen.

## Theorie

### Frontend als praktische Schnittstelle

In standortbasierten Lernanwendungen ist das Frontend eine praktische Schnittstelle: Es verbindet Menschen, Regeln, Orte und Datenströme. Theoretisch lässt sich seine Rolle in drei Ebenen beschreiben: Interaktionsebene: Bedienung, Lesbarkeit, Feedback, Kontrollebene: Regelprüfung, gültige Zustandsübergänge, Vertrauensebene: Transparenz bei Daten, Fairness und Fehlern.

Ein Frontend ist damit nicht bloß "die Oberfläche", sondern ein aktiver Teil der Systemzuverlässigkeit.

### Deklarative UI als Architekturprinzip

Flutter arbeitet nach einem klaren Prinzip: Die Oberfläche richtet sich immer nach dem aktuellen Zustand [@flutterDocs]. Für GeoQuest passt das sehr gut, weil sich Standort, Fortschritt und Session laufend ändern.

Der Ansatz hat drei praktische Vorteile. Erstens bleibt die Übersicht besser, weil sich der UI-Zustand direkt aus den Daten ergibt. Zweitens lassen sich Zustandswechsel sauber testen. Drittens bleibt der Code leichter wartbar, weil weniger UI-Workarounds nötig sind.

Grenze des Ansatzes: Ohne saubere Zustandsmodellierung entstehen auch deklarativ inkonsistente Ansichten. Deshalb ist State-Design wichtiger als reine Widget-Struktur.

### Zustandsmanagement in dynamischen Spielszenarien

Theoretisch sollte Zustand nach Lebensdauer getrennt werden: kurzlebig (Dialog geöffnet, Fokus, Button-Disable), funktionsbezogen (aktive Station, Warnungszähler, Countdown), dauerhaft gespeichert (Profil, Punkte, Stationsreihenfolge).

GeoQuest nutzt hierfür eine Mischform aus lokalem Widget-State, ValueNotifier und Firestore als dauerhaft gespeicherte Wahrheit. Diese Kombination ist für mittelgroße Projekte pragmatisch, erfordert aber klare Verantwortungsgrenzen.

### Navigation als Zustandsautomat

Navigation kann als klarer Ablauf mit festen Zuständen gesehen werden: Jeder Screen ist ein Zustand, jeder Button ein Übergang. Fehler entstehen dort, wo ungültige Übergänge zugelassen werden.

Beispiele für gültige Guard-Regeln: ohne Login kein Eintritt in Spielbereiche, ohne aktive Station keine Aufgabenbewertung, während Sperre kein Wechsel in Umgehungszustände.

Diese Perspektive hilft, UI-Entscheidungen systematisch statt ad hoc zu treffen.

### Informationsarchitektur und kognitive Last

Kognitive Last steigt stark, wenn pro Screen mehrere gleichgewichtige Entscheidungen verlangt werden. Die App reduziert diese Last durch: eine dominante Primäraktion pro Schritt, linearen Einstieg, tab-basierten Betrieb nach Initialphase, konsistente Positionen zentraler Bedienelemente.

Diese Reduktion ist kein Funktionsverlust, sondern eine Optimierung der Entscheidungsqualität unter Zeitdruck.

### Karten-UI als Spezialfall

Kartenansichten unterscheiden sich von klassischen Formular- oder Listen-UIs, weil sich der Inhalt permanent mit Position und Zoom verändert. Aus theoretischer Sicht benötigen solche UIs: stabile visuelle Referenzen, eindeutige klare Marker-Bedeutung, saubere Priorisierung von Informationen.

GeoQuest löst das u. a. über den Bottom-Statusbereich, klaren Radius-Feedback-Zustand und kontextabhängige Aktionsbuttons (QR-Scan vs. Aufgabenbewertung).

### Unsicherheit von Standortdaten

GPS ist nicht immer exakt gleich. Messwerte schwanken je nach Gerät, Umgebung und Bewegung. Daraus folgt: Distanzlogik muss robust gegen Unsicherheit sein.

Relevante wichtige Einstellungen: Radiusgröße, Updatefrequenz, Filterung von Ausreißern, Ersatzmechanismen (QR als Fallback).

Genau diese Kombination wurde praktisch umgesetzt, um einen fairen und zugleich benutzbaren Ablauf zu gewährleisten.

### Anti-Cheat aus Systemtheorie-Sicht

Anti-Cheat ist in Lernspielen nicht primär eine Sicherheitsfrage, sondern eine Fairnessfrage. Ein wirksames Modell braucht: nachvollziehbare Regeln, reproduzierbare Erkennung, angemessene Strafen, transparente Kommunikation.

Das in GeoQuest umgesetzte Stufenmodell (Warnung -> Sperre -> Punktabzug) ist deshalb wirksam, weil es nicht sofort maximal bestraft, aber wiederholtes Fehlverhalten klar begrenzt.

### Asynchrone Verarbeitung und Konsistenz

Moderne Mobile-Apps sind asynchron: Streams, Netzwerk, Timer und UI-Events laufen parallel. Typische Risiken sind gleichzeitige Konflikte, doppelte Schreibvorgänge und veraltete Anzeige.

Gegenmaßnahmen sind Firestore-Transaktionen für kritische Summenfelder, eine Update-Logik ohne Doppelwirkungen je Station, Guard-Flags gegen Doppeltrigger und sauberes Stoppen von Streams und Timern.

Diese Punkte sind nicht optional, sondern eine Grundvoraussetzung für stabile Einsätze in der Praxis.

### Datenstruktur und Benutzererlebnis

Ein inkonsistentes Datenmodell wirkt direkt als UX-Problem. Wenn Punkte, Fortschritt und Zeitdaten fachlich nicht zueinander passen, verliert die Benutzeroberfläche an Glaubwürdigkeit. Cloud Firestore wird offiziell als "flexible, scalable" Datenbank beschrieben; die Dokumentation formuliert dies mit "Cloud Firestore is a flexible, scalable database." [@firestoreDocs]. Im Projekt wurde diese Flexibilität gezielt genutzt, aber durch strukturierte Feldnamen und klar definierte Verantwortlichkeiten eingegrenzt.

### Authentifizierung und Autorisierung

Sichere Anmeldung allein reicht nicht, auch Rollenrechte müssen korrekt durchgesetzt werden. GeoQuest kombiniert deshalb die technische Identität über Firebase Authentication mit einer zusätzlichen Rollen-Freigabe über eine Admin-E-Mail-Liste.

Diese Trennung entspricht gängigen Security-Prinzipien wie "so wenig Rechte wie nötig" [@owaspMasvs].

### Datenschutz und Transparenz

Standortbasierte Anwendungen verarbeiten personenbezogene Daten. Aus DSGVO-Sicht sind besonders relevant: Zweckbindung, Datenminimierung, Transparenz, Rechte der Betroffenen [@gdpr].

Im Frontend bedeutet das: Berechtigungen nicht verstecken, Nutzen vor Abfrage erklären, verständliche Datenschutzinfos direkt in der App anbieten.

Datenschutz ist damit Teil der Produktqualität, nicht nur ein juristischer Anhang.

### Barrierefreiheit und Inklusion

Auch Schulapps sollten inklusiv nutzbar sein. Wichtige Aspekte: ausreichender Kontrast, konsistente Fokusführung, klare Sprache, Redundanz bei visuellen Codes (nicht nur Farbe).

Für Karten bedeutet das zusätzlich, dass wichtige Zustände textlich begleitet werden müssen, damit Informationen nicht allein über Markerfarbe transportiert werden.

### Performance, Energie und thermische Last

Performance ist auf Mobilgeräten nicht nur von einem Faktor abhängig: Reaktionsgeschwindigkeit, Speicherverbrauch, Energiebedarf, stabile Gerätetemperatur.

Standortstream + Karte + Netzwerkzugriffe können diese Faktoren schnell verschlechtern. Deshalb sind Drosselung, gezielte Neuberechnungen und sauberes Subscription-Management zentrale architektonische Maßnahmen.

### Wartbarkeit und technische Schulden

Langfristig entscheidet nicht nur, ob eine Version funktioniert, sondern wie änderbar sie bleibt. Wartbarkeit hängt u. a. ab von: Dateigröße und Verantwortungszuschnitt, Konsistenz der Benennung, Dokumentation von Entscheidungen, Testabdeckung kritischer Pfade.

GeoQuest zeigt hier zwei Seiten: positiv: klare Funktionsgrenzen zwischen vielen Screens, kritisch: hohe Komplexität im MapTab, die mittelfristig aufgeteilt werden sollte.

### Qualitätsmodell für GeoQuest

Ein passendes Qualitätsmodell für die Frontend-Schicht kombiniert drei Ebenen: Funktionale Qualität: korrekte Abläufe bei Normalbetrieb, Robustheitsqualität: sinnvolle Reaktion auf Fehler/Randfälle, gefühlte Qualität: Verständlichkeit, Vertrauen, Motivation.

Viele Projekte fokussieren nur Ebene 1. In standortbasierten Apps entscheidet jedoch vor allem Ebene 2 über reale Einsatzfähigkeit.

### Theorie-Praxis-Abgleich

Die theoretischen Prinzipien decken sich mit den praktischen Beobachtungen im Projekt: klare Zustandsmodelle reduzieren Fehler, transparente Fehlermeldungen senken Abbruchrate, faire Regeln brauchen sichtbare Kommunikation, modulare Architektur beschleunigt Änderungen.

Abweichungen zeigten sich vor allem dort, wo praktische Kompromisse nötig waren, etwa bei der Größe einzelner Dateien oder bei noch nicht vollständig automatisierter Testabdeckung.

### Ausblick auf Weiterentwicklung

Aus theoretischer und praktischer Sicht sind für die nächste Ausbaustufe vor allem diese Punkte sinnvoll: eine stärkere Zerlegung des Map-Moduls in getrennte Komponenten (Tracking, Anti-Cheat, Overlay, Bewertung), zusätzliche Widget- und Golden-Tests für kritische Zustände, eine optionale Offline-Zwischenspeicherung mit sauberem Retry, bessere Accessibility-Prüfungen sowie analytische Auswertungen für Lernfortschritt und Spielbalance.

### Gesamtschluss

Die Frontend-Teilaufgabe von GeoQuest zeigt für mich vor allem eines: Eine gute mobile App entsteht nicht durch ein schönes UI allein, sondern durch das Zusammenspiel aus Nutzerführung, klarer Architektur und sauberem Zustandsmanagement. Der aktuelle Stand ist im Schulkontext nutzbar und lässt sich sinnvoll erweitern.

Gleichzeitig wurde im Projekt deutlich, dass das Frontend bei standortbasierten Anwendungen für die Regeln wichtig ist. Regeln für Fairness, Zeit und Freigabe leben nicht nur im Backend, sondern direkt in der Oberfläche. Genau diese Sicht hat meine Umsetzung geprägt.

## Kompakter technischer Anhang

### End-to-End-Spielerfluss (gekürzt)

Damit die Umsetzung nachvollziehbar bleibt, fasse ich den realen Ablauf aus Spielersicht kurz zusammen: App startet, lädt Firebase und lokale Einstellungen, Beim ersten Start erscheint das Onboarding, Danach erfolgt die Rollenwahl (Spieler oder Admin), Spieler melden sich an oder registrieren sich, Über Dashboard und Route startet die nächste Station, In der Karte laufen Distanz-, Zeit- und Fairnessprüfung parallel, Aufgabe wird im Radius oder per QR freigeschaltet, Punkte werden vergeben und transaktionssicher gespeichert, Fortschritt/Ranking werden aktualisiert.

Dieser Flow war die Basis für meine manuellen Abnahmetests.

### Datenmodell auf einen Blick

Für die Frontend-Perspektive waren diese Datenbereiche entscheidend: Users/{uid} für Profil, Punkte und Spielfortschritt, Hunts/{huntId} als Spielrahmen, Hunts/{huntId}/Stadions/{stadionId} für Aufgaben/Stationen, PlayerLocation/{uid} für Live-Position und Admin-Ansicht.

Wichtig war mir dabei: Das UI schreibt nur die Felder, die es wirklich braucht. Das reduziert Fehler und hält die Logik verständlich.

### Warum die Architektur so geschnitten ist

Die App trennt Auth, Navigation, Kartenlogik und Fortschrittsanzeige bewusst voneinander. Das hat mir in der Umsetzung viel geholfen: Änderungen am Login haben die Kartenlogik nicht gebrochen, Neue UI-Texte konnten ohne Eingriff in Firestore-Zugriffe angepasst werden, Fehler ließen sich schneller eingrenzen, weil jede Schicht einen klaren Zweck hatte.

### Was im Betrieb gut funktioniert hat

Im Feldtest haben vor allem drei Dinge überzeugt: Der Einstieg war für neue Nutzer schnell verständlich, Die Aufgabenfreigabe war robust, weil Radius und QR kombiniert wurden, Lehrkräfte konnten einzelne Spieler über die Admin-Karte verlässlich verfolgen.

Besonders hilfreich war, dass wichtige Zustände immer sichtbar waren (Distanz, Countdown, Sperrhinweise).

### Wo es noch hakt

Trotz stabilem Stand gibt es klare Grenzen: Die Kartenlogik ist noch zu zentral in einer großen Komponente gebündelt, Automatisierte UI-Tests sind vorhanden, aber noch nicht tief genug, Offline-Verhalten ist nur teilweise abgedeckt, Einige Accessibility-Details sind noch ausbaufähig.

Diese Punkte sind keine Showstopper, aber sie begrenzen die Wartbarkeit im nächsten Ausbauschritt.

### Konkreter Refactoring-Pfad

Für die nächste Iteration ist ein kompakter, realistischer Plan sinnvoll. Konkret sollte MapTab in kleinere Verantwortungsbereiche wie Tracking, Freischaltung, Bewertung und Overlay aufgeteilt werden. Zusätzlich sollten Firestore-Schreibzugriffe stärker in Services gebündelt, ein einheitliches Fehlermodell statt verteilter Einzelmeldungen umgesetzt, mehr Widget-Tests für kritische Zustandswechsel ergänzt und gezielte Accessibility-Checks für Labels, Fokus und Touch-Ziele durchgeführt werden.

Damit sinkt technische Komplexität, ohne den laufenden Betrieb zu riskieren.

### Kompakter Screen-Überblick

Die lange Screen-by-Screen-Dokumentation wurde bewusst eingekürzt. Hier bleibt der technische Kern je Screen erhalten: SplashScreen: Initialisierung puffern und stabilen Zielscreen bestimmen, OnboardingFlow: Erstnutzern Regeln in vier kurzen Schritten erklären, RoleSelectScreen: Frühe Trennung von Spieler- und Admin-Pfad, SignInEmailScreen: Niedrigschwelliger Einstieg in Login/Registrierung, CreateAccountScreen: Lokale Validierung vor Netzwerkzugriff, LoginScreen: Username/E-Mail-Login mit klaren Fehlermeldungen, StartHuntScreen: Motivierender Start inklusive Spielkontext, StartRouteScreen: Nächste Station, Distanz, Zeit und Aktion auf einen Blick, HomeScreen: Einheitliche Navigation zwischen Map, Progress und Menü, MapTab: Live-Standort, Radiuscheck, QR-Fallback und Anti-Cheat, QuizScreen: Bewertungsflow mit sauberer Punktepersistenz, ProgressTab: Fortschritt, Ranking und Zwischenziele sichtbar machen, MenuTab: Sekundäre Aktionen ohne Störung des Spielkerns, Settings/Privacy/Imprint: Transparenz, Rechtliches und Konfiguration, AdminMapScreen: Betriebsansicht für Lehrkräfte mit Live-Tracking.

Im Projektalltag war diese klare Rollenverteilung der Screens entscheidend, weil Fehler dadurch schneller lokalisierbar waren.

### Drei konkrete Praxissituationen

Um die Entscheidungslinien der Frontend-Umsetzung greifbar zu machen, hier drei typische Situationen aus Tests und Schulbetrieb:

GPS springt am Schulhofrand.
Ein Schüler stand sichtbar nahe an der Station, die Distanz sprang aber kurzfristig über den Radius. Ohne Gegenmassnahme führt das zu Frust. In der App half der kombinierte Ansatz aus Distanzprüfung und QR-Fallback. So bleibt die Regel fair, ohne Spieler bei GPS-Ausreissern unnötig zu blockieren.

Instabile Datenverbindung während der Bewertung.
Beim Speichern einer Aufgabe gab es vereinzelt kurze Timeouts. Wichtig war deshalb, dass der Nutzer nicht im Unklaren bleibt. Statt still zu scheitern, zeigt die App einen klaren Fehlerhinweis und erlaubt einen erneuten Versuch. In der Praxis hat genau das Supportfragen reduziert.

Hohe Dynamik bei vielen gleichzeitig aktiven Spielern.
Im Parallelbetrieb wollten Lehrkräfte schnell sehen, ob einzelne Spieler unterwegs sind oder festhängen. Die Admin-Karte war hier der zentrale Mehrwert: nicht perfekt detailreich, aber schnell interpretierbar. Diese Betriebsansicht hat im Einsatz mehr geholfen als zusätzliche theoretische Kennzahlen.

### Beobachtungen aus der Umsetzung

Rückblickend waren für mich vor allem diese Punkte entscheidend: Kurze, direkte Texte in kritischen Momenten wirken besser als lange Erklärungen, Sichtbare Systemzustände schaffen Vertrauen, selbst wenn mal etwas langsam reagiert, Eine klare Navigation spart mehr Zeit als jede spät nachgerüstete Hilfeseite, Technische Sauberkeit im Zustandshandling zahlt sich unmittelbar im UI-Verhalten aus.

Ich habe ausserdem gemerkt, dass vermeintlich "kleine" Frontend-Entscheidungen grosse Auswirkungen haben. Ein klar benannter Button oder ein gut platzierter Hinweis kann über Spielfluss und Motivation entscheiden.

### Didaktische Eignung im Schulkontext

Für den Unterricht war wichtig, dass die App nicht nur funktioniert, sondern sich klar anfühlt. Genau das hat in der Praxis funktioniert: einfache Navigation, nachvollziehbare Regeln, transparente Rückmeldungen, motivierender Fortschritt.

Die Kombination aus Spielmechanik und klarer Oberfläche macht GeoQuest aus meiner Sicht gut im Schulalltag einsetzbar.

### Kurzfazit des Anhangs

Die ausführlichen Detailblöcke wurden hier bewusst komprimiert. Inhaltlich bleibt der Kern erhalten: Das Frontend steuert nicht nur Oberfläche, sondern einen großen Teil der Fachlogik rund um Fairness, Fortschritt und Betrieb.
