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
- Der Ablauf „Vorgehen bei Änderungen“ ist im Projekthandbuch als Prozess beschrieben (Team-Besprechung → Änderungsprotokoll → Aktualisierung Handbuch/Backlog → Vorstellung im nächsten Meeting).

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

## Praktische Arbeit

*Platzhalter*
 
