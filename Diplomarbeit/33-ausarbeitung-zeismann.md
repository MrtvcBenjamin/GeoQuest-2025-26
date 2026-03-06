# Teilaufgabe Schüler Zeismann
\textauthor{Tobias Zeismann}

## Praktische Arbeit

### Einordnung der Teilaufgabe

Im Gesamtprojekt **GeoQuest** war ich für die Frontend-Entwicklung verantwortlich. Ziel war eine mobile Anwendung, die eine schulische Schnitzeljagd technisch zuverlässig abbildet und dabei für unterschiedliche Nutzergruppen verständlich bleibt. Das Frontend sollte deshalb nicht nur gut aussehen, sondern im Alltag wirklich stabil funktionieren:

- klare Benutzerführung für Erstnutzer,
- stabile Verarbeitung von GPS- und Firestore-Daten,
- faire Spielmechanik (Anti-Cheat, Standortprüfung, Zeitbonus),
- robuste Fehlerrückmeldung,
- modulare Erweiterbarkeit für Folgeversionen.

Die inhaltliche Herausforderung war, dass in GeoQuest laufend neue Ereignisse eintreffen: Positionsupdates, Zeitabläufe, Session-Status, Firestore-Schreibvorgänge und Nutzeraktionen auf mehreren Screens. Die Oberfläche ist damit nicht nur Darstellungsfläche, sondern Teil der eigentlichen Spiellogik.

### Zielsetzung und Abnahmekriterien

Für die Frontend-Teilaufgabe wurden vor der Implementierung konkrete Abnahmekriterien definiert. Ein Frontend galt nur dann als "fertig", wenn die folgenden Kernpfade unter realistischen Bedingungen funktionieren:

1. App-Start inklusive Splash, Onboarding und Rollenwahl.
2. Registrierung/Anmeldung mit E-Mail und Passwort.
3. Spielstart über Dashboard und Route.
4. Live-Kartenansicht mit Standortstream.
5. Freischaltung der Aufgaben nur im Stationsradius oder per QR-Code.
6. Punktevergabe inklusive Zeitbonus und Fortschrittspersistenz.
7. Rankinganzeige im Progress-Tab.
8. Admin-Karte zur Live-Beobachtung der Teams.

Die Qualität wurde zusätzlich über nicht-funktionale Kriterien abgesichert: kurze Reaktionszeiten, nachvollziehbare Fehlermeldungen, konsistente Navigation und saubere Trennung zwischen UI, Zustandslogik und Datenzugriff.

### Projektkontext und technischer Rahmen

Die App wurde mit Flutter und Dart umgesetzt. Flutter erlaubt eine gemeinsame Codebasis für mehrere Plattformen und passt gut zu einem UI-lastigen Projekt mit vielen Zustandsänderungen [@flutterDocs]. Der Einstiegspunkt liegt in `application/lib/main.dart`. Dort werden Firebase und App-Einstellungen initialisiert, bevor die UI startet:

- `Firebase.initializeApp(...)` lädt die Plattformkonfiguration,
- auf Web wird `Persistence.LOCAL` aktiviert,
- `AppSettings.load()` lädt Theme, Sprache, Login-Modus und Onboarding-Status.

Als Backend-Dienste wurden Firebase Authentication und Cloud Firestore eingesetzt [@firebaseAuthDocs; @firestoreDocs]. Die Kartenansicht basiert auf OpenStreetMap-Daten über `flutter_map` [@flutterMapDocs; @openstreetmapCopyright]. Die Standortdaten kommen über `geolocator` [@geolocatorPkg].

> "Build apps for any screen." [@flutterWebsite]

Diese kurze Aussage aus der Flutter-Dokumentation beschreibt genau den technischen Kern unseres Vorgehens: eine gemeinsame UI-Codebasis mit konsistentem Verhalten.

### Entwicklungsumgebung und Arbeitsprozess

Die Entwicklung erfolgte im Team über Git-Branches mit regelmäßigen Merges. Für das Frontend war ein enger Integrationsrhythmus wichtig, weil viele Features dateiübergreifend arbeiten:

- `main.dart` und globale Settings,
- Auth-Screens,
- Home-Navigation,
- Map-Logik,
- Progress- und Admin-Auswertung.

Zusätzlich wurden frühe Funktionsstände auf echten Geräten geprüft, da GPS- und Netzverhalten im Emulator nur eingeschränkt die Realität abbilden. Der Testansatz kombinierte daher:

- schnelle Iteration im Simulator,
- Feldtests für Standort- und Bewegungslogik,
- Integrationstest für App-Boot (`integration_test/app_flow_test.dart`).

### Aufbau der Frontend-Architektur

Die Architektur trennt die App in funktionale Schichten:

- **Start- und Auth-Flow**: Splash, Onboarding, Rollenwahl, Login, Registrierung.
- **Spiel-Flow**: Dashboard (`StartHuntScreen`, `StartRouteScreen`), Map, Quiz.
- **Meta-Flow**: Progress, Menü, Datenschutz/Impressum, Einstellungen.
- **Admin-Flow**: Admin-Karte mit Live-Tracking.

Wesentliche zentrale Bausteine:

- `AppSettings` (persistente UI- und Session-Einstellungen via `SharedPreferences`),
- `AppNav` (globale Navigation/Map-Sperrzustände via `ValueNotifier`),
- `GameState` (reaktiver Zustand für nächste Station, Distanz, Zeit),
- Firestore-Collections `Users`, `PlayerLocation`, `Hunts`, `Hunts/{huntId}/Stadions`.

Der Vorteil dieser Trennung ist, dass die Map-Logik unabhängig vom Login-Layout weiterentwickelt werden kann und umgekehrt.

### Splash-Screen und intelligentes Routing

Der Splash-Screen (`splash_screen.dart`) ist nicht nur visuell, sondern logisch relevant. Nach einer kurzen Initialphase (1,5 Sekunden) wird der nächste Zielscreen anhand dreier Zustände bestimmt:

- Ist bereits ein User eingeloggt?
- Ist Onboarding bereits abgeschlossen?
- War der zuletzt gespeicherte Modus Spieler oder Admin?

Je nach Zustand navigiert der Code direkt zu `HomeScreen`, `AdminMapScreen`, `OnboardingFlow` oder `RoleSelectScreen`. Dadurch entsteht ein deterministischer Startprozess ohne Sackgassen.

