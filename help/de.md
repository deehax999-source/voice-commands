# Hilfe zu Voice Commands

Mit Voice Commands sprichst du eine Anweisung, und Claude Code führt sie auf deinem Rechner aus. Voice Commands ist ein inoffizielles Projekt und gehört nicht zu Anthropic.

## Die Tastenkürzel

- **{toggle}**: Aufnahme starten. Nochmal drücken beendet die Aufnahme und schickt den Befehl ab.
- **{cancel}**: Abbrechen. Stoppt eine laufende Aufnahme, einen Befehl, der gerade startet oder läuft, und das Vorlesen.
- **{window}**: Dieses Antwortfenster öffnen. Du findest es auch als **Voice Commands** in deinem Programmstarter.
- **{send}**: Den erkannten Befehl sofort senden, ohne die Bedenkzeit abzuwarten. Während der Aufnahme beendet es auch die Aufnahme.
- **{type}**: Ein Textfeld öffnen, um einen Befehl einzutippen, etwa wenn du gerade nicht sprechen kannst oder kein Mikrofon angeschlossen ist. Enter sendet, Shift+Enter beginnt eine neue Zeile, Esc schließt. Ein getippter Befehl startet ohne Bedenkzeit und läuft sonst wie ein gesprochener.

Die Kürzel änderst du unter **Einstellungen → Tastenkürzel**.

## So läuft ein Sprachbefehl ab

1. **Aufnahme:** Drücke {toggle} und sprich. Oben am Bildschirm zeigt eine Statusleiste die Aufnahmezeit. Nach 5 Minuten endet die Aufnahme von selbst.
2. **Erkennung:** Drücke {toggle} noch einmal. Deine Sprache wird auf deinem Rechner in Text umgewandelt. Füllwörter wie „äh“ werden entfernt.
3. **Bedenkzeit:** Eine Benachrichtigung zeigt, was verstanden wurde. Du hast jetzt einige Sekunden, um mit {cancel} abzubrechen, falls etwas falsch verstanden wurde. Mit {send} startet er sofort. Die Zeit stellst du in den Einstellungen ein, dort lässt sie sich auch ausschalten.
4. **Ausführung:** Claude arbeitet. Die Statusleiste zeigt, wie lange schon. Weitere Befehle warten so lange und kommen danach dran.
5. **Antwort:** Eine Benachrichtigung zeigt den Anfang der Antwort. Mit **Antwort öffnen** kommst du hierher. Auf Wunsch wird die Antwort auch vorgelesen.

**Tipp:** Sprich frei. Wenn du dich korrigierst („nein, ich meine …“), zählt die letzte Version. Ist ein Befehl unklar oder hätte er Folgen, die sich nicht rückgängig machen lassen, fragt Claude in der Antwort nach, statt ihn auszuführen.

## Weitermachen und Rückfragen

Gibst du innerhalb von 5 Minuten nach dem letzten Befehl wieder einen, setzt Claude dasselbe Gespräch fort und kennt den Zusammenhang. Danach beginnt ein neues Gespräch. Die Zeit stellst du unter **Einstellungen → Gespräch automatisch fortsetzen** ein: aus, 5, 15 oder 30 Minuten. Ein langes Gespräch kann Claude auch in die Irre führen, etwa wenn es frühere Wünsche nach Dateien weiter befolgt. Mit Sätzen wie „mach weiter“ oder „wo wir aufgehört haben“ setzt Claude auch später das letzte Gespräch fort.

## Was Claude darf

Claude hat einen eigenen Ordner, `~/Voice-Commands`. Dort darf es ohne Rückfrage lesen und schreiben. Für alles andere erscheint ein Ja-Nein-Fenster:

- **Dateien lesen** außerhalb dieses Ordners, auch Suchen in Ordnern.
- **Dateien anlegen oder ändern** außerhalb dieses Ordners.
- **Befehle ausführen.** Dabei siehst du den Befehl und Claudes eigene Beschreibung dazu. Entscheidend ist der Befehl. Befehle, die Dateien löschen oder Administratorrechte verlangen, sind extra markiert.
- **Andere Werkzeuge**, zum Beispiel verbundene Dienste.

