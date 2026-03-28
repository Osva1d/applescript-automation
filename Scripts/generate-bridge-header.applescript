-- ===========================================================================
-- Script:      Generate Bridge Header
-- Version:     2.3.0
-- Author:      Osva1d
-- Updated:     2026-03-15
-- Description: Bridge header generator for Shortcuts.app with keyboard shortcut.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------
property TOTAL_HEADER_WIDTH : 85
property MAX_CLIENT_LENGTH : 25
property MIN_SPACING : 2
property PROJECT_BASE_PATH : "/Volumes/PrintServer/Projects/Print Production"

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

-- Detect installed Adobe Bridge version dynamically.
-- Falls back to hardcoded name if detection fails.
--
-- Returns:
--   (string) - Application name (e.g. "Adobe Bridge 2026")
--
on getBridgeAppName()
	try
		set appPath to do shell script "ls -d /Applications/Adobe\\ Bridge\\ 20*.app 2>/dev/null | sort -r | head -1"
		if appPath is not "" then
			set AppleScript's text item delimiters to "/"
			set appFile to last text item of appPath
			set AppleScript's text item delimiters to ".app"
			set appName to first text item of appFile
			set AppleScript's text item delimiters to ""
			return appName
		end if
	on error
		set AppleScript's text item delimiters to ""
	end try
	return "Adobe Bridge " & (year of (current date) as string)
end getBridgeAppName

-- Return list of common legal forms to be stripped from client names.
-- Each Czech form has 8 variants: 4 prefixes (", " / " " / "," / no separator)
-- x 2 punctuation styles (with/without trailing dot).
-- International forms use " " prefix with dot only.
--
-- Returns:
--   (list of strings) - Legal forms with various spacings
--
on getLegalForms()
	-- a.s. (akciová společnost)
	-- s.r.o. (společnost s ručením omezeným)
	-- spol. s r.o., v.o.s., k.s., s.p., z.s., o.p.s.
	-- Každá forma má varianty: prefix (", " / " " / ",") × s/bez tečky × s/bez mezer
	-- Mezinárodní: Ltd., Inc., LLC, GmbH, AG, SE, SAS, SARL
	-- Řazeno od nejdelších forem ke kratším, aby delší shoda měla přednost
	return {¬
		", spol. s r. o.", " spol. s r. o.", ",spol. s r. o.", ", spol. s r. o", ",spol. s r. o", ¬
		", spol. s r.o.", " spol. s r.o.", ",spol. s r.o.", ", spol. s r.o", " spol. s r.o", ",spol. s r.o", ¬
		" o. p. s.", ",o. p. s.", ", o. p. s.", ", o. p. s", " o. p. s", ",o. p. s", ¬
		", o.p.s.", " o.p.s.", ",o.p.s.", ", o.p.s", " o.p.s", ",o.p.s", ¬
		" v. o. s.", ",v. o. s.", ", v. o. s", " v. o. s", ",v. o. s", ¬
		", v.o.s.", " v.o.s.", ",v.o.s.", ", v.o.s", " v.o.s", ",v.o.s", ¬
		" s. r. o.", ",s. r. o.", ", s. r. o", " s. r. o", ",s. r. o", ¬
		", s.r.o.", " s.r.o.", ",s.r.o.", ", s.r.o", " s.r.o", ",s.r.o", ¬
		" a. s.", ",a. s.", ", a. s", " a. s", ",a. s", ¬
		", a.s.", " a.s.", ",a.s.", ", a.s", " a.s", ",a.s", ¬
		" k. s.", ",k. s.", ", k. s", " k. s", ",k. s", ¬
		", k.s.", " k.s.", ",k.s.", ", k.s", " k.s", ",k.s", ¬
		" s. p.", ",s. p.", ", s. p", " s. p", ",s. p", ¬
		", s.p.", " s.p.", ",s.p.", ", s.p", " s.p", ",s.p", ¬
		" z. s.", ",z. s.", ", z. s", " z. s", ",z. s", ¬
		", z.s.", " z.s.", ",z.s.", ", z.s", " z.s", ",z.s", ¬
		" Ltd.", " Inc.", " LLC", " GmbH", " AG", " SE", " SAS", " SARL"}
end getLegalForms

