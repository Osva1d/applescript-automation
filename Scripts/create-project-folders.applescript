-- Zjednodu≈°en√Ω skript pro vytv√°≈ôen√≠ projektov√Ωch slo≈æek
on cleanText(inputText)
    -- Odstranƒõn√≠ b√≠l√Ωch znak≈Ø na zaƒç√°tku a konci
    set cleanedText to inputText
    
    -- Odstranƒõn√≠ b√≠l√Ωch znak≈Ø ze zaƒç√°tku
    repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
        if length of cleanedText > 1 then
            set cleanedText to text 2 thru -1 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Odstranƒõn√≠ b√≠l√Ωch znak≈Ø z konce
    repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
        if length of cleanedText > 1 then
            set cleanedText to text 1 thru -2 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Odstranƒõn√≠ zdvojen√Ωch mezer uvnit≈ô textu
    repeat while cleanedText contains "  "
        set AppleScript's text item delimiters to "  "
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to " "
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    -- Nahrazen√≠ nebezpeƒçn√Ωch znak≈Ø pro n√°zvy slo≈æek
    set dangerousChars to {"/", "\\", ":", "*", "?", "\"", "<", ">", "|", return, tab}
    set replacementChar to "_"
    
    repeat with dangerousChar in dangerousChars
        set AppleScript's text item delimiters to dangerousChar
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to replacementChar
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    -- Odstranƒõn√≠ v√≠cen√°sobn√Ωch podtr≈æ√≠tek
    repeat while cleanedText contains "__"
        set AppleScript's text item delimiters to "__"
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to "_"
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    return cleanedText
end cleanText

-- Z√≠sk√°n√≠ aktu√°ln√≠ho roku a posledn√≠ch dvojƒç√≠sl√≠
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Pevn√© um√≠stƒõn√≠ pro projektov√© slo≈æky
set folderLocation to "/Volumes/StudioTwo_T5/MARA/Tisk Studio Two" as POSIX file as alias

-- Extrakce dat ze Safari pomoc√≠ p≈ôesn√Ωch CSS selektor≈Ø
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejd≈ô√≠ve otev≈ôete zak√°zkov√Ω list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomoc√≠ JavaScript a p≈ôesn√Ωch selektor≈Ø
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce ƒç√≠sla zak√°zky ze span.Header1
            var zakazkaSpan = document.querySelector('span.Header1');
            if (zakazkaSpan) {
                var text = zakazkaSpan.textContent;
                var match = text.match(/Zak√°zka ƒç√≠slo:\\s*(\\d+\\.\\d+)/);
                if (match) {
                    result.projectNumber = match[1].replace('.', '');
                }
            }
            
            // Extrakce projektu z tabulky - hled√°me td.TabColHead obsahuj√≠c√≠ 'Projekt:'
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
            
            // Extrakce klienta z tabulky - hled√°me td.TabColHead obsahuj√≠c√≠ 'Klient:'
            for (var i = 0; i < allTabColHeads.length; i++) {
                if (allTabColHeads[i].textContent.trim() === 'Klient:') {
                    var nextTd = allTabColHeads[i].nextElementSibling;
                    if (nextTd && nextTd.classList.contains('TabValue')) {
                        result.clientName = nextTd.textContent.trim();
                        break;
                    }
                }
            }
            
            // Vr√°cen√≠ dat jako JSON string
            JSON.stringify(result);
        " in front document
        
        -- Parsov√°n√≠ JSON dat
        set projectNumber to ""
        set projectName to ""
        set clientName to ""
        
        -- Extrakce ƒç√≠sla projektu
        if extractedData contains "\"projectNumber\":\"" then
            set startPos to offset of "\"projectNumber\":\"" in extractedData
            set tempString to text (startPos + 17) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set projectNumber to text 1 thru (endPos - 1) of tempString
            end if
        end if
        
        -- Extrakce n√°zvu projektu
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
        
        -- Oƒçi≈°tƒõn√≠ v≈°ech text≈Ø
        set projectNumber to my cleanText(projectNumber)
        set clientName to my cleanText(clientName)
        set projectName to my cleanText(projectName)
        
        -- Sestaven√≠ fin√°ln√≠ho n√°zvu a zobrazen√≠ kontroln√≠ho dialogu
        if projectNumber is not "" and clientName is not "" and projectName is not "" then
            set projectInfo to projectNumber & " - " & clientName & " - " & projectName
            
            -- Kontroln√≠ dialog s n√°hledem dat
            activate  -- P≈ôenese focus na AppleScript dialog
            display dialog "Extrahovan√° data ze Safari:" & return & return & "ƒå√≠slo: " & projectNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Vytvo≈ôit projektov√© slo≈æky?" buttons {"Zru≈°it", "Vytvo≈ôit"} default button "Vytvo≈ôit"
            
            if button returned of result is "Zru≈°it" then
                return
            end if
        else
            -- Fallback na ruƒçn√≠ zad√°n√≠
            activate  -- P≈ôenese focus na AppleScript dialog
            display dialog "Automatick√° extrakce se nezda≈ôila. Zadejte √∫daje ruƒçnƒõ:" & return & "Form√°t: ƒç√≠slo - klient - n√°zev projektu" default answer "" buttons {"Zru≈°it", "OK"} default button "OK"
            if button returned of result is "Zru≈°it" then
                return
            end if
            set projectInfo to text returned of result
        end if
        
    on error errorMessage
        activate  -- P≈ôenese focus na AppleScript dialog
        display dialog "Chyba p≈ôi ƒçten√≠ dat ze Safari. Zadejte √∫daje ruƒçnƒõ:" & return & "Form√°t: ƒç√≠slo - klient - n√°zev projektu" default answer "" buttons {"Zru≈°it", "OK"} default button "OK"
        if button returned of result is "Zru≈°it" then
            return
        end if
        set projectInfo to text returned of result
    end try
