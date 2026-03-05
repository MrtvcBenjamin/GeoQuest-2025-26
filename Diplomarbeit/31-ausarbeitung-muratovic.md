# Teilaufgabe Schüler Muratovic
\textauthor{Benjamin Muratovic}

## Theoretischer Teil – Projektmanagement im Projekt „GeoQuest“

In der Diplomarbeit „GeoQuest“ habe ich die Projektmanagement-Aufgaben übernommen. Dazu zählten insbesondere die Koordination im Team, Termin- und Qualitätsmanagement, die Abstimmung mit Auftraggeber und Betreuung sowie die laufende Pflege der Projektdokumentation. Ziel meines Vorgehens war ein leichtgewichtiges, aber nachvollziehbares Projektmanagement, das für ein Schulprojekt praktikabel ist und gleichzeitig eine saubere Grundlage für Entscheidungen, Änderungen und Qualitätskontrolle schafft [@european_commission_pm2_2018].

Im Folgenden beschreibe ich die Methoden, die ich dafür verwendet habe, und wie sie im Projekt konkret umgesetzt wurden, etwa im Projekthandbuch, in den Meilensteinen, in den Anwendungsfällen und in der Fortschrittsdokumentation.

### 1. Iteratives Vorgehen und inkrementelle Umsetzung

Im Projekt wurde bewusst iterativ gearbeitet. Anforderungen wurden in kleinere Pakete zerlegt, priorisiert umgesetzt und regelmäßig zusammengeführt. Dieses Vorgehen entspricht agilen Grundideen, bei denen funktionierende Zwischenergebnisse früh sichtbar werden und Anpassungen laufend möglich bleiben [@beck_manifesto_2001]. Für ein Projekt mit realem Auftraggeber ist das besonders wichtig, weil sich Details in der Praxis oft erst während der Umsetzung klären.

Im Projekt zeigte sich das im Meilensteinverlauf klar: Zuerst standen Anforderungsanalyse und Konzept im Fokus, danach UI-Prototyp und Grundstruktur, später GPS- und Aufgabenlogik sowie zuletzt Systemtests und Feinschliff. Durch die regelmäßige Zusammenführung konnten Integrationsprobleme früh erkannt werden, statt sie erst ganz am Ende zu bündeln, was auch in den Statusberichten sichtbar wurde.

### 2. Projektorganisation, Rollen und Stakeholder

Damit Entscheidungen und Zuständigkeiten nicht nebenbei passieren, wurde die Projektorganisation explizit dokumentiert. In kleinen Teams ist das oft unterschätzt, gleichzeitig verhindert eine klare Rollenverteilung Doppelarbeit und reduziert Kommunikationsfehler. In etablierten Projektmethoden wie PM² ist die klare Definition von Rollen, Verantwortlichkeiten und Stakeholdern ein zentraler Bestandteil der Projektführung [@european_commission_pm2_2018].

Im Projekthandbuch wurden daher die Projektbeteiligten und Stakeholder wie Auftraggeber, Betreuer und Projektleiter festgehalten. Zusätzlich wurden die Rollen mit Aufgabenbeschreibung dokumentiert, damit Verantwortlichkeiten nachvollziehbar bleiben.

### 3. Terminplanung über Fixtermine und Meilensteine

Für das Schuljahr waren mehrere Fixtermine gegeben, etwa Zwischenpräsentationen und Abgaben. Um diese zuverlässig zu erreichen, habe ich mit einem Meilensteinplan gearbeitet. Meilensteine sind klar definierte Zwischenziele mit überprüfbaren Ergebnissen, wodurch Planung messbar und Fortschritt objektiv bewertbar wird [@european_commission_pm2_2018].

Die Fixtermine wurden in der Projektterminübersicht erfasst, und der Meilensteinplan beschrieb pro Datum konkrete Ergebnisse wie einen sichtbaren UI-Prototyp oder eine implementierte GPS-Funktion. Dadurch waren Abweichungen früh erkennbar.

### 4. Änderungsmanagement (Change Control)

