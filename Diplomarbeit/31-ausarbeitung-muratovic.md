# Teilaufgabe Schüler Muratovic
\textauthor{Benjamin Muratovic}

## Theoretischer Teil – Projektmanagement im Projekt „GeoQuest“

In der Diplomarbeit „GeoQuest“ habe ich die Projektmanagement-Aufgaben übernommen. Dazu zählten insbesondere die Koordination im Team, Termin- und Qualitätsmanagement, die Abstimmung mit Auftraggeber und Betreuung sowie die laufende Pflege der Projektdokumentation. Ziel meines Vorgehens war ein leichtgewichtiges, aber nachvollziehbares Projektmanagement, das für ein Schulprojekt praktikabel ist und gleichzeitig eine saubere Grundlage für Entscheidungen, Änderungen und Qualitätskontrolle schafft [@european_commission_pm2_2018].

Im Folgenden beschreibe ich die Methoden, die ich dafür verwendet habe, und wie sie im Projekt konkret umgesetzt wurden (siehe Projekthandbuch, Meilensteine, Anwendungsfälle und Fortschrittsdokumentation).

### 1. Iteratives Vorgehen und inkrementelle Umsetzung

Im Projekt wurde bewusst iterativ gearbeitet: Anforderungen wurden in kleinere Pakete zerlegt, priorisiert umgesetzt und regelmäßig zusammengeführt. Dieses Vorgehen entspricht agilen Grundideen, bei denen funktionierende Zwischenergebnisse früh sichtbar werden und Anpassungen laufend möglich bleiben [@beck_manifesto_2001]. Für ein Projekt mit realem Auftraggeber ist das besonders wichtig, weil sich Details in der Praxis oft erst während der Umsetzung klären.

**Umsetzung im Projekt:**
- Die schrittweise Umsetzung spiegelt sich in den Meilensteinen wider (z. B. zuerst „Anforderungsanalyse & Konzept“, danach „UI-Prototyp & Grundstruktur“, später „GPS- & Aufgabenlogik“ und „Systemtests & Feinschliff“; siehe Meilensteine).
- Durch die regelmäßige Zusammenführung konnten Integrationsprobleme früher erkannt werden, anstatt erst am Ende „alles zusammenzuschieben“ (sichtbar u. a. in den Statusberichten).

### 2. Projektorganisation, Rollen und Stakeholder

Damit Entscheidungen und Zuständigkeiten nicht „nebenbei“ passieren, wurde die Projektorganisation explizit dokumentiert. In kleinen Teams ist das oft unterschätzt – gleichzeitig verhindert eine klare Rollenverteilung Doppelarbeit und reduziert Kommunikationsfehler. In etablierten Projektmethoden (z. B. PM²) ist die klare Definition von Rollen, Verantwortlichkeiten und Stakeholdern ein zentraler Bestandteil der Projektführung [@european_commission_pm2_2018].

**Umsetzung im Projekt:**
- Projektbeteiligte und Stakeholder (Auftraggeber, Betreuer, Projektleiter) sind im Projekthandbuch dokumentiert.
- Projektrollen wurden mit Aufgabenbeschreibung festgehalten, um Verantwortlichkeiten nachvollziehbar zu machen.

### 3. Terminplanung über Fixtermine und Meilensteine

Für das Schuljahr waren mehrere Fixtermine gegeben (Zwischenpräsentationen, Abgaben). Um diese zuverlässig zu erreichen, habe ich mit einem Meilensteinplan gearbeitet: Meilensteine sind klar definierte Zwischenziele mit überprüfbaren Ergebnissen (Lieferobjekten). Dadurch wird Planung messbar und Fortschritt objektiv bewertbar [@european_commission_pm2_2018].

**Umsetzung im Projekt:**
- Fixtermine sind in der Projektterminübersicht erfasst.
- Der Meilensteinplan beschreibt pro Datum konkrete Ergebnisse (z. B. „UI-Prototyp sichtbar“, „GPS-Funktion implementiert“), wodurch Abweichungen früh erkennbar wurden.

### 4. Änderungsmanagement (Change Control)

In Softwareprojekten entstehen Änderungswünsche fast zwangsläufig. Ohne Änderungsmanagement führt das schnell zu Scope Creep (schleichender Umfangserweiterung) und zu inkonsistenter Dokumentation. Daher wurde ein klarer Ablauf definiert: Änderungen werden zuerst besprochen, danach dokumentiert und anschließend in Projekthandbuch sowie Backlog nachgezogen. Dieses Vorgehen entspricht dem Grundprinzip, Änderungen kontrolliert zu behandeln und Entscheidungen nachvollziehbar festzuhalten [@european_commission_pm2_2018].

