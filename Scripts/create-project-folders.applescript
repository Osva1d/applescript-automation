-- Zjednodu?en? skript pro vytv�?en� projektov?ch slo?ek
on cleanText(inputText)
    -- Odstran?n� b�l?ch znak? na za?�tku a konci
    set cleanedText to inputText
    
    -- Odstran?n� b�l?ch znak? ze za?�tku
    repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
        if length of cleanedText > 1 then
            set cleanedText to text 2 thru -1 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Odstran?n� b�l?ch znak? z konce
    repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
        if length of cleanedText > 1 then
            set cleanedText to text 1 thru -2 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Nahrazen� nebezpe?n?ch znak? pro n�zvy slo?ek
    set dangerousChars to {"/", "\\", ":", "*", "?", "\"", "<", ">", "|", return, tab}
    set replacementChar to "_"
    
    repeat with dangerousChar in dangerousChars
        set AppleScript's text item delimiters to dangerousChar
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to replacementChar
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    -- Odstran?n� v�cen�sobn?ch podtr?�tek
    repeat while cleanedText contains "__"
        set AppleScript's text item delimiters to "__"
        set textParts to text items of cleanedText
        set AppleScript's text item delimiters to "_"
        set cleanedText to textParts as string
    end repeat
    
    set AppleScript's text item delimiters to ""
    
    return cleanedText
end cleanText

-- Z�sk�n� aktu�ln�ho roku a posledn�ch dvoj?�sl�
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Pevn� um�st?n� pro projektov� slo?ky
set folderLocation to "/Volumes/StudioTwo_T5/MARA/Tisk Studio Two" as POSIX file as alias

-- Extrakce dat ze Safari pomoc� p?esn?ch CSS selektor?
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejd?�ve otev?ete zak�zkov? list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomoc� JavaScript a p?esn?ch selektor?
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce ?�sla zak�zky ze span.Header1
            var zakazkaSpan = document.querySelector('span.Header1');
            if (zakazkaSpan) {
                var text = zakazkaSpan.textContent;
                var match = text.match(/Zak�zka ?�slo:\\s*(\\d+\\.\\d+)/);
                if (match) {
                    result.projectNumber = match[1].replace('.', '');
                }
            }
            
            // Extrakce projektu z tabulky - hled�me td.TabColHead obsahuj�c� 'Projekt:'
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
            
            // Extrakce klienta z tabulky - hled�me td.TabColHead obsahuj�c� 'Klient:'
            for (var i = 0; i < allTabColHeads.length; i++) {
                if (allTabColHeads[i].textContent.trim() === 'Klient:') {
                    var nextTd = allTabColHeads[i].nextElementSibling;
                    if (nextTd && nextTd.classList.contains('TabValue')) {
                        result.clientName = nextTd.textContent.trim();
                        break;
                    }
                }
            }
            
            // Vr�cen� dat jako JSON string
            JSON.stringify(result);
        " in front document
        
        -- Parsov�n� JSON dat
        set projectNumber to ""
        set projectName to ""
        set clientName to ""
        
        -- Extrakce ?�sla projektu
        if extractedData contains "\"projectNumber\":\"" then
            set startPos to offset of "\"projectNumber\":\"" in extractedData
            set tempString to text (startPos + 17) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set projectNumber to text 1 thru (endPos - 1) of tempString
            end if
        end if
        
        -- Extrakce n�zvu projektu
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
        
        -- O?i?t?n� v?ech text?
        set projectNumber to my cleanText(projectNumber)
        set clientName to my cleanText(clientName)
        set projectName to my cleanText(projectName)
        
        -- Sestaven� fin�ln�ho n�zvu
        if projectNumber is not "" and clientName is not "" and projectName is not "" then
            set projectInfo to projectNumber & " - " & clientName & " - " & projectName
        else
            -- Fallback na ru?n� zad�n�
            display dialog "Automatick� extrakce se nezda?ila. Zadejte �daje ru?n?:" & return & "Form�t: ?�slo - klient - n�zev projektu" default answer "" buttons {"Zru?it", "OK"} default button "OK"
            if button returned of result is "Zru?it" then
                return
            end if
            set projectInfo to text returned of result
        end if
        
    on error errorMessage
        display dialog "Chyba p?i ?ten� dat ze Safari. Zadejte �daje ru?n?:" & return & "Form�t: ?�slo - klient - n�zev projektu" default answer "" buttons {"Zru?it", "OK"} default button "OK"
        if button returned of result is "Zru?it" then
            return
        end if
        set projectInfo to text returned of result
    end try
end tell

-- Kontrola, zda bylo n?co z�sk�no
if projectInfo is "" then
    display dialog "Nebyla z�sk�na ?�dn� data. Skript bude ukon?en." buttons {"OK"} default button "OK"
    return
end if

-- Extrakce ?�sla projektu z fin�ln�ho ?et?zce
set AppleScript's text item delimiters to " - "
set projectParts to text items of projectInfo
set AppleScript's text item delimiters to ""

if (count of projectParts) < 3 then
    display dialog "Chybn? form�t! Pou?ijte: ?�slo projektu - klient - n�zev projektu" buttons {"OK"} default button "OK"
    return
end if

set projectNumber to item 1 of projectParts

-- Vytvo?en� hlavn� slo?ky projektu
set mainFolderPath to (folderLocation as string) & projectInfo & ":"
tell application "Finder"
    try
        make new folder at folderLocation with properties {name:projectInfo}
        
        -- Vytvo?en� podslo?ek
        set subfolders to {"pracovn�", "zdroje"}
        repeat with subfolder in subfolders
            make new folder at folder mainFolderPath with properties {name:subfolder}
        end repeat
        
        -- Vytvo?en� fin�ln� slo?ky s n�zvem podle kl�?e
        set finalFolderName to lastTwoDigits & "_" & projectNumber
        make new folder at folder mainFolderPath with properties {name:finalFolderName}
        
        -- Jedin? z�v?re?n? dialog s potvrzen�m a p?ipomenut�m
        display dialog "Slo?ky projektu byly �sp??n? vytvo?eny!" & return & return & "Projekt: " & projectInfo & return & return & "Nezapome?te:" & return & "� Stisknout tla?�tko 'p?ijmout p?id?len�' v Safari" & return & "� Nakop�rovat zdrojov� data do slo?ky 'zdroje'" buttons {"OK"} default button "OK" with title "Hotovo!"
        
    on error
        display dialog "Chyba p?i vytv�?en� slo?ek! Mo?n� ji? existuj�." buttons {"OK"} default button "OK"
    end try
end tell