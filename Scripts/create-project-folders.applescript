-- ===========================================================================
-- Script:      Create Project Folders
-- Version:     1.3.0
-- Author:      Osva1d
-- Updated:     2026-03-15
-- Description: Creates project folder structure from Safari order page data.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

property PROJECT_BASE_PATH : "/Volumes/PrintServer/Projects/Print Production"
property SUBFOLDER_NAMES : {"pracovni", "zdroje"}
property DANGEROUS_CHARS : {"/", "\\", ":", "*", "?", "<", ">", "|"}


-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Check whether a POSIX path is accessible (volume mounted).
--
-- Parameters:
--   basePath (string) - POSIX path to check
--
-- Returns:
--   (boolean) - true if path is accessible
--
on checkVolumeAvailable(basePath)
	try
		POSIX file basePath as alias
		return true
	on error
		return false
	end try
end checkVolumeAvailable

-- Trim whitespace, collapse multiple spaces, replace filesystem-unsafe chars
-- with underscore, collapse consecutive underscores.
--
-- Parameters:
--   inputText (string) - raw text to sanitize
--
-- Returns:
--   (string) - cleaned text safe for use as folder name component
--
on cleanText(inputText)
	set cleanedText to inputText
	try
		repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
			if length of cleanedText > 1 then
				set cleanedText to text 2 thru -1 of cleanedText
			else
				set cleanedText to ""
				exit repeat
			end if
		end repeat
		repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
			if length of cleanedText > 1 then
				set cleanedText to text 1 thru -2 of cleanedText
			else
				set cleanedText to ""
				exit repeat
			end if
		end repeat
		-- Collapse all runs of spaces to single space (single pass)
		set AppleScript's text item delimiters to " "
		set nonEmptyParts to {}
		repeat with part in (text items of cleanedText)
			if part as string is not "" then
				set end of nonEmptyParts to (part as string)
			end if
		end repeat
		set cleanedText to nonEmptyParts as string
		set AppleScript's text item delimiters to ""
		set replacementChar to "_"
		repeat with dangerousChar in DANGEROUS_CHARS
			set AppleScript's text item delimiters to dangerousChar
			set textParts to text items of cleanedText
			set AppleScript's text item delimiters to replacementChar
			set cleanedText to textParts as string
		end repeat
		set AppleScript's text item delimiters to ""
		repeat while cleanedText contains "__"
			set AppleScript's text item delimiters to "__"
			set textParts to text items of cleanedText
			set AppleScript's text item delimiters to "_"
			set cleanedText to textParts as string
		end repeat
		set AppleScript's text item delimiters to ""
		-- Strip leading dots to prevent hidden files/folders
		repeat while cleanedText starts with "."
			if length of cleanedText > 1 then
				set cleanedText to text 2 thru -1 of cleanedText
			else
				set cleanedText to ""
				exit repeat
			end if
		end repeat
	on error errMsg
		set AppleScript's text item delimiters to ""
		error errMsg
	end try
	return cleanedText
end cleanText

-- Return last two digits of current year (e.g. "26" for 2026).
-- NOTE: Shared with generate-bridge-header.applescript — keep in sync.
on getCurrentYearSuffix()
	set currentYear to year of (current date)
	return text -2 thru -1 of (currentYear as string)
end getCurrentYearSuffix


-- ---------------------------------------------------------------------------
-- Safari Data Extraction
-- ---------------------------------------------------------------------------

-- Extract order data from the active Safari document via JavaScript.
-- Falls back to a manual input dialog if JavaScript fails.
--
-- Returns:
--   (string) - tab-separated values from page, "manual:<data>" from dialog,
--              or missing value if user cancels / no document open
--
on extractOrderData()
	tell application "Safari"
		if not (exists front document) then
			return missing value
		end if
		try
			set extractedData to do JavaScript "
                var orderNumber = '';
                var clientName = '';
                var projectName = '';
                var orderSpan = document.querySelector('span.Header1');
                if (orderSpan) {
                    var text = orderSpan.textContent;
                    var match = text.match(/Zakázka\\s*číslo:\\s*([\\d\\.]+)/);
                    if (match) {
                        var rawNum = match[1].replace(/\\./g, '');
                        while (rawNum.length < 4) {
                            rawNum = '0' + rawNum;
                        }
                        orderNumber = rawNum;
                    }
                }
                var allHeaders = document.querySelectorAll('td.TabColHead');
                for (var i = 0; i < allHeaders.length; i++) {
                    var headerText = allHeaders[i].textContent.trim();
                    var nextCell = allHeaders[i].nextElementSibling;
                    if (nextCell && nextCell.classList.contains('TabValue')) {
                        if (headerText === 'Projekt:') {
                            projectName = nextCell.textContent.trim();
                        } else if (headerText === 'Klient:') {
                            clientName = nextCell.textContent.trim();
                        }
                    }
                }
                orderNumber + '\\t' + clientName + '\\t' + projectName;
            " in front document
			return extractedData
		on error errorMessage
			activate
			set dialogResult to display dialog "Chyba při čtení dat ze Safari. Zadejte údaje ručně:" & return & "Formát: číslo - klient - název projektu" default answer "" buttons {"Zrušit", "OK"} default button "OK"
			if button returned of dialogResult is "Zrušit" then
				return missing value
			end if
			return "manual:" & (text returned of dialogResult)
		end try
	end tell