**Umsetzung im Projekt:**
- Der Ablauf „Vorgehen bei Änderungen“ ist im Projekthandbuch als Prozess beschrieben (Team-Besprechung -> Änderungsprotokoll -> Aktualisierung Handbuch/Backlog -> Vorstellung im nächsten Meeting).

### 5. Risikomanagement

Risikomanagement bedeutet, potenzielle Probleme früh zu erkennen und Maßnahmen zu planen, bevor sie eintreten. Gerade bei Diplomarbeiten sind typische Risiken z. B. ungenaue Aufwandsschätzungen, Lernkurven, Ressourcenausfälle oder unklare Anforderungen. Ein Risikoregister mit Eintrittswahrscheinlichkeit, Auswirkungen und Gegenmaßnahmen ist ein bewährtes Instrument zur Steuerung [@european_commission_pm2_2018].

**Umsetzung im Projekt:**
- Projektrisiken wurden als Tabelle dokumentiert (inkl. Eintrittswahrscheinlichkeit, Auswirkungen, Maßnahmen).
- Beispielhafte Gegenmaßnahmen waren u. a. Zeitpuffer, klare Fixpunkte mit Betreuung sowie frühe Prototypen/Tests zur technischen Absicherung.

### 6. Anforderungsmanagement mit User Stories

Um Anforderungen verständlich und nutzenorientiert zu erfassen, habe ich sie als User Stories formuliert. User Stories fokussieren auf „Wer braucht was und warum?“ und sind dadurch gut priorisierbar. Die bekannte Vorlage „As a … I want … so that …“ ist weit verbreitet und unterstützt die Kommunikation, weil sie Nutzen und Ziel explizit macht [@mountaingoat_user_stories_2025; @atlassian_user_stories_2026]. Wichtig ist dabei: Eine User Story ist bewusst kurz – Details entstehen in der gemeinsamen Klärung („conversation“) und werden anschließend durch überprüfbare Kriterien abgesichert [@mountaingoat_user_stories_2025].

**Umsetzung im Projekt:**
- Zentrale Funktionen wurden als Kurzbeschreibung in User-Story-Form dokumentiert (z. B. Karte & Standort, standortbasierte Aufgaben, Fortschritt).
- Die Stories dienen als Grundlage für die Priorisierung in Meilensteinen und als „gemeinsame Sprache“ zwischen Team und Stakeholdern.

### 7. Use-Case-Struktur für Abläufe, Randfälle und Systemzustände

Damit aus einer knappen User Story ein umsetzbarer Ablauf wird, habe ich die Anforderungen zusätzlich in einer Use-Case-ähnlichen Struktur dokumentiert. Diese Struktur macht den Ablauf prüfbar, weil Trigger, Vor- und Nachbedingungen, Akteure, Fehlersituationen und Systemzustände explizit genannt werden. Use Cases sind dafür ein etabliertes Mittel, um funktionale Abläufe klar zu beschreiben und Missverständnisse zu reduzieren [@cockburn_writing_2001].

**Umsetzung im Projekt:**
- In den Anwendungsfällen werden Trigger, Vor-/Nachbedingungen, Akteure, Fehlersituationen und Systemzustand im Fehlerfall strukturiert beschrieben.
- Dadurch ist nachvollziehbar, was das System im Normalfall und in Fehlerfällen tun muss (z. B. bei verweigerten Berechtigungen oder Netzwerkproblemen).

### 8. Akzeptanzkriterien mit Given/When/Then (BDD/Gherkin-Stil)

Ein häufiger Grund für Nacharbeit ist, dass „fertig“ subjektiv interpretiert wird. Akzeptanzkriterien definieren deshalb messbar, wann eine Anforderung erfüllt ist. Die Given/When/Then-Form (aus dem BDD-/Gherkin-Umfeld) ist dafür gut geeignet, weil sie Voraussetzungen, Aktion und erwartetes Ergebnis klar trennt und sich direkt zur Prüfung verwenden lässt [@cucumber_gherkin_reference_2025; @adzic_specification_2011]. Auch in der Projektpraxis werden Akzeptanzkriterien als Brücke zwischen Anforderungen und Testbarkeit genutzt [@atlassian_acceptance_criteria_2026].

