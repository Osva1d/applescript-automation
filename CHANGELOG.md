# Changelog

All notable changes to applescript-automation scripts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