![GeoQuest-Branding im Frontend-Einstieg\label{fig:zeismann_logo_frontend}](img/logo.png){width=32%}

### Onboarding als UX-Filter vor der Anmeldung

Das Onboarding (`onboarding_flow.dart`) besteht aus vier klaren Seiten:

1. Einführung in das Spielprinzip,
2. Erklärung der zufälligen Stationsreihenfolge,
3. Erklärung des Aufgabenformats,
4. Fairness-Regeln (Standortnähe, Geschwindigkeitsprüfung).

Jede Seite besitzt genau eine Primäraktion (`Weiter` bzw. `Los gehts!`). Die lineare Struktur verhindert Überforderung beim Erstkontakt. Nach dem letzten Schritt wird `onboarding_done` in den Einstellungen gespeichert.

Dieses Muster folgt dem UX-Prinzip "Progressive Disclosure": nur die Informationen zeigen, die für den nächsten Schritt notwendig sind [@normanDesign].

### Rollenwahl und Benutzergruppen

`role_select_screen.dart` trennt den Einstieg in zwei Pfade:

- **Admin**: Anmeldung nur mit freigegebener Lehrkräfte-E-Mail,
- **Spieler**: Registrierung oder Login für Teilnehmende.

Die Rollenwahl wird nicht nur visuell dargestellt, sondern in `AppSettings.loginMode` persistiert. Dadurch kann der Splash-Screen bei erneutem App-Start korrekt zurück in den letzten Modus navigieren.

### Authentifizierung und Kontolebenszyklus

Der Auth-Bereich besteht aus mehreren Screens:

- `SignInEmailScreen` für den Einstieg mit E-Mail,
- `CreateAccountScreen` für Registrierung,
- `LoginScreen` für Anmeldung,
- `ChangePasswordScreen` für Passwort-Reset.

#### Registrierung

In `CreateAccountScreen` werden Username, E-Mail und Passwort validiert:

- Username-RegEx: `^[A-Za-z0-9._-]{3,24}$`,
- E-Mail-RegEx für Basisformat,
- Passwortlänge mindestens 6 Zeichen.

Danach erfolgt:

1. Prüfung auf eindeutigen Username (`Users.UsernameLower`),
2. Anlage des Firebase-Auth-Kontos,
3. Versand einer Verifizierungs-E-Mail,
4. Schreiben des Benutzerprofils in `Users/{uid}`.

Ohne verifizierte E-Mail wird im Login kein dauerhafter Einstieg zugelassen. Dieser Mechanismus reduziert Fake-Accounts und verbessert die Nachvollziehbarkeit im Schulbetrieb [@firebaseAuthDocs].

#### Anmeldung

`LoginScreen` unterstützt Username- und E-Mail-Login. Bei Username-Login wird zuerst die E-Mail aus Firestore aufgelöst. Zusätzlich gibt es einen Legacy-Fallback mit der Domain `geoquest.local` für ältere Testkonten.

Fehler werden benutzerorientiert behandelt (z. B. "Keine Internetverbindung" statt roher SDK-Fehlercodes). Das erhöht die Nutzbarkeit deutlich.

#### Admin-Freigabe

Die Klasse `admin_access.dart` enthält freigegebene Admin-E-Mails und Logik zur Namensnormalisierung. Nach erfolgreichem Firebase-Login prüft die App, ob die E-Mail in der Admin-Liste liegt. Bei negativem Ergebnis wird die Sitzung sofort beendet.

Damit wird ein zweistufiges Modell umgesetzt:

- technische Authentifizierung durch Firebase,
- fachliche Autorisierung durch App-Regeln.

### Home-Shell und Tab-Architektur

`home_screen.dart` bildet die zentrale Spiel-Shell mit vier Tabs:

1. Dashboard,
2. Karte,
3. Fortschritt,
4. Menü.

Technisch wurde `IndexedStack` verwendet, damit Tab-Zustände erhalten bleiben. Das vermeidet unnötige Neuinitialisierung beim Wechsel.

Eine wichtige Besonderheit ist der globale Sperrmechanismus: Wenn `AppNav.mapBlocked` aktiv ist (Anti-Cheat-Sperre), wird der Benutzer automatisch auf den Karten-Tab zurückgeführt. So kann die Sperrlogik nicht durch Tab-Wechsel umgangen werden.

### Dashboard-Flow: Hunt-Start und nächste Route

Der Dashboard-Pfad besteht aus:

- `StartHuntScreen`: motivierender Einstieg mit Hinweis auf Zeitbonus,
- `StartRouteScreen`: nächste Station, Distanz, Punkte und verbleibende Zeit.

In `StartRouteScreen` werden Daten aus Firestore und `GameState` zusammengeführt. Der Screen zeigt u. a.:

- `nextStationName`,
- `nextStationDistanceMeters`,
- `nextStationPoints`,
- `remainingTime`.

Beim ersten Start ruft der Button `GameState.startHunt()` auf und aktiviert `AppNav.stationActive`. Danach wird direkt auf die Karte gewechselt.

### Reaktiver Kern über `GameState`

`game_state.dart` ist der zentrale Datenvermittler zwischen Firestore und UI.

Wichtige ValueNotifier:

- `huntStarted`,
- `nextStationName`,
- `nextStationDistanceMeters`,
- `nextStationPoints`,
- `remainingTime`.

Datenquellen:

- `Hunts/{huntId}` (z. B. `durationMinutes`),
- `Hunts/{huntId}/Stadions` (Titel, Punkte, Standort),
- `PlayerLocation/{uid}` (aktuelle Position, Index, Startzeit),
- `Users/{uid}` (persönliche Reihenfolge, Fortschritt).

#### Deterministische Stationsreihenfolge

Um Menschenansammlungen an einzelnen Stationen zu reduzieren, wird für jeden Benutzer eine reproduzierbare, aber individuelle Reihenfolge berechnet. Dazu werden Stations-IDs mit einem Seed aus `uid:huntId` geshuffelt und in `Users.StationOrderByHunt` gespeichert.

Diese Lösung erfüllt zwei Ziele gleichzeitig:

- faire Verteilung im Gelände,
- stabile Reihenfolge über App-Neustarts hinweg.

