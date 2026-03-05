\newpage
## Projektabschlussbericht

### Erfolgsmessung

#### Erreichung Leistungs-/Qualitätsziele
Das ursprünglich vereinbarte Hauptziel – die Entwicklung einer **eigenen, schulisch anpassbaren Schnitzeljagd-App** als Ersatz für eine externe Lösung – wurde **im Kern erreicht**. Die Anwendung deckt die wesentlichen Funktionsbereiche ab (standortbasierter Ablauf, Stationslogik, Interaktion in der App) und ist so aufgebaut, dass sie **langfristig wiederverwendbar und erweiterbar** bleibt.

**Abweichungen und Umgang damit**
- Zu Beginn wurden Umfang und Zeitaufwand unterschätzt, wodurch einzelne Qualitätsaspekte (z. B. „Nice-to-have“-Features, Feinschliff in UI/UX) zeitweise zugunsten der Kernfunktionalität zurückgestellt wurden.
- Technische Probleme, insbesondere **Dependency Conflicts** (Flutter SDK/Package-Versionen), führten dazu, dass mehr Zeit in Stabilisierung und Build-Fähigkeit investiert werden musste als ursprünglich geplant.
- Gegenmaßnahmen:
  - Fokus auf „Must-have“-Anforderungen und schrittweiser Ausbau (iteratives Vorgehen).
  - Konsistentes Testen zentraler Abläufe nach größeren Änderungen.
  - Vereinheitlichung der Toolchain (Flutter-Version) und bewusster Umgang mit Paketversionen, um die Build-Stabilität zu sichern.

In Summe wurde damit die geforderte Funktionalität zuverlässig erreicht; Abweichungen betrafen primär Umfang/Polish, nicht das Kernziel.

#### Erreichung Terminziele
Die Terminziele konnten **nicht durchgehend** im ursprünglichen Zeitplan eingehalten werden. Insbesondere in der frühen Projektphase kam es zu Verzögerungen, da der Projektstart organisatorisch und zeitlich unterschätzt wurde und zunächst nur geringe konkrete Umsetzungsarbeit erfolgte.

**Begründung für Verzögerungen**
- Unterschätzung der Initialphase (Setup, Architekturentscheidungen, Abstimmung, Toolchain).
- Technische Blocker durch **Dependency-/SDK-Konflikte**, die Builds verzögert und geplante Arbeitspakete unterbrochen haben.
- Notwendigkeit, Anforderungen im Detail zu klären (z. B. Ablaufentscheidungen, Trigger-Logik, Anti-Schummel-Ansätze), bevor stabil implementiert werden konnte.

**Maßnahmen**
- Neu-Strukturierung über Meilensteine mit klaren Lieferobjekten.
- Regelmäßige Statusberichte mit Maßnahmenableitung, um Abweichungen sichtbar zu machen.
- Priorisierung: zuerst Stabilität + Kernabläufe, danach Erweiterungen.

Durch diese Maßnahmen konnten die späteren Projektphasen deutlich strukturierter abgearbeitet werden, sodass zentrale Abgaben/Präsentationsstände planbarer erreicht wurden, auch wenn die frühe Abweichung nicht vollständig „aufholbar“ war.

#### Erreichung Kosten-/Aufwandsziele
Ein monetäres Budget konnte im Wesentlichen eingehalten werden, da überwiegend auf **kostenfreie Entwicklungswerkzeuge** und schulische Infrastruktur zurückgegriffen wurde (Open-Source/Free Tools, eigene Endgeräte, schulische Betreuung). Zusätzliche direkte Kosten sind nicht in relevantem Ausmaß entstanden.

Beim **Zeit-/Aufwandsbudget** gab es jedoch Abweichungen:
- Der tatsächliche Aufwand lag phasenweise über der Planung, insbesondere durch:
  - Setup- und Integrationsaufwand,
  - Build-/Dependency-Probleme (Flutter SDK vs. Paketversionen),
  - zusätzliche Abstimmungen durch Änderungswünsche bzw. Detailklärungen.
- Gegenmaßnahmen:
  - Reduktion bzw. Verschiebung von „Nice-to-have“-Umfang.
  - Klare Priorisierung nach Nutzen und Umsetzbarkeit.
  - Dokumentierte Änderungsprozesse, um Scope Creep zu vermeiden.

### Reflexion / Lessons Learned

#### Teamarbeit
**Was gut gelaufen ist**
- Klare Arbeitsteilung (Projektmanagement, Backend, Frontend) hat Zuständigkeiten transparent gemacht.
- Gemeinsame Abstimmungen ermöglichten, dass Anforderungen und Umsetzung konsistent geblieben sind.
- Bei konkreten Blockern (z. B. Build-Probleme) konnte gezielt Unterstützung organisiert werden.

