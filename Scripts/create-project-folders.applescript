-- Automatizace zalo?ení projektov?ch slo?ek
-- Autor: AppleScript pro zakázkov? systém
-- Verze: 1.0

-- Získání aktuálního roku a posledních dvoj?íslí
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Funkce pro o?i?t?ní textu od bíl?ch znak? a nebezpe?n?ch znak?
on cleanText(inputText)
    -- Odstran?ní bíl?ch znak? na za?átku a konci
    set cleanedText to inputText
    
    -- Odstran?ní bíl?ch znak? ze za?átku
    repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
        set cleanedText to text 2 thru -1 of cleanedText
    end repeat
    
    -- Odstran?ní bíl?ch znak? z konce
    repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
        set cleanedText to text 1 thru -2 of cleanedText
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

-- Extrakce dat ze Safari
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejd?íve otev?ete zakázkov? list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce ?ísla zakázky (hledáme text "Zakázka ?íslo: X.XXX")
        set pageText to do JavaScript "document.body.innerText" in front document
        
        -- Hledání ?ísla zakázky
        set projectNumber to ""
        if pageText contains "Zakázka ?íslo:" then
            set textItems to paragraphs of pageText
            repeat with textItem in textItems
                if textItem contains "Zakázka ?íslo:" then
                    set rawNumber to text ((offset of "Zakázka ?íslo: " in textItem) + 14) thru -1 of textItem
                    -- Odstran?ní te?ky z ?ísla (nap?. "7.261" -> "7261")
                    set AppleScript's text item delimiters to "."
                    set numberParts to text items of rawNumber
                    set AppleScript's text item delimiters to ""
                    set projectNumber to numberParts as string
                    exit repeat
                end if
            end repeat
        end if
        
        -- Extrakce názvu projektu (hledáme ?ádek s "Projekt:")
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
        
        -- Extrakce klienta (hledáme "Klient:" a následující ?ádek)
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
        
        -- O?i?t?ní v?ech text?
        set projectNumber to cleanText(projectNumber)
        set clientName to cleanText(clientName)
        set projectName to cleanText(projectName)
        
        -- Sestavení finálního názvu
        set projectInfo to projectNumber & " - " & clientName & " - " & projectName
        
        -- Zobrazení extrahovan?ch dat pro kontrolu
        display dialog "Extrahovaná data:" & return & return & projectInfo & return & return & "Pokra?ovat?" buttons {"Zru?it", "Ano"} default button "Ano"
        if button returned of result is "Zru?it" then
            return
        end if
        
    on error errorMessage
        display dialog "Chyba p?i ?tení dat ze Safari:" & return & errorMessage & return & return & "Zadejte údaje ru?n?:" default answer "" buttons {"Zru?it", "OK"} default button "OK"
        if button returned of result is "Zru?it" then
            return
        end if
        set projectInfo to text returned of result
    end try
end tell

-- Extrakce ?ísla projektu (první ?ást p?ed první poml?kou)
set AppleScript's text item delimiters to " - "
set projectParts to text items of projectInfo
set AppleScript's text item delimiters to ""

if (count of projectParts) < 3 then
    display dialog "Chybn? formát! Pou?ijte: ?íslo projektu - klient - název projektu" buttons {"OK"} default button "OK"
    return
end if

set projectNumber to item 1 of projectParts

-- Pevné umíst?ní pro projektové slo?ky (upravte cestu podle va?ich pot?eb)
set folderLocation to (path to desktop) -- M??ete zm?nit na: (path to documents folder), (path to home folder), nebo konkrétní cestu
-- Pro konkrétní cestu pou?ijte: set folderLocation to "Macintosh HD:Users:Va?eJméno:Projekty:" as alias

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

-- Otev?ení hlavní slo?ky projektu
tell application "Finder"
    open folder mainFolderPath
end tell

-- P?ipomenutí úkol?
display dialog "Slo?ky projektu byly úsp??n? vytvo?eny!" & return & return & "Nezapome?te:" & return & "• Stisknout tla?ítko 'p?ijmout p?id?lení' v Safari" & return & "• Nakopírovat zdrojová data do slo?ky 'zdroje'" buttons {"OK"} default button "OK" with title "Hotovo!"

-- Otev?ení Safari pro p?ijmutí zakázky (volitelné)
display dialog "Chcete otev?ít Safari pro p?ijmutí zakázky?" buttons {"Ne", "Ano"} default button "Ano"
if button returned of result is "Ano" then
    tell application "Safari"
        activate
        -- Zde by bylo mo?né p?idat specifickou URL, pokud je známa
        -- open location "https://vase-zakazky.cz/pridat-zakazku"
    end tell
end if