### Kartenansicht als zentrale Spielfläche

Die Kartenansicht ist in `map_tab.dart` implementiert und umfasst über 1200 Zeilen, weil dort mehrere komplexe Anforderungen zusammenlaufen:

- Live-Position,
- Distanzberechnung zur nächsten Station,
- Radiusprüfung,
- QR-Freischaltung,
- Anti-Cheat,
- Zeitlogik,
- Punktevergabe,
- Fortschrittsspeicherung.

Die Karte basiert auf `flutter_map` mit OSM-Tiles. Zusätzlich wird ein `MapController` eingesetzt, um den initialen Kartenausschnitt dynamisch zu setzen:

- nur Spielerposition, wenn keine aktive Station,
- Bounds-Spieler-zu-Station, wenn eine Station aktiv ist.

### Standortstream und Berechtigungslogik

`_startLocationStream()` prüft vor dem Start:

1. Sind Standortdienste aktiv?
2. Liegen Berechtigungen vor?

Dann startet `Geolocator.getPositionStream(...)` mit:

- hoher Genauigkeit (`best`),
- `distanceFilter: 2` Meter.

Bei jedem Standortupdate passieren drei Dinge:

- UI-Zustand aktualisieren,
- Position gedrosselt in Firestore schreiben (`_dbWriteCooldown = 10s`),
- Spielregeln prüfen (Radius, Geschwindigkeit, Zeitschätzung).

Diese Drosselung reduziert Firestore-Last und Stromverbrauch deutlich [@firestoreDocs].

### Radiusprüfung und Aufgabenfreigabe

Eine Aufgabe darf nur gelöst werden, wenn der Benutzer die Station erreicht hat oder den passenden QR-Code scannt. Für die räumliche Prüfung wird der Abstand Spieler-zu-Station berechnet und gegen den Schwellwert verglichen:

- `_stationRadiusMeters = 15`.

Wird der Radius unterschritten, wechselt der UI-Zustand auf `MapUiState.inRadius`, und der Button "Zur Aufgabenbewertung" wird freigeschaltet.

Dieser Radius ist ein praxisbasierter Kompromiss: zu klein führt bei GPS-Schwankungen zu Frust, zu groß reduziert Fairness.

### QR-Validierung als zweiter Freischaltkanal

In manchen Situationen (GPS drift, ungünstige Umgebung) reicht Radius allein nicht aus. Deshalb wurde eine QR-Freischaltung ergänzt:

- `QrScanScreen` scannt über `mobile_scanner`,
- der erkannte Wert wird normalisiert (trim + lowercase),
- Vergleich mit erwartetem Stationscode.

Bei Erfolg setzt die App `_qrUnlockedForStation = true`, wodurch die Aufgabenbewertung ebenfalls gestartet werden kann.

![QR-Scan-Ansicht als Teil des Frontend-Flows\label{fig:zeismann_qr_frontend}](img/ios_qr_webapp.png){width=62%}

### Anti-Cheat-Mechanik (Geschwindigkeit)

Ein zentrales Qualitätsziel war Fairness. Die App erkennt zu schnelle Bewegung und behandelt diese in Eskalationsstufen:

- Warnschwelle: `15 km/h` (`_speedWarnThresholdMps`),
- Mindestdauer der Überschreitung: 3 Sekunden,
- Warnungs-Cooldown: 12 Sekunden,
- nach 3 Warnungen: 5 Minuten Sperre (`_blockSeconds = 300`).

Zusätzlich filtert `_isLikelyLocationJump(...)` unplausible GPS-Sprünge (z. B. hohe Genauigkeitsfehler), damit keine falschen Cheating-Detektionen ausgelöst werden.

Bei Sperre passiert Folgendes:

1. `AppNav.mapBlocked = true`,
2. Abzug von 2 Punkten in Firestore,
3. Countdown-Dialog mit verbleibender Sperrzeit,
4. nach Ablauf Entsperrdialog und Rückkehr in Normalzustand.

Diese Umsetzung macht Regeln transparent und verhindert gleichzeitige Ausnutzung durch Navigationstricks.

### Zeitmodell und Bonuspunkte

Während einer aktiven Station berechnet die App eine verbleibende Richtzeit. Diese basiert auf Distanz und einem Puffer (5/7/10 Minuten abhängig von Streckenlänge). Das Ergebnis wird auf volle Minuten gerundet und als Countdown angezeigt.

Beim Abschließen einer Station wird entschieden:

- `inTime == true` -> Zeitbonus `+2.0` Punkte,
- sonst kein Bonus.

Neben Gesamtpunkten werden stationsweise Details gespeichert:

- `TeacherPointsByStation`,
- `TimeBonusByStation`,
- `TimeSecondsByStation`.

Damit ist die Bewertung später nachvollziehbar und auswertbar.

### Aufgabenbewertung und Punktepersistenz

Die fachliche Bewertung erfolgt über `QuizIntroScreen` und `QuizScreen`:

- Lehrperson trägt Punkte von `0.0` bis `10.0` ein,
- Werte werden validiert (maximal eine Nachkommastelle),
- Rückgabe der Punktzahl an `MapTab`.

`_awardPointsForCurrentStadion(...)` führt dann eine Firestore-Transaktion aus. Dadurch werden race conditions bei parallelen Updates vermieden [@firestoreDocs]. Aktualisiert werden u. a.:

- `Points`,
- `TeacherPointsTotal`,
- `TimeBonusPoints`,
- `SolvedCount`,
- `CompletedStadions`,
- `TotalTimeSeconds` und `TotalTimeText`.

Anschließend speichert `_saveProgress(...)` den neuen Stationsindex in `PlayerLocation` und `Users.CurrentStadionIndexByHunt`.

### Fortschrittsanzeige und Ranking

`progress_tab.dart` liest alle User-Dokumente aus `Users` und erstellt ein Ranking:

- primär sortiert nach Punkten,
- sekundär nach gelösten Aufgaben.

Zusätzlich werden angezeigt:

- eigene Gesamtpunkte,
- Zeitbonusanteil,
- gelöste Aufgaben,
- Gesamtzeit.

Die Kombination aus persönlichem Fortschritt und Leaderboard wirkt motivierend, solange die Rangliste stabil und nachvollziehbar bleibt [@nielsen1994].