Im Ja-Nein-Fenster ist **Nein** vorausgewählt, und **Ja** lässt sich erst nach einer Sekunde anklicken, damit kein versehentlicher Klick etwas erlaubt. Antwortest du nicht innerhalb von 2 Minuten, gilt das als **Nein**; ein Balken zeigt die verbleibende Zeit. Nach einem Nein sucht Claude keinen anderen Weg, sondern sagt dir, was es nicht tun konnte.

**Alle Berechtigungen für diese Anfrage:** Mit diesem Knopf fragt Claude bis zum Ende des aktuellen Befehls nicht mehr nach. Vorher kommt eine zweite Warnung. Nur wenn Claude bekannte Orte, an denen oft Passwörter oder Schlüssel liegen, direkt lesen oder ändern will, fragt es trotzdem. Befehle laufen dann ohne Rückfrage und können auch diese Orte erreichen. Voice Commands erkennt sie nur an festen Namen und kann andere übersehen. Nutze das nur, wenn du genau weißt, was der Befehl tun wird.

**Befehle ohne Rückfrage:** In den Einstellungen unter „Befehle ohne Rückfrage“ stehen Befehle, die ohne Ja-Nein-Abfrage laufen: Systeminfos wie `date` oder `uptime` und lesende Dateibefehle wie `ls`, `cat` oder `find`. Wie weit jeder Dateibefehl ohne Abfrage reicht, wählst du neben ihm: nur Arbeitsordner, dazu die freigegebenen Ordner, dazu deine persönlichen Ordner (Dokumente, Downloads, Bilder …), dein Home-Ordner ohne versteckte Ordner, dazu Systemdateien (/etc, /usr …), systemweit oder dazu eigene Ordner, die du mit dem Ordner-Knopf daneben festlegst. Der Arbeitsordner ist immer dabei; anderswo fragt Claude nach. Jeden davon kannst du ausschalten und später wieder einschalten. Unter „Eigene Befehle“ fügst du auf eigene Gefahr weitere hinzu; dann läuft alles ohne Abfrage, was mit diesen Wörtern beginnt. Bekannte lesende Programme wie `rg`, `fd`, `diff`, `sort` oder `sha256sum` bekommen dabei ebenfalls ein Auswahlmenü für die Reichweite, anfangs nur der Arbeitsordner; Optionen, mit denen sie etwas ausführen oder schreiben könnten, fragen immer. Alle anderen eigenen Befehle dürfen jeden Ort lesen, den Claude ihnen nennt. Lies vorher den Hinweis „Eigene Befehle auf eigene Gefahr“. Claude bekommt bei jedem Befehl eine aktuelle Liste dessen, was gerade ohne Abfrage geht, und nutzt bevorzugt diese Wege. Die Liste gibt keine Rechte frei, entschieden wird weiterhin bei jedem Aufruf. Bei bekannten Risiken, etwa Programmen, die Dateien löschen, Befehle aus Projektdateien ausführen oder Zugangsdaten anzeigen, nennt die Rückfrage das Risiko. Programme wie `printenv`, `ps`, `journalctl`, `gpg` oder `gh` zeigen Zugangsdaten, ohne einen Ort zu nennen; für sie greift der Schutz für Orte mit Passwörtern oder Schlüsseln nicht. sudo, Shells und Programme wie python oder env lassen sich nicht freigeben. Eingebaute Befehle wie `wc` lassen sich nicht noch einmal als eigene hinzufügen; ihre Reichweite stellst du im Auswahlmenü neben ihnen ein. Alles gilt nur für einfache Aufrufe ohne Verkettung, Umleitung oder eingebettete Befehle, und bekannte Orte mit Passwörtern oder Schlüsseln fragen immer. Diese erkennt Voice Commands aber nur an festen Namen, etwa `~/.ssh`, `.env` oder Dateien mit „password“ im Namen. Zugangsdaten an anderen Orten, etwa in Einstellungsdateien von Programmen, in `/etc` oder in einer eigenen Notiz, erkennt es nicht. Je weiter ein Befehl reicht, desto eher kann Claude solche Dateien ohne Abfrage lesen. Deshalb warnt die Auswahl von „Home ohne versteckte Ordner“, „+ Systemdateien“ und „Systemweit“ vorher.

