# AppleScript automatizace pro tiskovou produkci

Automatizace workflow pro tiskove studio -- vytvareni projektovych slozek, generovani Adobe Bridge hlavicek a automaticke nastaveni Finderu pri prihlaseni.

> **Poznamka:** Skripty obsahuji placeholder hodnoty pro cesty a nazvy serveru.
> Pred pouzitim upravte `property` konstanty na zacatku kazdeho skriptu
> podle vasi konfigurace (viz sekce [Konfigurace](#konfigurace)).

## Skripty

### 1. create-project-folders.applescript (v1.3.0)

- Extrahuje data ze Safari zakazkoveho listu
- Vytvari strukturu projektovych slozek
- Automaticke pojmenovani podle vzoru: "cislo - klient - projekt"
- Vytvari podslozky: "pracovni", "zdroje" a finalni slozku "XX_cislo" (XX = posledni dvojcisli aktualniho roku)
- Kompatibilni se Shortcuts.app

### 2. generate-bridge-header.applescript (v2.3.0)

- Generuje centrovanou hlavicku pro Adobe Bridge (85 znaku, font Menlo)
- Inteligentni zkraceni nazvu klienta (odstranovani pravnich forem)
- Automaticke kopirovani do schranky
- Vyhledani produkcni slozky a otevreni v Bridge
- Dynamicka detekce verze Adobe Bridge
- Kompatibilni se Shortcuts.app

### 3. start-finder.applescript (v14.4.1)

- Automaticke pripojeni sitovych disku pri prihlaseni (AFP/SMB)
- Kontrola dostupnosti site pred pripojenim s konfigurovatelnym timeoutem
- Vytvoreni Finder okna s panely (taby) pro produkcni slozky
- Oznameni o stavu -- uspesne pripojeni nebo seznam neprpojenych disku

## Pozadavky

- **macOS 13+** (Ventura nebo novejsi)
- **Safari** -- pro cteni zakázkovych listu (create-project-folders, generate-bridge-header)
  - Povoleny JavaScript z Apple Events (Safari → Develop → Allow JavaScript from Apple Events)
- **Shortcuts.app** -- pro spousteni skriptu
- **Adobe Bridge** (volitelne) -- pro pouziti hlavicek (generate-bridge-header)
- **Accessibility permission** -- nutne pro start-finder (Nastaveni systemu → Soukromi a zabezpeceni → Zpristupneni)

## Instalace

Vsechny tri skripty se spousteji pres **Shortcuts.app**:

1. Otevrte Shortcuts.app (Zkratky)
2. Vytvorte novou zkratku
3. Pridejte akci "Run AppleScript" (Spustit AppleScript)
4. Vlozte obsah prislusneho `.applescript` souboru
5. Pojmenujte zkratku (napr. "Vytvor slozky", "Bridge hlavicka", "Start Finder")
6. Volitelne: prirad'te klavesovou zkratku nebo pridejte do menu baru

### start-finder -- automaticke spusteni pri prihlaseni

1. Nastaveni systemu → Obecne → Prihlasovaci polozky
2. Pridejte zkratku "Start Finder"
3. Skript se spusti automaticky po prihlaseni

## Konfigurace

Kazdy skript ma na zacatku `property` konstanty, ktere je treba upravit pro vase prostredi.

### create-project-folders.applescript

| Property | Popis | Vychozi (placeholder) |
|----------|-------|-----------------------|
| `PROJECT_BASE_PATH` | Korenova cesta pro vytvareni slozek | `"/Volumes/PrintServer/Projects/Print Production"` |
| `SUBFOLDER_NAMES` | Nazvy podslozek | `{"pracovni", "zdroje"}` |
| `DANGEROUS_CHARS` | Znaky nahrazene podtrzitkem | `{"/", "\\", ":", "*", "?", "<", ">", "\|"}` |

### generate-bridge-header.applescript

| Property | Popis | Vychozi (placeholder) |
|----------|-------|-----------------------|
| `PROJECT_BASE_PATH` | Cesta pro vyhledani produkcni slozky | `"/Volumes/PrintServer/Projects/Print Production"` |
| `TOTAL_HEADER_WIDTH` | Sirka hlavicky ve znacich (Menlo font) | `85` |
| `MAX_CLIENT_LENGTH` | Maximalni delka jmena klienta | `25` |
| `MIN_SPACING` | Minimalni mezera mezi elementy | `2` |

### start-finder.applescript

| Property | Popis | Vychozi (placeholder) |
|----------|-------|-----------------------|
| `CHECK_SERVER` | Server pro kontrolu dostupnosti site | `"fileserver.local"` |
| `SERVER_LIST` | Seznam sitovych disku k pripojeni `{dName, dAddr}` | viz skript |
| `PANEL_PATHS` | POSIX cesty pro panely Finderu (prvni = hlavni okno) | viz skript |
| `NETWORK_TIMEOUT` | Max. cekani na sit v sekundach | `60` |
| `TAB_DELAY` | Prodleva mezi vytvarenim zalozek (zvyste na pomalejsich strojich) | `0.6` |
| `WINDOW_BOUNDS` | Pozice a velikost okna Finderu `{left, top, right, bottom}` | `{50, 50, 1600, 1000}` |

## Pouziti

### Vytvareni projektovych slozek

1. Otevrte zakazkovy list v Safari
2. Spust'te zkratku "Vytvor slozky"
3. Zkontrolujte extrahovana data a potvrdte vytvoreni
4. Slozka se vytvori a zobrazi ve Finderu

### Generovani Bridge hlavicky

1. Otevrte zakazkovy list v Safari
2. Spust'te zkratku "Bridge hlavicka"
3. Hlavicka se zkopiruje do schranky
4. Skript vyhleda produkcni slozku a nabidne otevreni v Bridge
5. Vlozte do Adobe Bridge (Cmd+V)

### Nastaveni Finderu (start-finder)

1. Skript se spusti automaticky pri prihlaseni (nebo rucne)
2. Pocka na dostupnost sitoveho serveru (max. 60 sekund)
3. Pokud ceka dele nez 5 sekund, zobrazi notifikaci "Cekam na sit..."
4. Pripoji vsechny sitove disky, ktere jeste nejsou pripojene
5. Otevre Finder s jednim oknem a zalozkami pro kazdou nakonfigurovanou cestu
6. Zobrazi vyslednou notifikaci

## Sdileny kod

Skripty `create-project-folders` a `generate-bridge-header` sdileji funkce:
- `getCurrentYearSuffix()` -- posledni dvojcisli aktualniho roku
- `extractJSONValue()` -- extrakce hodnot z JSON retezce

Zmeny v techto funkcich je treba synchronizovat rucne mezi obema skripty.

---

## Troubleshooting

### Safari vraci chybu pri cteni dat

**Symptom:** Dialog "Chyba pri cteni dat ze Safari"

**Reseni:**
1. Zkontrolujte, ze jste na spravne strance zakazkoveho listu
2. Zkuste obnovit stranku (Cmd+R)
3. Pouzijte manualni zadani dat ve formatu: `cislo - klient - projekt`
   - **Priklad:** `12345 - ACME Corp - Logo Redesign`

**Safari DOM struktura:**
Skript ocekava HTML strukturu s elementy:
- `<span class="Header1">` obsahujici "Zakazka cislo: X.Y"
- `<td class="TabColHead">` s textami "Projekt:" a "Klient:"
- `<td class="TabValue">` s hodnotami vedle

Pokud se struktura zakazkoveho listu zmeni, pouzijte manualni zadani.

### Slozka jiz existuje

**Symptom:** Alert "Slozka jiz existuje"

**Reseni:**
- Kliknete "Otevrit slozku" pro zobrazeni existujici struktury
- Pokud chcete vytvorit novou, zmente cislo zakazky nebo nazev projektu

### Disk neni pripojeny

**Symptom:** Notifikace "Sitovy disk neni pripojen"

**Reseni:**
1. Pripojte sitovy disk ve Finderu
2. Overte cestu v souboru skriptu:
   - Otevrte skript v Script Editor
   - Najdete radek: `property PROJECT_BASE_PATH : "..."`
   - Upravte cestu na vase umisteni
   - Ulozte (Cmd+S)
3. Zkuste skript znovu spustit

### Safari neni spusteny

**Symptom:** Alert "Safari neni spusteny"

**Reseni:**
- Spust'te Safari pred spustenim skriptu
- Otevrte zakazkovy list
- Zkuste znovu

### Nazev slozky je prilis dlouhy

**Symptom:** Alert "Nazev slozky je prilis dlouhy"

**Reseni:**
- macOS limit pro nazvy slozek je 255 znaku (skript kontroluje 240)
- Zkrat'te nazev klienta nebo projektu v zakázkovem liste
- Nebo pouzijte manualni zadani s kratsimi nazvy

### start-finder: "Not allowed assistive access"

**Symptom:** System dialog o chybejicim Accessibility pristupu

**Reseni:**
- Nastaveni systemu → Soukromi a zabezpeceni → Zpristupneni
- Povolte Shortcuts.app (nebo terminal, ze ktereho skript spoustite)

### start-finder: Sit neni dostupna

**Symptom:** Dialog "Sit neni dostupna" po vyprseni timeoutu

**Reseni:**
- Zkontrolujte sitove pripojeni
- Overte ze `CHECK_SERVER` ukazuje na spravny server
- Zvyste `NETWORK_TIMEOUT` pokud je sit pomala

### start-finder: WINDOW_BOUNDS neodpovida monitoru

**Reseni:**
- Zjistete rozmery sveho displeje prikazem v Script Editoru:
  `tell application "Finder" to get bounds of window of desktop`
- Vysledek pouzijte jako hodnotu `WINDOW_BOUNDS`

---

## Znama omezeni

- **Safari-dependent:** create-project-folders a generate-bridge-header vyzaduji specifickou HTML strukturu zakazkoveho listu
- **Zalozky Finderu:** start-finder vytvari zalozky pres `keystroke "t" using command down` (System Events) -- Finder nema nativni AppleScript prikaz pro vytvareni zalozek
- **Accessibility:** start-finder vyzaduje Accessibility permission pro odesilani klavesovych zkratek
- **WINDOW_BOUNDS:** Hardcoded pro konkretni rozliseni monitoru -- musi se upravit pri zmene displeje
- **TAB_DELAY:** Na pomalejsich strojich muze byt potreba zvysit hodnotu
- **Zadny batch mode:** Jeden projekt / jedna hlavicka najednou
- **Zadne undo:** Vytvorene slozky je treba mazat rucne
- **close every window:** start-finder pri spusteni zavre vsechna existujici okna Finderu -- zamerne pro cisty stav pri prihlaseni, ale destruktivni pri rucnim spusteni

---

## Changelog

Vsechny zmeny jsou dokumentovany v [CHANGELOG.md](CHANGELOG.md).

---

## Autor

- **Koncept a testovani:** Ladislav Osvald
- **Implementace:** Claude (Anthropic AI)
- **Rok:** 2025-2026