### Admin-Karte für Lehrkräfte

`admin_map_screen.dart` ist ein eigener Frontend-Modus und zeigt Live-Positionen aller aktiven Spieler.

Funktionen:

- Stream auf `Users` und `PlayerLocation`,
- Filterung von Admin-Konten,
- Marker pro Spieler,
- Suchfeld nach Name/E-Mail,
- Detailsheet mit nächster Station und Stationsanzahl,
- Fokus-Funktion auf gewählten Spieler.

Für die Anzeige der nächsten Station werden entweder die persönliche Reihenfolge (`StationOrderByHunt`) oder die allgemeine Hunt-Reihenfolge verwendet. Diese Logik stellt sicher, dass die Admin-Ansicht mit dem tatsächlichen Spielverlauf übereinstimmt.

### Menü, Einstellungen und rechtliche Screens

`menu_tab.dart` kapselt den Meta-Bereich:

- Einstellungen (Theme + Sprache),
- Datenschutz,
- Impressum,
- Logout.

Die Einstellungen nutzen `AppSettings` und sind persistent. Unterstützt werden Deutsch/Englisch sowie Hell/Dunkel-Modus.

Der Datenschutz-Screen erklärt verständlich:

- welche Daten verarbeitet werden,
- zu welchem Zweck,
- wie lange gespeichert wird,
- welche Rechte Nutzer haben.

Damit wird Datenschutz nicht nur formal, sondern als Teil der UX umgesetzt [@gdpr].

### Internationalisierung und Sprachumschaltung

Die App besitzt zwei Ebenen der Mehrsprachigkeit:

- globale Flutter-Lokalisierung in `main.dart` (`supportedLocales`),
- projektinterne Kurzfunktion `tr(de, en)` für schnelle Textumschaltung.

Zusätzlich existieren ARB-Dateien (`app_de.arb`, `app_en.arb`). Die Sprachauswahl wird in `SharedPreferences` gespeichert, sodass der Nutzer nach Neustart in der gewählten Sprache bleibt.

### Fehlerbehandlung und Recovery-Strategien

Aus den Feldtests ergaben sich typische Fehlerbilder:

- GPS ausgeschaltet,
- Permission verweigert,
- instabile Internetverbindung,
- auslaufende Session,
- verzögerte Firestore-Antworten.

Die Frontend-Strategie arbeitet mit drei Ebenen:

1. **Prävention**: Vorabprüfungen und Guard-Logik.
2. **Kommunikation**: klare Hinweise statt technischer Rohtexte.
3. **Recovery**: Retry-Buttons, sichere Rücksprünge, erneute Berechtigungsabfrage.

Ein konkretes Beispiel ist `MapTab`: Kann die Stationenliste nicht geladen werden, bleibt die Oberfläche bedienbar und bietet "Erneut versuchen" anstatt eines stillen Abbruchs.

### Performance-Entscheidungen

Mehrere Maßnahmen wurden bewusst für mobile Performance eingebaut:

- Firestore-Write-Throttling der Standortdaten (10 Sekunden),
- Vermeidung unnötiger Rebuilds durch gezielte `setState`-Blöcke,
- kontrolliertes Start/Stop von Standortstreams beim Tabwechsel,
- Abbruch und Cleanup von Timern/Subscriptions in `dispose()`.

Gerade bei Kartenanwendungen ist diese Disziplin wichtig, weil häufige Rebuilds und permanente Streams sonst direkt auf Akku und UI-Flüssigkeit schlagen [@flutterPerf].

### Sicherheits- und Datenschutzaspekte der Implementierung

Sicherheitsrelevante Punkte im Frontend:

- keine sensiblen Klartextdaten lokal persistieren,
- Zugriff auf Spielzustand an Auth-Session koppeln,
- Admin-Routen nur mit zusätzlicher E-Mail-Autorisierung,
- reduzierte Fehlermeldungen ohne interne Systemdetails.

Datenschutzrelevant ist vor allem die Standortverarbeitung. Diese wird funktional begründet (Stationserkennung/Fairness) und auf den Spielkontext begrenzt. Das entspricht dem Prinzip der Datenminimierung [@gdpr].

### Teststrategie und Qualitätssicherung

Die QS bestand aus drei Bausteinen:

1. **Manuelle End-to-End-Tests** auf Emulator und realen Geräten.
2. **Regressionsläufe** für kritische Flows (Login, Map, Fortschritt).
3. **Integrationstest**: App-Boot und Sichtbarkeit zentraler Marken-UI.

Typische Testfälle:

- neuer Benutzer registriert sich und verifiziert E-Mail,
- Benutzer startet Hunt und erhält individuelle Reihenfolge,
- Station wird nur im Radius oder per QR freigeschaltet,
- Anti-Cheat-Sperre setzt korrekt ein und endet nach Countdown,
- Punkte und Zeitbonus werden transaktionssicher gespeichert,
- Admin sieht Live-Standorte ohne Admin-Konten in der Liste.

Zusätzlich wurden Dark-/Light-Mode und Deutsch/Englisch visuell geprüft, um abgeschnittene Texte und Kontrastprobleme früh zu erkennen.

### Vergleich von Ziel und Ergebnis

Die ursprünglichen Frontend-Ziele wurden im Wesentlichen erreicht:

- geführter Einstieg: umgesetzt,
- stabile Login-/Session-Logik: umgesetzt,
- Map-Flow mit Radius und QR: umgesetzt,
- faire Spielmechanik mit Sanktionen: umgesetzt,
- Fortschritt und Ranking: umgesetzt,
- Admin-Monitoring: umgesetzt.

Offene Verbesserungsfelder:

- mehr automatisierte Widget- und Golden-Tests,
- noch feinere Offline-Strategie,
- stärkere Entkopplung großer Map-Tab-Logik in Subkomponenten.

### Reflexion der praktischen Umsetzung

Die größte technische Erkenntnis war, dass bei standortbasierten Apps nicht eine einzelne Funktion über Erfolg entscheidet, sondern das Zusammenspiel vieler kleiner Schutzmechanismen. Besonders wichtig waren:

- defensive GPS-Verarbeitung,
- robuste Zustandsübergänge,
- transaktionssichere Punktevergabe,
- klare Nutzerkommunikation in Fehlersituationen.

