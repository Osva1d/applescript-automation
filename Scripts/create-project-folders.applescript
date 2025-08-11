-- Automatizace zalo?en� projektov?ch slo?ek
-- Autor: AppleScript pro zak�zkov? syst�m
-- Verze: 1.0

-- Z�sk�n� aktu�ln�ho roku a posledn�ch dvoj?�sl�
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Z�sk�n� aktu�ln�ho roku a posledn�ch dvoj?�sl�
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Pevn� um�st?n� pro projektov� slo?ky (upravte cestu podle va?ich pot?eb)
set folderLocation to (path to desktop) -- M??ete zm?nit na: (path to documents folder), (path to home folder), nebo konkr�tn� cestu
-- Pro konkr�tn� cestu pou?ijte: set folderLocation to "Macintosh HD:Users:Va?eJm�no:Projekty:" as alias

-- Funkce pro o?i?t?n� textu od b�l?ch znak? a nebezpe?n?ch znak?
on cleanText(inputText)
    -- Odstran?n� b�l?ch znak? na za?�tku a konci
    set cleanedText to inputText
    
    -- Odstran?n� b�l?ch znak? ze za?�tku
    repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
        set cleanedText to text 2 thru -1 of cleanedText
    end repeat
    
    -- Odstran?n� b�l?ch znak? z konce
    repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
        set cleanedText to text 1 thru -2 of cleanedText
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
    
end cleanText

-- Z�sk�n� aktu�ln�ho roku a posledn�ch dvoj?�sl�
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Pevn� um�st?n� pro projektov� slo?ky (upravte cestu podle va?ich pot?eb)
set folderLocation to (path to desktop) -- M??ete zm?nit na: (path to documents folder), (path to home folder), nebo konkr�tn� cestu
-- Pro konkr�tn� cestu pou?ijte: set folderLocation to "Macintosh HD:Users:Va?eJm�no:Projekty:" as alias

-- Extrakce dat ze Safari
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejd?�ve otev?ete zak�zkov? list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomoc� JavaScript
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce ?�sla zak�zky (hled�me 'Zak�zka ?�slo: X.XXX')
            var zakazkaElement = document.querySelector('span.Header1');
            if (zakazkaElement && zakazkaElement.textContent.includes('Zak�zka ?�slo:')) {
                var zakazkaText = zakazkaElement.textContent;
                var match = zakazkaText.match(/Zak�zka ?�slo:\\s*(\\d+\\.\\d+)/);
                if (match) {
                    result.projectNumber = match[1].replace('.', '');
                }
            }
            
            // Extrakce n�zvu projektu (hled�me v tabulce ?�dek s 'Projekt:')
            var tables = document.querySelectorAll('table.TabVertic');
            for (var i = 0; i < tables.length; i++) {
                var rows = tables[i].querySelectorAll('tr');
                for (var j = 0; j < rows.length; j++) {
                    var cells = rows[j].querySelectorAll('td');
                    if (cells.length >= 2 && cells[0].textContent.includes('Projekt:')) {
                        result.projectName = cells[1].textContent.trim();
                        break;
                    }
                }
                if (result.projectName) break;
            }
            
            // Extrakce klienta (hled�me v tabulce ?�dek s 'Klient:')
            for (var i = 0; i < tables.length; i++) {
                var rows = tables[i].querySelectorAll('tr');
                for (var j = 0; j < rows.length; j++) {
                    var cells = rows[j].querySelectorAll('td');
                    if (cells.length >= 2 && cells[0].textContent.includes('Klient:')) {
                        result.clientName = cells[1].textContent.trim();
                        break;
                    }
                }
                if (result.clientName) break;
            }
            
            // Vr�cen� dat jako JSON string
            JSON.stringify(result);
        " in front document
        
        -- Parsov�n� JSON dat
        set dataRecord to extractedData
        
        -- Extrakce jednotliv?ch hodnot z JSON (jednoduch? parsing)
        set projectNumber to ""
        set projectName to ""
        set clientName to ""
        
        -- Parsov�n� ?�sla projektu
        if dataRecord contains "\"projectNumber\":\"" then
            set startPos to offset of "\"projectNumber\":\"" in dataRecord
            set tempString to text (startPos + 17) thru -1 of dataRecord
            set endPos to offset of "\"" in tempString
            set projectNumber to text 1 thru (endPos - 1) of tempString
        end if
        
        -- Parsov�n� n�zvu projektu
        if dataRecord contains "\"projectName\":\"" then
            set startPos to offset of "\"projectName\":\"" in dataRecord
            set tempString to text (startPos + 15) thru -1 of dataRecord
            set endPos to offset of "\"" in tempString
            set projectName to text 1 thru (endPos - 1) of tempString
        end if
        
        -- Parsov�n� klienta
        if dataRecord contains "\"clientName\":\"" then
            set startPos to offset of "\"clientName\":\"" in dataRecord
            set tempString to text (startPos + 14) thru -1 of dataRecord
            set endPos to offset of "\"" in tempString
            set clientName to text 1 thru (endPos - 1) of tempString
        end if
        
        -- O?i?t?n� v?ech text?
        set projectNumber to my cleanText(projectNumber)
        set clientName to my cleanText(clientName)
        set projectName to my cleanText(projectName)
        
        -- Sestaven� fin�ln�ho n�zvu
        set projectInfo to projectNumber & " - " & clientName & " - " & projectName
        
        -- Zobrazen� extrahovan?ch dat pro kontrolu
        display dialog "Extrahovan� data:" & return & return & "?�slo: " & projectNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Fin�ln� n�zev: " & projectInfo & return & return & "Pokra?ovat?" buttons {"Zru?it", "Ano"} default button "Ano"
        if button returned of result is "Zru?it" then
            return
        end if
        
    on error errorMessage
        display dialog "Chyba p?i ?ten� dat ze Safari:" & return & errorMessage & return & return & "Zadejte �daje ru?n?:" default answer "" buttons {"Zru?it", "OK"} default button "OK"
        if button returned of result is "Zru?it" then
            return
        end if
        set projectInfo to text returned of result
    end try
