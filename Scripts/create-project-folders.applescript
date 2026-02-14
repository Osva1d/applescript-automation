(*
 * ===========================================================================
 * Script:      Create Project Folders
 * Version:     1.2.0
 * Author:      Osva1d
 * Updated:     2026-02-14
 * 
 * Description:
 *   Project folder creation script for print production with Safari extraction.
 * ===========================================================================
 *)

-- Configuration
property PROJECT_BASE_PATH : "/Volumes/StudioTwo_T5/MARA/Tisk Studio Two"
property SUBFOLDER_NAMES : {"pracovni", "zdroje"}
property DANGEROUS_CHARS : {"/", "\\", ":", "*", "?", "\"", "<", ">", "|", "®", "™", "©", "•", "°"}

-- UI Strings
property UI_BTN_OK : "OK"
property UI_BTN_CANCEL : "Zrušit"
property UI_BTN_CREATE : "Vytvořit"
property UI_BTN_OPEN : "Otevřít složku"

-- Clean and sanitize text for folder names
--
-- Parameters:
--   inputText (string) - Raw text from Safari or user input
--
-- Returns:
--   (string) - Sanitized text safe for macOS file system
--
on cleanText(inputText)
	set cleanedText to inputText
	
	-- Remove whitespace from beginning
	repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
		if length of cleanedText > 1 then
			set cleanedText to text 2 thru -1 of cleanedText
		else
			set cleanedText to ""
			exit repeat
		end if
	end repeat
	
	-- Remove whitespace from end
	repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
		if length of cleanedText > 1 then
			set cleanedText to text 1 thru -2 of cleanedText
		else
			set cleanedText to ""
			exit repeat
		end if
	end repeat
	
	-- Remove double spaces
	repeat while cleanedText contains "  "
		set AppleScript's text item delimiters to "  "
		set textParts to text items of cleanedText
		set AppleScript's text item delimiters to " "
		set cleanedText to textParts as string
	end repeat
	
	set AppleScript's text item delimiters to ""
	
	-- Replace dangerous characters
	set replacementChar to "_"
	repeat with dangerousChar in DANGEROUS_CHARS
		set AppleScript's text item delimiters to dangerousChar
		set textParts to text items of cleanedText
		set AppleScript's text item delimiters to replacementChar
		set cleanedText to textParts as string
	end repeat
	
	set AppleScript's text item delimiters to ""
	
	-- Remove multiple underscores
	repeat while cleanedText contains "__"
		set AppleScript's text item delimiters to "__"
		set textParts to text items of cleanedText
		set AppleScript's text item delimiters to "_"
		set cleanedText to textParts as string
	end repeat
	
	-- Remove underscore from beginning or end
	if cleanedText starts with "_" then set cleanedText to text 2 thru -1 of cleanedText
	if cleanedText ends with "_" then set cleanedText to text 1 thru -2 of cleanedText
	
	return cleanedText
end cleanText

-- Get current year last two digits
--
-- Returns:
--   (string) - Last two digits of current year (e.g., "26" for 2026)
--
on getCurrentYearSuffix()
	set currentYear to year of (current date)
	return text -2 thru -1 of (currentYear as string)
end getCurrentYearSuffix