**Was weniger gut gelaufen ist**
- In der frühen Phase fehlte ein konsequenter Rhythmus aus Planung, Umsetzung und Kontrolle, wodurch sich Startverzögerungen aufgebaut haben.
- Toolchain-/Dependency-Themen (unterschiedliche lokale SDK-Stände) haben Zusammenarbeit und Reproduzierbarkeit teilweise erschwert.

**Wichtigste Erkenntnis**
- Für Schulprojekte ist nicht „mehr Meetings“, sondern **frühe Klarheit** entscheidend: gleiche Toolchain, klarer Minimalumfang, und definierte Fixpunkte für Entscheidungen.

#### Projektmanagement
**Erkenntnisse**
- Ein pragmatischer Mix aus agilen Elementen (iterativ, priorisiert, inkrementell) und klassischem Controlling (Meilensteine, Risiken, Statusberichte) hat sich bewährt.
- Besonders hilfreich waren:
  - ein definierter Änderungsprozess (damit Dokumentation und Umsetzung synchron bleiben),
  - sichtbare Risiken mit Maßnahmen,
  - regelmäßige Statusberichte, die nicht nur berichten, sondern konkrete nächste Schritte festlegen.

**Was ich nächstes Mal früher machen würde**
- Frühzeitige Stabilisierung der Toolchain (Flutter-Version fixieren, Dependency-Strategie festlegen).
- Früher einen „Minimum Viable Stand“ definieren, der immer buildbar ist (stabile Basis), und erst danach Feature-Ausbau.
- Frühere und konsequentere Milestone-Gates (z. B. „Build muss grün sein“ als harte Regel vor Feature-Merge).

#### Sonstige Lernerfahrungen
- Technisch: Dependency Management in Flutter/Dart ist nicht nur „Pakete updaten“, sondern ein aktiver Teil der Projektarbeit (Version-Constraints, SDK-Kompatibilität, Lockfiles, Pinning).
- Organisatorisch: Dokumentation ist dann wertvoll, wenn sie Entscheidungen und Änderungen nachvollziehbar macht (nicht nur „Protokoll“, sondern Steuerungsinstrument).
- Produktbezogen: Bei Anwendungen für Schuleinsatz ist Benutzerführung entscheidend – Abläufe müssen klar, robust und für unterschiedliche Nutzergruppen verständlich sein.

### Nachhaltigkeitsanalyse

Die Arbeit an „GeoQuest“ leistet vor allem in den Bereichen **Bildung, digitale Infrastruktur und nachhaltige Nutzung** Beiträge. Relevant betroffen sind insbesondere folgende Sustainable Development Goals (SDGs):

- **SDG 4 – Hochwertige Bildung**  
  GeoQuest unterstützt Lernen außerhalb des klassischen Unterrichts durch eine motivierende, spielerische Form (Schnitzeljagd). Lehrkräfte können Inhalte in Aufgabenform pädagogisch sinnvoll einsetzen und an die Klasse anpassen. Dadurch wird Lernen praxisnaher, aktiver und potenziell inklusiver, weil verschiedene Aufgabenformate möglich sind (z. B. Wissensfragen, Beobachtungsaufgaben).

- **SDG 9 – Industrie, Innovation und Infrastruktur**  
  Durch die Eigenentwicklung entsteht eine langfristig wartbare digitale Lösung für eine schulische Anwendung. Die App reduziert Abhängigkeiten von Drittanbietern, kann erweitert werden und schafft eine technische Grundlage, die künftige Jahrgänge weiterverwenden können.

- **SDG 12 – Nachhaltige/r Konsum und Produktion**  
  Indem die Schule eine eigene Lösung nutzt statt laufend externe Apps zu verwenden, wird die Abhängigkeit von externen Plattformen und deren Änderungen reduziert. Die Anwendung ist so ausgelegt, dass sie **wiederverwendbar** ist (jährliche Schnitzeljagd) und nicht jedes Jahr „neu angeschafft“ oder neu eingelernt werden muss.

- **SDG 17 – Partnerschaften zur Erreichung der Ziele**  
  Das Projekt entsteht in Kooperation zwischen Schülerteam, Schule, Auftraggeber und Betreuung. Diese Zusammenarbeit stärkt Wissenstransfer und ermöglicht, dass reale Anforderungen in eine nachhaltige Lösung übersetzt werden.

**Mögliche negative Aspekte / Risiken**
- Nutzung von Smartphones verursacht Energieverbrauch und setzt Geräteverfügbarkeit voraus. Dieser Effekt ist jedoch im Projektkontext begrenzt (kurzzeitige Nutzung zu Veranstaltungszwecken).  
- Wichtig bleibt ein verantwortungsvoller Umgang mit Daten (z. B. Standortdaten) durch möglichst sparsame Speicherung und klare Zweckbindung.

Insgesamt überwiegt der positive Beitrag, da GeoQuest eine wiederverwendbare, schulisch anpassbare Lösung schafft und Lernprozesse modernisiert, ohne dauerhaft zusätzliche Ressourcen zu benötigen.
