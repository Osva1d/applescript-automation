-- Kompletn√≠ skript: Safari ‚Üí Bridge hlaviƒçka
-- Funkce pro oƒçi≈°tƒõn√≠ textu
on cleanText(inputText)
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
    
    -- Odstranƒõn√≠ interpunkce na konci (ƒç√°rky, teƒçky, st≈ôedn√≠ky)
    repeat while cleanedText ends with "," or cleanedText ends with "." or cleanedText ends with ";" or cleanedText ends with ":"
        if length of cleanedText > 1 then
            set cleanedText to text 1 thru -2 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Odstranƒõn√≠ b√≠l√Ωch znak≈Ø z konce (znovu, po odstranƒõn√≠ interpunkce)
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

-- Funkce pro zkr√°cen√≠ a oƒçi≈°tƒõn√≠ n√°zvu klienta
on cleanClientName(clientName, maxLength)
    set cleanedName to my cleanText(clientName)
    
    -- Seznam pr√°vn√≠ch forem k odstranƒõn√≠ (nyn√≠ s v√≠ce variantami)
    set legalForms to {", a.s.", ", s.r.o.", ", spol. s r.o.", ", v.o.s.", ", k.s.", ", s.p.", ", z.s.", " a.s.", " s.r.o.", " spol. s r.o.", " v.o.s.", " k.s.", " s.p.", " z.s.", " a. s.", " s. r. o.", " spol. s r. o.", " v. o. s.", " k. s.", " s. p.", " z. s.", " Ltd.", " Inc.", " LLC", " GmbH", " AG", " SE", " SAS", " SARL", ",a.s.", ",s.r.o.", ",spol. s r.o.", ",v.o.s.", ",k.s.", ",s.p.", ",z.s.", ",a. s.", ",s. r. o.", ",spol. s r. o.", ",v. o. s.", ",k. s.", ",s. p.", ",z. s.", ", a.s", ", s.r.o", ", spol. s r.o", ", v.o.s", ", k.s", ", s.p", ", z.s", " a.s", " s.r.o", " spol. s r.o", " v.o.s", " k.s", " s.p", " z.s", " a. s", " s. r. o", " spol. s r. o", " v. o. s", " k. s", " s. p", " z. s", ",a.s", ",s.r.o", ",spol. s r.o", ",v.o.s", ",k.s", ",s.p", ",z.s", ",a. s", ",s. r. o", ",spol. s r. o", ",v. o. s", ",k. s", ",s. p", ",z. s"}
    
    -- Odstranƒõn√≠ pr√°vn√≠ch forem
    repeat with legalForm in legalForms
        if cleanedName ends with legalForm then
            set cleanedName to text 1 thru ((length of cleanedName) - (length of legalForm)) of cleanedName
            exit repeat
        end if
    end repeat
    
    -- Dal≈°√≠ ƒçi≈°tƒõn√≠ na konci
    set cleanedName to my cleanText(cleanedName)
    
    -- Zkr√°cen√≠, pokud je p≈ô√≠li≈° dlouh√©
    if length of cleanedName > maxLength then
        set cleanedName to text 1 thru maxLength of cleanedName
        -- O≈ô√≠znut√≠ na posledn√≠m cel√©m slovƒõ
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

-- Funkce pro vytvo≈ôen√≠ centrovan√© hlaviƒçky Bridge
on createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
    set totalWidth to 85  -- Menlo font ≈°√≠≈ôka
    set rightText to lastTwoDigits & "_" & projectNumber
    
    -- V√Ωpoƒçet pozic
    set leftLength to length of clientName
    set centerLength to length of technology
    set rightLength to length of rightText
    
    -- Pozice pro centrov√°n√≠ technologie
    set centerPosition to (totalWidth - centerLength) / 2
    set leftSpaces to centerPosition - leftLength
    set rightSpaces to totalWidth - leftLength - leftSpaces - centerLength - rightLength
    
    -- Zajist√≠me, ≈æe poƒçet mezer nen√≠ z√°porn√Ω
    if leftSpaces < 1 then set leftSpaces to 1
    if rightSpaces < 1 then set rightSpaces to 1
    
    -- Vytvo≈ôen√≠ mezer
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

-- Z√≠sk√°n√≠ aktu√°ln√≠ho roku
set currentYear to year of (current date)
set lastTwoDigits to text -2 thru -1 of (currentYear as string)

-- Extrakce dat ze Safari
tell application "Safari"
    if not (exists front document) then
        activate  -- P≈ôenese focus na AppleScript dialog
        display dialog "Nejd≈ô√≠ve otev≈ôete zak√°zkov√Ω list v Safari!" buttons {"OK"} default button "OK"
        return
    end if
    
    try
        -- Extrakce dat pomoc√≠ JavaScript a CSS selektor≈Ø
        set extractedData to do JavaScript "
            var result = {};
            
            // Extrakce ƒç√≠sla zak√°zky
            var zakazkaSpan = document.querySelector('span.Header1');
            if (zakazkaSpan) {
                var text = zakazkaSpan.textContent;
                var match = text.match(/Zak√°zka ƒç√≠slo:\\s*(\\d+\\.\\d+)/);
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
        
        -- Parsov√°n√≠ JSON dat
        set projectNumber to ""
        set clientName to ""
        set technology to ""
        
        -- Extrakce ƒç√≠sla projektu
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
        
        -- Oƒçi≈°tƒõn√≠ text≈Ø
        set projectNumber to my cleanText(projectNumber)
        set technology to my cleanText(technology)
        
        -- Zpracov√°n√≠ n√°zvu klienta - oƒçi≈°tƒõn√≠ a zkr√°cen√≠
        set maxClientLength to 25
        set clientName to my cleanClientName(clientName, maxClientLength)
        
        -- Zobrazen√≠ extrahovan√Ωch dat a zpracov√°n√≠
        if projectNumber is not "" and clientName is not "" and technology is not "" then
            activate  -- P≈ôenese focus na AppleScript dialog
            display dialog "Extrahovan√° data ze Safari:" & return & return & "ƒå√≠slo: " & projectNumber & return & "Klient: " & clientName & return & "Technologie: " & technology & return & return & "Hlaviƒçka zkop√≠rov√°na do schr√°nky!" buttons {"OK"} default button "OK"
            
            -- Automatick√© vytvo≈ôen√≠ a kop√≠rov√°n√≠ Bridge hlaviƒçky
            set bridgeHeader to my createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
            set the clipboard to bridgeHeader
        else
            activate  -- P≈ôenese focus na AppleScript dialog
            display dialog "Nepoda≈ôilo se extrahovat v≈°echna data:" & return & return & "ƒå√≠slo: '" & projectNumber & "'" & return & "Klient: '" & clientName & "'" & return & "Technologie: '" & technology & "'" buttons {"OK"} default button "OK"
        end if
        
    on error errorMessage
        activate  -- P≈ôenese focus na AppleScript dialog
        display dialog "Chyba p≈ôi ƒçten√≠ dat ze Safari:" & return & errorMessage buttons {"OK"} default button "OK"
    end try
end tell