Ein zweiter zentraler Punkt war die Wartbarkeit. Große Dateien wie `map_tab.dart` funktionieren funktional, erhöhen aber auf Dauer Review- und Änderungsaufwand. Für Folgeversionen ist eine stärkere modulare Zerlegung sinnvoll.

### Frontend-Abbildungen im Dokument

Zusätzlich zu den bestehenden Projektgrafiken wurden Frontend-Abbildungen bewusst integriert, damit die schriftliche Arbeit nicht nur Architektur und Theorie, sondern auch die konkrete Benutzeroberfläche zeigt.

![Projektorganisation im Kontext des Frontend-Entwicklungsprozesses\label{fig:zeismann_projektorganisation}](img/projektorganisation.png){width=80%}

![Anwendungsfallübersicht mit Bezug auf Frontend-Interaktionen\label{fig:zeismann_usecase}](img/anwendungsfalldiagramm.png){width=80%}

![Auswertungsbeispiel aus der Entwicklungsphase\label{fig:zeismann_graph}](img/graph.png){width=70%}

#### Geplante App-Screenshots (hier einfügen)

Die folgenden Screenshots sollten im finalen PDF ergänzt werden. Die Position ist hier bewusst definiert, damit der Frontend-Flow visuell vollständig dokumentiert ist.

- Nach Abschnitt **Splash-Screen und intelligentes Routing**:
  `SCREENSHOT EINFUEGEN: SplashScreen mit Logo und Ladeanimation`
- Nach Abschnitt **Onboarding als UX-Filter vor der Anmeldung**:
  `SCREENSHOT EINFUEGEN: Onboarding-Seite 1 (Willkommen) und Seite 4 (Fairness-Regeln)`
- Nach Abschnitt **Authentifizierung und Kontolebenszyklus**:
  `SCREENSHOT EINFUEGEN: LoginScreen mit Username/E-Mail und Passwortfeld`
- Nach Abschnitt **Dashboard-Flow: Hunt-Start und nächste Route**:
  `SCREENSHOT EINFUEGEN: StartHuntScreen und StartRouteScreen`
- Nach Abschnitt **Kartenansicht als zentrale Spielfläche**:
  `SCREENSHOT EINFUEGEN: MapTab mit Spielerposition und Stationsmarker`
- Nach Abschnitt **Anti-Cheat-Mechanik (Geschwindigkeit)**:
  `SCREENSHOT EINFUEGEN: Warnungsdialog oder Sperr-Countdown`
- Nach Abschnitt **Fortschrittsanzeige und Ranking**:
  `SCREENSHOT EINFUEGEN: ProgressTab mit Rankingliste`
- Nach Abschnitt **Admin-Karte für Lehrkräfte**:
  `SCREENSHOT EINFUEGEN: AdminMapScreen mit mehreren Spielern`
- Nach Abschnitt **Menü, Einstellungen und rechtliche Screens**:
  `SCREENSHOT EINFUEGEN: Einstellungen (Theme/Sprache) oder Datenschutzansicht`

Hinweis: Für ein sauberes Druckbild sollten alle App-Screenshots im selben Seitenverhältnis (z. B. iPhone-Portrait) und mit gleicher Breite im Dokument eingebunden werden.

### Ergebnis der praktischen Teilaufgabe

Die Frontend-Teilaufgabe liefert ein funktionsfähiges und in realen Tests belastbares System. Benutzer werden von der ersten App-Öffnung bis zum Abschluss von Stationen geführt, erhalten klare Rückmeldungen und sehen ihren Fortschritt transparent. Lehrkräfte erhalten mit der Admin-Karte eine operative Sicht auf den Live-Betrieb.

Aus technischer Sicht ist die Umsetzung nicht nur ein Prototyp, sondern eine tragfähige Basis für weitere Ausbaustufen wie neue Spielmodi, komplexere Aufgabenformate oder detaillierte Auswertungen.

## Theoretischer Teil - Frontend der Schnitzeljagd-App "GeoQuest"

### Frontend als sozio-technische Schnittstelle

In standortbasierten Lernanwendungen ist das Frontend eine sozio-technische Schnittstelle: Es verbindet Menschen, Regeln, Orte und Datenströme. Theoretisch lässt sich seine Rolle in drei Ebenen beschreiben:

1. **Interaktionsebene**: Bedienung, Lesbarkeit, Feedback.
2. **Kontrollebene**: Regelprüfung, gültige Zustandsübergänge.
3. **Vertrauensebene**: Transparenz bei Daten, Fairness und Fehlern.

Ein Frontend ist damit nicht bloß "die Oberfläche", sondern ein aktiver Teil der Systemzuverlässigkeit.

### Deklarative UI als Architekturprinzip

Flutter folgt einem deklarativen Paradigma: Die Oberfläche ist eine Funktion des Zustands [@flutterDocs]. Für GeoQuest ist das besonders geeignet, da sich Standort, Fortschritt und Session ständig ändern.

Der deklarative Ansatz hat drei praktische Vorteile:

- **Nachvollziehbarkeit**: UI-Zustand lässt sich auf Datenzustand zurückführen.
- **Testbarkeit**: Zustandswechsel können reproduzierbar geprüft werden.
- **Wartbarkeit**: weniger imperativer UI-"Klebstoff".

Grenze des Ansatzes: Ohne saubere Zustandsmodellierung entstehen auch deklarativ inkonsistente Ansichten. Deshalb ist State-Design wichtiger als reine Widget-Struktur.

### Zustandsmanagement in dynamischen Spielszenarien

Theoretisch sollte Zustand nach Lebensdauer getrennt werden:

- **ephemer** (Dialog geöffnet, Fokus, Button-Disable),
- **featurebezogen** (aktive Station, Warnungszähler, Countdown),
- **persistent** (Profil, Punkte, Stationsreihenfolge).

GeoQuest nutzt hierfür eine Mischform aus lokalem Widget-State, `ValueNotifier` und Firestore als persistente Wahrheit. Diese Kombination ist für mittelgroße Projekte pragmatisch, erfordert aber klare Verantwortungsgrenzen.

### Navigation als Zustandsautomat

