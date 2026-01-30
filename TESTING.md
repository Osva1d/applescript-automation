# Testing Protocol - create-project-folders.applescript

**Version:** 1.1.0  
**Last Updated:** 2026-01-30

---

## Prerequisites

- macOS with Script Editor
- Safari installed and working
- Network disk mounted (or use temp test folder for testing)
- Access to sample order page OR manual input capability

---

## Test Suite

### Test 1: Standard Safari Extraction ✅

**Priority:** HIGH  
**Goal:** Verify basic happy path - Safari extraction works correctly

**Setup:**
1. Open Safari
2. Navigate to order page with structure:
   - `<span class="Header1">Zakázka číslo: 123.45</span>`
   - `<td class="TabColHead">Klient:</td><td class="TabValue">Test Client</td>`
   - `<td class="TabColHead">Projekt:</td><td class="TabValue">Test Project</td>`

**Execute:**
1. Run `create-project-folders.applescript`
2. Verify confirmation dialog shows:
   - Číslo: `12345`
   - Klient: `Test Client`
   - Projekt: `Test Project`
3. Click "Vytvořit"

**Expected Result:**
- ✅ Folder created: `12345 - Test Client - Test Project/`
- ✅ Subfolders exist: `pracovni/`, `zdroje/`, `26_12345/`
- ✅ Finder reveals folder and activates
- ✅ Success dialog appears after ~0.5s delay

**Cleanup:** Delete test folder manually

---

### Test 2: Manual Input ✅

**Priority:** HIGH  
**Goal:** Verify fallback when Safari extraction fails

**Setup:**
1. Safari closed OR on wrong page (e.g., google.com)

**Execute:**
1. Run script
2. Click "OK" on Safari error dialog OR "OK" on "Nejdříve otevřete zakázkový list" dialog
3. In manual input prompt, enter: `67890 - Manual Client - Manual Project`
4. Click "OK"

**Expected Result:**
- ✅ Confirmation dialog shows parsed data correctly
- ✅ Folder `67890 - Manual Client - Manual Project/` created
- ✅ All subfolders present

**Cleanup:** Delete test folder

---

### Test 3: Folder Already Exists (Idempotence) 🆕

**Priority:** HIGH  
**Goal:** Verify v1.1.0 idempotence fix works

**Setup:**
1. Manually create folder: `12345 - Test - Test/`
2. Or rerun Test 1 without cleanup

**Execute:**
1. Run script with same data (12345 - Test - Test)
2. Confirm data when prompted

**Expected Result:**
- ✅ Alert "Složka již existuje" appears
- ✅ Two buttons: "Zrušit", "Otevřít složku"
- ✅ Click "Otevřít složku" → Finder reveals existing folder
- ✅ Click "Zrušit" → Script exits gracefully without error
- ✅ **NO CRASH** (this was broken in v1.0.0)

**Cleanup:** Delete test folder

---

### Test 4: Disk Not Mounted 🆕

**Priority:** HIGH  
**Goal:** Verify v1.1.0 disk validation

**Setup:**
1. Edit script temporarily: Change `PROJECT_BASE_PATH` to non-existent path like `"/Volumes/NonExistentDisk/Test"`
2. OR: If using network disk, unmount it

**Execute:**
1. Run script with any valid data

**Expected Result:**
- ✅ Alert "Síťový disk není připojen" appears BEFORE any Finder operations
- ✅ Message shows the path that needs to be mounted
- ✅ Script exits without attempting folder creation
- ✅ **NO CRASH** (this was broken in v1.0.0)

**Cleanup:** Restore correct `PROJECT_BASE_PATH`

---

### 2. generate-bridge-header.applescript

- [ ] Test 1: **Standardní extrakce (Safari)** -> Data správně načtena, header zkopírován.
- [ ] Test 2: **Odstranění právních forem** -> "s.r.o.", "a.s." atd. úspěšně odstraněno.
- [ ] Test 3: **Inteligentní zkrácení** -> Velmi dlouhý název zkrácen na celé slovo, header má přesně 85 znaků.
- [ ] Test 4: **Kontrola Safari** -> Skript hlásí chybu, pokud Safari neběží.
- [ ] Test 5: **Manuální zadání** -> Funguje i při nefunkční extrakci (fallback).
- [ ] Test 6: **Speciální znaky v názvech** (česká diakritika, mezery) -> Diakritika zachována, mezery ošetřeny.

