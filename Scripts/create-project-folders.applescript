-- Zjednodušený skript pro vytváření projektových složek
on cleanText(inputText)
    -- Odstranění bílých znaků na začátku a konci
    set cleanedText to inputText
    
    -- Odstranění bílých znaků ze začátku
    repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
        if length of cleanedText > 1 then
            set cleanedText to text 2 thru -1 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Odstranění bílých znaků z konce
    repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
        if length of cleanedText > 1 then
            set cleanedText to text 1 thru -2 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Odstranění zdvojených mezer uvnitř textu
    repeat while cleanedText contains "  "
        set AppleScript's text item delimiters to "  "
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to " "
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    -- Nahrazení nebezpečných znaků pro názvy složek
    set dangerousChars to {"/", "\\", ":", "*", "?", "\"", "<", ">", "|", return, tab}
    set replacementChar to "_"
    
    repeat with dangerousChar in dangerousChars
        set AppleScript's text item delimiters to dangerousChar
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to replacementChar
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    -- Odstranění vícenásobných podtržítek
    repeat while cleanedText contains "__"
        set AppleScript's text item delimiters to "__"
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to "_"
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    return cleanedText
end cleanText

-- Získání aktuálního roku a posledních dvojčíslí
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Pevné umístění pro projektové složky
set folderLocation to "/Volumes/StudioTwo_T5/MARA/Tisk Studio Two" as POSIX file as alias

-- Extrakce dat ze Safari pomocí přesných CSS selektorů
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejdříve otevřete zakázkový list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomocí JavaScript a přesných selektorů
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce čísla zakázky ze span.Header1
            var zakazkaSpan = document.querySelector('span.Header1');
            if (zakazkaSpan) {
                var text = zakazkaSpan.textContent;
                var match = text.match(/Zakázka číslo:\\s*(\\d+\\.\\d+)/);
                if (match) {
                    result.projectNumber = match[1].replace('.', '');
                }
            }
            
            // Extrakce projektu z tabulky - hledáme td.TabColHead obsahující 'Projekt:'
            var allTabColHeads = document.querySelectorAll('td.TabColHead');
            for (var i = 0; i < allTabColHeads.length; i++) {
                if (allTabColHeads[i].textContent.trim() === 'Projekt:') {
                    var nextTd = allTabColHeads[i].nextElementSibling;
                    if (nextTd && nextTd.classList.contains('TabValue')) {
                        result.projectName = nextTd.textContent.trim();
                        break;
                    }
                }
            }
            
            // Extrakce klienta z tabulky - hledáme td.TabColHead obsahující 'Klient:'
            for (var i = 0; i < allTabColHeads.length; i++) {
                if (allTabColHeads[i].textContent.trim() === 'Klient:') {
                    var nextTd = allTabColHeads[i].nextElementSibling;
                    if (nextTd && nextTd.classList.contains('TabValue')) {
                        result.clientName = nextTd.textContent.trim();
                        break;
                    }
                }
            }
            
            // Vrácení dat jako JSON string
            JSON.stringify(result);
        " in front document
        
        -- Parsování JSON dat
        set projectNumber to ""
        set projectName to ""
        set clientName to ""
        
        -- Extrakce čísla projektu
        if extractedData contains "\"projectNumber\":\"" then
            set startPos to offset of "\"projectNumber\":\"" in extractedData
            set tempString to text (startPos + 17) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set projectNumber to text 1 thru (endPos - 1) of tempString
            end if
        end if
        
        -- Extrakce názvu projektu
        if extractedData contains "\"projectName\":\"" then
            set startPos to offset of "\"projectName\":\"" in extractedData
            set tempString to text (startPos + 15) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set projectName to text 1 thru (endPos - 1) of tempString
            end if
        end if
        
        -- Extrakce klienta
        if extractedData contains "\"clientName\":\"" then
            set startPos to offset of "\"clientName\":\"" in extractedData
            set tempString to text (startPos + 14) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set clientName to text 1 thru (endPos - 1) of tempString
            end if
        end if
        
        -- Očištění všech textů
        set projectNumber to my cleanText(projectNumber)
        set clientName to my cleanText(clientName)
        set projectName to my cleanText(projectName)
        
        -- Sestavení finálního názvu a zobrazení kontrolního dialogu
        if projectNumber is not "" and clientName is not "" and projectName is not "" then
            set projectInfo to projectNumber & " - " & clientName & " - " & projectName
            
            -- Kontrolní dialog s náhledem dat
            activate  -- Přenese focus na AppleScript dialog
            display dialog "Extrahovaná data ze Safari:" & return & return & "Číslo: " & projectNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Vytvořit projektové složky?" buttons {"Zrušit", "Vytvořit"} default button "Vytvořit"
            
            if button returned of result is "Zrušit" then
                return
            end if
        else
            -- Fallback na ruční zadání
            activate  -- Přenese focus na AppleScript dialog
            display dialog "Automatická extrakce se nezdařila. Zadejte údaje ručně:" & return & "Formát: číslo - klient - název projektu" default answer "" buttons {"Zrušit", "OK"} default button "OK"
            if button returned of result is "Zrušit" then
                return
            end if
            set projectInfo to text returned of result
        end if
        
    on error errorMessage
        activate  -- Přenese focus na AppleScript dialog
        display dialog "Chyba při čtení dat ze Safari. Zadejte údaje ručně:" & return & "Formát: číslo - klient - název projektu" default answer "" buttons {"Zrušit", "OK"} default button "OK"
        if button returned of result is "Zrušit" then
            return
        end if
        set projectInfo to text returned of result
    end try
end tell

-- Kontrola, zda bylo něco získáno
if projectInfo is "" then
    display dialog "Nebyla získána žádná data. Skript bude ukončen." buttons {"OK"} default button "OK"
    return
end if

-- Extrakce čísla projektu z finálního řetězce
set AppleScript's text item delimiters to " - "
set projectParts to text items of projectInfo
set AppleScript's text item delimiters to ""

if (count of projectParts) < 3 then
    display dialog "Chybný formát! Použijte: číslo projektu - klient - název projektu" buttons {"OK"} default button "OK"
    return
end if

set projectNumber to item 1 of projectParts

-- TEPRVE TEĎ se vytvoří složky (po potvrzení uživatele)
set mainFolderPath to (folderLocation as string) & projectInfo & ":"
tell application "Finder"
    try
        make new folder at folderLocation with properties {name:projectInfo}
        
        -- Vytvoření podsložek
        set subfolders to {"pracovní", "zdroje"}
        repeat with subfolder in subfolders
            make new folder at folder mainFolderPath with properties {name:subfolder}
        end repeat
        
        -- Vytvoření finální složky s názvem podle klíče
        set finalFolderName to lastTwoDigits & "_" & projectNumber
        make new folder at folder mainFolderPath with properties {name:finalFolderName}
        
        -- Krátké potvrzení o úspěchu
        activate  -- Přenese focus na AppleScript dialog
        display dialog "Složky úspěšně vytvořeny!" & return & return & "Nezapomeňte:" & return & "• Přijmout přidělení v Safari" & return & "• Nakopírovat zdroje" buttons {"OK"} default button "OK" with title "Hotovo!"
        
    on error
        display dialog "Chyba při vytváření složek! Možná již existují." buttons {"OK"} default button "OK"
    end try
end tell