Navigation kann als endlicher Automat modelliert werden: Jeder Screen ist ein Zustand, jeder Button eine Transition. Fehler entstehen dort, wo ungültige Transitionen zugelassen werden.

Beispiele für gültige Guard-Regeln:

- ohne Login kein Eintritt in Spielbereiche,
- ohne aktive Station keine Aufgabenbewertung,
- während Sperre kein Wechsel in Umgehungszustände.

Diese Perspektive hilft, UI-Entscheidungen systematisch statt ad hoc zu treffen.

### Mobile UX unter realen Umgebungsbedingungen

Nach ISO 9241-110 sind Dialogprinzipien wie Aufgabenangemessenheit, Fehlertoleranz und Selbstbeschreibungsfähigkeit zentral [@iso9241]. Für mobile Schnitzeljagden kommen reale Störfaktoren hinzu:

- Bewegung,
- wechselnde Lichtverhältnisse,
- geteilte Aufmerksamkeit,
- unsichere Netzqualität.

Daraus folgen Designregeln:

- kurze Textblöcke,
- eindeutige Primäraktionen,
- hohe Kontraste,
- klare Statuskommunikation.

### Informationsarchitektur und kognitive Last

Kognitive Last steigt stark, wenn pro Screen mehrere gleichgewichtige Entscheidungen verlangt werden. Die App reduziert diese Last durch:

- eine dominante Primäraktion pro Schritt,
- linearen Einstieg,
- tab-basierten Betrieb nach Initialphase,
- konsistente Positionen zentraler Bedienelemente.

Diese Reduktion ist kein Funktionsverlust, sondern eine Optimierung der Entscheidungsqualität unter Zeitdruck.

### Karten-UI als Spezialfall

Kartenoberflächen unterscheiden sich von klassischen Formular- oder Listen-UIs, weil sich der Inhalt permanent mit Position und Zoom verändert. Aus theoretischer Sicht benötigen solche UIs:

- stabile visuelle Referenzen,
- eindeutige Markersemantik,
- saubere Priorisierung von Informationen.

GeoQuest löst das u. a. über den Bottom-Statusbereich, klaren Radius-Feedback-Zustand und kontextabhängige Aktionsbuttons (QR-Scan vs. Aufgabenbewertung).

### Unsicherheit von Standortdaten

GPS ist probabilistisch, nicht deterministisch. Messwerte schwanken je nach Gerät, Umgebung und Bewegung. Daraus folgt: Distanzlogik muss robust gegen Unsicherheit sein.

Relevante Gestaltungsparameter:

- Radiusgröße,
- Updatefrequenz,
- Filterung von Ausreißern,
- Ersatzmechanismen (QR als Fallback).

Genau diese Kombination wurde praktisch umgesetzt, um einen fairen und zugleich benutzbaren Ablauf zu gewährleisten.

### Anti-Cheat aus Systemtheorie-Sicht

Anti-Cheat ist in Lernspielen nicht primär eine Sicherheitsfrage, sondern eine Fairnessfrage. Ein wirksames Modell braucht:

1. nachvollziehbare Regeln,
2. reproduzierbare Erkennung,
3. proportionale Sanktionen,
4. transparente Kommunikation.

Das in GeoQuest umgesetzte Stufenmodell (Warnung -> Sperre -> Punktabzug) ist deshalb wirksam, weil es nicht sofort maximal bestraft, aber wiederholtes Fehlverhalten klar begrenzt.

### Asynchrone Verarbeitung und Konsistenz

Moderne Mobile-Apps sind asynchron: Streams, Netzwerk, Timer und UI-Events laufen parallel. Typische Risiken sind race conditions, doppelte Schreibvorgänge und stale UI.

Gegenmaßnahmen:

- Firestore-Transaktionen für kritische Summenfelder,
- idempotente Update-Logik je Station,
- Guard-Flags gegen Doppeltrigger,
- Lebenszyklusgerechtes Dispose von Streams/Timern.

Diese Punkte sind nicht optional, sondern Grundvoraussetzung für belastbare Feldanwendungen.

### Datenmodellierung als UX-Faktor

Ein inkonsistentes Datenmodell wirkt direkt als UX-Problem. Wenn Punkte, Fortschritt und Zeitdaten fachlich nicht zueinander passen, verliert die Benutzeroberfläche an Glaubwürdigkeit.

Cloud Firestore wird offiziell als "flexible, scalable" Datenbank beschrieben [@firestoreDocs].

> "Cloud Firestore is a flexible, scalable database." [@firestoreDocs]

Im Projekt wurde diese Flexibilität gezielt genutzt, aber durch strukturierte Feldnamen und klar definierte Verantwortlichkeiten eingegrenzt.

### Authentifizierung und Autorisierung

Sichere Anmeldung allein reicht nicht; auch Rollenrechte müssen fachlich korrekt durchgesetzt werden. GeoQuest kombiniert deshalb:

- technische Identität via Firebase Authentication,
- fachliche Rollenfreigabe über Admin-E-Mail-Liste.

Diese Trennung entspricht gängigen Security-Prinzipien wie "least privilege" [@owaspMasvs].

### Datenschutz und Transparenz

Standortbasierte Anwendungen verarbeiten personenbezogene Daten. Aus DSGVO-Sicht sind besonders relevant:

- Zweckbindung,
- Datenminimierung,
- Transparenz,
- Rechte der Betroffenen [@gdpr].

Im Frontend bedeutet das:

- Berechtigungen nicht verstecken,
- Nutzen vor Abfrage erklären,
- verständliche Datenschutzinfos direkt in der App anbieten.

Datenschutz ist damit Teil der Produktqualität, nicht nur ein juristischer Anhang.

### Barrierefreiheit und Inklusion

Auch Schulapps sollten inklusiv nutzbar sein. Wichtige Aspekte:

- ausreichender Kontrast,
- konsistente Fokusführung,
- klare Sprache,
- Redundanz bei visuellen Codes (nicht nur Farbe).

Für Karten bedeutet das zusätzlich, dass wichtige Zustände textlich begleitet werden müssen, damit Informationen nicht allein über Markerfarbe transportiert werden.

### Performance, Energie und thermische Last

Performance ist auf Mobilgeräten mehrdimensional:

- Reaktionsgeschwindigkeit,
- Speicherverbrauch,
- Energiebedarf,
- thermische Stabilität.