end tell

-- Kontrola, zda bylo nƒõco z√≠sk√°no
if projectInfo is "" then
    display dialog "Nebyla z√≠sk√°na ≈æ√°dn√° data. Skript bude ukonƒçen." buttons {"OK"} default button "OK"
    return
end if

-- Extrakce ƒç√≠sla projektu z fin√°ln√≠ho ≈ôetƒõzce
set AppleScript's text item delimiters to " - "
set projectParts to text items of projectInfo
set AppleScript's text item delimiters to ""

if (count of projectParts) < 3 then
    display dialog "Chybn√Ω form√°t! Pou≈æijte: ƒç√≠slo projektu - klient - n√°zev projektu" buttons {"OK"} default button "OK"
    return
end if

set projectNumber to item 1 of projectParts

-- TEPRVE TEƒé se vytvo≈ô√≠ slo≈æky (po potvrzen√≠ u≈æivatele)
set mainFolderPath to (folderLocation as string) & projectInfo & ":"
tell application "Finder"
    try
        make new folder at folderLocation with properties {name:projectInfo}
        
        -- Vytvo≈ôen√≠ podslo≈æek
        set subfolders to {"pracovn√≠", "zdroje"}
        repeat with subfolder in subfolders
            make new folder at folder mainFolderPath with properties {name:subfolder}
        end repeat
        
        -- Vytvo≈ôen√≠ fin√°ln√≠ slo≈æky s n√°zvem podle kl√≠ƒçe
        set finalFolderName to lastTwoDigits & "_" & projectNumber
        make new folder at folder mainFolderPath with properties {name:finalFolderName}
        
        -- Kr√°tk√© potvrzen√≠ o √∫spƒõchu
        activate  -- P≈ôenese focus na AppleScript dialog
        display dialog "Slo≈æky √∫spƒõ≈°nƒõ vytvo≈ôeny!" & return & return & "Nezapome≈àte:" & return & "‚Ä¢ P≈ôijmout p≈ôidƒõlen√≠ v Safari" & return & "‚Ä¢ Nakop√≠rovat zdroje" buttons {"OK"} default button "OK" with title "Hotovo!"
        
    on error
        display dialog "Chyba p≈ôi vytv√°≈ôen√≠ slo≈æek! Mo≈æn√° ji≈æ existuj√≠." buttons {"OK"} default button "OK"
    end try
end tell