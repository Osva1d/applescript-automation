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

## Autor
- **Koncept a testování:** Ladislav Osvald
- **Implementace:** Claude (Anthropic AI)
- **Rok:** 2025