end extractOrderData

-- Parse raw string from extractOrderData() into a structured record.
-- Handles both tab-separated (page extraction) and "manual:<data>" (fallback dialog).
--
-- Parameters:
--   rawData (string) - output of extractOrderData()
--
-- Returns:
--   (record) {orderNumber, clientName, projectName} - empty strings on failure
--
on parseOrderData(rawData)
	set orderNumber to ""
	set projectName to ""
	set clientName to ""
	try
		if rawData starts with "manual:" then
			set manualData to text 8 thru -1 of rawData
			set AppleScript's text item delimiters to " - "
			set dataParts to text items of manualData
			set AppleScript's text item delimiters to ""
			if (count of dataParts) ≥ 3 then
				set orderNumber to item 1 of dataParts
				set clientName to item 2 of dataParts
				-- Rejoin items 3+ to preserve " - " in project names
				set projectName to item 3 of dataParts
				repeat with i from 4 to (count of dataParts)
					set projectName to projectName & " - " & item i of dataParts
				end repeat
			else
				activate
				display dialog "Nesprávný formát zadání:" & return & return & "Zadáno: " & manualData & return & return & "Očekávaný formát: číslo - klient - název projektu" & return & "(odděleno " & quote & " - " & quote & ")" buttons {"OK"} default button "OK" with icon caution
			end if
		else
			-- Parse tab-separated values from JavaScript extraction
			set AppleScript's text item delimiters to tab
			set dataParts to text items of rawData
			set AppleScript's text item delimiters to ""
			if (count of dataParts) ≥ 3 then
				set orderNumber to item 1 of dataParts
				set clientName to item 2 of dataParts
				set projectName to item 3 of dataParts
			end if
		end if
		set orderNumber to my cleanText(orderNumber)
		set clientName to my cleanText(clientName)
		set projectName to my cleanText(projectName)
	on error
		set orderNumber to ""
		set clientName to ""
		set projectName to ""
	end try
	return {orderNumber:orderNumber, clientName:clientName, projectName:projectName}
end parseOrderData


-- ---------------------------------------------------------------------------
-- Project Creation
-- ---------------------------------------------------------------------------

-- Create the project folder hierarchy under PROJECT_BASE_PATH.
-- Guards against overwriting an existing folder with the same name.
--
-- Parameters:
--   orderNumber (string) - cleaned order number (e.g. "0042")
--   clientName  (string) - cleaned client name
--   projectName (string) - cleaned project name
--
-- Returns:
--   (boolean) - true on success, false on error
--
on createProjectFolders(orderNumber, clientName, projectName)
	set yearSuffix to my getCurrentYearSuffix()
	set projectInfo to orderNumber & " - " & clientName & " - " & projectName
	try
		set folderLocation to PROJECT_BASE_PATH as POSIX file as alias
		set mainFolderPath to (folderLocation as string) & projectInfo & ":"
		tell application "Finder"
			-- Guard: prevent overwriting an existing project folder
			if exists folder mainFolderPath then
				error "Složka \"" & projectInfo & "\" již existuje."
			end if
			make new folder at folderLocation with properties {name:projectInfo}
			repeat with subfolderName in SUBFOLDER_NAMES
				make new folder at folder mainFolderPath with properties {name:subfolderName}
			end repeat
			set finalFolderName to yearSuffix & "_" & orderNumber
			make new folder at folder mainFolderPath with properties {name:finalFolderName}
		end tell
		return true
	on error errorMessage
		activate
		display dialog "Chyba při vytváření složek: " & errorMessage buttons {"OK"} default button "OK" with icon caution
		return false
	end try
end createProjectFolders


-- ---------------------------------------------------------------------------
-- Entry Point
-- ---------------------------------------------------------------------------

-- Entry point for Shortcuts.app (compatible with Script Editor and Automator).
on run argv
	-- Accept both Shortcuts.app {input, parameters} and direct invocation (no args)
	if class of argv is not list then set argv to {}

	-- Guard: verify volume is mounted before any file operations
	if not my checkVolumeAvailable(PROJECT_BASE_PATH) then
		display notification "Disk není připojen." with title "Projektové složky"
		return argv
	end if

	set orderData to my extractOrderData()

	if orderData is missing value then
		display notification "Safari nemá otevřenou stránku zakázky." with title "Projektové složky"
		return argv
	end if

	set parsedData to my parseOrderData(orderData)
	set orderNumber to orderNumber of parsedData
	set clientName to clientName of parsedData
	set projectName to projectName of parsedData

	if orderNumber is "" or clientName is "" or projectName is "" then
		activate
		display dialog "Nepodařilo se extrahovat všechna data:" & return & return & "Zakázka: " & orderNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName buttons {"OK"} default button "OK" with title "Projektové složky" with icon caution
		return argv
	end if

	-- Single preview dialog: verify extracted data, Enter to proceed
	set projectInfo to orderNumber & " - " & clientName & " - " & projectName
	set previewMsg to "Zakázka: " & orderNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Složka: " & projectInfo

	activate
	set userChoice to button returned of (display dialog previewMsg with title "Projektové složky" buttons {"Zrušit", "Vytvořit"} default button "Vytvořit")
	if userChoice is "Zrušit" then return argv

	-- Action: create folders (no Finder reveal — target folder is already open in a panel)
	my createProjectFolders(orderNumber, clientName, projectName)

	return argv
end run
