-- Project folder creation script for print production
-- Skript pro vytváření projektových složek
--
-- Version: 1.1.0
-- Last Updated: 2026-01-30
-- Author: Ladislav Osvald (concept), Claude AI (implementation)

-- Configuration - Konfigurace
-- IMPORTANT: Update this path to your project folder location
-- DŮLEŽITÉ: Upravte tuto cestu na umístění vašich projektových složek
property PROJECT_BASE_PATH : "/Volumes/StudioTwo_T5/MARA/Tisk Studio Two"
property SUBFOLDER_NAMES : {"pracovni", "zdroje"}
property DANGEROUS_CHARS : {"/", "\\", ":", "*", "?", "\"", "<", ">", "|", "®", "™", "©", "•", "°"}

-- UI Strings - Texty uživatelského rozhraní
property UI_BTN_OK : "OK"
property UI_BTN_CANCEL : "Zrušit"
property UI_BTN_CREATE : "Vytvořit"
property UI_BTN_OPEN : "Otevřít složku"

-- Clean and sanitize text for folder names
-- Očištění a sanitizace textu pro názvy složek
--
-- Parameters:
--   inputText (string) - Raw text from Safari or user input
-- Returns:
--   (string) - Sanitized text safe for folder names
on cleanText(inputText)
	set cleanedText to inputText
	
	-- Remove whitespace from beginning - Odstranění bílých znaků ze začátku
	repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
		if length of cleanedText > 1 then
			set cleanedText to text 2 thru -1 of cleanedText
		else
			set cleanedText to ""
			exit repeat
		end if
	end repeat
	
	-- Remove whitespace from end - Odstranění bílých znaků z konce
	repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
		if length of cleanedText > 1 then
			set cleanedText to text 1 thru -2 of cleanedText
		else
			set cleanedText to ""
			exit repeat
		end if
	end repeat
	
	-- Remove double spaces - Odstranění zdvojených mezer
	repeat while cleanedText contains "  "
		set AppleScript's text item delimiters to "  "
		set textParts to text items of cleanedText
		set AppleScript's text item delimiters to " "
		set cleanedText to textParts as string
	end repeat
	
	set AppleScript's text item delimiters to ""
	
	-- Replace dangerous characters - Nahrazení nebezpečných znaků
	set replacementChar to "_"
	repeat with dangerousChar in DANGEROUS_CHARS
		set AppleScript's text item delimiters to dangerousChar
		set textParts to text items of cleanedText
		set AppleScript's text item delimiters to replacementChar
		set cleanedText to textParts as string
	end repeat
	
	set AppleScript's text item delimiters to ""
	
	-- Remove multiple underscores - Odstranění vícenásobných podtržítek
	repeat while cleanedText contains "__"
		set AppleScript's text item delimiters to "__"
		set textParts to text items of cleanedText
		set AppleScript's text item delimiters to "_"
		set cleanedText to textParts as string
	end repeat
	
	set AppleScript's text item delimiters to ""
	
	return cleanedText
end cleanText

-- Get current year last two digits
-- Získání posledních dvou číslic roku
--
-- Returns:
--   (string) - Last two digits of current year (e.g., "26" for 2026)
on getCurrentYearSuffix()
	set currentYear to year of (current date)
	set yearString to currentYear as string
	return text -2 thru -1 of yearString
end getCurrentYearSuffix