Standortstream + Karte + Netzwerkzugriffe können diese Faktoren schnell verschlechtern. Deshalb sind Drosselung, selektive Rebuilds und sauberes Subscription-Management zentrale architektonische Maßnahmen.

### Wartbarkeit und technische Schulden

Langfristig entscheidet nicht nur, ob eine Version funktioniert, sondern wie änderbar sie bleibt. Wartbarkeit hängt u. a. ab von:

- Dateigröße und Verantwortungszuschnitt,
- Konsistenz der Benennung,
- Dokumentation von Entscheidungen,
- Testabdeckung kritischer Pfade.

GeoQuest zeigt hier zwei Seiten:

- positiv: klare Funktionsgrenzen zwischen vielen Screens,
- kritisch: hohe Komplexität im `MapTab`, die mittelfristig aufgeteilt werden sollte.

### Qualitätsmodell für GeoQuest

Ein passendes Qualitätsmodell für die Frontend-Schicht kombiniert drei Ebenen:

1. **Funktionale Qualität**: korrekte Abläufe bei Normalbetrieb.
2. **Robustheitsqualität**: sinnvolle Reaktion auf Fehler/Randfälle.
3. **Erlebte Qualität**: Verständlichkeit, Vertrauen, Motivation.

Viele Projekte fokussieren nur Ebene 1. In standortbasierten Apps entscheidet jedoch vor allem Ebene 2 über reale Einsatzfähigkeit.

### Theorie-Praxis-Abgleich

Die theoretischen Prinzipien decken sich mit den praktischen Beobachtungen im Projekt:

- klare Zustandsmodelle reduzieren Fehler,
- transparente Fehlermeldungen senken Abbruchrate,
- faire Regeln brauchen sichtbare Kommunikation,
- modulare Architektur beschleunigt Änderungen.

Abweichungen zeigten sich vor allem dort, wo praktische Kompromisse nötig waren, etwa bei der Größe einzelner Dateien oder bei noch nicht vollständig automatisierter Testabdeckung.

### Ausblick auf Weiterentwicklung

Aus theoretischer und praktischer Sicht sind für die nächste Ausbaustufe sinnvoll:

1. stärkere Zerlegung des Map-Moduls in dedizierte Komponenten (Tracking, Anti-Cheat, Overlay, Bewertung),
2. zusätzliche Widget-/Golden-Tests für kritische States,
3. optionale Offline-Zwischenspeicherung mit synchronem Retry,
4. erweiterte Accessibility-Prüfung (Screenreader-Labels, Touch-Ziele),
5. analytische Auswertungen für Lernfortschritt und Spielbalance.

### Gesamtschluss

Die Frontend-Teilaufgabe von GeoQuest zeigt für mich vor allem eines: Eine gute mobile App entsteht nicht durch ein schönes UI allein, sondern durch das Zusammenspiel aus Nutzerführung, klarer Architektur und sauberem Zustandsmanagement. Der aktuelle Stand ist im Schulkontext nutzbar und lässt sich sinnvoll erweitern.

Gleichzeitig wurde im Projekt deutlich, dass das Frontend bei standortbasierten Anwendungen fachlich mitentscheidet. Regeln für Fairness, Zeit und Freigabe leben nicht nur im Backend, sondern direkt in der Oberfläche. Genau diese Sicht hat meine Umsetzung geprägt.

## Kompakter technischer Anhang

### End-to-End-Spielerfluss (gekürzt)

Damit die Umsetzung nachvollziehbar bleibt, fasse ich den realen Ablauf aus Spielersicht kurz zusammen:

1. App startet, lädt Firebase und lokale Einstellungen.
2. Beim ersten Start erscheint das Onboarding.
3. Danach erfolgt die Rollenwahl (Spieler oder Admin).
4. Spieler melden sich an oder registrieren sich.
5. Über Dashboard und Route startet die nächste Station.
6. In der Karte laufen Distanz-, Zeit- und Fairnessprüfung parallel.
7. Aufgabe wird im Radius oder per QR freigeschaltet.
8. Punkte werden vergeben und transaktionssicher gespeichert.
9. Fortschritt/Ranking werden aktualisiert.

Dieser Flow war die Basis für meine manuellen Abnahmetests.

### Datenmodell auf einen Blick

Für die Frontend-Perspektive waren diese Datenbereiche entscheidend:

- `Users/{uid}` für Profil, Punkte und Spielfortschritt,
- `Hunts/{huntId}` als Spielrahmen,
- `Hunts/{huntId}/Stadions/{stadionId}` für Aufgaben/Stationen,
- `PlayerLocation/{uid}` für Live-Position und Admin-Ansicht.

Wichtig war mir dabei: Das UI schreibt nur die Felder, die es wirklich braucht. Das reduziert Fehler und hält die Logik verständlich.

### Warum die Architektur so geschnitten ist

Die App trennt Auth, Navigation, Kartenlogik und Fortschrittsanzeige bewusst voneinander. Das hat mir in der Umsetzung viel geholfen:

- Änderungen am Login haben die Kartenlogik nicht gebrochen.
- Neue UI-Texte konnten ohne Eingriff in Firestore-Zugriffe angepasst werden.
- Fehler ließen sich schneller eingrenzen, weil jede Schicht einen klaren Zweck hatte.

### Was im Betrieb gut funktioniert hat

Im Feldtest haben vor allem drei Dinge überzeugt:

- Der Einstieg war für neue Nutzer schnell verständlich.
- Die Aufgabenfreigabe war robust, weil Radius und QR kombiniert wurden.
- Lehrkräfte konnten Teams über die Admin-Karte verlässlich verfolgen.

Besonders hilfreich war, dass wichtige Zustände immer sichtbar waren (Distanz, Countdown, Sperrhinweise).

### Wo es noch hakt

Trotz stabilem Stand gibt es klare Grenzen:

- Die Kartenlogik ist noch zu zentral in einer großen Komponente gebündelt.
- Automatisierte UI-Tests sind vorhanden, aber noch nicht tief genug.
- Offline-Verhalten ist nur teilweise abgedeckt.
- Einige Accessibility-Details sind noch ausbaufähig.

Diese Punkte sind keine Showstopper, aber sie begrenzen die Wartbarkeit im nächsten Ausbauschritt.

