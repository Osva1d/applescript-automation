# Create Project Folders

Skript automaticky vytváří projektovou strukturu složek na základě dat ze zakázkové stránky v Safari. Stačí mít otevřenou zakázku, spustit klávesovou zkratkou — a složky jsou připravené.

## Proč existuje

Při zakládání nového tiskového projektu je potřeba ručně vytvořit složku se správným názvem (číslo zakázky, klient, název projektu) a uvnitř ní pracovní podsložky. Při 8–15 nových zakázkách týdně to znamená opakované kopírování údajů ze systému, přejmenování složek a kontrolu formátu. Tento skript celý proces redukuje na jedno stisknutí klávesy.

## Prerekvizity

- macOS 13+ (Ventura nebo novější)
- Safari — povolení „Allow JavaScript from Apple Events" (Safari → Develop → Allow JavaScript from Apple Events)
- Přístup k síťovému disku `PrintServer` (nebo úprava `PROJECT_BASE_PATH`)
- Shortcuts.app (součást macOS)

## Instalace

1. Otevřete Shortcuts.app (Zkratky)
2. Vytvořte novou zkratku
3. Přidejte akci „Run AppleScript" (Spustit AppleScript)
4. Vložte obsah souboru `create-project-folders.applescript`
5. Pojmenujte zkratku (např. „Projektové složky")
6. Přiřaďte klávesovou zkratku: Zkratka → Nastavení → Přidat klávesovou zkratku

## Konfigurace

Upravte `property` konstanty na začátku skriptu:

| Property | Popis | Příklad |
|----------|-------|---------|
| `PROJECT_BASE_PATH` | Kořenová cesta pro vytváření složek | `"/Volumes/PrintServer/Projects/Print Production"` |
| `SUBFOLDER_NAMES` | Seznam podsložek v každém projektu | `{"pracovni", "zdroje"}` |
| `DANGEROUS_CHARS` | Znaky nahrazované podtržítkem v názvech | `{"/", "\\", ":", "*", "?", "<", ">", "\|"}` |

## Použití

1. Otevřete zakázkovou stránku v Safari
2. Spusťte skript klávesovou zkratkou
3. Skript extrahuje číslo zakázky, klienta a název projektu
4. Zobrazí potvrzovací dialog s náhledem názvu složky
5. Po potvrzení vytvoří složku a podsložky
6. Nabídne otevření složky ve Finderu

### Vytvořená struktura

```
<číslo> - <klient> - <projekt>/
├── pracovni/
├── zdroje/
└── <RR>_<číslo>/          ← RR = poslední dvě číslice roku (např. 26 pro 2026)
```

## Fallback

Pokud JavaScript extrakce ze Safari selže (nesprávná stránka, chybějící DOM elementy), zobrazí se dialog pro ruční zadání ve formátu:

```
číslo - klient - název projektu
```

Pokud zadáte nesprávný formát, skript zobrazí chybovou hlášku s tím, co bylo zadáno a co bylo očekáváno.

## Známá omezení

- Funguje pouze se Safari (Chrome/Firefox nemají AppleScript API pro JavaScript)
- Závisí na konkrétní struktuře DOM zakázkové stránky (`span.Header1`, `td.TabColHead`)
- Nekontroluje, zda síťový disk má dostatek místa
- Název složky je omezen na znaky povolené souborovým systémem — nebezpečné znaky se nahrazují podtržítkem

## Sdílený kód

Funkce `getCurrentYearSuffix()` je sdílena s projektem [`generate-bridge-header`](../generate-bridge-header/). Při úpravě synchronizujte obě kopie ručně.

## Řešení problémů

- **„Safari nemá otevřenou stránku zakázky"** — Otevřete zakázkovou stránku v Safari a zkuste znovu.
- **JavaScript nefunguje** — Zapněte menu Develop: Safari → Settings → Advanced → „Show features for web developers". Poté: Develop → Allow JavaScript from Apple Events.
- **„Disk není připojen"** — Připojte síťový disk `PrintServer` nebo upravte `PROJECT_BASE_PATH` ve skriptu.

## Deploy do verejneho repo

Verejna verze tohoto skriptu je v repo `applescript-automation`.
Deploy postup viz `_deploy/PLACEHOLDERS.md` v koreni incubatoru.

Pri deployi se realne hodnoty v property sekcich automaticky nahrazuji
placeholdery (skript `_deploy/anonymize.sh`).

## Changelog

### v1.3.0 (2026-03)
- Aktualni verze

---

## For GitHub

### Create Project Folders — Automated Project Directory Setup for Print Production

A macOS AppleScript automation that reads order data from a web-based order management system (via Safari) and creates a standardized project folder structure on a shared volume.

**The problem:** In a print production studio handling 8–15 new orders per week, each order requires a folder with a specific naming convention (`orderNumber - clientName - projectName`) and a set of subfolders. Doing this manually means switching between browser and Finder, copying text, creating folders, and double-checking names. Multiply by 10+ orders per week, and it adds up to hours of repetitive work per month.

**What it does:**
- Extracts order number, client name, and project name from the active Safari tab via JavaScript DOM injection
- Sanitizes text for filesystem safety (removes special characters, collapses whitespace)
- Shows a confirmation dialog with the exact folder name before creating anything
- Creates the full folder hierarchy in one step
- Offers to reveal the new folder in Finder after creation
- Falls back to manual input if automatic extraction fails

**How it runs:** As a Shortcuts.app shortcut triggered by a keyboard shortcut. One keypress, one confirmation, done.

**Requirements:** macOS 13+, Safari with JavaScript from Apple Events enabled.
