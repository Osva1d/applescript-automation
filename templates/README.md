# <Název Skriptu>

<Jedna až dvě věty: co skript dělá a pro koho.>

## Proč existuje

<Konkrétní bolest, kterou řeší: co se dělalo ručně, jak často, kolik to stálo času.
Číslo pomáhá — „8–15 zakázek týdně", „20–40 operací týdně".>

## Prerekvizity

- macOS 13+ (Ventura a novější)
- Shortcuts.app
- <další: Safari s „Allow JavaScript from Apple Events", Adobe Bridge, Accessibility permission…>

## Instalace

1. Otevři `<slug>.applescript` a zkopíruj obsah.
2. V Shortcuts.app vytvoř zkratku, přidej akci **Run AppleScript**, vlož zdroj.
3. Přiřaď klávesovou zkratku (nebo přidej mezi přihlašovací položky).

## První spuštění

Konfigurace je **přímo ve skriptu** v bloku `KONFIGURACE` na jeho začátku (žádný
externí soubor). Po vložení do Shortcutu:

1. Přepiš hodnoty v bloku `KONFIGURACE` na své.
2. Nastav `property CONFIG_DONE : true`.

Bez kroku 2 se skript odmítne spustit a upozorní tě — pojistka proti běhu
s neupravenými placeholder hodnotami.

## Konfigurace

| Property | Význam | Výchozí (placeholder) |
|---|---|---|
| `CONFIG_DONE` | Pojistka — přepni na `true` po vyplnění | `false` |
| `<PROPERTY>` | <co ovlivňuje> | `"<placeholder>"` |

## Použití

<Krok za krokem, co uživatel udělá a co se stane.>

## Řešení problémů

- **„Nejdřív vyplň konfigurační blok…"** — Pojistka `CONFIG_DONE`; viz [První spuštění](#první-spuštění).
- **<symptom v uvozovkách>** — <příčina a náprava>.

## Známá omezení

- <co skript neumí a proč; technické důvody, ne omluvy>

## Changelog

Viz [CHANGELOG.md](CHANGELOG.md).
