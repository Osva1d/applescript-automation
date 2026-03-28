# Testing Protocol - AppleScript Automation

**Version:** 2.0.0
**Last Updated:** 2026-03

---

## Prerequisites

- macOS 13+ with Script Editor
- Safari installed and working
- Network disk mounted (or use temp test folder for testing)
- Access to sample order page OR manual input capability
- Shortcuts.app
- Accessibility permission (for start-finder)

---

## 1. create-project-folders.applescript (v1.3.0)

### Test 1: Standard Safari Extraction

**Priority:** HIGH
**Goal:** Verify basic happy path - Safari extraction works correctly

**Setup:**
1. Open Safari
2. Navigate to order page with structure:
   - `<span class="Header1">Zakazka cislo: 123.45</span>`
   - `<td class="TabColHead">Klient:</td><td class="TabValue">Test Client</td>`
   - `<td class="TabColHead">Projekt:</td><td class="TabValue">Test Project</td>`

**Execute:**
1. Run `create-project-folders.applescript` via Shortcuts.app
2. Verify confirmation dialog shows:
   - Cislo: `12345`
   - Klient: `Test Client`
   - Projekt: `Test Project`
3. Click "Vytvorit"

**Expected Result:**
- Folder created: `12345 - Test Client - Test Project/`
- Subfolders exist: `pracovni/`, `zdroje/`, `26_12345/`
- Finder reveals folder and activates
- Success dialog appears

**Cleanup:** Delete test folder manually

---

### Test 2: Manual Input

**Priority:** HIGH
**Goal:** Verify fallback when Safari extraction fails

**Setup:**
1. Safari closed OR on wrong page

**Execute:**
1. Run script
2. In manual input prompt, enter: `67890 - Manual Client - Manual Project`
3. Click "OK"

**Expected Result:**
- Confirmation dialog shows parsed data correctly
- Folder `67890 - Manual Client - Manual Project/` created
- All subfolders present

**Cleanup:** Delete test folder

---

### Test 3: Folder Already Exists (Idempotence)

**Priority:** HIGH
**Goal:** Verify idempotence check

**Setup:**
1. Manually create folder: `12345 - Test - Test/`

**Execute:**
1. Run script with same data (12345 - Test - Test)

**Expected Result:**
- Alert "Slozka jiz existuje" appears
- Option to open existing folder or cancel
- No crash, no duplicate folders

**Cleanup:** Delete test folder

---

### Test 4: Disk Not Mounted

**Priority:** HIGH
**Goal:** Verify volume availability check

**Setup:**
1. Edit script: Change `PROJECT_BASE_PATH` to non-existent path like `"/Volumes/NonExistentDisk/Test"`

**Execute:**
1. Run script with any valid data

**Expected Result:**
- Notification about unavailable disk appears
- Script exits without attempting folder creation

**Cleanup:** Restore correct `PROJECT_BASE_PATH`

---

### Test 5: Special Characters Sanitization

**Priority:** MEDIUM
**Goal:** Verify dangerous character replacement

**Execute:**
1. Manual input: `11111 - Client/Name - Project:Test`

**Expected Result:**
- Folder created: `11111 - Client_Name - Project_Test/`
- Characters `/`, `:` replaced with `_`
- Multiple `_` collapsed to single `_`

**Cleanup:** Delete test folder

---

### Test 6: Folder Name Too Long

**Priority:** MEDIUM
**Goal:** Verify length validation (240 char limit)

**Execute:**
1. Manual input with very long name (>240 chars)

**Expected Result:**
- Alert about name being too long
- Script exits before attempting folder creation

---

### Test 7: Safari Not Running

**Priority:** MEDIUM
**Goal:** Verify Safari running check

**Setup:**
1. Quit Safari completely (Cmd+Q)

**Execute:**
1. Run script

**Expected Result:**
- Alert "Safari neni spusteny" appears immediately
- No system dialog "Do you want to start Safari?"
- Script exits gracefully

---

## 2. generate-bridge-header.applescript (v2.3.0)

### Test 1: Standard Header Generation

**Priority:** HIGH
**Goal:** Verify header creation and clipboard copy

**Setup:**
1. Open Safari on order page

**Execute:**
1. Run script via Shortcuts.app
2. Verify confirmation dialog shows correct data
3. Confirm

**Expected Result:**
- Header exactly 85 characters wide
- Format: `Client    TECHNOLOGY    26_12345`
- Technology centered
- Header copied to clipboard (verify with Cmd+V in text editor)

---

### Test 2: Legal Forms Removal

**Priority:** HIGH
**Goal:** Verify legal form stripping

**Execute:**
1. Manual input with client name: `12345 - ACME Corporation, s.r.o. - OFFSET - Test Project`

**Expected Result:**
- Header shows `ACME Corporation` (without `, s.r.o.`)
- Technology: `OFFSET`
- Right side: `26_12345`

---

### Test 3: Long Client Name Truncation

**Priority:** MEDIUM
**Goal:** Verify intelligent word-boundary truncation

**Execute:**
1. Manual input: `12345 - Velmi Dlouhy Nazev Klienta Spolecnosti - DIGITAL - Project`

**Expected Result:**
- Client name truncated to last complete word within MAX_CLIENT_LENGTH
- No word broken mid-word
- Header still exactly 85 characters

---

### Test 4: Safari Not Running

**Priority:** MEDIUM
**Goal:** Verify error handling

