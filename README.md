# AppleScript automatizace pro tiskovou produkci

Automatizace workflow pro tiskové studio - vytváření projektových složek a generování Adobe Bridge hlaviček.

## Skripty

### 1. create-project-folders.applescript
- Extrahuje data ze Safari zakázkového listu
- Vytváří strukturu projektových složek
- Automatické pojmenování podle vzoru: "číslo - klient - projekt"
- Vytváří podsložky: "pracovní", "zdroje" a finální složku "XX_číslo" (XX = poslední dvojčíslí aktuálního roku)

### 2. generate-bridge-header.applescript
- Generuje centrovanou hlavičku pro Adobe Bridge
- Inteligentní zkrácení názvu klienta (odstraňuje s.r.o., a.s. atd.)
- Automatické kopírování do schránky
- Formát: `Klient    TECHNOLOGIE    XX_číslo` (XX = poslední dvojčíslí aktuálního roku)

## Požadavky

- **macOS**
- **Safari** - pro čtení zakázkových listů
- **Adobe Bridge** (volitelné) - pro použití hlaviček

## Instalace

1. Stáhněte skripty z repositáře
2. Upravte cestu k projektovým složkám v `create-project-folders.applescript`:
   ```applescript
   set folderLocation to "/Your/Project/Path" as POSIX file as alias
   ```
3. Otevřete `.applescript` soubory v Script Editor nebo zkompilujte do `.scpt`

### Spouštění klávesovou zkratkou
Pro rychlé spouštění můžete použít **Automator**:
1. Otevřete Automator → vytvořte "Quick Action"
2. Přidejte akci "Run AppleScript" a vložte kód skriptu
3. Uložte jako "Vytvoř projektové složky"
4. V System Preferences → Keyboard → Shortcuts → Services přiřaďte klávesovou zkratku

## Použití

### Vytváření projektových složek
1. Otevřete zakázkový list v Safari
2. Spusťte `create-project-folders.applescript`
3. Zkontrolujte extrahovaná data a potvrďte vytvoření

### Generování Bridge hlavičky
1. Otevřete zakázkový list v Safari
2. Spusťte `generate-bridge-header.applescript`
3. Hlavička se zkopíruje do schránky
4. Vložte do Adobe Bridge (Cmd+V)

---

## Troubleshooting

### Safari vrací chybu při čtení dat

**Symptom:** Dialog "Chyba při čtení dat ze Safari"

**Řešení:**
1. Zkontrolujte, že jste na správné stránce zakázkového listu
2. Zkuste obnovit stránku (Cmd+R)
3. Použijte manuální zadání dat ve formátu: `číslo - klient - projekt`
   - **Příklad:** `12345 - ACME Corp - Logo Redesign`

**Safari DOM struktura:**  
Skript očekává HTML strukturu s elementy:
- `<span class="Header1">` obsahující "Zakázka číslo: X.Y"
- `<td class="TabColHead">` s textami "Projekt:" a "Klient:"
- `<td class="TabValue">` s hodnotami vedle

Pokud se struktura zakázkového listu změní, použijte manuální zadání.

### Složka již existuje

**Symptom:** Alert "Složka již existuje"

**Řešení:**
- Klikněte "Otevřít složku" pro zobrazení existující struktury
- Pokud chcete vytvořit novou, změňte číslo zakázky nebo název projektu

### Disk není připojený

**Symptom:** Alert "Síťový disk není připojen"

**Řešení:**
1. Připojte síťový disk (např. `StudioTwo_T5` v Finderu)
2. Ověřte cestu v souboru skriptu:
   - Otevřete skript v Script Editor
   - Najděte řádek: `property PROJECT_BASE_PATH : "..."`
   - Upravte cestu na vaše umístění
   - Uložte (Cmd+S)
3. Zkuste skript znovu spustit

### Safari není spuštěný

**Symptom:** Alert "Safari není spuštěný"

**Řešení:**
- Spusťte Safari před spuštěním skriptu
- Otevřete zakázkový list
- Zkuste znovu

### Název složky je příliš dlouhý

**Symptom:** Alert "Název složky je příliš dlouhý"

**Řešení:**
- macOS limit pro názvy složek je 255 znaků (skript kontroluje 240)
- Zkraťte název klienta nebo projektu v zakázkovém listě
- Nebo použijte manuální zadání s kratšími názvy

---

## Changelog

Všechny změny jsou dokumentovány v [CHANGELOG.md](CHANGELOG.md).

**Aktuální verze:** 1.1.0 (2026-01-30)

---

## Autor
- **Koncept a testování:** Ladislav Osvald
- **Implementace:** Claude (Anthropic AI)
- **Rok:** 2025