In Softwareprojekten entstehen Änderungswünsche fast zwangsläufig. Ohne Änderungsmanagement führt das schnell zu Scope Creep und zu inkonsistenter Dokumentation. Daher wurde ein klarer Ablauf definiert: Änderungen werden zuerst besprochen, danach dokumentiert und anschließend in Projekthandbuch sowie Backlog nachgezogen. Dieses Vorgehen entspricht dem Grundprinzip, Änderungen kontrolliert zu behandeln und Entscheidungen nachvollziehbar festzuhalten [@european_commission_pm2_2018].

Der konkrete Ablauf bei Änderungen wurde als Prozess im Projekthandbuch beschrieben, von der Team-Besprechung über das Änderungsprotokoll bis zur Aktualisierung von Handbuch und Backlog sowie zur Vorstellung im nächsten Meeting.

### 5. Risikomanagement

Risikomanagement bedeutet, potenzielle Probleme früh zu erkennen und Maßnahmen zu planen, bevor sie eintreten. Gerade bei Diplomarbeiten sind typische Risiken ungenaue Aufwandsschätzungen, Lernkurven, Ressourcenausfälle oder unklare Anforderungen. Ein Risikoregister mit Eintrittswahrscheinlichkeit, Auswirkungen und Gegenmaßnahmen ist ein bewährtes Instrument zur Steuerung [@european_commission_pm2_2018].

Im Projekt wurden Risiken tabellarisch dokumentiert, inklusive Wahrscheinlichkeit, Auswirkungen und Maßnahmen. Als Gegenmaßnahmen wurden unter anderem Zeitpuffer, klare Fixpunkte mit Betreuung sowie frühe Prototypen und Tests zur technischen Absicherung eingesetzt.

### 6. Anforderungsmanagement mit User Stories

Um Anforderungen verständlich und nutzenorientiert zu erfassen, habe ich sie als User Stories formuliert. User Stories fokussieren auf „Wer braucht was und warum?“ und sind dadurch gut priorisierbar. Die bekannte Vorlage „As a … I want … so that …“ ist weit verbreitet und unterstützt die Kommunikation, weil sie Nutzen und Ziel explizit macht [@mountaingoat_user_stories_2025; @atlassian_user_stories_2026]. Wichtig ist dabei, dass eine User Story bewusst kurz bleibt, während Details in der gemeinsamen Klärung entstehen und anschließend durch überprüfbare Kriterien abgesichert werden [@mountaingoat_user_stories_2025].

Im Projekt wurden zentrale Funktionen wie Karte und Standort, standortbasierte Aufgaben und Fortschritt in User-Story-Form dokumentiert. Diese Stories dienten als Grundlage für die Priorisierung in Meilensteinen und als gemeinsame Sprache zwischen Team und Stakeholdern.

### 7. Use-Case-Struktur für Abläufe, Randfälle und Systemzustände

Damit aus einer knappen User Story ein umsetzbarer Ablauf wird, habe ich die Anforderungen zusätzlich in einer Use-Case-ähnlichen Struktur dokumentiert. Diese Struktur macht den Ablauf prüfbar, weil Trigger, Vor- und Nachbedingungen, Akteure, Fehlersituationen und Systemzustände explizit genannt werden. Use Cases sind dafür ein etabliertes Mittel, um funktionale Abläufe klar zu beschreiben und Missverständnisse zu reduzieren [@cockburn_writing_2001].

In den Anwendungsfällen wurden Trigger, Vor- und Nachbedingungen, Akteure, Fehlersituationen und der Systemzustand im Fehlerfall strukturiert beschrieben. Dadurch wurde nachvollziehbar, was das System im Normalfall und in Fehlerfällen tun muss, etwa bei verweigerten Berechtigungen oder Netzwerkproblemen.

### 8. Akzeptanzkriterien mit Given/When/Then (BDD/Gherkin-Stil)

