-- Kompletn� skript: Safari ? Bridge hlavi?ka
-- Funkce pro o?i?t?n� textu
on cleanText(inputText)
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
    
    return cleanedText
end cleanText

-- Funkce pro vytvo?en� centrovan� hlavi?ky Bridge
on createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
    set totalWidth to 79  -- Courier font ?�?ka
    set rightText to lastTwoDigits & "_" & projectNumber
    
    -- V?po?et pozic
    set leftLength to length of clientName
    set centerLength to length of technology
    set rightLength to length of rightText
    
    -- Pozice pro centrov�n� technologie
    set centerPosition to (totalWidth - centerLength) / 2
    set leftSpaces to centerPosition - leftLength
    set rightSpaces to totalWidth - leftLength - leftSpaces - centerLength - rightLength
    
    -- Zajist�me, ?e po?et mezer nen� z�porn?
    if leftSpaces < 1 then set leftSpaces to 1
    if rightSpaces < 1 then set rightSpaces to 1
    
    -- Vytvo?en� mezer
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

-- Z�sk�n� aktu�ln�ho roku
set currentYear to year of (current date)
set lastTwoDigits to text -2 thru -1 of (currentYear as string)

-- Extrakce dat ze Safari
tell application "Safari"
    if not (exists front document) then
        display dialog "Nejd?�ve otev?ete zak�zkov? list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomoc� JavaScript a CSS selektor?
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce ?�sla zak�zky
            var zakazkaSpan = document.querySelector('span.Header1');
            if (zakazkaSpan) {
                var text = zakazkaSpan.textContent;
                var match = text.match(/Zak�zka ?�slo:\\s*(\\d+\\.\\d+)/);
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
                    if (headText === 'Projekt:') {
                        result.projectName = nextTd.textContent.trim();
                    } else if (headText === 'Klient:') {
                        result.clientName = nextTd.textContent.trim();
                    } else if (headText === 'Technologie:') {
                        result.technology = nextTd.textContent.trim();
                    }
                }
            }
            
            JSON.stringify(result);
        " in front document
        
        -- Parsov�n� JSON dat
        set projectNumber to ""
        set projectName to ""
        set clientName to ""
        set technology to ""
        
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
        
        -- Extrakce technologie
        if extractedData contains "\"technology\":\"" then
            set startPos to offset of "\"technology\":\"" in extractedData
            set tempString to text (startPos + 14) thru -1 of extractedData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                set technology to text 1 thru (endPos - 1) of tempString
            end if
        end if
        
        -- O?i?t?n� text?
        set projectNumber to my cleanText(projectNumber)
        set clientName to my cleanText(clientName)
        set projectName to my cleanText(projectName)
        set technology to my cleanText(technology)
        
        -- Zobrazen� extrahovan?ch dat
        if projectNumber is not "" and clientName is not "" and technology is not "" then
            display dialog "Extrahovan� data ze Safari:" & return & return & "?�slo: " & projectNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & "Technologie: " & technology & return & return & "Vytvo?it Bridge hlavi?ku?" buttons {"Zru?it", "Ano"} default button "Ano"
            
            if button returned of result is "Ano" then
                -- Vytvo?en� Bridge hlavi?ky
                set bridgeHeader to my createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
                
                -- Zobrazen� v?sledku
                display dialog "Bridge hlavi?ka:" & return & return & bridgeHeader & return & return & "D�lka: " & (length of bridgeHeader) & " znak? (c�l: 79)" & return & return & "Zkop�rovat do schr�nky?" buttons {"Ne", "Ano"} default button "Ano"
                
                if button returned of result is "Ano" then
                    set the clipboard to bridgeHeader
                    display dialog "Hlavi?ka byla zkop�rov�na do schr�nky!" & return & return & "Vlo?te ji do Adobe Bridge pomoc� Cmd+V" & return & return & "D?LE?IT�: Ujist?te se, ?e m�te nastaven? font Courier!" buttons {"OK"} default button "OK"
                end if
            end if
        else
            display dialog "Nepoda?ilo se extrahovat v?echna data:" & return & return & "?�slo: '" & projectNumber & "'" & return & "Klient: '" & clientName & "'" & return & "Technologie: '" & technology & "'" buttons {"OK"} default button "OK"
        end if
        
    on error errorMessage
        display dialog "Chyba p?i ?ten� dat ze Safari:" & return & errorMessage buttons {"OK"} default button "OK"
    end try
end tell