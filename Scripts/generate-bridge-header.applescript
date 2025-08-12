-- Kompletní skript: Safari → Bridge hlavička
-- Funkce pro očištění textu
on cleanText(inputText)
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
    
    return cleanedText
end cleanText

-- Funkce pro zkrácení a očištění názvu klienta
on cleanClientName(clientName, maxLength)
    set cleanedName to my cleanText(clientName)
    
    -- Seznam právních forem k odstranění
    set legalForms to {", a.s.", ", s.r.o.", ", spol. s r.o.", ", v.o.s.", ", k.s.", ", s.p.", " a.s.", " s.r.o.", " spol. s r.o.", " v.o.s.", " k.s.", " s.p.", " a. s.", " s. r. o.", " spol. s r. o.", " v. o. s.", " k. s.", " s. p.", " Ltd.", " Inc.", " LLC", " GmbH", " AG", " SE", " SAS", " SARL"}
    
    -- Odstranění právních forem
    repeat with legalForm in legalForms
        if cleanedName ends with legalForm then
            set cleanedName to text 1 thru ((length of cleanedName) - (length of legalForm)) of cleanedName
            exit repeat
        end if
    end repeat
    
    -- Další čištění na konci
    set cleanedName to my cleanText(cleanedName)
    
    -- Zkrácení, pokud je příliš dlouhé
    if length of cleanedName > maxLength then
        set cleanedName to text 1 thru maxLength of cleanedName
        -- Oříznutí na posledním celém slově
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
end cleanClientName

-- Funkce pro vytvoření centrované hlavičky Bridge
on createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
    set totalWidth to 85  -- Menlo font šířka
    set rightText to lastTwoDigits & "_" & projectNumber
    
    -- Výpočet pozic
    set leftLength to length of clientName
    set centerLength to length of technology
    set rightLength to length of rightText
    
    -- Pozice pro centrování technologie
    set centerPosition to (totalWidth - centerLength) / 2
    set leftSpaces to centerPosition - leftLength
    set rightSpaces to totalWidth - leftLength - leftSpaces - centerLength - rightLength
    
    -- Zajistíme, že počet mezer není záporný
    if leftSpaces < 1 then set leftSpaces to 1
    if rightSpaces < 1 then set rightSpaces to 1
    
    -- Vytvoření mezer
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

-- Získání aktuálního roku
set currentYear to year of (current date)
set lastTwoDigits to text -2 thru -1 of (currentYear as string)

-- Extrakce dat ze Safari
tell application "Safari"
    if not (exists front document) then
        activate  -- Přenese focus na AppleScript dialog
        display dialog "Nejdříve otevřete zakázkový list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomocí JavaScript a CSS selektorů
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce čísla zakázky
            var zakazkaSpan = document.querySelector('span.Header1');
            if (zakazkaSpan) {
                var text = zakazkaSpan.textContent;
                var match = text.match(/Zakázka číslo:\\s*(\\d+\\.\\d+)/);
                if (match) {
                    result.projectNumber = match[1].replace('.', '');
                }
            }
            
            // Extrakce projektu, klienta a technologie
            var allTabColHeads = document.querySelectorAll('td.TabColHead');
            for (var i = 0; i < allTabColHeads.length; i++) {
                var headText = allTabColHeads[i].textContent.trim();
                var nextTd = allTabColHeads[i].nextElementSibling;
                
                if (nextTd && nextTd.classList.contains('TabValue')) {
                    if (headText === 'Klient:') {
                        result.clientName = nextTd.textContent.trim();
                    } else if (headText === 'Technologie:') {
                        result.technology = nextTd.textContent.trim();
                    }
                }
            }
            
            JSON.stringify(result);
        " in front document
        
        -- Parsování JSON dat
        set projectNumber to ""
        set clientName to ""
        set technology to ""
        
        -- Extrakce čísla projektu
        if extractedData contains "\"projectNumber\":\"" then
            set startPos to offset of "\"projectNumber\":\"" in extractedData
            set tempString to text (startPos + 17) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set projectNumber to text 1 thru (endPos - 1) of tempString
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
        
        -- Extrakce technologie
        if extractedData contains "\"technology\":\"" then
            set startPos to offset of "\"technology\":\"" in extractedData
            set tempString to text (startPos + 14) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set technology to text 1 thru (endPos - 1) of tempString
            end if
        end if
        
        -- Očištění textů
        set projectNumber to my cleanText(projectNumber)
        set technology to my cleanText(technology)
        
        -- Zpracování názvu klienta - očištění a zkrácení
        set maxClientLength to 25
        set clientName to my cleanClientName(clientName, maxClientLength)
        
        -- Zobrazení extrahovaných dat a zpracování
        if projectNumber is not "" and clientName is not "" and technology is not "" then
            activate  -- Přenese focus na AppleScript dialog
            display dialog "Extrahovaná data ze Safari:" & return & return & "Číslo: " & projectNumber & return & "Klient: " & clientName & return & "Technologie: " & technology & return & return & "Hlavička zkopírována do schránky!" buttons {"OK"} default button "OK"
            
            -- Automatické vytvoření a kopírování Bridge hlavičky
            set bridgeHeader to my createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
            set the clipboard to bridgeHeader
        else
            activate  -- Přenese focus na AppleScript dialog
            display dialog "Nepodařilo se extrahovat všechna data:" & return & return & "Číslo: '" & projectNumber & "'" & return & "Klient: '" & clientName & "'" & return & "Technologie: '" & technology & "'" buttons {"OK"} default button "OK"
        end if
        
    on error errorMessage
        activate  -- Přenese focus na AppleScript dialog
        display dialog "Chyba při čtení dat ze Safari:" & return & errorMessage buttons {"OK"} default button "OK"
    end try
end tell