**Setup:**
1. Quit Safari

**Execute:**
1. Run script

**Expected Result:**
- Error dialog about Safari not running
- Script exits gracefully

---

### Test 5: Production Folder Lookup

**Priority:** MEDIUM
**Goal:** Verify findProductionFolder and openInBridge

**Setup:**
1. Ensure `PROJECT_BASE_PATH` volume is mounted
2. Create a test folder matching expected pattern (e.g., `26_12345`)

**Execute:**
1. Run script with matching order number

**Expected Result:**
- Script finds production folder
- Offers to open in Adobe Bridge (if installed)
- If Bridge not installed, graceful fallback

**Cleanup:** Delete test folder

---

### Test 6: Header Too Long

**Priority:** LOW
**Goal:** Verify HEADER_TOO_LONG error handling

**Execute:**
1. Provide very long technology name + long client name

**Expected Result:**
- Error about header being too long
- Script handles error gracefully

---

## 3. start-finder.applescript (v14.4.1)

### Test 1: Full Happy Path (Network Available)

**Priority:** HIGH
**Goal:** Verify complete login setup flow

**Setup:**
1. Network available, at least one server in `SERVER_LIST` accessible
2. Accessibility permission granted to Shortcuts.app

**Execute:**
1. Run script via Shortcuts.app

**Expected Result:**
- Network check passes
- Volumes mounted (or already mounted)
- Finder window opens with correct WINDOW_BOUNDS
- Tabs created for each path in PANEL_PATHS (that exists)
- Final notification shows status

---

### Test 2: Network Timeout

**Priority:** HIGH
**Goal:** Verify timeout handling when network is unavailable

**Setup:**
1. Disconnect from network OR set `CHECK_SERVER` to unreachable host
2. Set `NETWORK_TIMEOUT` to short value (e.g., 5) for faster testing

**Execute:**
1. Run script

**Expected Result:**
- "Cekam na sit..." notification appears after ~5 seconds
- After timeout: dialog "Sit neni dostupna"
- Script exits without mounting or creating panels

**Cleanup:** Restore `CHECK_SERVER` and `NETWORK_TIMEOUT`

---

### Test 3: Volume Mount Failure

**Priority:** HIGH
**Goal:** Verify handling of unmountable volumes

**Setup:**
1. Network available
2. Add a fake entry to `SERVER_LIST`: `{dName:"FakeVol", dAddr:"smb://fake.local/FakeVol"}`

**Execute:**
1. Run script

**Expected Result:**
- Other volumes mount normally
- Fake volume fails silently (no crash)
- Final notification lists unmounted volumes
- Finder panels created for available paths only

**Cleanup:** Remove fake entry from `SERVER_LIST`

---

### Test 4: Accessibility Permission Missing

**Priority:** HIGH
**Goal:** Verify error when keystroke simulation is blocked

**Setup:**
1. Remove Accessibility permission for Shortcuts.app

**Execute:**
1. Run script

**Expected Result:**
- Volumes mount (no Accessibility needed for mount)
- Tab creation fails with "Not allowed assistive access" error
- Error is surfaced to user

**Cleanup:** Re-enable Accessibility permission

---

### Test 5: Panel Path Not Found

**Priority:** MEDIUM
**Goal:** Verify handling of non-existent panel paths

**Setup:**
1. Add non-existent path to `PANEL_PATHS`: `"/Volumes/NonExistent"`

**Execute:**
1. Run script

**Expected Result:**
- Panel for non-existent path is skipped
- Other panels created normally
- Notification lists skipped paths

**Cleanup:** Remove fake path

---

### Test 6: close every window Behavior

**Priority:** MEDIUM
**Goal:** Verify that existing Finder windows are closed

**Setup:**
1. Open several Finder windows manually

**Execute:**
1. Run script

**Expected Result:**
- All existing Finder windows closed
- New window created with tabs
- This is intentional behavior (documented as known limitation)

---

## Regression Tests

After ANY code change, run these critical tests:

### create-project-folders
1. Test 1 (Safari extraction)
2. Test 2 (manual input)
3. Test 3 (idempotence)
4. Test 4 (disk validation)

### generate-bridge-header
1. Test 1 (standard header)
2. Test 2 (legal forms)

### start-finder
1. Test 1 (happy path)
2. Test 2 (network timeout)

If all pass → Safe to deploy

---

## Edge Cases to Monitor

### Not Currently Tested
- [ ] Safari page with incomplete data (e.g., missing ProjectName field)
- [ ] Safari JavaScript disabled
- [ ] Multiple Safari windows open (which one is "front document"?)
- [ ] Non-ASCII filenames on non-UTF8 network drives
- [ ] Concurrent runs (two users running script at same time on same disk)
- [ ] Very slow network (volume mounts take >30s each)
- [ ] Mixed AFP/SMB failures (some mount, some don't)
- [ ] TAB_DELAY too low on slow machine (tabs not created properly)

### Known Limitations (by design)
- **No SQLite/database:** Folder creation is idempotent but doesn't track history
- **No undo:** If folder created wrong, must delete manually
- **No batch mode:** One project at a time
- **Safari-dependent:** Requires specific HTML structure
- **Finder tabs via keystrokes:** Fragile, depends on Accessibility and timing

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
| All | 2026-03 | - | PENDING | v2.0.0 initial setup |

---

**Next Review:** After first production use or macOS update
