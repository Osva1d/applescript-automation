-- Opraven? skript pro extrakci dat ze Safari podle HTML struktury
on cleanText(inputText)
    -- Odstran?ní bíl?ch znak? na za?átku a konci
    set cleanedText to inputText
    
    -- Odstran?ní bíl?ch znak? ze za?átku
    repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
        if length of cleanedText > 1 then
            set cleanedText to text 2 thru -1 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Odstran?ní bíl?ch znak? z konce
    repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
        if length of cleanedText > 1 then
            set cleanedText to text 1 thru -2 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Nahrazení nebezpe?n?ch znak? pro názvy slo?ek
    set dangerousChars to {"/", "\\", ":", "*", "?", "\"", "<", ">", "|", return, tab}
    set replacementChar to "_"
    
    repeat with dangerousChar in dangerousChars
        set AppleScript's text item delimiters to dangerousChar
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to replacementChar
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    -- Odstran?ní vícenásobn?ch podtr?ítek
    repeat while cleanedText contains "__"
        set AppleScript's text item delimiters to "__"
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to "_"
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    return cleanedText
end cleanText

-- Získání aktuálního roku a posledních dvoj?íslí
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Pevné umíst?ní pro projektové slo?ky
set folderLocation to "/Volumes/StudioTwo_T5/MARA/Tisk Studio Two" as POSIX file as alias

-- Extrakce dat ze Safari pomocí p?esn?ch CSS selektor?
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejd?íve otev?ete zakázkov? list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomocí JavaScript a p?esn?ch selektor?
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce ?ísla zakázky ze span.Header1
            var zakazkaSpan = document.querySelector('span.Header1');
            if (zakazkaSpan) {
                var text = zakazkaSpan.textContent;
                var match = text.match(/Zakázka ?íslo:\\s*(\\d+\\.\\d+)/);
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
        
        -- Parsování JSON dat (zjednodu?ené)
        set projectNumber to ""
        set projectName to ""
        set clientName to ""
        
        -- Extrakce ?ísla projektu
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
        
        -- O?i?t?ní v?ech text?
        set projectNumber to my cleanText(projectNumber)
        set clientName to my cleanText(clientName)
        set projectName to my cleanText(projectName)
        
        -- Sestavení finálního názvu
        if projectNumber is not "" and clientName is not "" and projectName is not "" then
            set projectInfo to projectNumber & " - " & clientName & " - " & projectName
            
            -- Zobrazení extrahovan?ch dat pro kontrolu
            display dialog "Extrahovaná data:" & return & return & "?íslo: " & projectNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Finální název: " & projectInfo & return & return & "Pokra?ovat?" buttons {"Zru?it", "Ano"} default button "Ano"
            if button returned of result is "Zru?it" then
                return
            end if
        else
            -- Fallback na ru?ní zadání
            display dialog "Automatická extrakce se nezda?ila:" & return & "?íslo: '" & projectNumber & "'" & return & "Klient: '" & clientName & "'" & return & "Projekt: '" & projectName & "'" & return & return & "Zadejte údaje ru?n?:" default answer "" buttons {"Zru?it", "OK"} default button "OK"
            if button returned of result is "Zru?it" then
                return
            end if
            set projectInfo to text returned of result
        end if
        
    on error errorMessage
        display dialog "Chyba p?i ?tení dat ze Safari:" & return & errorMessage & return & return & "Zadejte údaje ru?n?:" default answer "" buttons {"Zru?it", "OK"} default button "OK"
        if button returned of result is "Zru?it" then
            return
        end if
        set projectInfo to text returned of result
    end try
end tell

-- Kontrola, zda bylo n?co získáno
if projectInfo is "" then
    display dialog "Nebyla získána ?ádná data. Skript bude ukon?en." buttons {"OK"} default button "OK"
    return
end if

-- Extrakce ?ísla projektu z finálního ?et?zce
set AppleScript's text item delimiters to " - "
set projectParts to text items of projectInfo
set AppleScript's text item delimiters to ""

if (count of projectParts) < 3 then
    display dialog "Chybn? formát! Pou?ijte: ?íslo projektu - klient - název projektu" buttons {"OK"} default button "OK"
    return
end if

set projectNumber to item 1 of projectParts

-- Vytvo?ení hlavní slo?ky projektu
set mainFolderPath to (folderLocation as string) & projectInfo & ":"
tell application "Finder"
    try
        make new folder at folderLocation with properties {name:projectInfo}
    on error
        display dialog "Chyba p?i vytvá?ení hlavní slo?ky! Mo?ná ji? existuje." buttons {"OK"} default button "OK"
        return
    end try
end tell

-- Vytvo?ení podslo?ek
set subfolders to {"pracovní", "zdroje"}
tell application "Finder"
    repeat with subfolder in subfolders
        try
            make new folder at folder mainFolderPath with properties {name:subfolder}
        on error
            display dialog "Chyba p?i vytvá?ení slo?ky: " & subfolder buttons {"OK"} default button "OK"
        end try
    end repeat
end tell

-- Vytvo?ení finální slo?ky s názvem podle klí?e (poslední dvoj?íslí roku_?íslo projektu)
set finalFolderName to lastTwoDigits & "_" & projectNumber
tell application "Finder"
    try
        make new folder at folder mainFolderPath with properties {name:finalFolderName}
    on error
        display dialog "Chyba p?i vytvá?ení finální slo?ky!" buttons {"OK"} default button "OK"
    end try
end tell

-- Otev?ení hlavní slo?ky projektu jako nové zálo?ky ve Finderu
tell application "Finder"
    if (count of Finder windows) > 0 then
        -- Pokud jsou otev?ená okna Finderu, otev?i jako novou zálo?ku
        set target of tab -1 of front Finder window to folder mainFolderPath
    else
        -- Pokud ?ádné okno není otev?ené, otev?i normáln?
        open folder mainFolderPath
    end if
end tell

-- P?ipomenutí úkol?
display dialog "Slo?ky projektu byly úsp??n? vytvo?eny!" & return & return & "Nezapome?te:" & return & "• Stisknout tla?ítko 'p?ijmout p?id?lení' v Safari" & return & "• Nakopírovat zdrojová data do slo?ky 'zdroje'" buttons {"OK"} default button "OK" with title "Hotovo!"

-- Otev?ení Safari pro p?ijmutí zakázky (volitelné)
display dialog "Chcete otev?ít Safari pro p?ijmutí zakázky?" buttons {"Ne", "Ano"} default button "Ano"
if button returned of result is "Ano" then
    tell application "Safari"
        activate
    end tell
end if