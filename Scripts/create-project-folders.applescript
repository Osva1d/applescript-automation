-- Automatizace zalo?en� projektov?ch slo?ek
-- Autor: AppleScript pro zak�zkov? syst�m
-- Verze: 1.0

-- Z�sk�n� aktu�ln�ho roku a posledn�ch dvoj?�sl�
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

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
    
    return cleanedText
end cleanText

-- Extrakce dat ze Safari
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejd?�ve otev?ete zak�zkov? list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce ?�sla zak�zky (hled�me text "Zak�zka ?�slo: X.XXX")
        set pageText to do JavaScript "document.body.innerText" in front document
        
        -- Hled�n� ?�sla zak�zky
        set projectNumber to ""
        if pageText contains "Zak�zka ?�slo:" then
            set textItems to paragraphs of pageText
            repeat with textItem in textItems
                if textItem contains "Zak�zka ?�slo:" then
                    set rawNumber to text ((offset of "Zak�zka ?�slo: " in textItem) + 14) thru -1 of textItem
                    -- Odstran?n� te?ky z ?�sla (nap?. "7.261" -> "7261")
                    set AppleScript's text item delimiters to "."
                    set numberParts to text items of rawNumber
                    set AppleScript's text item delimiters to ""
                    set projectNumber to numberParts as string
                    exit repeat
                end if
            end repeat
        end if
        
        -- Extrakce n�zvu projektu (hled�me ?�dek s "Projekt:")
        set projectName to ""
        if pageText contains "Projekt:" then
            set textItems to paragraphs of pageText
            repeat with i from 1 to count of textItems
                if (item i of textItems) contains "Projekt:" then
                    if i < count of textItems then
                        set projectName to item (i + 1) of textItems
                        exit repeat
                    end if
                end if
            end repeat
        end if
        
        -- Extrakce klienta (hled�me "Klient:" a n�sleduj�c� ?�dek)
        set clientName to ""
        if pageText contains "Klient:" then
            set textItems to paragraphs of pageText
            repeat with i from 1 to count of textItems
                if (item i of textItems) contains "Klient:" then
                    if i < count of textItems then
                        set clientName to item (i + 1) of textItems
                        exit repeat
                    end if
                end if
            end repeat
        end if
        
        -- O?i?t?n� v?ech text?
        set projectNumber to cleanText(projectNumber)
        set clientName to cleanText(clientName)
        set projectName to cleanText(projectName)
        
        -- Sestaven� fin�ln�ho n�zvu
        set projectInfo to projectNumber & " - " & clientName & " - " & projectName
        
        -- Zobrazen� extrahovan?ch dat pro kontrolu
        display dialog "Extrahovan� data:" & return & return & projectInfo & return & return & "Pokra?ovat?" buttons {"Zru?it", "Ano"} default button "Ano"
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