Ein häufiger Grund für Nacharbeit ist, dass „fertig“ subjektiv interpretiert wird. Akzeptanzkriterien definieren deshalb messbar, wann eine Anforderung erfüllt ist. Die Given/When/Then-Form aus dem BDD- und Gherkin-Umfeld ist dafür gut geeignet, weil sie Voraussetzungen, Aktion und erwartetes Ergebnis klar trennt und sich direkt zur Prüfung verwenden lässt [@cucumber_gherkin_reference_2025; @adzic_specification_2011]. Auch in der Projektpraxis werden Akzeptanzkriterien als Brücke zwischen Anforderungen und Testbarkeit genutzt [@atlassian_acceptance_criteria_2026].

Im Projekt wurde der Standardablauf vieler Use Cases explizit über Akzeptanzkriterien beschrieben. Dadurch konnten Anforderungen auch ohne formale Testautomatisierung objektiv abgenommen werden, etwa wenn die Karte die Position zeigt, Marker im Radius sichtbar sind oder die Standortfreigabe verweigert wird.

### 9. Offene Punkte und Entscheidungsfindung (Conversation Points)

In frühen Phasen sind nicht alle Details sofort entscheidbar. Entscheidend ist, dass offene Fragen sichtbar bleiben und nicht untergehen. Dafür wurden Conversation Points genutzt, also kurze Listen von Punkten, die noch zu klären sind, zum Beispiel bei der Update-Strategie für Standorte, bei Radius und Filter, beim Offline-Verhalten oder beim Anti-Cheat-Ansatz. Das unterstützt die schrittweise Präzisierung der Anforderungen und entspricht dem Gedanken, dass Spezifikation und gemeinsame Klärung zusammengehören [@mountaingoat_user_stories_2025; @adzic_specification_2011].

Zu jedem Use Case wurden diese offenen Punkte dokumentiert und als Input für Teamentscheidungen sowie für die Priorisierung der nächsten Arbeitsschritte verwendet.

### 10. Projektcontrolling, Statusberichte und Qualitätssicherung

Damit Fortschritt nicht nur gefühlt, sondern objektiv sichtbar wird, habe ich regelmäßige Statusberichte verwendet. Projektcontrolling bedeutet dabei, den Plan laufend mit dem Ist-Zustand zu vergleichen und bei Abweichungen Maßnahmen abzuleiten. Dieses Prinzip wird auch in etablierten PM-Ansätzen über Monitoring, Control und Maßnahmenableitung betont [@european_commission_pm2_2018].

Parallel dazu ist Qualitätssicherung ein laufender Bestandteil: Anforderungen und Umsetzungen müssen geprüft werden, bevor sie als stabil gelten. Ein verbreiteter Grundgedanke im Testing ist, dass Tests nicht nur Fehler finden, sondern auch Anforderungen und Work Products wie User Stories evaluierbar machen und damit Qualität absichern [@istqb_ctfl_2024].

In der Dokumentation wurden Zeiträume mit einem fixen Schema berichtet, bestehend aus Gesamtstatus, durchgeführten Arbeiten, notwendigen Entscheidungen und nächsten Schritten. Dadurch wurden Abweichungen und Gegenmaßnahmen transparent. Interne Tests der Kernfunktionen sowie Fehlerbehebungen waren ein fixer Teil der Umsetzung, und Meilensteine wurden zusätzlich als Qualitäts-Gates genutzt, sodass vor Präsentationen und Abgaben ein stabiler Zwischenstand vorliegen musste.

## Praktischer Teil – Dependency Conflicts in Flutter-Projekten

Ein wesentlicher Teil meiner praktischen Arbeit im Projekt bestand darin, Dependency Conflicts zu analysieren und zu beheben. In Flutter und Dart werden externe Pakete über pub verwaltet und in der pubspec.yaml als Abhängigkeiten eingetragen [@flutter_using_packages_2026] [@dart_pub_dependencies_2026]. In unserer Diplomarbeit traten Konflikte vor allem dann auf, wenn die lokal installierte Flutter- oder Dart-Version zu alt war oder wenn Dependencies zu neu gewählt wurden und dadurch nicht mehr zur SDK-Version oder zu Flutter-spezifischen Einschränkungen passten, insbesondere bei pinned packages [@dart_pubspec_2025] [@dart_flutter_pinned_packages_2026].

### 1. Grundlagen: Was sind Dependencies und warum können sie kollidieren?