**Umsetzung im Projekt:**
- Der Standardablauf vieler Use Cases wird explizit „durch Akzeptanzkriterien beschrieben“ (Given/When/Then).
- Dadurch konnten Anforderungen auch ohne formale Testautomatisierung objektiv abgenommen werden (z. B. Karte zeigt Position, Marker im Radius, Verhalten bei verweigerter Standortfreigabe).

### 9. Offene Punkte und Entscheidungsfindung (Conversation Points)

In frühen Phasen sind nicht alle Details entscheidbar – entscheidend ist, dass offene Fragen sichtbar bleiben und nicht „untergehen“. Dafür wurden Conversation Points genutzt: eine kurze Liste von Punkten, die noch zu klären sind (z. B. Update-Strategie Standort, Radius/Filter, Offline-Verhalten, Anti-Cheat-Ansatz). Das unterstützt die schrittweise Präzisierung der Anforderungen und entspricht dem Gedanken, dass Spezifikation und gemeinsame Klärung zusammengehören [@mountaingoat_user_stories_2025; @adzic_specification_2011].

**Umsetzung im Projekt:**
- Zu jedem Use Case wurden Conversation Points dokumentiert.
- Diese Punkte wurden als Input für Teamentscheidungen und für die Priorisierung weiterer Arbeitsschritte genutzt.

### 10. Projektcontrolling, Statusberichte und Qualitätssicherung

Damit Fortschritt nicht nur „gefühlt“, sondern objektiv sichtbar wird, habe ich regelmäßige Statusberichte verwendet. Projektcontrolling bedeutet dabei: Ist das Projekt im Plan? Wenn nicht – welche Maßnahmen folgen daraus? Dieses Prinzip wird auch in etablierten PM-Ansätzen über Monitoring/Control und Maßnahmenableitung betont [@european_commission_pm2_2018].

Parallel dazu ist Qualitätssicherung ein laufender Bestandteil: Anforderungen und Umsetzungen müssen geprüft werden, bevor sie als stabil gelten. Ein verbreiteter Grundgedanke im Testing ist, dass Tests nicht nur Fehler finden, sondern auch Anforderungen/Work Products (z. B. User Stories) evaluierbar machen und damit Qualität absichern [@istqb_ctfl_2024].

**Umsetzung im Projekt:**
- In der Dokumentation werden Zeiträume mit fixem Schema berichtet (Gesamtstatus, durchgeführte Arbeiten, notwendige Entscheidungen, nächste Schritte). Dadurch werden Abweichungen und Gegenmaßnahmen transparent.
- Interne Tests der Kernfunktionen sowie Fehlerbehebungen wurden als Teil der Umsetzung geführt (u. a. in Statusberichten sichtbar).
- Meilensteine dienten zusätzlich als „Qualitäts-Gates“ (vor Präsentationen/Abgaben musste ein stabiler Zwischenstand existieren).

## Praktischer Teil – Dependency Conflicts in Flutter-Projekten

Ein wesentlicher Teil meiner praktischen Arbeit im Projekt bestand darin, **Dependency Conflicts** (Abhängigkeitskonflikte) zu analysieren und zu beheben. In Flutter/Dart werden externe Pakete über **pub** (Paketmanager) verwaltet und in der `pubspec.yaml` als Abhängigkeiten eingetragen [@flutter_using_packages_2026; @dart_pub_dependencies_2026].  
In unserer Diplomarbeit traten Konflikte vor allem dann auf, wenn **die lokal installierte Flutter-/Dart-Version zu alt** war oder wenn **Dependencies zu neu gewählt** wurden und dadurch nicht mehr zur SDK-Version oder zu Flutter-spezifischen Einschränkungen passten (insbesondere bei „pinned packages“) [@dart_pubspec_2025; @dart_flutter_pinned_packages_2026].

### 1. Grundlagen: Was sind Dependencies und warum können sie kollidieren?

Eine **Dependency** ist ein externes Paket, das das Projekt benötigt. Pub unterscheidet dabei:

- **Direkte Dependencies:** Pakete, die das Projekt unmittelbar in der `pubspec.yaml` angibt.
- **Transitive Dependencies:** Pakete, die indirekt hineinkommen, weil eine direkte Dependency ihrerseits wiederum andere Pakete benötigt [@dart_pub_dependencies_2026].

