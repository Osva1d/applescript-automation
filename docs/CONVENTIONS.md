# Konvence — applescript-automation

Vytěženo z kódu (2026-07-26), ne vymyšleno dopředu. Popisuje, co tři skripty
v tomto repu **reálně dělají**. Když se kód a tento dokument rozejdou, měř kód.

Rozdělení podle **vynutitelnosti**:

| značka | co to znamená |
|---|---|
| 🔒 **vynuceno** | zastaví běh nebo push |
| 📋 **šablona** | v `templates/` — kopíruj, nepiš znovu |
| 📝 **prosa** | nikdo to nehlídá; drž se toho, nebo to změň vědomě |

> **Proč jiné konvence než `extendscript-automation`:** jiný jazyk, žádný build,
> jiná instalace (copy-paste do Shortcuts.app místo souboru v Presets). Sjednocovat
> to, co se liší oprávněně, by byl churn za vzhled.

---

## 🔒 Vynuceno

- **`CONFIG_DONE` guard** — každý skript začíná `property CONFIG_DONE : false`
  a odmítne běžet, dokud ji uživatel nepřepne na `true`. Chrání před prvním během
  nad placeholder hodnotami (jinak by spadl na „nepřipojený svazek" a příčina by
  byla neviditelná).
- **Identita commitů** — `git config --global user.email` = noreply + GitHub
  „Block command line pushes that expose my email". Push se skutečnou adresou neprojde.

## 📋 Šablony (`templates/`)

- `script-header.applescript` — hlavička + `KONFIGURACE` blok + guard + `on run` kostra
- `README.md` — kostra README skriptu
- `CHANGELOG.md` — Keep a Changelog kostra

---

## 📝 Kód

**Hlavička skriptu** — pět polí v pořadí `Script / Version / Author / Updated /
Description`, rámovaná `-- ===`. `Author` je vždy **`Ladislav Osvald`**.

**`Updated:` = datum verze**, ne datum poslední editace. Musí odpovídat datu
poslední položky v `CHANGELOG.md`. Ručně udržované „datum editace" duplikovalo git
a driftlo — jako datum verze se mění jen při vydání.

**Konfigurace je ve skriptu**, ne v externím souboru:
```applescript
-- ===========================================================================
-- KONFIGURACE — po vložení do Shortcutu přepiš hodnoty na své a nastav
-- CONFIG_DONE na true. Skript se jinak odmítne spustit (viz guard v on run).
-- ===========================================================================
property CONFIG_DONE : false
property EXAMPLE_PATH : "/Volumes/PrintServer/…"
-- ===========================================================================
```
Externí config existuje proto, aby přežil *aktualizaci kódu*. Tady se nic
nepřepisuje — instalace je copy-paste zdroje do Shortcuts.app, takže kopie
uživatele je od začátku soukromá. Externí config by řešil neexistující problém.

**Placeholdery** — neutrální hodnoty ze společného slovníku (`fileserver.local`,
`/Volumes/PrintServer/…`). Stejné hodnoty v kódu, README i `examples/`. Slovník
placeholder → realita je privátně v `~/Dev/_archive/`, nikdy v repu.

**Guard při chybě** — dvě varianty, obě zastaví běh:
- `error "…"` uvnitř `try` (start-finder — má obalený `on run`)
- `display notification … + return argv` (create-project-folders, generate-bridge-header
  — kopírují vlastní vzor volume guardu hned pod ním)

Obojí je správně: každý sedí na strukturu svého skriptu. **Guard, který jen
upozorní a pokračuje, není guard** — vždy musí následovat `error` nebo `return`.

**Struktura skriptu** — hlavička → `KONFIGURACE` blok → helper handlery
(oddělené `-- ---` separátory) → `on run argv` na konci.

**Obranné vzory** (drží všechny tři):
- `try / on error errMsg number errNum`, `-128` (user cancel) se přehazuje dál
- `quoted form of` na každé shellové cestě
- `checkVolumeAvailable()` před každou operací se soubory
- `if class of argv is not list then set argv to {}` — Shortcuts i přímé spuštění

**Komentáře anglicky**, sekční separátory `-- ---------`. Uživatelské texty
(dialogy, notifikace) **česky**.

## 📝 Git

**Conventional Commits** — 100 % commitů. Typy: `chore`, `docs`, `feat`, `revert`.

**Scope = plný název adresáře skriptu** (`create-project-folders`), ne jazyk.

**Tagy** — slash-namespace `<skript>/vX.Y.Z`, anotované (`git tag -a`).

**Větve** — `feat/`, `fix/`, `docs/` + krátký popis; merge do `main` vědomě `--no-ff`.

## 📝 Dokumentace

**Root:** `README.md` + `README.cs.md` (rozcestník, plná parita), `LICENSE`,
`examples/` (šablony konfigurace a ukázková data).

**Per-skript:** `README.md` (česky), `CHANGELOG.md`.

**`docs/` obsahuje jen tento soubor** — ARCHITECTURE/MANUAL_TEST tu nejsou záměrně:
repo je jednoduché (tři samostatné skripty, žádný build, žádná sdílená vrstva),
README stačí.

**README kostra** (viz `templates/`): Proč existuje · Prerekvizity · Instalace ·
První spuštění · Konfigurace · Použití · Řešení problémů · Známá omezení · Changelog.

**CHANGELOG** — Keep a Changelog, česky, z pohledu uživatele. README na něj jen
odkazuje. Interní řadu pod „Před veřejným vydáním (interní řada)".

**Kdy psát entry:** změna, kterou uživatel pocítí. **Kdy bumpovat:** patch = oprava,
minor = nová schopnost/změna chování, major = rozbití existující konfigurace.
Bump = hlavička skriptu + `CHANGELOG.md` + `Updated:` na datum verze.

## 📝 Distribuce

**Žádný build, žádné Release assety** — zdroj *je* deliverable. Uživatel kopíruje
`.applescript` z repa do akce „Run AppleScript". Tagy proto neznačí artefakt, jen
stav zdroje.
