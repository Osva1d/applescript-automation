# Changelog

All notable changes to applescript-automation scripts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [2.0.0] - 2026-03

### Added

- **start-finder** (v14.4.1): New login automation script
  - Network server availability check with configurable timeout
  - Automatic AFP/SMB volume mounting
  - Finder window with tabbed panels for production folders
  - Progress notification during network wait
  - Summary notification with mount/panel status
  - Graceful handling of unavailable volumes (skipped, not crashed)
- **generate-bridge-header**: `findProductionFolder()` - locates production folder on disk
- **generate-bridge-header**: `openInBridge()` - opens folder in Adobe Bridge
- **generate-bridge-header**: `checkVolumeAvailable()` - volume check before file operations
- **generate-bridge-header**: `getBridgeAppName()` - dynamic detection of installed Adobe Bridge version
- **generate-bridge-header**: `extractJSONValue()` - lightweight JSON field extraction
- **generate-bridge-header**: `PROJECT_BASE_PATH` property for production folder lookup
- **create-project-folders**: `checkVolumeAvailable()` - standalone volume check function
- **create-project-folders**: Leading dot stripping in `cleanText()` to prevent hidden files

### Changed

- **create-project-folders** (v1.2.0 -> v1.3.0):
  - Refactored to `on run argv` entry point for Shortcuts.app compatibility
  - Simplified `DANGEROUS_CHARS` to basic filesystem-unsafe characters (removed emoji/symbol set)
  - Disk availability check uses notification instead of modal dialog
  - Removed UI string properties (inlined)
  - Removed PDF capture feature (`captureOrderSheet`) - moved to separate workflow
  - Simplified comment header from block `(* *)` to line `--` style
- **generate-bridge-header** (v1.1.1 -> v2.3.0):
  - Major refactor with Shortcuts.app compatible `on run argv` entry point
  - JSON-based Safari data extraction (replaces direct DOM scraping)
  - Simplified `getLegalForms()` - focused Czech forms + key international (was 280+ variants)
  - Renamed `cleanText()` to `stripDisplayText()` to clarify its purpose
  - `createBridgeHeader()` now throws `"HEADER_TOO_LONG"` error instead of returning error string
  - Integer division (`div`) for center position calculation
  - Removed UI string properties (inlined)

### Security

- All scripts now use placeholder values for paths and server names
- Real configuration values must be set by the user before first use

---

## [1.2.0] - 2026-02-14

### Added

- **create-project-folders**: Full-page PDF capture of order sheet to `pracovni/` folder using Safari's native "Export as PDF"
- **create-project-folders**: UI feedback for PDF capture success/failure in final dialog

### Changed

- **create-project-folders**: Author updated to Osva1d, comments English-only unification
- **generate-bridge-header**: Author updated to Osva1d, comments English-only unification (v1.1.1)

---

## [1.1.0] - 2026-01-30

### Added

- **create-project-folders**: [FIX] Oprava kódování souboru na UTF-8 (plná podpora české diakritiky).
- **create-project-folders**: [IMP] Idempotence check - skript detekuje existující složku (H1).
- **create-project-folders**: [IMP] Validace připojeného disku před pokusem o vytvoření (M1).
- **generate-bridge-header**: [IMP] Nová v1.1.0 verze s vylepšenou robustností.
- **generate-bridge-header**: [FEAT] Kontrola spuštěného Safari před extrakcí (prevence chyb).
- **generate-bridge-header**: [REF] Refaktorizace do `main()` patternu a oddělení UI textů.
- **generate-bridge-header**: [IMP] Externalizace konfigurace (`MIN_SPACING`, `TOTAL_HEADER_WIDTH`).
- **create-project-folders**: Safari running check before extraction attempt - prevents confusing system dialogs
- **create-project-folders**: Folder name length validation (240 char limit to prevent macOS filesystem errors)
- **create-project-folders**: Extended character sanitization - now removes emoji and special symbols (©, ®, ™, •, °)
- **create-project-folders**: Reveal created folder in Finder after successful creation
- **create-project-folders**: UI string properties for future localization support
- **create-project-folders**: Version header with metadata (version, date, authors)
- **create-project-folders**: JSDoc-style parameter and return documentation for all functions

### Changed
- **create-project-folders**: Refactored main execution into `main()` function for better structure and testability
- **create-project-folders**: All UI button labels now use properties (UI_BTN_OK, UI_BTN_CANCEL, etc.)
- **create-project-folders**: Improved error messages with actionable instructions

### Improved
- **Documentation**: README includes troubleshooting section for common issues
- **Documentation**: README documents Safari DOM structure expectations
- **Inline documentation**: All functions now have parameter and return type comments
- **User experience**: Clearer feedback when folders already exist
- **User experience**: Better error messages when disk is not mounted or Safari is not running
- **Reliability**: Script can be run multiple times safely (idempotent)

---

## [1.0.0] - 2025-XX-XX

### Added
- Initial release of `create-project-folders.applescript`
- Initial release of `generate-bridge-header.applescript`
- Safari data extraction with JavaScript DOM scraping
- Manual input fallback when Safari extraction fails
- Automatic folder structure creation (main folder + pracovni/zdroje subfolders + YY_number folder)
- Character sanitization for filesystem-safe folder names
- Confirmation dialog with extracted data preview
- Year suffix calculation for final folder naming