Eine Dependency ist ein externes Paket, das das Projekt benötigt. Pub unterscheidet direkte Dependencies, die im Projekt explizit eingetragen sind, und transitive Dependencies, die indirekt über andere Pakete hineinkommen [@dart_pub_dependencies_2026].

Ein Dependency Conflict liegt vor, wenn pub keine Kombination von Paketversionen finden kann, die alle Anforderungen gleichzeitig erfüllt. In der Praxis zeigt sich das meist als Fehler bei flutter pub get, typischerweise mit der Meldung „version solving failed“ [@dart_pub_get_2025] [@dart_pubgrub_solver_2026]. Der Kern des Problems ist, dass pub für das gesamte Projekt eine konsistente Menge von Paketversionen finden muss, damit alle Constraints zusammenpassen.

### 2. Wie Versionsangaben funktionieren: SemVer, Constraints und Caret-Syntax

Damit Pakete unabhängig voneinander weiterentwickelt werden können, basiert das Ökosystem auf Versionierung und Versionsbereichen statt auf fixen Einzelversionen. Das zentrale Prinzip ist Semantic Versioning mit MAJOR.MINOR.PATCH [@semver_2013] [@dart_pub_versioning_2025].

In der pubspec.yaml werden Versionen meist als Bereich angegeben, etwa als expliziter Bereich wie ">=1.2.0 <2.0.0" oder mit Caret-Syntax wie "^1.2.0", die kompatible Updates innerhalb desselben Major-Bereichs erlaubt [@dart_pub_dependencies_2026] [@dart_pubspec_2025]. Diese Flexibilität ist gewollt, erhöht aber die Chance auf Konflikte, sobald mehrere Pakete unterschiedliche Anforderungen an dieselbe Dependency stellen.

### 3. Warum „version solving failed“ passiert: PubGrub und das „eine Version pro Paket“-Prinzip

Pub verwendet mit PubGrub einen Version-Solver. Dieser versucht, aus allen möglichen Versionen aller Pakete eine Auswahl zu treffen, bei der jede gewählte Version ihre Abhängigkeiten erfüllt, pro Paket im gesamten Projekt nur eine Version aktiv ist und keine unnötigen Pakete gewählt werden [@dart_pubgrub_solver_2026].

Wenn der Solver auf einen Widerspruch stößt, geht er per Backtracking zurück und probiert Alternativen. Gibt es keine Lösung, wird der Konflikt als „version solving failed“ ausgegeben, inklusive einer Kette, welches Paket welche Version verlangt. Genau diese Kette ist meist der wichtigste Diagnosehinweis [@dart_pubgrub_solver_2026].

### 4. Typische Konfliktarten in Flutter (und warum sie in Schulprojekten so häufig sind)

#### 4.1 Direkte Versionskonflikte
Direkte Versionskonflikte entstehen, wenn zwei Dependencies inkompatible Versionen derselben Library verlangen. Wenn etwa Paket A "foo <2.0.0" und Paket B "foo >=2.0.0" fordert, existiert keine Version, die beide Bedingungen gleichzeitig erfüllt.

#### 4.2 Transitive Konflikte („Dependency Hell“)
Sehr häufig kollidieren nicht direkte, sondern transitive Anforderungen. In der Fehlermeldung sieht man dann, dass ein Paket über mehrere Stufen eine bestimmte Version erzwingt [@dart_pub_dependencies_2026]. Gerade in Flutter-Apps wird das durch Plugins verstärkt, weil diese oft viele transitive Abhängigkeiten mitbringen.

#### 4.3 SDK-Constraints: Dart-/Flutter-Version passt nicht
Pakete können Mindestanforderungen an Dart und optional auch an Flutter definieren, zum Beispiel eine Dart-SDK ab Version 3.2.0 und Flutter ab Version 3.22.0. Wenn die lokal installierte SDK darunter liegt, darf pub das Paket nicht auswählen. Pub sucht dann eine ältere, noch kompatible Paketversion, und wenn es diese nicht gibt, entsteht ein unlösbarer Konflikt [@dart_pubspec_2025]. Das war in unserem Projekt eine der häufigsten Ursachen, weil die lokale Flutter- und Dart-Version zeitweise veraltet war, während einzelne Packages bereits neuere SDK-Funktionen oder Constraints voraussetzten.