-- Extract order data from active Safari page using JavaScript
--
-- Returns:
--   (string) - Order JSON or manual input prefix
--
on extractOrderData()
	tell application "System Events"
		if not (exists process "Safari") then
			activate
			display alert "Safari není spuštěný" message "Spusťte Safari, otevřete zakázkový list, a zkuste znovu." buttons {UI_BTN_OK} default button UI_BTN_OK
			return missing value
		end if
	end tell
	
	tell application "Safari"
		if not (exists front document) then
			display dialog "Nejdříve otevřete zakázkový list v Safari!" buttons {UI_BTN_OK} default button UI_BTN_OK
			return missing value
		end if
		
		try
			set extractedData to do JavaScript "
				var result = {};
				
				// Extract order number
				var orderSpan = document.querySelector('span.Header1');
				if (orderSpan) {
					var text = orderSpan.textContent;
					var match = text.match(/Zakázka číslo:\\s*(\\d+\\.\\d+)/);
					if (match) {
						result.orderNumber = match[1].replace('.', '');
					}
				}
				
				// Extract project name
				var projectCell = document.querySelector('td.Task1[width=\"420\"]');
				if (projectCell) {
					result.projectName = projectCell.textContent.trim();
				}
				
				// Extract client name
				var clientCell = document.querySelector('td.Task1[width=\"220\"]');
				if (clientCell) {
					result.clientName = clientCell.textContent.trim();
				}
				
				return JSON.stringify(result);
			" in front document
			
			return extractedData
			
		on error errorMessage
			-- Show error and ask for manual input
			display dialog "Chyba při čtení dat ze Safari. Zadejte údaje ručně:" & return & "Formát: číslo - klient - název projektu" default answer "" buttons {UI_BTN_CANCEL, UI_BTN_OK} default button UI_BTN_OK
			if button returned of result is UI_BTN_CANCEL then
				return missing value
			end if
			-- Return manual input with special prefix
			return "manual:" & (text returned of result)
		end try
	end tell
end extractOrderData

-- Safely extract value from JSON-like string
--
-- Parameters:
--   jsonData (string) - JSON string
--   fieldName (string) - Key to extract
--
-- Returns:
--   (string) - Extracted value
--
on extractJSONValue(jsonData, fieldName)
	try
		set searchPattern to "\"" & fieldName & "\":\""
		set AppleScript's text item delimiters to searchPattern
		set tempParts to text items of jsonData
		
		if (count of tempParts) > 1 then
			set afterKey to item 2 of tempParts
			set AppleScript's text item delimiters to "\""
			return item 1 of text items of afterKey
		end if
	end try
	return ""
end extractJSONValue

-- Parse order data from JSON or manual input
--
-- Parameters:
--   jsonData (string) - JSON string or "manual:" prefixed input
--
-- Returns:
--   (record) - {orderNumber:string, clientName:string, projectName:string}
--
on parseOrderData(jsonData)
	set orderNumber to ""
	set projectName to ""
	set clientName to ""
	
	try
		-- Handle manual input
		if jsonData starts with "manual:" then
			set manualData to text 8 thru -1 of jsonData
			set AppleScript's text item delimiters to " - "
			set dataParts to text items of manualData
			
			if (count of dataParts) is 3 then
				set orderNumber to item 1 of dataParts
				set clientName to item 2 of dataParts
				set projectName to item 3 of dataParts
			else
				error "Nesprávný formát ručního zadání"
			end if
		else
			-- Parse JSON safely
			set orderNumber to my extractJSONValue(jsonData, "orderNumber")
			set projectName to my extractJSONValue(jsonData, "projectName")
			set clientName to my extractJSONValue(jsonData, "clientName")
		end if
		
		-- Clean all texts
		set orderNumber to my cleanText(orderNumber)
		set clientName to my cleanText(clientName)
		set projectName to my cleanText(projectName)
		
	on error errorMessage
		-- Fallback to empty values on any parsing error
		set orderNumber to ""
		set clientName to ""
		set projectName to ""
	end try
	
	return {orderNumber:orderNumber, clientName:clientName, projectName:projectName}
end parseOrderData