### Konkreter Refactoring-Pfad

Für die nächste Iteration ist dieser Plan realistisch und wirksam:

1. `MapTab` in kleinere Verantwortungsbereiche aufteilen (Tracking, Freischaltung, Bewertung, Overlay).
2. Firestore-Schreibzugriffe stärker in Services bündeln.
3. Einheitliches Fehlermodell statt verteilter Einzelmeldungen.
4. Mehr Widget-Tests für kritische Zustandswechsel.
5. Gezielte Accessibility-Checks (Labels, Fokus, Touch-Ziele).

Damit sinkt technische Komplexität, ohne den laufenden Betrieb zu riskieren.

### Kompakter Screen-Ueberblick

Die lange Screen-by-Screen-Dokumentation wurde bewusst eingekuerzt. Hier bleibt der technische Kern je Screen erhalten:

- `SplashScreen`: Initialisierung puffern und stabilen Zielscreen bestimmen.
- `OnboardingFlow`: Erstnutzern Regeln in vier kurzen Schritten erklaeren.
- `RoleSelectScreen`: Fruehe Trennung von Spieler- und Admin-Pfad.
- `SignInEmailScreen`: Niedrigschwelliger Einstieg in Login/Registrierung.
- `CreateAccountScreen`: Lokale Validierung vor Netzwerkzugriff.
- `LoginScreen`: Username/E-Mail-Login mit klaren Fehlermeldungen.
- `StartHuntScreen`: Motivierender Start inklusive Spielkontext.
- `StartRouteScreen`: Naechste Station, Distanz, Zeit und Aktion auf einen Blick.
- `HomeScreen`: Einheitliche Navigation zwischen Map, Progress und Menue.
- `MapTab`: Live-Standort, Radiuscheck, QR-Fallback und Anti-Cheat.
- `QuizScreen`: Bewertungsflow mit sauberer Punktepersistenz.
- `ProgressTab`: Fortschritt, Ranking und Zwischenziele sichtbar machen.
- `MenuTab`: Sekundaere Aktionen ohne Stoerung des Spielkerns.
- `Settings/Privacy/Imprint`: Transparenz, Rechtliches und Konfiguration.
- `AdminMapScreen`: Betriebsansicht fuer Lehrkraefte mit Live-Tracking.

Im Projektalltag war diese klare Rollenverteilung der Screens entscheidend, weil Fehler dadurch schneller lokalisierbar waren.

### Drei konkrete Praxissituationen

Um die Entscheidungslinien der Frontend-Umsetzung greifbar zu machen, hier drei typische Situationen aus Tests und Schulbetrieb:

1. **GPS springt am Schulhofrand**
Ein Team stand sichtbar nahe an der Station, die Distanz sprang aber kurzfristig ueber den Radius. Ohne Gegenmassnahme fuehrt das zu Frust. In der App half der kombinierte Ansatz aus Distanzpruefung und QR-Fallback. So bleibt die Regel fair, ohne Teams bei GPS-Ausreissern unnoetig zu blockieren.

2. **Instabile Datenverbindung waehrend der Bewertung**
Beim Speichern einer Aufgabe gab es vereinzelt kurze Timeouts. Wichtig war deshalb, dass der Nutzer nicht im Unklaren bleibt. Statt still zu scheitern, zeigt die App einen klaren Fehlerhinweis und erlaubt einen erneuten Versuch. In der Praxis hat genau das Supportfragen reduziert.

3. **Hohe Dynamik bei mehreren Teams gleichzeitig**
Im Parallelbetrieb wollten Lehrkraefte schnell sehen, ob Teams unterwegs sind oder festhaengen. Die Admin-Karte war hier der zentrale Mehrwert: nicht perfekt detailreich, aber schnell interpretierbar. Diese Betriebsansicht hat im Einsatz mehr geholfen als zusaetzliche theoretische Kennzahlen.

### Beobachtungen aus der Umsetzung

Rueckblickend waren fuer mich vor allem diese Punkte entscheidend:

- Kurze, direkte Texte in kritischen Momenten wirken besser als lange Erklaerungen.
- Sichtbare Systemzustaende schaffen Vertrauen, selbst wenn mal etwas langsam reagiert.
- Eine klare Navigation spart mehr Zeit als jede spaet nachgeruestete Hilfeseite.
- Technische Sauberkeit im Zustandshandling zahlt sich unmittelbar im UI-Verhalten aus.

Ich habe ausserdem gemerkt, dass vermeintlich "kleine" Frontend-Entscheidungen grosse Auswirkungen haben. Ein klar benannter Button oder ein gut platzierter Hinweis kann ueber Spielfluss und Motivation entscheiden.

### Was bewusst gekuerzt wurde

Fuer diese Version habe ich absichtlich Inhalte entfernt, die zwar technisch interessant sind, aber den Lesefluss stark bremsen:

- sehr tiefe Detailanalysen einzelner Klassen,
- lange, redundante Screen-fuer-Screen-Passagen,
- theoretische Dopplungen ohne direkten Mehrwert fuer die Bewertung der Teilaufgabe.

Das Ziel der Kuerzung war nicht, Inhalt zu verstecken, sondern den Kern besser sichtbar zu machen: Wie das Frontend in der Praxis funktioniert, welche Entscheidungen tragfaehig waren und wo die naechsten Verbesserungen liegen.

### Didaktische Eignung im Schulkontext

Für den Unterricht war wichtig, dass die App nicht nur funktioniert, sondern sich klar anfühlt. Genau das hat in der Praxis funktioniert:

- einfache Navigation,
- nachvollziehbare Regeln,
- transparente Rückmeldungen,
- motivierender Fortschritt.

Die Kombination aus Spielmechanik und klarer Oberfläche macht GeoQuest aus meiner Sicht gut im Schulalltag einsetzbar.

### Kurzfazit des Anhangs

Die ausführlichen Detailblöcke wurden hier bewusst komprimiert. Inhaltlich bleibt der Kern erhalten: Das Frontend steuert nicht nur Oberfläche, sondern einen großen Teil der Fachlogik rund um Fairness, Fortschritt und Betrieb.

Durch die Kürzung ist die Dokumentation fokussierter, leichter lesbar und näher an der tatsächlichen Projektpraxis.

