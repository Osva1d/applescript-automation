# Generate Bridge Header

Skript generuje formátovanou hlavičku pro Adobe Bridge ze zakázkových dat v Safari. Hlavička se automaticky zkopíruje do schránky a volitelně se otevře produkční složka v Bridge — stačí vložit přes Cmd+V.

## Proč existuje

Při přípravě tiskových souborů v Adobe Bridge je potřeba do záhlaví vložit hlavičku s názvem klienta, technologií tisku a číslem zakázky. Hlavička musí být přesně zarovnaná na 85 znaků — klient vlevo, technologie uprostřed, číslo zakázky vpravo. Ruční formátování mezerami je zdlouhavé a náchylné k chybám. Při 20–40 operacích týdně tento skript ušetří desítky minut a eliminuje chyby v zarovnání.

## Prerekvizity

- macOS 13+ (Ventura nebo novější)
- Safari — povolení „Allow JavaScript from Apple Events"
- Adobe Bridge (libovolná verze 2020+, detekce je automatická)
- Přístup k síťovému disku `PrintServer` (pro vyhledání produkční složky)
- Shortcuts.app

## Instalace

1. Otevřete Shortcuts.app (Zkratky)
2. Vytvořte novou zkratku
3. Přidejte akci „Run AppleScript" (Spustit AppleScript)
4. Vložte obsah souboru `generate-bridge-header.applescript`
5. Pojmenujte zkratku (např. „Bridge hlavička")
6. Přiřaďte klávesovou zkratku: Zkratka → Nastavení → Přidat klávesovou zkratku

## Konfigurace

Upravte `property` konstanty na začátku skriptu:

| Property | Popis | Příklad |
|----------|-------|---------|
| `TOTAL_HEADER_WIDTH` | Celková šířka hlavičky ve znacích | `85` |
| `MAX_CLIENT_LENGTH` | Max. délka jména klienta | `25` |
| `MIN_SPACING` | Min. počet mezer mezi sekcemi | `2` |
| `PROJECT_BASE_PATH` | Cesta pro vyhledání produkční složky | `"/Volumes/PrintServer/Projects/Print Production"` |

## Použití

1. Otevřete zakázkovou stránku v Safari
2. Spusťte skript klávesovou zkratkou
3. Skript extrahuje číslo zakázky, klienta a technologii
4. Zobrazí náhled formátované hlavičky
5. Po potvrzení zkopíruje hlavičku do schránky
6. Vyhledá produkční složku a otevře ji v Bridge
7. Po kliknutí na OK přepne focus na Bridge — stačí Cmd+V

### Formát hlavičky

```
Klient ABC                    Digitální tisk                         26_0042
```

Klient vlevo, technologie centrovaná, rok_číslo vpravo. Celkem 85 znaků.

## Fallback

- Pokud JavaScript extrakce ze Safari selže, zobrazí se dialog pro ruční zadání: `číslo - klient - technologie`
- Pokud produkční složka neexistuje, hlavička se stále zkopíruje do schránky
- Pokud Bridge nelze otevřít, zobrazí se chybová zpráva s důvodem
- Pokud je jméno klienta příliš dlouhé, automaticky se zkrátí na celá slova

## Zpracování klientského jména

Skript automaticky:
1. Odstraní právní formu (s.r.o., a.s., GmbH, Ltd. atd.)
2. Ořízne trailing interpunkci
3. Pokud je jméno stále příliš dlouhé, zkrátí na celá slova

## Sdílený kód

Funkce `getCurrentYearSuffix()` je sdílena s projektem [`create-project-folders`](../create-project-folders/). Při úpravě synchronizujte obě kopie ručně.

## Proč 85 znaků

Hlavička Bridge má pevnou šířku 85 znaků. Tato hodnota odpovídá šířce záhlaví v Adobe Bridge panelu — delší řetězce se ořezávají, kratší narušují vizuální zarovnání.

## Známá omezení

- Bridge nemá AppleScript slovník — otevírání složky funguje přes `open -a` (shell)
- Funguje pouze se Safari
- Závisí na konkrétní DOM struktuře zakázkové stránky
- Verze Bridge se detekuje automaticky z `/Applications/`, ale vyžaduje instalaci v default umístění

## Deploy do veřejného repo

Veřejná verze tohoto skriptu je v repo `applescript-automation`.
Deploy postup viz `_deploy/PLACEHOLDERS.md` v kořeni incubátoru.

Při deployi se reálné hodnoty v property sekcích automaticky nahrazují
placeholdery (skript `_deploy/anonymize.sh`).

## Changelog

### v2.3.0 (2026-03)
- Aktuální verze

---

## For GitHub

### Generate Bridge Header — Formatted Clipboard Headers for Adobe Bridge

A macOS AppleScript automation that generates precisely formatted header strings for Adobe Bridge from web-based order data, copies them to clipboard, and optionally opens the production folder in Bridge.

**The problem:** In print production, every job needs a header in Adobe Bridge containing the client name, print technology, and order number — formatted to exactly 85 characters with specific alignment (left / center / right). Composing this by hand with spaces means counting characters, adjusting alignment, and frequently getting it wrong. With 20–40 Bridge operations per week, this is a significant time sink.

**What it does:**
- Extracts client name, technology, and order number from the active Safari tab
- Strips legal entity suffixes (s.r.o., a.s., GmbH, Ltd., etc.) from client names
- Truncates long names at word boundaries
- Generates a fixed-width header with precise center alignment using integer division
- Shows a preview of the formatted header before copying
- Searches for the matching production folder on the shared volume
- Opens the folder in Adobe Bridge automatically
- Detects the installed Bridge version dynamically (no hardcoded year)
- Falls back to manual input if automatic extraction fails

**How it runs:** As a Shortcuts.app shortcut triggered by a keyboard shortcut. Extract → preview → confirm → paste into Bridge.

**Requirements:** macOS 13+, Safari with JavaScript from Apple Events enabled, Adobe Bridge.