Ein **Dependency Conflict** liegt vor, wenn pub **keine Kombination von Paketversionen** finden kann, die alle Anforderungen gleichzeitig erfüllt. In der Praxis zeigt sich das meist als Fehler beim Ausführen von `flutter pub get`, typischerweise mit der Meldung **„version solving failed“** [@dart_pub_get_2025; @dart_pubgrub_solver_2026].  
Der Kern des Problems ist: Pub muss für das gesamte Projekt eine **konsistente Menge** von Paketversionen finden, sodass alle Versionseinschränkungen („Constraints“) zusammenpassen.

### 2. Wie Versionsangaben funktionieren: SemVer, Constraints und Caret-Syntax

Damit Pakete unabhängig voneinander weiterentwickelt werden können, basiert das Ökosystem auf **Versionierung** und **Versionsbereichen** statt fixen Einzelversionen. Das zentrale Prinzip ist dabei „Semantic Versioning“ (MAJOR.MINOR.PATCH) [@semver_2013; @dart_pub_versioning_2025].

In der `pubspec.yaml` werden Versionen meist als **Bereich** angegeben, z. B.:

- `'>=1.2.0 <2.0.0'` (expliziter Bereich)
- `^1.2.0` (Caret-Syntax, erlaubt kompatible Updates innerhalb desselben Major-Bereichs) [@dart_pub_dependencies_2026; @dart_pubspec_2025]

Diese Flexibilität ist gewollt (Updates und Bugfixes können automatisch genutzt werden), erhöht aber die Chance auf Konflikte, sobald mehrere Pakete unterschiedliche Anforderungen an dieselbe Dependency stellen.

### 3. Warum „version solving failed“ passiert: PubGrub und das „eine Version pro Paket“-Prinzip

Pub verwendet einen Version-Solver (PubGrub). Der Solver versucht, aus allen möglichen Versionen aller Pakete eine Auswahl zu treffen, sodass:

- jede gewählte Version die Dependencies erfüllt,
- **nur eine Version pro Paket** im gesamten Projekt ausgewählt wird,
- und keine unnötigen Pakete dabei sind [@dart_pubgrub_solver_2026].

Wenn der Solver auf einen Widerspruch stößt, muss er zurückgehen („backtracking“) und Alternativen probieren. Gibt es keine Lösung, wird der Konflikt als „version solving failed“ ausgegeben – inklusive einer Kette, **welches Paket welche Version verlangt** (diese Kette ist der wichtigste Diagnosehinweis) [@dart_pubgrub_solver_2026].

### 4. Typische Konfliktarten in Flutter (und warum sie in Schulprojekten so häufig sind)

#### 4.1 Direkte Versionskonflikte
Zwei Dependencies verlangen inkompatible Versionen derselben Library. Beispielprinzip:
- Paket A verlangt `foo <2.0.0`
- Paket B verlangt `foo >=2.0.0`
-> keine Version erfüllt beides.

#### 4.2 Transitive Konflikte („Dependency Hell“)
Sehr häufig kollidieren nicht direkte, sondern **transitive** Anforderungen. Man sieht dann in der Fehlermeldung, dass ein Paket über mehrere Stufen eine bestimmte Version erzwingt [@dart_pub_dependencies_2026].  
Gerade in Flutter-Apps wird das durch Plugins verstärkt, weil diese oft viele transitive Abhängigkeiten mitbringen.

#### 4.3 SDK-Constraints: Dart-/Flutter-Version passt nicht
Pakete können Mindestanforderungen an die **Dart SDK** (und optional auch an **Flutter**) definieren:

```yaml
environment:
  sdk: ^3.2.0
  flutter: '>=3.22.0'
```

Wenn die lokal installierte SDK-Version darunter liegt, darf pub das Paket nicht auswählen. Pub sucht dann eine ältere Paketversion, die noch kompatibel wäre – wenn es diese nicht gibt, entsteht ein unlösbarer Konflikt [@dart_pubspec_2025].  
Das war in unserem Projekt eine der häufigsten Ursachen: **Flutter/Dart war lokal veraltet**, während einzelne Packages bereits neuere SDK-Funktionen oder Constraints voraussetzten.

#### 4.4 Flutter „Pinned Packages“ (besonders relevant in unserem Projekt)
Flutter pinnt bestimmte Paketversionen innerhalb des SDK auf konkrete Versionen. Zweck: Eine App, die mit einer bestimmten Flutter-Version gebaut wurde, soll nicht plötzlich durch neue Paket-Releases „von außen“ brechen [@dart_flutter_pinned_packages_2026].  
Das hat eine direkte Auswirkung:

