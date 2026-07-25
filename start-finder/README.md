# Start Finder

Přihlašovací skript — připojí síťové disky a otevře Finder s předkonfigurovanými panely pro tiskovou produkci.

## Proč existuje

Po přihlášení k macOS je potřeba ručně připojit síťové disky a otevřít Finder s konkrétními složkami v záložkách. Tento skript celý proces automatizuje — počká na síť, připojí všechny disky a otevře Finder s přednastavenými panely v list view.

## Prerekvizity

- macOS 13+ (Ventura nebo novější)
- **Accessibility permission** (Nastavení systému → Soukromí a zabezpečení → Zpřístupnění) — nutné pro vytváření záložek přes klávesové zkratky
- Síťový přístup k `fileserver.local`
- Shortcuts.app

## Instalace

1. Otevřete Shortcuts.app (Zkratky)
2. Vytvořte novou zkratku
3. Přidejte akci „Run AppleScript" (Spustit AppleScript)
4. Vložte obsah souboru `start-finder.applescript`
5. Pojmenujte zkratku (např. „Start Finder")
6. Pro automatické spuštění při přihlášení: Nastavení systému → Obecné → Přihlašovací položky → přidejte zkratku
7. Nebo přiřaďte klávesovou zkratku / přidejte do menu baru

## První spuštění

Konfigurace je **přímo ve skriptu** v bloku `KONFIGURACE` na jeho začátku (žádný
externí soubor). Po vložení skriptu do Shortcutu:

1. Přepiš hodnoty v bloku `KONFIGURACE` na své — server, síťové disky (`SERVER_LIST`), cesty (`PANEL_PATHS`).
2. Nastav `property CONFIG_DONE : true`.

Bez kroku 2 se skript odmítne spustit a upozorní tě — pojistka proti běhu
s neupravenými placeholder hodnotami.

## Konfigurace

Upravte `property` konstanty na začátku skriptu:

| Property | Popis | Příklad |
|----------|-------|---------|
| `CHECK_SERVER` | Server pro kontrolu dostupnosti sítě | `"fileserver.local"` |
| `NETWORK_TIMEOUT` | Max. čekání na síť v sekundách | `60` |
| `TAB_DELAY` | Prodleva mezi vytvářením záložek — zvyšte na pomalejších strojích | `0.6` |
| `WINDOW_BOUNDS` | Pozice a velikost okna Finderu `{left, top, right, bottom}` — **upravte podle svého monitoru** | `{50, 50, 1600, 1000}` |
| `SERVER_LIST` | Seznam síťových disků k připojení `{dName, dAddr}` | viz skript |
| `PANEL_PATHS` | POSIX cesty pro záložky Finderu (první = hlavní okno) | viz skript |

## Použití

1. Skript se spustí automaticky při přihlášení (nebo ručně)
2. Počká na dostupnost síťového serveru (max. 60 sekund)
3. Pokud čeká déle než 5 sekund, zobrazí notifikaci „Čekám na síť..."
4. Připojí všechny síťové disky, které ještě nejsou připojené
5. Otevře Finder s jedním oknem a záložkami pro každou nakonfigurovanou cestu
6. Zobrazí výslednou notifikaci — buď úspěch, nebo seznam nepřipojených/přeskočených

## Chování při chybách

- **Síť nedostupná:** Po vypršení timeoutu zobrazí dialog a skript se ukončí
- **Disk se nepodařilo připojit:** Pokračuje s ostatními, nepřipojené zobrazí v závěrečné notifikaci
- **Cesta neexistuje:** Záložka se přeskočí, přeskočené cesty se zobrazí v notifikaci
- Skript nikdy neblokuje dialogem (kromě kritického timeoutu) — běží na pozadí při přihlášení

## Důležité upozornění

Funkce `createPanels` při spuštění **zavře všechna existující okna Finderu** (`close every window`). Toto chování je záměrné (čistý stav pro přihlášení), ale při ručním spuštění může být destruktivní — neuložená práce v oknech Finderu bude ztracena.

## Řešení problémů

- **„Nejdřív vyplň konfigurační blok…"** — Pojistka `CONFIG_DONE`. Skript ještě běží na placeholder hodnotách: uprav blok `KONFIGURACE` na začátku skriptu (server, `SERVER_LIST`, `PANEL_PATHS`) a nastav `property CONFIG_DONE : true`. Vzorovou konfiguraci najdeš v [`examples/start-finder-config.txt`](../examples/start-finder-config.txt).
- **„Síť nedostupná" po vypršení timeoutu** — Zkontrolujte připojení k síti; ověřte, že `CHECK_SERVER` míří na správný hostitel; na pomalých sítích zvyšte `NETWORK_TIMEOUT`.
- **„Not allowed assistive access"** — Skript vyžaduje Accessibility permission: Nastavení systému → Soukromí a zabezpečení → Zpřístupnění → povolit Shortcuts.app (nebo terminál, ze kterého skript spouštíte)
- **`WINDOW_BOUNDS` neodpovídá monitoru** — Zjistěte rozměry svého displeje příkazem v Script Editoru: `tell application "Finder" to get bounds of window of desktop`. Výsledek použijte jako hodnotu `WINDOW_BOUNDS`.

## Changelog

Viz [CHANGELOG.md](CHANGELOG.md).

## Známá omezení

- Záložky Finderu se vytvářejí přes `keystroke "t" using command down` (System Events) — Finder nemá nativní AppleScript příkaz pro vytváření záložek
- Vyžaduje Accessibility permission pro odesílání klávesových zkratek
- `WINDOW_BOUNDS` je hardcoded pro konkrétní rozlišení monitoru — musí se upravit při změně displeje
- `TAB_DELAY` může být potřeba zvýšit na starších strojích
- Klíče `dName`/`dAddr` se používají místo `name` kvůli kolizi s klíčovým slovem Finderu