---

### Test 5: Special Characters Sanitization 🆕

**Priority:** MEDIUM  
**Goal:** Verify v1.1.0 extended sanitization (M2)

**Execute:**
1. Manual input: `11111 - Client/Name (©2024)™ - Project:Test•Data`

**Expected Result:**
- ✅ Folder created: `11111 - Client_Name _2024__ - Project_Test_Data/`
- ✅ All special chars (`/`, `:`, `©`, `™`, `•`) replaced with `_`
- ✅ Multiple `_` collapsed to single `_` where appropriate

**Cleanup:** Delete test folder

---

### Test 6: Folder Name Too Long 🆕

**Priority:** MEDIUM  
**Goal:** Verify v1.1.0 length validation (M3)

**Execute:**
1. Manual input with very long name (>240 chars):
   ```
   99999 - Very Long Client Name That Will Definitely Exceed The Maximum Allowed Length For macOS Folder Names And Will Be Rejected - And An Equally Long Project Name That Pushes It Over
   ```

**Expected Result:**
- ✅ Alert "Název složky je příliš dlouhý" appears
- ✅ Shows character count (e.g., "Celková délka: 185 znaků")
- ✅ Script exits **before** attempting folder creation
- ✅ No folder created

---

### Test 7: Safari Not Running 🆕

**Priority:** MEDIUM  
**Goal:** Verify v1.1.0 Safari check (M4)

**Setup:**
1. Quit Safari completely (Cmd+Q)

**Execute:**
1. Run script

**Expected Result:**
- ✅ Alert "Safari není spuštěný" appears IMMEDIATELY
- ✅ Message instructs user to start Safari
- ✅ Script exits gracefully
- ✅ **NO system dialog** "Do you want to start Safari?" (prevented by v1.1.0 fix)

---

### Test 8: Emoji in Name (Extended Sanitization) 🆕

**Priority:** LOW  
**Goal:** Verify emoji removal

**Execute:**
1. Manual input: `12345 - 🎨 Art Studio® - Logo 💼 Design°`

**Expected Result:**
- ✅ Folder created: `12345 - _ Art Studio_ - Logo _ Design_/`
- ✅ Emoji (`🎨`, `💼`) replaced with `_`
- ✅ Special symbols (`®`, `°`) also replaced

**Cleanup:** Delete test folder

---

### Test 9: Reveal in Finder (UX Enhancement) 🆕

**Priority:** LOW  
**Goal:** Verify v1.1.0 UX improvement (L5)

**Execute:**
1. Run any successful test (e.g., Test 1)

**Expected Result:**
- ✅ After clicking "Vytvořit", Finder opens and reveals created folder
- ✅ Finder window activates (comes to front)
- ✅ ~0.5s delay before success dialog appears
- ✅ Success dialog shows after user has seen Finder

---

## Regression Tests

After ANY code change to `create-project-folders.applescript`, run:

1. **Test 1** (happy path Safari extraction)
2. **Test 2** (manual input fallback)
3. **Test 3** (idempotence - folder exists)
4. **Test 4** (disk validation)

If all 4 pass → Safe to deploy

---

## Edge Cases to Monitor

### Not Currently Tested
- [ ] Safari page with incomplete data (e.g., missing ProjectName field)
- [ ] Safari JavaScript disabled
- [ ] Multiple Safari windows open (which one is "front document"?)
- [ ] Non-ASCII filenames on non-UTF8 network drives
- [ ] Concurrent runs (two users running script at same time on same disk)

### Known Limitations (by design)
- **No SQLite/database:** Folder creation is idempotent but doesn't track history
- **No undo:** If folder created wrong, must delete manually
- **No batch mode:** One project at a time
- **Safari-dependent:** Requires specific HTML structure

---

## Manual Verification Checklist

After each test:
- [ ] Script completed without crash/hang
- [ ] Error messages are clear and actionable
- [ ] Folder structure matches expected (if created)
- [ ] No orphaned/incomplete folders left on error
- [ ] Finder reveal worked (if applicable)
- [ ] No console errors in Script Editor

---

## Test Results Log

| Test | Date | Tester | Status | Notes |
|------|------|--------|--------|-------|
| All | 2026-01-30 | @orchestrator | PENDING | Initial setup |

---

**Next Review:** After first production use or macOS update
