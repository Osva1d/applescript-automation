-- Project folder creation script for print production
-- Skript pro vytváření projektových složek

-- Configuration - Konfigurace
property PROJECT_BASE_PATH : "/Volumes/StudioTwo_T5/MARA/Tisk Studio Two"
property SUBFOLDER_NAMES : {"pracovni", "zdroje"}
property DANGEROUS_CHARS : {"/", "\\", ":", "*", "?", "\"", "<", ">", "|"}

-- Clean and sanitize text for folder names
-- Očištění a sanitizace textu pro názvy složek
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

-- Get current year last two digits - Získání posledních dvou číslic roku
on getCurrentYearSuffix()
    set currentYear to year of (current date)
    set yearString to currentYear as string
    return text -2 thru -1 of yearString
end getCurrentYearSuffix

-- Extract data from Safari order page - Extrakce dat ze Safari zakázkového listu
on extractOrderData()
    tell application "Safari"
        if not (exists front document) then
            display dialog "Nejdříve otevřete zakázkový list v Safari!" buttons {"OK"} default button "OK"
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
            display dialog "Chyba při čtení dat ze Safari. Zadejte údaje ručně:" & return & "Formát: číslo - klient - název projektu" default answer "" buttons {"Zrušit", "OK"} default button "OK"
            if button returned of result is "Zrušit" then
                return missing value
            end if
            -- Return manual input with special prefix - Vrácení ručního zadání se speciálním prefixem
            return "manual:" & (text returned of result)
        end try
    end tell
end extractOrderData

-- Safely extract value from JSON-like string - Bezpečná extrakce hodnoty z JSON řetězce
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

-- Parse order data from JSON or manual input - Parsování dat ze JSON nebo ručního zadání
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

-- Create folder structure - Vytvoření struktury složek
on createProjectFolders(orderNumber, clientName, projectName)
    set yearSuffix to my getCurrentYearSuffix()
    set projectInfo to orderNumber & " - " & clientName & " - " & projectName
    
    try
        set folderLocation to PROJECT_BASE_PATH as POSIX file as alias
        set mainFolderPath to (folderLocation as string) & projectInfo & ":"
        
        tell application "Finder"
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
        display dialog "Chyba při vytváření složek: " & errorMessage buttons {"OK"} default button "OK"
        return false
    end try
end createProjectFolders

-- Main execution - Hlavní spuštění
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
        display dialog "Extrahovaná data ze Safari:" & return & return & "Číslo: " & orderNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Vytvořit projektové složky?" buttons {"Zrušit", "Vytvořit"} default button "Vytvořit"
        
        if button returned of result is "Vytvořit" then
            set success to my createProjectFolders(orderNumber, clientName, projectName)
            if success then
                activate
                display dialog "Složky úspěšně vytvořeny!" & return & return & "Nezapomeňte:" & return & "• Přijmout přidělení v Safari" & return & "• Nakopírovat zdroje" buttons {"OK"} default button "OK" with title "Hotovo!"
            end if
        end if
    else
        display dialog "Chybný formát dat! Použijte: číslo projektu - klient - název projektu" buttons {"OK"} default button "OK"
    end if
else
    display dialog "Nebyla získána žádná data. Skript bude ukončen." buttons {"OK"} default button "OK"
end if