**Freigegebene Ordner:** In den Einstellungen (Zahnrad) kannst du unter „Freigegebene Ordner“ Ordner dauerhaft freigeben, so wie in der Desktop-App. Dort darf Claude ohne Rückfrage lesen, und wenn du „Lesen und ändern“ wählst, auch Dateien anlegen und ändern. Befehle fragen trotzdem, ebenso bekannte Orte mit Passwörtern oder Schlüsseln und Dateien, die Programme starten können, etwa Einstellungen in `~/.config/hypr` oder Git-Hooks. Passwörter und Schlüssel erkennt Voice Commands nur an bekannten Namen wie `~/.ssh` oder `.env`; andere Zugangsdaten, etwa in einer eigenen Notiz, liest Claude in freigegebenen Ordnern ohne Rückfrage. Was Claude liest, wird an Anthropic gesendet. Gib deshalb nur die Ordner frei, die Claude wirklich braucht, und nicht deinen ganzen Home-Ordner. Tipps dazu stehen in den Einstellungen unter „Worauf du achten solltest“. Bevor du „Lesen und ändern“ wählst oder deinen Home-Ordner, einen Systemordner oder einen Einstellungsordner wie `~/.config` freigibst, kommt eine Warnung.

Im Internet suchen und Webseiten lesen darf Claude ohne Rückfrage.

## Programme im Hintergrund

Claude kann Programme auf einem unsichtbaren Bildschirm bedienen, ohne deinen Bildschirm zu benutzen. Dafür macht es Bildschirmfotos dieses unsichtbaren Bildschirms. Diese Programme schließen sich nach 15 Minuten ohne Aktivität, und nicht gespeicherte Inhalte gehen dabei verloren. Sag Claude also, dass es Ergebnisse speichern soll.

Das Starten und Bedienen fragt nicht nach. Startet Claude ein Programm mit etwas anderem als einer Internetadresse, etwa einer Datei, kommt eine Rückfrage. Editoren, Entwicklungsumgebungen, Dateimanager und Terminals lassen sich gar nicht starten, weil sie Befehle ausführen können. Ein laufendes Programm kann Claude frei bedienen wie du selbst, etwa über die Adressleiste eines Browsers Dateien öffnen und im Bildschirmfoto ansehen. Deshalb laufen Hintergrundprogramme in einem geschützten Bereich (bubblewrap): Bekannte Orte mit Passwörtern oder Schlüsseln wie `~/.ssh` und die Profile deiner Browser sind für sie leer, andere Programme und deren Umgebung unsichtbar. Ein Browser im Hintergrund startet daher mit einem leeren Profil, ohne deine Anmeldungen. Ändern können sie nur deinen Arbeitsordner `~/Voice-Commands` und Ordner, die du zum Lesen und Ändern freigegeben hast; Downloads landen in `~/Voice-Commands/Downloads`. Ausgenommen sind ein freigegebener Home-Ordner selbst und versteckte Ordner wie `~/.config`, und `.git`-Ordner bleiben schreibgeschützt. Was sie anderswo in deinem Home-Ordner schreiben, etwa über einen Speichern-Dialog, verschwindet, sobald sie schließen. Lesen können sie deine übrigen Dateien wie du. Programme mit eigener Skript- oder Makrofunktion wie LibreOffice, GIMP oder Blender sind erlaubt; ein Skript darin läuft mit denselben Grenzen wie das Programm. Dafür lädt das Paket beim Start des Rechners das Kernelmodul `overlay`.

## Das Antwortfenster

