# AppleScript automatizace pro tiskovou produkci na macOS

[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

> Tři macOS AppleScript automatizace, které odstraňují opakované kroky z tiskového
> workflow — připojení disků, zakládání projektových složek a formátování hlaviček
> pro Adobe Bridge. Každá běží jako zkratka v Shortcuts.app, spouštěná klávesou.

**Jazyk:** [English](README.md) · Čeština

Repozitář obsahuje **tři nezávislé skripty**. Každý má vlastní README a changelog —
tato stránka je rozcestník.

---

## Co repozitář obsahuje

| Skript | Co dělá | Dokumentace |
|--------|---------|-------------|
| **start-finder** | Počká na síť, připojí všechny sdílené disky a otevře Finder s přednastavenými panely v list view | [README](start-finder/README.md) · [CHANGELOG](start-finder/CHANGELOG.md) |
| **create-project-folders** | Načte údaje o zakázce z aktivní karty Safari a vytvoří standardizovanou strukturu projektových složek (`čísloZakázky - klient - projekt`) na sdíleném disku | [README](create-project-folders/README.md) · [CHANGELOG](create-project-folders/CHANGELOG.md) |
| **generate-bridge-header** | Sestaví hlavičku pro Adobe Bridge s pevnou šířkou (85 znaků) z údajů o zakázce, zkopíruje ji do schránky a otevře odpovídající produkční složku v Bridge | [README](generate-bridge-header/README.md) · [CHANGELOG](generate-bridge-header/CHANGELOG.md) |

### Proč existují

- **start-finder** — po každém přihlášení k macOS je potřeba ručně připojit síťové disky a otevřít Finder na konkrétních složkách. Skript celou sekvenci provede bez obsluhy.
- **create-project-folders** — studio s 8–15 novými zakázkami týdně potřebuje ke každé složku s přesnou konvencí názvu. Ručně to znamená přepínat mezi prohlížečem a Finderem, kopírovat text a kontrolovat formát.
- **generate-bridge-header** — každá zakázka potřebuje v Bridge hlavičku s klientem, technologií tisku a číslem zakázky, zarovnanou přesně na 85 znaků (vlevo / uprostřed / vpravo). Ruční skládání mezerami znamená počítat znaky a chybovat. Při 20–40 operacích týdně to narůstá.

---

## Společné konvence

- **Běží ze Shortcuts.app** — každý skript se vloží do akce „Run AppleScript" a spouští klávesovou zkratkou nebo jako přihlašovací položka. Žádný instalátor, žádný build.
- **Konfigurace je přímo ve skriptu** — jasně označený blok `KONFIGURACE` na začátku drží hodnoty, které je potřeba změnit (server, disky, cesty). Žádný externí konfigurační soubor: protože instalace je copy-paste zdroje, tvoje kopie je od začátku soukromá.
- **Pojistka `CONFIG_DONE`** — každý skript začíná `property CONFIG_DONE : false` a odmítne se spustit, dokud ji nepřepneš na `true`. Brání prvnímu spuštění nad placeholder hodnotami s matoucí hláškou „disk není připojen".
- **České uživatelské rozhraní** — dialogy a notifikace česky; komentáře v kódu anglicky.
- **Defenzivní ve výchozím stavu** — `try / on error` kolem každé vnější hranice, `quoted form of` u každé shellové cesty, kontrola dostupnosti disku před každou operací se soubory.

---

## Požadavky

- **OS:** macOS 13+ (Ventura a novější)
- **Shortcuts.app** — odtud se skripty spouštějí
- **Safari se zapnutým „Allow JavaScript from Apple Events"** — pro dva skripty, které čtou údaje o zakázce z webové stránky
- **Adobe Bridge** — jen pro `generate-bridge-header`
- **Accessibility permission** — pro `start-finder` (vytváří záložky Finderu přes klávesové zkratky)

---

## První kroky

Není co stahovat ani sestavovat — zdrojový kód *je* výsledný produkt:

1. Otevři `.applescript` soubor daného skriptu v tomto repozitáři a zkopíruj jeho obsah.
2. V Shortcuts.app vytvoř novou zkratku, přidej akci **Run AppleScript** a vlož zdroj.
3. Uprav blok `KONFIGURACE` na začátku: nahraď placeholder hodnoty (server, disky, cesty) svými.
4. Nastav `property CONFIG_DONE : true`.
5. Přiřaď klávesovou zkratku, nebo zkratku přidej mezi přihlašovací položky.

Podrobnosti ke každému skriptu (tabulka konfigurace, použití, řešení problémů) jsou
v jeho README, odkazy v tabulce výše.

> **Poznámka k placeholder hodnotám.** Cesty a hostnames v repozitáři
> (`fileserver.local`, `/Volumes/PrintServer/…`) jsou neutrální příklady, ne reálné
> prostředí. Nahraď je svými.

---

## Licence

Licence MIT. Copyright (C) 2025–2026 Ladislav Osvald. Viz [`LICENSE`](LICENSE).

Volně k použití, kopírování, úpravám i distribuci (včetně komerční), při zachování
copyrightové poznámky. Poskytováno „tak jak je", bez jakékoli záruky.

---

## Autor

Ladislav Osvald (Osva1d), 2025–2026.