-- Extract data from Safari order page
-- Extrakce dat ze Safari zakázkového listu
--
-- Returns:
--   (string) - JSON string with extracted data or "manual:" prefix with user input
--   missing value - if user cancels or Safari not available
on extractOrderData()
	-- Check if Safari is running
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
			-- Extract data using JavaScript - Extrakce dat pomocí JavaScript
			set extractedData to do JavaScript "
				var result = {};
				
				// Extract order number - Extrakce čísla zakázky
				var orderSpan = document.querySelector('span.Header1');
				if (orderSpan) {
					var text = orderSpan.textContent;
					var match = text.match(/Zakázka číslo:\\s*(\\d+\\.\\d+)/);
					if (match) {
						result.orderNumber = match[1].replace('.', '');
					}
				}
				
				// Extract project and client - Extrakce projektu a klienta
				var allHeaders = document.querySelectorAll('td.TabColHead');
				for (var i = 0; i < allHeaders.length; i++) {
					var headerText = allHeaders[i].textContent.trim();
					var nextCell = allHeaders[i].nextElementSibling;
					
					if (nextCell && nextCell.classList.contains('TabValue')) {
						if (headerText === 'Projekt:') {
							result.projectName = nextCell.textContent.trim();
						} else if (headerText === 'Klient:') {
							result.clientName = nextCell.textContent.trim();
						}
					}
				}
				
				JSON.stringify(result);
			" in front document
			
			return extractedData
			
		on error errorMessage
			-- Show error and ask for manual input - Zobrazení chyby a požádání o ruční zadání
			display dialog "Chyba při čtení dat ze Safari. Zadejte údaje ručně:" & return & "Formát: číslo - klient - název projektu" default answer "" buttons {UI_BTN_CANCEL, UI_BTN_OK} default button UI_BTN_OK
			if button returned of result is UI_BTN_CANCEL then
				return missing value
			end if
			-- Return manual input with special prefix - Vrácení ručního zadání se speciálním prefixem
			return "manual:" & (text returned of result)
		end try
	end tell
end extractOrderData

-- Safely extract value from JSON-like string
-- Bezpečná extrakce hodnoty z JSON řetězce
--
-- Parameters:
--   jsonData (string) - JSON string
--   fieldName (string) - Field name to extract
-- Returns:
--   (string) - Extracted value or empty string
on extractJSONValue(jsonData, fieldName)
	try
		set searchPattern to "\"" & fieldName & "\":\""
		if jsonData contains searchPattern then
			set startPos to offset of searchPattern in jsonData
			set tempString to text (startPos + (length of searchPattern)) thru -1 of jsonData
			set endPos to offset of "\"" in tempString
			if endPos > 0 then
				return text 1 thru (endPos - 1) of tempString
			end if
		end if
	on error
		return ""
	end try
	return ""
end extractJSONValue

-- Parse order data from JSON or manual input
-- Parsování dat ze JSON nebo ručního zadání
--
-- Parameters:
--   jsonData (string) - JSON string or "manual:" prefixed input
-- Returns:
--   {orderNumber, clientName, projectName} - Record with parsed values
on parseOrderData(jsonData)
	set orderNumber to ""
	set projectName to ""
	set clientName to ""
	
	try
		-- Handle manual input - Zpracování ručního zadání
		if jsonData starts with "manual:" then
			set manualData to text 8 thru -1 of jsonData
			set AppleScript's text item delimiters to " - "
			set dataParts to text items of manualData
			set AppleScript's text item delimiters to ""
			
			if (count of dataParts) >= 3 then
				set orderNumber to item 1 of dataParts
				set clientName to item 2 of dataParts
				set projectName to item 3 of dataParts
			else
				error "Nesprávný formát ručního zadání"
			end if
		else
			-- Parse JSON safely - Bezpečné parsování JSON
			set orderNumber to my extractJSONValue(jsonData, "orderNumber")
			set projectName to my extractJSONValue(jsonData, "projectName")
			set clientName to my extractJSONValue(jsonData, "clientName")
		end if
		
		-- Clean all texts - Očištění všech textů
		set orderNumber to my cleanText(orderNumber)
		set clientName to my cleanText(clientName)
		set projectName to my cleanText(projectName)
		
	on error errorMessage
		-- Fallback to empty values on any parsing error
		-- Záložní prázdné hodnoty při jakékoliv chybě parsování
		set orderNumber to ""
		set clientName to ""
		set projectName to ""
	end try
	
	return {orderNumber:orderNumber, clientName:clientName, projectName:projectName}
end parseOrderData