- Hier stehen die letzten 50 Antworten, die neueste oben, mit Uhrzeit und deinem Befehl. Lange Antworten zeigen nur ihre ersten drei Zeilen; **Ganze Antwort anzeigen** klappt sie auf, **Weniger anzeigen** wieder zu. Beim Öffnen des Fensters sind alle wieder zugeklappt. Kopieren und Vorlesen nehmen immer die ganze Antwort.
- **Dateien unter einer Antwort:** Dateien, die Claude bei diesem Befehl angelegt oder geändert hat. Ein Klick öffnet sie mit dem passenden Programm, ein Rechtsklick zeigt sie in ihrem Ordner. Programme und Skripte werden zur Sicherheit nicht direkt geöffnet, sondern nur in ihrem Ordner gezeigt. Ausgegraut heißt, die Datei gibt es nicht mehr.
- **Ordner-Knopf oben:** öffnet den Arbeitsordner `~/Voice-Commands`, in dem Claude seine Dateien speichert. Claude sortiert neue Dateien dort nach Thema in Unterordner, zum Beispiel `Rezepte`, und nimmt dafür einen passenden vorhandenen Ordner oder legt einen neuen an. Vorhandene Dateien verschiebt es nicht. Nennst du einen Ordner oder Dateinamen, nimmt Claude diesen.
- **Lautsprecher-Knopf:** liest die ganze Antwort vor. Nochmal drücken stoppt.
- **Fragezeichen-Knopf oben (F1):** öffnet diese Hilfe. Ihr Lautsprecher-Knopf oben links liest sie vor; nochmal drücken oder die Hilfe schließen stoppt.
- **Kopieren:** kopiert die Antwort mit ihren Markdown-Zeichen, damit die Struktur beim Einfügen erhalten bleibt. Du kannst Text auch markieren.
- **In Claude Desktop weiterführen:** öffnet das Gespräch in der Claude-Desktop-App, falls du sie hast. Dort gelten die Ja-Nein-Abfragen von Voice Commands nicht. Unter Linux ist diese Verbindung nicht offiziell und kann mit einem Update aufhören zu funktionieren. Getestet ist sie mit dem Paket `claude-desktop` aus dem AUR oder dem CachyOS-Repository. Mit anderen Varianten, etwa Flatpak, Snap oder einem AppImage, klappt sie vielleicht nicht.
- **Mülleimer:** löscht die Antwort und das Gespräch aus dem Speicher von Claude Code. Ein paar Sekunden lang kannst du das mit **Rückgängig** zurücknehmen. Gehört die Antwort zu einem fortgesetzten Gespräch, zeigt eine Rückfrage alle Antworten dieses Gesprächs. Claude Code speichert ein Gespräch nur als Ganzes, deshalb löscht **Ganzes Gespräch löschen** sie alle. **Nur aus der Übersicht löschen** entfernt nur diese eine Antwort aus dem Fenster; in der Aufzeichnung von Claude Code bleibt sie dann erhalten, bis die Frist unter **Gespräche aufbewahren** abläuft.
- **Modell:** Oben links wählst du das Claude-Modell für Sprachbefehle. Normale Claude-Code-Sitzungen bleiben davon unberührt.
- Ein Streifen oben warnt, wenn ein Tastenkürzel nicht funktioniert oder doppelt belegt ist.

## Die Einstellungen

Das Zahnrad oben rechts öffnet die Einstellungen. Änderungen gelten erst, wenn du sie in der Leiste am unteren Rand übernimmst; mit „Verwerfen“ bleibt alles, wie es war. Schließt du die Einstellungen mit offenen Änderungen, fragt Voice Commands nach.

- **Erscheinungsbild:** hell, dunkel oder wie das System. Gilt auch für die Ja-Nein-Fenster und die Statusleiste.
- **Antworten vorlesen:** liest neue Antworten automatisch vor, entweder nur den ersten Absatz oder alles, langsam, normal oder schnell. Code und Internetadressen werden übersprungen. Mit Piper klingt die Stimme natürlicher. Ohne Piper wird eine Systemstimme benutzt, falls eine eingerichtet ist.
- **Gesprochene Sprache:** hilft der Spracherkennung. „Automatisch erkennen“ ist praktisch, wenn du mal Deutsch und mal Englisch sprichst.
- **Bedenkzeit vor dem Start:** 3, 5 oder 10 Sekunden zum Abbrechen, oder aus. Ausgeschaltet startet ein Befehl, sobald er erkannt ist, und lässt sich nur noch während der Ausführung mit {cancel} stoppen.
- **Tastenkürzel:** Mit **Ändern** drückst du einfach die neue Kombination. Solange sind die Kürzel des Desktops für höchstens 20 Sekunden aus, damit jede Taste ankommt. Escape bricht ab. Ist eine Taste schon für etwas anderes belegt, wird sie nicht übernommen. Mach sie dann zuerst frei, unter Hyprland in deinen Hyprland-Einstellungen, unter KDE Plasma in den Systemeinstellungen unter Tastatur → Tastenkurzbefehle, unter GNOME in den Einstellungen unter Tastatur → Tastenkürzel ansehen und anpassen. GNOME fragt beim ersten Mal, ob das Fenster seine Kürzel kurz abschalten darf. Das geht unter Hyprland, KDE Plasma und GNOME, auf anderen Desktops legst du die Kürzel in deinen Tastatureinstellungen fest.
- **Gespräche aufbewahren:** wie lange die Gespräche mit allem, was Claude gelesen hat, gespeichert bleiben.
- **Öffnen, wenn Claude fertig ist:** zeigt jede Antwort sofort in diesem Fenster.
- **Verlauf löschen:** löscht alle gespeicherten Antworten und alle Gespräche der Sprachbefehle im Speicher von Claude Code. Danach lässt sich kein Gespräch mehr fortsetzen. Dateien, die Claude in `~/Voice-Commands` gespeichert hat, bleiben erhalten.

