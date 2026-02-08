# Aufgabenstellung 

## Auftraggeber
Auftraggeber dieser Diplomarbeit ist Herr Klaus Kepplinger von der HTL Leoben, der für die Organisation der Schnitzeljagd der ersten Jahrgänge am Ende des Schuljahres verantwortlich ist. Die Idee zur Diplomarbeit entstand aus dem Bedarf, die bisher verwendete externe Lösung durch eine eigens entwickelte Anwendung zu ersetzen, um unabhängiger von Drittanbietern zu sein und die Durchführung der Schnitzeljagd flexibler zu gestalten.

Der Auftraggeber verspricht sich von dieser Arbeit eine langfristig einsetzbare, an die schulischen Anforderungen angepasste Anwendung, die organisatorische Abläufe vereinfacht, technische Probleme reduziert und zukünftig problemlos erweitert oder angepasst werden kann.

## Ausgangssituation

Eine allgemeine Aufgabenstellung 

* Was ist die derzeitige Situation ? 
* Wie wird derzeit gearbeitet ?


### So gehen Zitate

Hier ein einzel Zitat eines Buches das auf der Seite 17 zu finden ist:  
([@hattie_lernen_2013] S. 17) 

Zitatsammlung:  
(vergleich dazu @heise oder @t3n)  
[@hattie_lernen_2013, S. 33-35; außerdem @leeb_einfuhrung_2016, S. 6 f.]

Zitat ohne Autor  
Hattie sagte bla bla [-@hattie_lernen_2013]

Name des Autors mit Jahr in Klammern  
@hattie_lernen_2013 sagte einmal bla bla bla

Auch Videos kann man Zitieren wi Zum Biespiel hier [@Zatko15] in dieser Referenz.

Hier noch ein Zitat mit Seitenangabe [[@Zatko15] Seite 5f.]

Man darf auch ChatGPT oder andere KIs befragen um Wissen zu erlangen. Dazu muss allerdings ein PDF Log des exakten Chats in die Metadata.yaml eingetragen werden und der dort eingetragene `short-prompt` auch in der bib Datei eingefügt werden. Dann könnten indirekte Zitate so aussehen [@gpt-pandoc] oder auch so [@gpt-atomaufbau].

Wichtig ist es, das beim Author die verwendete KI eingetragen wird (mit Versionsnummern - so genau wie möglich), beim title eine kurze Referenz zum Prompt und beim Jahr - das Jahr in dem die Abfrage gemacht wurde. Das hat dem `short-prompt` aus der metadata.yaml zu entsprechen.

~~~~~
@unpublished{gpt-pandoc,
  author = {{ChatGPT 4.0}},
  title  = {Was ist Pandoc ?},
  year   = {2024},
  url={https://chat.openai.com/c/ef535195-0e39-4d5c-9c85-cdb7ec18ad03},
  urldate = {2023-02-29}
}
~~~~~ 

Oben sieht man wie ein korrekter Bibtech Eintrag für eine ChatGPT Konversation aussieht. Zusätzlich wurden hier bei URL noch die url des Chats eingetragen - was zwar praktisch ist, uns allerdings nicht von der Pflicht entbindet den Chatverlauf in der DA als PDF einzufügen.
Anzumerkein ist ebenfalls noch das wir hier ein `unpublished` Tag verwenden weil wir hier eben Quellen verwenden die in dieser Form nicht gepublished wurden.

### Systembeschreibung Y 

### Systembeschreibung Z 