end tell

-- Extrakce ?�sla projektu (prvn� ?�st p?ed prvn� poml?kou)
set AppleScript's text item delimiters to " - "
set projectParts to text items of projectInfo
set AppleScript's text item delimiters to ""

if (count of projectParts) < 3 then
    display dialog "Chybn? form�t! Pou?ijte: ?�slo projektu - klient - n�zev projektu" buttons {"OK"} default button "OK"
    return
end if

set projectNumber to item 1 of projectParts

-- Pevn� um�st?n� pro projektov� slo?ky (upravte cestu podle va?ich pot?eb)
set folderLocation to (path to desktop) -- M??ete zm?nit na: (path to documents folder), (path to home folder), nebo konkr�tn� cestu
-- Pro konkr�tn� cestu pou?ijte: set folderLocation to "Macintosh HD:Users:Va?eJm�no:Projekty:" as alias

-- Vytvo?en� hlavn� slo?ky projektu
set mainFolderPath to (folderLocation as string) & projectInfo & ":"
tell application "Finder"
    try
        make new folder at folderLocation with properties {name:projectInfo}
    on error
        display dialog "Chyba p?i vytv�?en� hlavn� slo?ky! Mo?n� ji? existuje." buttons {"OK"} default button "OK"
        return
    end try
end tell

-- Vytvo?en� podslo?ek
set subfolders to {"pracovn�", "zdroje"}
tell application "Finder"
    repeat with subfolder in subfolders
        try
            make new folder at folder mainFolderPath with properties {name:subfolder}
        on error
            display dialog "Chyba p?i vytv�?en� slo?ky: " & subfolder buttons {"OK"} default button "OK"
        end try
    end repeat
end tell

-- Vytvo?en� fin�ln� slo?ky s n�zvem podle kl�?e (posledn� dvoj?�sl� roku_?�slo projektu)
set finalFolderName to lastTwoDigits & "_" & projectNumber
tell application "Finder"
    try
        make new folder at folder mainFolderPath with properties {name:finalFolderName}
    on error
        display dialog "Chyba p?i vytv�?en� fin�ln� slo?ky!" buttons {"OK"} default button "OK"
    end try
end tell

-- Otev?en� hlavn� slo?ky projektu
tell application "Finder"
    open folder mainFolderPath
end tell

-- P?ipomenut� �kol?
display dialog "Slo?ky projektu byly �sp??n? vytvo?eny!" & return & return & "Nezapome?te:" & return & "� Stisknout tla?�tko 'p?ijmout p?id?len�' v Safari" & return & "� Nakop�rovat zdrojov� data do slo?ky 'zdroje'" buttons {"OK"} default button "OK" with title "Hotovo!"

-- Otev?en� Safari pro p?ijmut� zak�zky (voliteln�)
display dialog "Chcete otev?�t Safari pro p?ijmut� zak�zky?" buttons {"Ne", "Ano"} default button "Ano"
if button returned of result is "Ano" then
    tell application "Safari"
        activate
        -- Zde by bylo mo?n� p?idat specifickou URL, pokud je zn�ma
        -- open location "https://vase-zakazky.cz/pridat-zakazku"
    end tell
end if