-- Create folder structure
-- Vytvoření struktury složek
--
-- Parameters:
--   orderNumber (string) - Order number
--   clientName (string) - Client name
--   projectName (string) - Project name
-- Returns:
--   (boolean) - true if successful, false otherwise
on createProjectFolders(orderNumber, clientName, projectName)
	set yearSuffix to my getCurrentYearSuffix()
	set projectInfo to orderNumber & " - " & clientName & " - " & projectName
	
	-- Validate max length (macOS limit 255 chars)
	if length of projectInfo > 240 then
		activate
		display alert "Název složky je příliš dlouhý" message "Celková délka: " & (length of projectInfo) & " znaků (max 240)." & return & return & "Zkraťte název klienta nebo projektu." buttons {UI_BTN_OK} default button UI_BTN_OK
		return false
	end if
	
	try
		-- Validate base path exists (disk mounted)
		try
			set folderLocation to PROJECT_BASE_PATH as POSIX file as alias
		on error
			activate
			display alert "Síťový disk není připojen" message "Připojte disk obsahující složku:" & return & return & PROJECT_BASE_PATH & return & return & "a zkuste znovu." buttons {UI_BTN_OK} default button UI_BTN_OK
			return false
		end try
		
		set mainFolderPath to (folderLocation as string) & projectInfo & ":"
		
		tell application "Finder"
			-- Check if main folder already exists (idempotence)
			if exists folder projectInfo of folderLocation then
				activate
				display alert "Složka již existuje" message "Projektová složka \"" & projectInfo & "\" již byla vytvořena. Chcete pokračovat?" buttons {UI_BTN_CANCEL, UI_BTN_OPEN} default button UI_BTN_OPEN cancel button UI_BTN_CANCEL
				
				if button returned of result is UI_BTN_OPEN then
					reveal folder mainFolderPath
					activate
				end if
				return true -- Already exists, consider success
			end if
			
			-- Create main folder - Vytvoření hlavní složky
			make new folder at folderLocation with properties {name:projectInfo}
			
			-- Create subfolders - Vytvoření podsložek
			repeat with subfolderName in SUBFOLDER_NAMES
				make new folder at folder mainFolderPath with properties {name:subfolderName}
			end repeat
			
			-- Create final numbered folder - Vytvoření finální číslované složky
			set finalFolderName to yearSuffix & "_" & orderNumber
			make new folder at folder mainFolderPath with properties {name:finalFolderName}
		end tell
		
		return true
		
	on error errorMessage
		display dialog "Chyba při vytváření složek: " & errorMessage buttons {UI_BTN_OK} default button UI_BTN_OK
		return false
	end try
end createProjectFolders

-- Main execution function
-- Hlavní spouštěcí funkce
on main()
	set orderData to my extractOrderData()
	
	if orderData is not missing value then
		set parsedData to my parseOrderData(orderData)
		set orderNumber to orderNumber of parsedData
		set clientName to clientName of parsedData
		set projectName to projectName of parsedData
		
		-- Validate extracted data - Validace extrahovaných dat
		if orderNumber is not "" and clientName is not "" and projectName is not "" then
			-- Show confirmation dialog - Zobrazení kontrolního dialogu
			activate
			display dialog "Extrahovaná data ze Safari:" & return & return & "Číslo: " & orderNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Vytvořit projektové složky?" buttons {UI_BTN_CANCEL, UI_BTN_CREATE} default button UI_BTN_CREATE
			
			if button returned of result is UI_BTN_CREATE then
				set success to my createProjectFolders(orderNumber, clientName, projectName)
				if success then
					-- Reveal created folder in Finder
					tell application "Finder"
						try
							set revealPath to (PROJECT_BASE_PATH as POSIX file as text) & orderNumber & " - " & clientName & " - " & projectName & ":"
							reveal folder revealPath
							activate
						end try
					end tell
					
					delay 0.5 -- Give user time to see Finder
					
					activate
					display dialog "Složky úspěšně vytvořeny!" & return & return & "Nezapomeňte:" & return & "• Přijmout přidělení v Safari" & return & "• Nakopírovat zdroje" buttons {UI_BTN_OK} default button UI_BTN_OK with title "Hotovo!"
				end if
			end if
		else
			display dialog "Chybný formát dat! Použijte: číslo projektu - klient - název projektu" buttons {UI_BTN_OK} default button UI_BTN_OK
		end if
	else
		display dialog "Nebyla získána žádná data. Skript bude ukončen." buttons {UI_BTN_OK} default button UI_BTN_OK
	end if
end main

-- Execute main function
main()