-- Create folder structure
--
-- Parameters:
--   orderNumber (string) - Order number
--   clientName (string) - Client name
--   projectName (string) - Project name
--
-- Returns:
--   (boolean) - Success status
--
on createProjectFolders(orderNumber, clientName, projectName)
	set yearSuffix to my getCurrentYearSuffix()
	set projectInfo to clientName & " - " & projectName
	set mainFolderPath to (PROJECT_BASE_PATH & "/" & projectInfo) as string
	
	-- Validate max length (macOS limit 255 chars)
	if length of projectInfo > 240 then
		activate
		display alert "Název složky je příliš dlouhý" message "Celková délka: " & (length of projectInfo) & " znaků (max 240)." & return & return & "Zkraťte název klienta nebo projektu." buttons {UI_BTN_OK} default button UI_BTN_OK
		return false
	end if
	
	try
		-- Try to get folder alias - Check if volume is mounted
		try
			set folderLocation to PROJECT_BASE_PATH as POSIX file as alias
		on error
			activate
			display alert "Síťový disk není připojen" message "Připojte disk obsahující složku:" & return & return & PROJECT_BASE_PATH & return & return & "a zkuste znovu." buttons {UI_BTN_OK} default button UI_BTN_OK
			return false
		end try
		
		tell application "Finder"
			-- Check if main folder already exists (idempotence)
			if exists folder projectInfo of folderLocation then
				activate
				display alert "Složka již existuje" message "Projektová složka \"" & projectInfo & "\" již byla vytvořena. Chcete pokračovat?" buttons {UI_BTN_CANCEL, UI_BTN_OPEN} default button UI_BTN_OPEN cancel button UI_BTN_CANCEL
				
				if button returned of result is UI_BTN_OPEN then
					reveal folder (POSIX file (POSIX path of folderLocation & "/" & projectInfo) as alias)
					activate
				end if
				return true -- Already exists, consider success
			end if
			
			-- Create main folder
			set mainFolder to make new folder at folderLocation with properties {name:projectInfo}
			
			-- Create subfolders
			repeat with subfolderName in SUBFOLDER_NAMES
				make new folder at mainFolder with properties {name:subfolderName}
			end repeat
			
			-- Create final numbered folder
			set finalFolderName to yearSuffix & "_" & orderNumber
			make new folder at mainFolder with properties {name:finalFolderName}
		end tell
		
		-- Export order sheet as full-page PDF to pracovni/
		set pdfName to "Z" & orderNumber & ".pdf"
		set pdfPath to mainFolderPath & "/pracovni/" & pdfName
		my captureOrderSheet(pdfPath)
		
		return true
		
	on error errorMessage
		display dialog "Chyba při vytváření složek: " & errorMessage buttons {UI_BTN_OK} default button UI_BTN_OK
		return false
	end try
end createProjectFolders

-- Extract filename without extension from POSIX path
--
-- Parameters:
--   posixPath (string) - Full POSIX path (e.g. "/path/to/Z261234.pdf")
--
-- Returns:
--   (string) - Filename without extension (e.g. "Z261234")
--
on getFilenameWithoutExtension(posixPath)
	set AppleScript's text item delimiters to "/"
	set fileName to last text item of posixPath
	set AppleScript's text item delimiters to "."
	set nameParts to text items of fileName
	if (count of nameParts) > 1 then
		set fileName to (items 1 thru -2 of nameParts) as string
	end if
	set AppleScript's text item delimiters to ""
	return fileName
end getFilenameWithoutExtension

-- Extract parent folder from POSIX path
--
-- Parameters:
--   posixPath (string) - Full POSIX path
--
-- Returns:
--   (string) - Parent directory path
--
on getParentFolder(posixPath)
	set AppleScript's text item delimiters to "/"
	set pathParts to text items of posixPath
	set parentParts to items 1 thru -2 of pathParts
	set parentPath to parentParts as string
	set AppleScript's text item delimiters to ""
	return parentPath
end getParentFolder