-- Strip leading/trailing whitespace and trailing punctuation for display.
-- NOTE: Odlišná od cleanText() v create-project-folders.applescript, která
--       sanitizuje text pro souborový systém. Tyto funkce NESYNCHRONIZOVAT.
--
-- Parameters:
--   inputText (string) - Text to clean
--
-- Returns:
--   (string) - Cleaned text
--
on stripDisplayText(inputText)
	set cleanedText to inputText
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
	repeat while cleanedText ends with "," or cleanedText ends with "." or cleanedText ends with ";" or cleanedText ends with ":"
		if length of cleanedText > 1 then
			set cleanedText to text 1 thru -2 of cleanedText
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
	return cleanedText
end stripDisplayText

-- Process client name by stripping legal forms and truncating to max length.
--
-- Parameters:
--   clientName (string) - Raw client name
--   maxLength (integer) - Maximum allowed length
--
-- Returns:
--   (string) - Processed and truncated client name
--
on processClientName(clientName, maxLength)
	set cleanedName to my stripDisplayText(clientName)
	set legalForms to my getLegalForms()
	repeat with legalForm in legalForms
		if cleanedName ends with legalForm then
			set cleanedName to text 1 thru ((length of cleanedName) - (length of legalForm)) of cleanedName
			exit repeat
		end if
	end repeat
	set cleanedName to my stripDisplayText(cleanedName)
	if length of cleanedName > maxLength then
		set cleanedName to text 1 thru maxLength of cleanedName
		set lastSpacePos to 0
		repeat with i from maxLength to 1 by -1
			if character i of cleanedName is " " then
				set lastSpacePos to i - 1
				exit repeat
			end if
		end repeat
		if lastSpacePos > 0 then
			set cleanedName to text 1 thru lastSpacePos of cleanedName
		end if
	end if
	return cleanedName
end processClientName

-- Create formatted header string with client name, technology, and order info.
--
-- Parameters:
--   clientName (string) - Processed client name
--   technology (string) - Technology name
--   orderNumber (string) - Order number
--   yearSuffix (string) - 2-digit year suffix
--
-- Returns:
--   (string) - Formatted header
-- Throws:
--   error "HEADER_TOO_LONG" if content cannot fit
--
on createBridgeHeader(clientName, technology, orderNumber, yearSuffix)
	set rightText to yearSuffix & "_" & orderNumber
	set leftLength to length of clientName
	set centerLength to length of technology
	set rightLength to length of rightText
	set totalContentLength to leftLength + centerLength + rightLength + (MIN_SPACING * 2)
	if totalContentLength > TOTAL_HEADER_WIDTH then
		set maxClientForFit to TOTAL_HEADER_WIDTH - centerLength - rightLength - (MIN_SPACING * 2)
		if maxClientForFit < 5 then
			error "HEADER_TOO_LONG"
		end if
		set clientName to my processClientName(clientName, maxClientForFit)
		set leftLength to length of clientName
	end if
	set centerPosition to (TOTAL_HEADER_WIDTH - centerLength) div 2
	set leftSpaces to centerPosition - leftLength
	if leftSpaces < MIN_SPACING then set leftSpaces to MIN_SPACING
	set rightSpaces to TOTAL_HEADER_WIDTH - leftLength - leftSpaces - centerLength - rightLength
	if rightSpaces < MIN_SPACING then set rightSpaces to MIN_SPACING
	set leftPadding to ""
	repeat leftSpaces times
		set leftPadding to leftPadding & " "
	end repeat
	set rightPadding to ""
	repeat rightSpaces times
		set rightPadding to rightPadding & " "
	end repeat
	return clientName & leftPadding & technology & rightPadding & rightText
end createBridgeHeader