#### 4.4 Flutter „Pinned Packages“ (besonders relevant in unserem Projekt)
Flutter pinnt bestimmte Paketversionen innerhalb des SDK auf konkrete Versionen, damit eine App mit einer bestimmten Flutter-Version nicht plötzlich durch externe Paket-Releases bricht [@dart_flutter_pinned_packages_2026]. Dadurch muss die eigene pubspec.yaml diese gepinnten Bereiche einschließen, und das gilt auch transitiv. Wenn also ein verwendetes Plugin eine inkompatible Constraint auf ein gepinntes Paket wie path hat, scheitert der Solver [@dart_flutter_pinned_packages_2026]. Für uns war das ein wiederkehrendes Muster, weil Dependency-Versionen teils zu neu oder zu eng eingeschränkt waren.

### 5. Vorgehensweise bei der Diagnose (wie ich Konflikte systematisch zerlegt habe)

Damit das Lösen nicht zum Trial-and-Error wird, bin ich in der Praxis immer gleich vorgegangen. Zuerst habe ich die Fehlermeldung von flutter pub get gelesen, weil sie fast immer zeigt, welches Paket welche Version verlangt und wo der Konflikt liegt [@dart_pub_get_2025] [@dart_pubgrub_solver_2026]. Danach habe ich mit dart pub deps den Dependency-Graph geprüft, um den Ursprung problematischer transitiver Dependencies zu sehen [@dart_pub_deps_2025]. Abschließend habe ich mit dart pub outdated die realistisch auflösbaren Update-Pfade geprüft, statt blind zu aktualisieren [@dart_pub_outdated_2025]. Diese drei Schritte reichten in der Praxis meist aus, um klar zwischen SDK-Upgrade und Dependency-Anpassung zu entscheiden.

### 6. Lösungsstrategien (Beheben von Dependency Conflicts)

#### 6.1 Flutter-/Dart-SDK aktualisieren (sauberste Lösung bei „SDK zu alt“)
Wenn Packages eine neuere SDK voraussetzen, ist ein SDK-Upgrade oft der sinnvollste Weg, weil es die Kompatibilitätsbasis erweitert. Flutter dokumentiert den Update-Prozess über den Befehl flutter upgrade [@flutter_upgrade_2026]. Im Projekt war das häufig die schnellste Lösung, wenn eine Mindest-Dart-Version lokal noch nicht erfüllt war. Konkret wurde bei zu hohen SDK-Constraints die lokale Flutter-Version aktualisiert und danach erneut aufgelöst, um zu prüfen, ob der Konflikt damit bereits verschwindet.

#### 6.2 Dependency-Versionen anpassen (typisch bei „Dependency zu neu“)
Wenn ein SDK-Upgrade nicht möglich oder nicht sinnvoll ist, bleibt meist das Anpassen von Dependency-Versionen und Constraints [@dart_pub_dependencies_2026] [@dart_pubspec_2025]. In der Praxis bedeutete das, zu neue Paketversionen auf kompatible Stände zurückzusetzen und Constraints so zu wählen, dass Flutter-pinned Versionen nicht ausgeschlossen werden [@dart_flutter_pinned_packages_2026].

#### 6.3 Constraints weiten statt unnötig fixieren
Wenn eine Dependency zu eng eingetragen ist, kann das Konflikte verursachen, obwohl eigentlich kompatible Versionen existieren. Flutter nennt das explizit als Workaround bei Pinning-Problemen [@dart_flutter_pinned_packages_2026], und Dart empfiehlt die Caret-Syntax als Standard, weil sie Updates zulässt, aber trotzdem einen oberen Sicherheitsrahmen setzt [@dart_pub_dependencies_2026]. Im Projekt wurden Constraints deshalb wo möglich erweitert, um den Solver nicht unnötig zu blockieren.