-- Export full Safari page as PDF to specified path
--
-- Uses Safari's native "Export as PDF" which captures the entire page
-- including content below the viewport (no scrolling needed).
--
-- Requires: Accessibility permissions for UI scripting
--
-- Parameters:
--   savePath (string) - POSIX path for output PDF file
--
-- Returns:
--   (boolean) - Success status
--
on captureOrderSheet(savePath)
	try
		tell application "Safari" to activate
		delay 0.5
		
		tell application "System Events"
			tell process "Safari"
				-- File → Export as PDF...
				click menu item "Export as PDF…" of menu "File" of menu bar 1
				
				-- Wait for save dialog
				repeat 30 times
					if exists sheet 1 of window 1 then exit repeat
					delay 0.1
				end repeat
				
				if not (exists sheet 1 of window 1) then
					error "Save dialog did not appear"
				end if
				
				tell sheet 1 of window 1
					-- Set filename (without extension, Safari adds .pdf)
					set value of text field 1 to my getFilenameWithoutExtension(savePath)
					
					-- Navigate to target folder via Go To Folder (Shift+Cmd+G)
					keystroke "g" using {shift down, command down}
					delay 0.5
					
					-- Wait for path input sheet
					repeat 20 times
						if exists sheet 1 then exit repeat
						delay 0.1
					end repeat
					
					tell sheet 1
						set value of text field 1 to my getParentFolder(savePath)
						delay 0.3
						click button "Go"
					end tell
					
					delay 0.5
					
					-- Click Save
					click button "Save"
				end tell
			end tell
		end tell
		
		-- Verify file was created
		delay 1
		try
			do shell script "test -f " & quoted form of savePath
			return true
		on error
			return false
		end try
		
	on error errorMessage
		-- Dismiss any open dialog to leave Safari in clean state
		try
			tell application "System Events"
				tell process "Safari"
					keystroke "." using command down
				end tell
			end tell
		end try
		return false
	end try
end captureOrderSheet

-- Main execution function
on main()
	set orderData to my extractOrderData()
	
	if orderData is not missing value then
		set parsedData to my parseOrderData(orderData)
		set orderNumber to orderNumber of parsedData
		set clientName to clientName of parsedData
		set projectName to projectName of parsedData
		
		-- Validate extracted data
		if orderNumber is not "" and clientName is not "" and projectName is not "" then
			-- Show confirmation dialog
			activate
			display dialog "Extrahovaná data ze Safari:" & return & return & "Číslo: " & orderNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Vytvořit projektové složky?" buttons {UI_BTN_CANCEL, UI_BTN_CREATE} default button UI_BTN_CREATE
			
			if button returned of result is UI_BTN_CREATE then
				set success to my createProjectFolders(orderNumber, clientName, projectName)
				
				if success then
					set projectInfo to clientName & " - " & projectName
					set mainFolderPath to POSIX path of ((PROJECT_BASE_PATH & "/" & projectInfo) as POSIX file)
					
					tell application "Finder"
						reveal folder (mainFolderPath as POSIX file)
						activate
					end tell
					delay 0.5 -- Give user time to see Finder
					
					-- Check if PDF was saved
					set pdfName to "Z" & orderNumber & ".pdf"
					set pdfFile to mainFolderPath & "/pracovni/" & pdfName
					
					try
						do shell script "test -f " & quoted form of pdfFile
						set pdfNote to return & "• Zakázkový list uložen jako " & pdfName
					on error
						set pdfNote to return & "• ⚠ PDF otisk zakázkového listu se nepodařil"
					end try
					
					activate
					display dialog "Složky úspěšně vytvořeny!" & return & return & "Nezapomeňte:" & return & "• Přijmout přidělení v Safari" & return & "• Nakopírovat zdroje" & pdfNote buttons {UI_BTN_OK} default button UI_BTN_OK with title "Hotovo!"
				end if
			end if
		else
			display dialog "Chybný formát dat! Použijte: číslo projektu - klient - název projektu" buttons {UI_BTN_OK} default button UI_BTN_OK
		end if
	else
		display dialog "Nebyla získána žádná data. Skript bude ukončen." buttons {UI_BTN_OK} default button UI_BTN_OK
	end if
end main

main()