-- Return last two digits of current year (e.g. "26" for 2026).
-- NOTE: Sdíleno s create-project-folders.applescript — synchronizujte změny.
--
-- Returns:
--   (string) - 2-digit year suffix
--
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
--   (string) - JSON string from page, "manual:<data>" from dialog,
--              or missing value if user cancels / no document open
--
on extractOrderData()
	tell application "Safari"
		if not (exists front document) then
			return missing value
		end if
		try
			set extractedData to do JavaScript "
                var result = {};
                var orderSpan = document.querySelector('span.Header1');
                if (orderSpan) {
                    var text = orderSpan.textContent;
                    var match = text.match(/Zakázka ?číslo:\\s*([\\d\\.]+)/);
                    if (match) {
                        var rawNum = match[1].replace(/\\./g, '');
                        while (rawNum.length < 4) {
                            rawNum = '0' + rawNum;
                        }
                        result.orderNumber = rawNum;
                    }
                }
                var allHeaders = document.querySelectorAll('td.TabColHead');
                for (var i = 0; i < allHeaders.length; i++) {
                    var headerText = allHeaders[i].textContent.trim();
                    var nextCell = allHeaders[i].nextElementSibling;
                    if (nextCell && nextCell.classList.contains('TabValue')) {
                        if (headerText === 'Klient:') {
                            result.clientName = nextCell.textContent.trim();
                        } else if (headerText === 'Technologie:') {
                            result.technology = nextCell.textContent.trim();
                        }
                    }
                }
                JSON.stringify(result);
            " in front document
			return extractedData
		on error errorMessage
			activate
			set dialogResult to display dialog "Chyba při čtení dat ze Safari. Zadejte údaje ručně:" & return & "Formát: číslo - klient - technologie" default answer "" buttons {"Zrušit", "OK"} default button "OK"
			if button returned of dialogResult is "Zrušit" then
				return missing value
			end if
			return "manual:" & (text returned of dialogResult)
		end try
	end tell
end extractOrderData

-- Extract a single string value from a simple JSON string by field name.
-- NOTE: Sdíleno s create-project-folders.applescript — synchronizujte změny.
--
-- Parameters:
--   jsonData (string) - JSON string to search
--   fieldName (string) - key name to look up
--
-- Returns:
--   (string) - extracted value, or "" if not found
--
on extractJSONValue(jsonData, fieldName)
	try
		set q to ASCII character 34
		set searchPattern to q & fieldName & q & ":" & q
		if jsonData contains searchPattern then
			set startPos to offset of searchPattern in jsonData
			set tempString to text (startPos + (length of searchPattern)) thru -1 of jsonData
			set endPos to offset of q in tempString
			if endPos > 0 then
				return text 1 thru (endPos - 1) of tempString
			end if
		end if
	on error
		return ""
	end try
	return ""
end extractJSONValue

-- Parse raw string from extractOrderData() into a structured record.
-- Handles both JSON (page extraction) and "manual:<data>" (fallback dialog).
--
-- Parameters:
--   jsonData (string) - output of extractOrderData()
--
-- Returns:
--   (record) {orderNumber, clientName, technology} - empty strings on failure
--
on parseOrderData(jsonData)
	set orderNumber to ""
	set clientName to ""
	set technology to ""
	try
		if jsonData starts with "manual:" then
			set manualData to text 8 thru -1 of jsonData
			set AppleScript's text item delimiters to " - "
			set dataParts to text items of manualData
			set AppleScript's text item delimiters to ""
			if (count of dataParts) ≥ 3 then
				set orderNumber to item 1 of dataParts
				set clientName to item 2 of dataParts
				-- Rejoin items 3+ to preserve " - " inside technology name
				set technology to item 3 of dataParts
				repeat with i from 4 to (count of dataParts)
					set technology to technology & " - " & (item i of dataParts)
				end repeat
			else
				activate
				display dialog "Nesprávný formát zadání:" & return & return & "Zadáno: " & manualData & return & return & "Očekávaný formát: číslo - klient - technologie" & return & "(odděleno " & quote & " - " & quote & ")" buttons {"OK"} default button "OK" with icon caution
			end if
		else
			set orderNumber to my extractJSONValue(jsonData, "orderNumber")
			set clientName to my extractJSONValue(jsonData, "clientName")
			set technology to my extractJSONValue(jsonData, "technology")
		end if
		set orderNumber to my stripDisplayText(orderNumber)
		set technology to my stripDisplayText(technology)
		set clientName to my processClientName(clientName, MAX_CLIENT_LENGTH)
	on error
		set orderNumber to ""
		set clientName to ""
		set technology to ""
	end try
	return {orderNumber:orderNumber, clientName:clientName, technology:technology}
end parseOrderData

-- ---------------------------------------------------------------------------
-- Bridge Integration
-- ---------------------------------------------------------------------------