## Deine Daten

- **Bleibt auf deinem Rechner:** deine Stimme, die Spracherkennung und das Vorlesen.
- **Geht an Anthropic:** der erkannte Text, alles, was Claude lesen darf, und die Bildschirmfotos der Hintergrundprogramme. Sprachbefehle zählen zu den Grenzen deines Claude-Tarifs.
- **Gespeichert wird:** die letzten 50 Antworten und die letzten 1000 Zeilen des Protokolls in `~/Voice-Commands`. Bildschirmfotos liegen nur im Arbeitsspeicher. Sie werden gelöscht, sobald die Hintergrundprogramme schließen, spätestens beim Herunterfahren oder Abmelden.
- **Gesprächsdateien von Claude Code:** Claude Code speichert jedes Gespräch in `~/.claude/projects`, mit allem, was Claude gelesen hat, auch den Bildschirmfotos, die es sich angesehen hat. Voice Commands löscht seine eigenen Gespräche nach der Zeit, die du unter **Einstellungen → Datenschutz** wählst: 1, 7 oder 30 Tage, Standard 7 Tage. Danach lassen sie sich nicht mehr fortsetzen oder in Claude Desktop öffnen. Deine anderen Claude-Code-Sitzungen bleiben unberührt.
- Was Claude für dich in `~/Voice-Commands` speichert, gehört dir und wird nie automatisch gelöscht.

Andere Stimmen in der Nähe deines Mikrofons und fremde Daten in Programmen können ebenfalls an Anthropic gehen. Nutze Voice Commands nicht mit Daten, die du nicht weitergeben darfst.

## Wenn etwas nicht klappt

- **Die Tastenkürzel reagieren nicht:** Schau, ob oben im Fenster ein Warnstreifen steht. Führe sonst `voice-commands-setup` im Terminal aus.
- **„Nichts erkannt“:** Prüfe das Mikrofon und sprich etwas länger. Unter **Gesprochene Sprache** kannst du die Sprache fest einstellen.
- **Fehler bei Claude:** Die Details stehen in `~/Voice-Commands/log.txt`. Prüfe, ob Claude Code angemeldet ist, indem du einmal `claude` im Terminal startest.
- **Hintergrundprogramme starten nicht:** Sie brauchen bubblewrap und das Kernelmodul `overlay`. Führe `voice-commands-setup` aus, es nennt, was fehlt. Meldet `sudo modprobe overlay`, das Modul sei nicht zu finden, wurde der Kernel seit dem letzten Start aktualisiert: Starte den Rechner neu.
- **Keine Stimme beim Vorlesen:** Installiere `piper-tts` aus dem AUR oder mit `pipx install piper-tts` (vorher `sudo pacman -S python-pipx`) und führe danach `voice-commands-setup` aus. Die pipx-Version aktualisierst du selbst mit `pipx upgrade piper-tts`.
- **Hyprland zeigt eine Warnung zu Voice Commands:** Führe `voice-commands-setup` aus. Steht danach noch eine Warnung im Fenster, ändere das betroffene Tastenkürzel.

## Deinstallieren

Entferne das Paket mit `sudo pacman -Rns voice-commands`. Was danach noch zu löschen ist, steht in der README unter `/usr/share/doc/voice-commands/README.md`.