#### 6.4 dependency_overrides (kurzfristige Notlösung)
Mit dependency_overrides kann man pub zwingen, eine Version zu verwenden, auch wenn sie nicht zu allen Constraints passt. Flutter und Dart warnen dabei ausdrücklich, weil solche Kombinationen nicht zwingend gemeinsam getestet wurden und Analyse- oder Runtime-Probleme verursachen können [@dart_flutter_pinned_packages_2026] [@dart_pub_dependencies_2026]. Im Projekt wurden Overrides deshalb nur als kurzfristige Maßnahme genutzt, dokumentiert und später wieder entfernt.

#### 6.5 Lockfile bewusst nutzen (Reproduzierbarkeit im Team)
Pub erzeugt mit pubspec.lock die konkret aufgelösten Versionen. Für Application Packages empfiehlt Dart, dieses Lockfile zu committen, damit transitive Updates nicht unbemerkt passieren und alle Entwickler mit denselben Versionen arbeiten [@dart_private_files_2024]. Das reduziert typische Team-Probleme, bei denen derselbe Code auf zwei Rechnern unterschiedlich auflöst. Im Projekt wurde pubspec.lock daher als Stabilitätsanker genutzt, und Änderungen an Dependencies wurden dadurch im Diff transparent.

### 7. Prävention (Verhindern statt Reparieren)

#### 7.1 Toolchain vereinheitlichen (Flutter-Version im Team fixieren)
Viele Konflikte entstehen nicht durch schlechte Dependencies, sondern durch unterschiedliche lokale SDK-Stände. Präventiv hilft daher vor allem eine definierte Flutter-Version als Projektstandard und ein bewusst gesteuertes Upgrade-Vorgehen [@flutter_upgrade_2026].

#### 7.2 Updates geplant durchführen (kleine Schritte statt große Sprünge)
Statt seltener Mega-Upgrades ist es stabiler, regelmäßig den Zustand zu prüfen, etwa was veraltet ist und welche Updates pub tatsächlich sinnvoll auflösen kann. Dafür sind dart pub outdated und die dokumentierten Abhängigkeitsregeln hilfreich [@dart_pub_outdated_2025] [@dart_pub_dependencies_2026].

#### 7.3 Constraints sinnvoll setzen
In der Praxis sollten Constraints weder unnötig eng noch komplett offen gewählt werden. Zu enge Bereiche erzeugen vermeidbare Konflikte, und "any" führt zu unkontrollierten Kombinationen. Sinnvoll sind meist Caret- oder Range-Constraints [@dart_pub_dependencies_2026] [@dart_pub_versioning_2025].

#### 7.4 CI/Build stabilisieren (Lockfile erzwingen)
Wenn ein Lockfile genutzt wird, kann in automatisierten Builds verhindert werden, dass die Dependency-Auflösung plötzlich anders ausfällt. Dart dokumentiert dafür Optionen wie --enforce-lockfile, um sicherzustellen, dass die Auflösung exakt dem Lockfile entspricht [@dart_pub_dependencies_2026] [@dart_pub_get_2025].

### 8. Bezug zur Diplomarbeit: Warum bei uns fast immer „SDK vs. Dependency“ der Kern war

Im Projekt zeigte sich ein typisches Flutter-Schulprojekt-Muster: Die lokale Flutter- und Dart-Version war zeitweise hinter dem Ökosystem zurück, während einzelne Packages bereits neue Mindestanforderungen oder neue transitive Abhängigkeiten mitbrachten [@dart_pubspec_2025]. Zusätzlich entstanden Konflikte durch Flutter pinned packages, weil Flutter bestimmte Paketversionen festlegt, die in der gesamten Auflösung berücksichtigt werden müssen [@dart_flutter_pinned_packages_2026].

Dadurch waren die wirksamen Lösungen in der Praxis meist eindeutig. Entweder musste Flutter aktualisiert werden, wenn die SDK zu alt war [@flutter_upgrade_2026], oder Dependency-Versionen und Constraints mussten so angepasst werden, dass sie zur vorhandenen SDK- und Pinning-Situation passen [@dart_flutter_pinned_packages_2026] [@dart_pub_dependencies_2026].