-- Find production folder path matching the order number and year suffix.
--
-- Parameters:
--   orderNumber (string) - Order number
--   yearSuffix (string) - 2-digit year suffix
--
-- Returns:
--   (string) - Path to production folder or "" if not found
--
on findProductionFolder(orderNumber, yearSuffix)
	set folderName to yearSuffix & "_" & orderNumber
	try
		do shell script "test -d " & quoted form of PROJECT_BASE_PATH
	on error
		return ""
	end try
	try
		set foundPath to do shell script "ls -d " & quoted form of PROJECT_BASE_PATH & "/*/" & quoted form of folderName & " 2>/dev/null | head -1"
		return foundPath
	on error
		return ""
	end try
end findProductionFolder

-- Open the specified folder path in Adobe Bridge.
--
-- Parameters:
--   folderPath    (string) - Path to open
--   bridgeAppName (string) - Bridge application name
--
-- Returns:
--   (string) - empty on success, error message on failure
--
on openInBridge(folderPath, bridgeAppName)
	try
		do shell script "open -a " & quoted form of bridgeAppName & " " & quoted form of folderPath
		return ""
	on error errMsg
		return errMsg
	end try
end openInBridge

-- ---------------------------------------------------------------------------
-- Main Entry Point
-- ---------------------------------------------------------------------------

-- Entry point for Shortcuts.app
on run argv
	-- Accept both Shortcuts.app {input, parameters} and direct invocation (no args)
	if class of argv is not list then set argv to {}

	-- Guard: verify volume is mounted before any file operations
	if not my checkVolumeAvailable(PROJECT_BASE_PATH) then
		display notification "Disk není připojen." with title "Bridge hlavička"
		return argv
	end if

	-- Detect Bridge version once
	set bridgeAppName to my getBridgeAppName()

	set orderData to my extractOrderData()
	if orderData is missing value then
		display notification "Safari nemá otevřenou stránku zakázky." with title "Bridge hlavička"
		return argv
	end if

	set parsedData to my parseOrderData(orderData)
	set orderNumber to orderNumber of parsedData
	set clientName to clientName of parsedData
	set technology to technology of parsedData

	if orderNumber is "" or clientName is "" or technology is "" then
		activate
		display dialog "Nepodařilo se extrahovat všechna data:" & return & return & "Zakázka: " & orderNumber & return & "Klient: " & clientName & return & "Technologie: " & technology buttons {"OK"} default button "OK" with title "Bridge hlavička" with icon caution
		return argv
	end if

	set yearSuffix to my getCurrentYearSuffix()
	try
		set bridgeHeader to my createBridgeHeader(clientName, technology, orderNumber, yearSuffix)
	on error errMsg
		if errMsg contains "HEADER_TOO_LONG" then
			activate
			display dialog "Jméno klienta je příliš dlouhé pro šířku hlavičky (" & TOTAL_HEADER_WIDTH & " znaků)." buttons {"OK"} default button "OK" with title "Bridge hlavička" with icon caution
			return argv
		else
			error errMsg
		end if
	end try

	-- Prepare everything before showing dialog (eliminates post-dialog delay)
	set orderLabel to yearSuffix & "_" & orderNumber
	set productionFolder to my findProductionFolder(orderNumber, yearSuffix)

	-- Single preview dialog: verify extracted data, Enter to proceed
	set previewMsg to "Zakázka: " & orderLabel & return & "Klient: " & clientName & return & "Technologie: " & technology
	if productionFolder is not "" then
		set previewMsg to previewMsg & return & return & "Složka nalezena — otevře se v Bridge."
	else
		set previewMsg to previewMsg & return & return & "Složka nenalezena na disku."
	end if

	activate
	set userChoice to button returned of (display dialog previewMsg with title "Bridge hlavička" buttons {"Zrušit", "Kopírovat"} default button "Kopírovat")
	if userChoice is "Zrušit" then return argv

	-- Action: copy to clipboard + open Bridge + focus
	set the clipboard to bridgeHeader
	if productionFolder is not "" then
		set bridgeResult to my openInBridge(productionFolder, bridgeAppName)
		if bridgeResult is "" then
			tell application bridgeAppName to activate
		end if
	end if

	return argv
end run