- Wenn Flutter z. B. `package:path` auf eine bestimmte Version pinnt, muss die eigene `pubspec.yaml` diesen Bereich **einschließen**.
- Das gilt **auch transitiv**: Wenn ein verwendetes Plugin eine inkompatible `path`-Constraint hat, scheitert der Solver [@dart_flutter_pinned_packages_2026].

Für uns war das praktisch ein wiederkehrendes Muster: **Dependency-Versionen waren zu neu** (oder zu eng eingeschränkt), sodass sie die von Flutter gepinnten Versionen nicht mehr akzeptierten.

### 5. Vorgehensweise bei der Diagnose (wie ich Konflikte systematisch zerlegt habe)

Damit das Lösen nicht zum „Trial-and-Error“ wird, bin ich in der Praxis immer gleich vorgegangen:

1. **Fehlermeldung von `flutter pub get` lesen**  
   Die Meldung enthält fast immer den entscheidenden Hinweis: welches Paket welche Version verlangt und wo es kollidiert [@dart_pub_get_2025; @dart_pubgrub_solver_2026].

2. **Dependency-Graph prüfen (wer zieht was rein?)**  
   Mit `dart pub deps` lässt sich der Dependency-Tree darstellen, wodurch sichtbar wird, welches Paket die problematische transitive Dependency überhaupt hineinbringt [@dart_pub_deps_2025].

3. **Update-Optionen objektiv prüfen statt blind updaten**  
   `dart pub outdated` zeigt, welche Updates möglich wären (inkl. „resolvable“) und hilft, realistische Upgrade-Pfade zu finden [@dart_pub_outdated_2025].

Diese drei Schritte haben in der Praxis meistens gereicht, um klar zu entscheiden, ob ein **SDK-Upgrade** nötig ist oder ob man nur eine **Dependency-Version anpassen** muss.

### 6. Lösungsstrategien (Beheben von Dependency Conflicts)

#### 6.1 Flutter-/Dart-SDK aktualisieren (sauberste Lösung bei „SDK zu alt“)
Wenn Packages eine neuere SDK voraussetzen, ist ein SDK-Upgrade häufig der sinnvollste Weg, weil es die Kompatibilitätsbasis erweitert. Flutter dokumentiert den Update-Prozess über `flutter upgrade` [@flutter_upgrade_2026].  
Das war bei uns oft die schnellste Lösung, wenn ein Package eine Mindest-Dart-Version verlangt hat, die wir lokal noch nicht erfüllt haben.

**Umsetzung im Projekt**
- Bei Konflikten mit zu hohen SDK-Constraints wurde die lokale Flutter-Version aktualisiert.
- Danach wurden Dependencies erneut aufgelöst, um zu prüfen, ob sich der Konflikt „von selbst“ erledigt (was häufig der Fall war).

#### 6.2 Dependency-Versionen anpassen (typisch bei „Dependency zu neu“)
Wenn ein Upgrade der SDK nicht möglich oder nicht sinnvoll ist, bleibt der Gegenweg:
- Dependency-Version **downgraden** oder
- Constraint **so anpassen**, dass sie kompatible Versionen zulässt [@dart_pub_dependencies_2026; @dart_pubspec_2025].

Gerade bei pinned packages ist das entscheidend: Die eigene Constraint muss die gepinnte Version enthalten [@dart_flutter_pinned_packages_2026].

**Umsetzung im Projekt**
- Zu neue Paketversionen wurden auf kompatible Versionen zurückgesetzt, wenn Flutter/Dart lokal nicht passend war.
- Constraints wurden so gewählt, dass sie die Flutter-pinned Versionen nicht ausschließen.

#### 6.3 Constraints „weiten“ (widen constraints) statt unnötig fixieren
Wenn eine Dependency „zu eng“ eingetragen ist (z. B. ein sehr kleiner Bereich), kann das Konflikte erzeugen, obwohl eigentlich kompatible Versionen existieren. Flutter nennt das explizit als Workaround bei Pinning-Problemen [@dart_flutter_pinned_packages_2026].  
Dart empfiehlt außerdem Caret-Syntax als Standard, weil sie Updates zulässt, aber trotzdem einen oberen Sicherheitsrahmen setzt [@dart_pub_dependencies_2026].

