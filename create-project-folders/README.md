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

## První spuštění

Konfigurace je **přímo ve skriptu** v bloku `KONFIGURACE` na jeho začátku. Po
vložení skriptu do Shortcutu přepiš `PROJECT_BASE_PATH` na svou produkční cestu
a nastav `property CONFIG_DONE : true`. Bez toho se skript odmítne spustit.

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

- **„Nejdřív vyplň PROJECT_BASE_PATH…"** — Pojistka `CONFIG_DONE`. Skript ještě běží na placeholder cestě: uprav `PROJECT_BASE_PATH` v bloku `KONFIGURACE` na začátku skriptu a nastav `property CONFIG_DONE : true`.
- **Safari neběží** — Spusťte Safari, otevřete stránku zakázky a zkuste znovu.
- **„Safari nemá otevřenou stránku zakázky"** — Otevřete zakázkovou stránku v Safari a zkuste znovu.
- **JavaScript nefunguje** — Zapněte menu Develop: Safari → Settings → Advanced → „Show features for web developers". Poté: Develop → Allow JavaScript from Apple Events.
- **Chyba při čtení dat ze Safari** — Skript čte konkrétní HTML strukturu stránky: `<span class="Header1">` s textem „Zakazka cislo: X.Y", a `<td class="TabColHead">` s popisky „Projekt:" / „Klient:" následované `<td class="TabValue">` s hodnotami. Pokud se rozvržení stránky změní, použijte manuální zadání (viz [Fallback](#fallback)).
- **„Složka už existuje"** — Klikněte na „Otevřít složku" pro zobrazení existující struktury. Pro vytvoření nové změňte číslo zakázky nebo název projektu.
- **„Název složky je příliš dlouhý"** — Limit macOS je 255 znaků (skript vynucuje 240). Zkraťte název klienta nebo projektu v zakázce, případně použijte manuální zadání s kratšími názvy.
- **„Disk není připojen"** — Připojte síťový disk `PrintServer` nebo upravte `PROJECT_BASE_PATH` v bloku `KONFIGURACE`.

## Changelog

Viz [CHANGELOG.md](CHANGELOG.md).