**Umsetzung im Projekt**
- Wo möglich wurden Constraints erweitert, um den Solver nicht unnötig zu blockieren.

#### 6.4 `dependency_overrides` (kurzfristige Notlösung)
Mit `dependency_overrides` kann man pub zwingen, eine Version zu verwenden, auch wenn das nicht zu allen Constraints passt. Flutter/Dart warnen dabei ausdrücklich: Man konsumiert dann Kombinationen, die nicht gemeinsam getestet wurden, was zu Analyse- oder Runtime-Problemen führen kann [@dart_flutter_pinned_packages_2026; @dart_pub_dependencies_2026].

**Umsetzung im Projekt**
- Overrides wurden nur als kurzfristige Maßnahme betrachtet und sollten dokumentiert sowie später wieder entfernt werden.

#### 6.5 Lockfile bewusst nutzen (Reproduzierbarkeit im Team)
Pub erzeugt ein `pubspec.lock`, das die konkret aufgelösten Versionen festhält. Für **Application Packages** empfiehlt Dart ausdrücklich, dieses Lockfile zu committen, damit transitive Updates nicht „unbemerkt“ passieren und alle Entwickler dieselben Versionen verwenden [@dart_private_files_2024].  
Das reduziert typische Team-Probleme, bei denen derselbe Code auf zwei Rechnern unterschiedlich auflöst.

**Umsetzung im Projekt**
- `pubspec.lock` wurde als Stabilitätsanker betrachtet, um „bei mir geht’s, bei dir nicht“ zu vermeiden.
- Änderungen an Dependencies wurden dadurch transparenter, weil sie im Diff sichtbar werden [@dart_private_files_2024].

### 7. Prävention (Verhindern statt Reparieren)

#### 7.1 Toolchain vereinheitlichen (Flutter-Version im Team fixieren)
Viele Konflikte entstehen nicht durch „schlechte Dependencies“, sondern durch unterschiedliche lokale SDK-Stände. Präventiv hilft daher vor allem: **eine definierte Flutter-Version als Projektstandard** und Upgrades bewusst steuern [@flutter_upgrade_2026].

#### 7.2 Updates geplant durchführen (kleine Schritte statt große Sprünge)
Statt seltene „Mega-Upgrades“ ist es stabiler, regelmäßig zu prüfen:
- was veraltet ist (`dart pub outdated`) [@dart_pub_outdated_2025]
- welche Updates pub überhaupt sinnvoll auflösen kann [@dart_pub_dependencies_2026].

#### 7.3 Constraints sinnvoll setzen
- nicht zu eng (führt unnötig zu Konflikten),
- nicht „any“ (führt zu unkontrollierten Kombinationen),
- bevorzugt Caret-/Range-Constraints [@dart_pub_dependencies_2026; @dart_pub_versioning_2025].

#### 7.4 CI/Build stabilisieren (Lockfile erzwingen)
Wenn ein Lockfile genutzt wird, kann man in automatisierten Builds verhindern, dass die Dependency-Auflösung plötzlich anders ausfällt. Dart dokumentiert dafür Optionen wie `--enforce-lockfile`, um sicherzustellen, dass die Auflösung exakt dem Lockfile entspricht [@dart_pub_dependencies_2026; @dart_pub_get_2025].

### 8. Bezug zur Diplomarbeit: Warum bei uns fast immer „SDK vs. Dependency“ der Kern war

Im Projekt zeigte sich ein sehr typisches Flutter-Schulprojekt-Muster:

- Eine lokale Flutter-/Dart-Version war zeitweise **hinter dem Ökosystem zurück**, während einzelne Packages bereits neue Mindestanforderungen oder neue transitive Abhängigkeiten mitbrachten [@dart_pubspec_2025].
- Zusätzlich kamen Konflikte durch **Flutter pinned packages**, weil Flutter bestimmte Paketversionen festlegt und diese in der gesamten Auflösung berücksichtigt werden müssen [@dart_flutter_pinned_packages_2026].

Dadurch waren die praktisch wirksamen Lösungen in der Regel eindeutig:
- entweder **Flutter upgraden**, wenn die SDK zu alt ist [@flutter_upgrade_2026],
- oder **Dependency-Versionen/Constraints anpassen**, damit sie zur vorhandenen SDK- und Pinning-Situation passen [@dart_flutter_pinned_packages_2026; @dart_pub_dependencies_2026].
environment:
  sdk: ">=3.2.0 <4.0.0"
