-- Bridge header generator for print production
-- Generátor Bridge hlaviček pro tiskovou produkci

-- Configuration - Konfigurace
property TOTAL_HEADER_WIDTH : 85  -- Width in Menlo font characters
property MAX_CLIENT_LENGTH : 25   -- Maximum client name length

-- Get list of legal forms to remove - Seznam právních forem k odstranění
on getLegalForms()
    return {", a.s.", ", s.r.o.", ", spol. s r.o.", ", v.o.s.", ", k.s.", ", s.p.", ", z.s.", ", o.p.s.", ", o.s.", ", druzstvo", ", spolek", ", nadace", ", ustav", " a.s.", " s.r.o.", " spol. s r.o.", " v.o.s.", " k.s.", " s.p.", " z.s.", " o.p.s.", " o.s.", " druzstvo", " spolek", " nadace", " ustav", ",a.s.", ",s.r.o.", ",spol. s r.o.", ",v.o.s.", ",k.s.", ",s.p.", ",z.s.", ",o.p.s.", ",o.s.", ",druzstvo", ",spolek", ",nadace", ",ustav", ", a.s", ", s.r.o", ", spol. s r.o", ", v.o.s", ", k.s", ", s.p", ", z.s", ", o.p.s", ", o.s", " a.s", " s.r.o", " spol. s r.o", " v.o.s", " k.s", " s.p", " z.s", " o.p.s", " o.s", ",a.s", ",s.r.o", ",spol. s r.o", ",v.o.s", ",k.s", ",s.p", ",z.s", ",o.p.s", ",o.s", ", a. s.", ", s. r. o.", ", spol. s r. o.", ", v. o. s.", ", k. s.", ", s. p.", ", z. s.", ", o. p. s.", ", o. s.", " a. s.", " s. r. o.", " spol. s r. o.", " v. o. s.", " k. s.", " s. p.", " z. s.", " o. p. s.", " o. s.", ",a. s.", ",s. r. o.", ",spol. s r. o.", ",v. o. s.", ",k. s.", ",s. p.", ",z. s.", ",o. p. s.", ",o. s.", ", a. s", ", s. r. o", ", spol. s r. o", ", v. o. s", ", k. s", ", s. p", ", z. s", ", o. p. s", ", o. s", " a. s", " s. r. o", " spol. s r. o", " v. o. s", " k. s", " s. p", " z. s", " o. p. s", " o. s", ",a. s", ",s. r. o", ",spol. s r. o", ",v. o. s", ",k. s", ",s. p", ",z. s", ",o. p. s", ",o. s", " Ltd.", " Inc.", " LLC", " Corp.", " Company", " Co.", " LLP", " LP", " PC", " PLLC", ", Ltd.", ", Inc.", ", LLC", ", Corp.", ", Company", ", Co.", ", LLP", ", LP", ", PC", ", PLLC", ",Ltd.", ",Inc.", ",LLC", ",Corp.", ",Company", ",Co.", ",LLP", ",LP", ",PC", ",PLLC", " GmbH", " AG", " KG", " OHG", " GbR", " eG", " SE", " KGaA", ", GmbH", ", AG", ", KG", ", OHG", ", GbR", ", eG", ", SE", ", KGaA", ",GmbH", ",AG", ",KG", ",OHG", ",GbR", ",eG", ",SE", ",KGaA", " SA", " SARL", " SAS", " SASU", " SNC", " SCS", " EURL", ", SA", ", SARL", ", SAS", ", SASU", ", SNC", ", SCS", ", EURL", ",SA", ",SARL", ",SAS", ",SASU", ",SNC", ",SCS", ",EURL", " S.p.A.", " S.r.l.", " S.n.c.", " S.a.s.", " S.s.", ", S.p.A.", ", S.r.l.", ", S.n.c.", ", S.a.s.", ", S.s.", ",S.p.A.", ",S.r.l.", ",S.n.c.", ",S.a.s.", ",S.s.", " SpA", " Srl", " Snc", " Sas", " Ss", ", SpA", ", Srl", ", Snc", ", Sas", ", Ss", ",SpA", ",Srl", ",Snc", ",Sas", ",Ss", " S.A.", " S.L.", " S.C.", ", S.A.", ", S.L.", ", S.C.", ",S.A.", ",S.L.", ",S.C.", " B.V.", " N.V.", " V.O.F.", " C.V.", ", B.V.", ", N.V.", ", V.O.F.", ", C.V.", ",B.V.", ",N.V.", ",V.O.F.", ",C.V.", " Sp. z o.o.", " Sp. j.", " Sp. p.", " Sp. k.", ", Sp. z o.o.", ", Sp. j.", ", Sp. p.", ", Sp. k.", ",Sp. z o.o.", ",Sp. j.", ",Sp. p.", ",Sp. k.", " Kft.", " Zrt.", " Bt.", " Kkt.", " Nyrt.", ", Kft.", ", Zrt.", ", Bt.", ", Kkt.", ", Nyrt.", ",Kft.", ",Zrt.", ",Bt.", ",Kkt.", ",Nyrt.", " A/S", " ApS", " I/S", " K/S", " P/S", ", A/S", ", ApS", ", I/S", ", K/S", ", P/S", ",A/S", ",ApS", ",I/S", ",K/S", ",P/S", " AB", " HB", " KB", " BRF", " EF", ", AB", ", HB", ", KB", ", BRF", ", EF", ",AB", ",HB", ",KB", ",BRF", ",EF", " AS", " ASA", " BA", " BL", " DA", " KF", " KS", " SF", " SL", ", AS", ", ASA", ", BA", ", BL", ", DA", ", KF", ", KS", ", SF", ", SL", ",AS", ",ASA", ",BA", ",BL", ",DA", ",KF", ",KS", ",SF", ",SL", " Oy", " Oyj", " Ky", " Ay", ", Oy", ", Oyj", ", Ky", ", Ay", ",Oy", ",Oyj", ",Ky", ",Ay"}
end getLegalForms

-- Clean text from whitespace and punctuation
-- Čištění textu od bílých znaků a interpunkce
on cleanText(inputText)
    set cleanedText to inputText
    
    -- Remove whitespace from beginning - Odstranění bílých znaků ze začátku
    repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
        if length of cleanedText > 1 then
            set cleanedText to text 2 thru -1 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Remove whitespace from end - Odstranění bílých znaků z konce
    repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
        if length of cleanedText > 1 then
            set cleanedText to text 1 thru -2 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Remove punctuation from end - Odstranění interpunkce na konci
    repeat while cleanedText ends with "," or cleanedText ends with "." or cleanedText ends with ";" or cleanedText ends with ":"
        if length of cleanedText > 1 then
            set cleanedText to text 1 thru -2 of cleanedText
        else
            set cleanedText to ""
            exit repeat
        end if
    end repeat
    
    -- Remove whitespace again after punctuation removal
    -- Znovu odstranění bílých znaků po odstranění interpunkce
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

-- Clean and shorten client name - Očištění a zkrácení názvu klienta
on processClientName(clientName, maxLength)
    set cleanedName to my cleanText(clientName)
    
    -- Remove legal forms - Odstranění právních forem
    set legalForms to my getLegalForms()
    repeat with legalForm in legalForms
        if cleanedName ends with legalForm then
            set cleanedName to text 1 thru ((length of cleanedName) - (length of legalForm)) of cleanedName
            exit repeat
        end if
    end repeat
    
    -- Clean again after legal form removal - Další čištění po odstranění právní formy
    set cleanedName to my cleanText(cleanedName)
    
    -- Shorten if too long - Zkrácení pokud je příliš dlouhé
    if length of cleanedName > maxLength then
        set cleanedName to text 1 thru maxLength of cleanedName
        -- Trim to last complete word - Oříznutí na posledním celém slově
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
end processClientName

-- Create centered Bridge header with validation - Vytvoření centrované Bridge hlavičky s validací
on createBridgeHeader(clientName, technology, orderNumber, yearSuffix)
    set rightText to yearSuffix & "_" & orderNumber
    
    -- Calculate total content length - Výpočet celkové délky obsahu
    set leftLength to length of clientName
    set centerLength to length of technology
    set rightLength to length of rightText
    set minSpacing to 2  -- Minimum spaces between elements
    set totalContentLength to leftLength + centerLength + rightLength + (minSpacing * 2)
    
    -- Validate total length - Validace celkové délky
    if totalContentLength > TOTAL_HEADER_WIDTH then
        -- Header too long, try to shorten client name - Header moc dlouhý, zkusit zkrátit jméno klienta
        set maxClientForFit to TOTAL_HEADER_WIDTH - centerLength - rightLength - (minSpacing * 2)
        if maxClientForFit < 5 then
            -- Cannot fit, return error indicator - Nevejde se, vrátit chybový indikátor
            return "ERROR: Header příliš dlouhý pro " & TOTAL_HEADER_WIDTH & " znaků"
        end if
        
        -- Shorten client name to fit - Zkrácení jména klienta, aby se vešlo
        set clientName to my processClientName(clientName, maxClientForFit)
        set leftLength to length of clientName
    end if
    
    -- Calculate positions for centering - Výpočet pozic pro centrování
    set centerPosition to (TOTAL_HEADER_WIDTH - centerLength) / 2
    set leftSpaces to centerPosition - leftLength
    set rightSpaces to TOTAL_HEADER_WIDTH - leftLength - leftSpaces - centerLength - rightLength
    
    -- Ensure minimum spacing - Zajištění minimálních mezer
    if leftSpaces < minSpacing then set leftSpaces to minSpacing
    if rightSpaces < minSpacing then set rightSpaces to minSpacing
    
    -- Create spacing - Vytvoření mezer
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

-- Get current year last two digits - Získání posledních dvou číslic roku
on getCurrentYearSuffix()
    set currentYear to year of (current date)
    return text -2 thru -1 of (currentYear as string)
end getCurrentYearSuffix

-- Extract data from Safari order page - Extrakce dat ze Safari zakázkového listu
on extractOrderData()
    tell application "Safari"
        if not (exists front document) then
            activate
            display dialog "Nejdříve otevřete zakázkový list v Safari!" buttons {"OK"} default button "OK"
            return missing value
        end if
        
        try
            -- Extract data using JavaScript - Extrakce dat pomocí JavaScript
            set extractedData to do JavaScript "
                var result = {};
                
                // Extract order number - Extrakce čísla zakázky
                var orderSpan = document.querySelector('span.Header1');
                if (orderSpan) {
                    var text = orderSpan.textContent;
                    var match = text.match(/Zakázka číslo:\\s*(\\d+\\.\\d+)/);
                    if (match) {
                        result.orderNumber = match[1].replace('.', '');
                    }
                }
                
                // Extract client, technology - Extrakce klienta a technologie
                var allHeaders = document.querySelectorAll('td.TabColHead');
                for (var i = 0; i < allHeaders.length; i++) {
                    var headerText = allHeaders[i].textContent.trim();
                    var nextCell = allHeaders[i].nextElementSibling;
                    
                    if (nextCell && nextCell.classList.contains('TabValue')) {
                        if (headerText === 'Klient:') {
                            result.clientName = nextCell.textContent.trim();
                        } else if (headerText === 'Technologie:') {
                            result.technology = nextCell.textContent.trim();
                        }
                    }
                }
                
                JSON.stringify(result);
            " in front document
            
            return extractedData
            
        on error errorMessage
            activate
            display dialog "Chyba při čtení dat ze Safari:" & return & errorMessage buttons {"OK"} default button "OK"
            return missing value
        end try
    end tell
end extractOrderData

-- Safely extract value from JSON-like string - Bezpečná extrakce hodnoty z JSON řetězce  
on extractJSONValue(jsonData, fieldName)
    try
        set searchPattern to "\"" & fieldName & "\":\""
        if jsonData contains searchPattern then
            set startPos to offset of searchPattern in jsonData
            set tempString to text (startPos + (length of searchPattern)) thru -1 of jsonData
            set endPos to offset of "\"" in tempString
            if endPos > 0 then
                return text 1 thru (endPos - 1) of tempString
            end if
        end if
    on error
        return ""
    end try
    return ""
end extractJSONValue

-- Parse order data safely - Bezpečné parsování dat objednávky
on parseOrderData(jsonData)
    set orderNumber to ""
    set clientName to ""
    set technology to ""
    
    try
        -- Parse JSON fields safely - Bezpečné parsování JSON polí
        set orderNumber to my extractJSONValue(jsonData, "orderNumber")
        set clientName to my extractJSONValue(jsonData, "clientName") 
        set technology to my extractJSONValue(jsonData, "technology")
        
        -- Clean all texts - Očištění všech textů
        set orderNumber to my cleanText(orderNumber)
        set technology to my cleanText(technology)
        
        -- Process client name - Zpracování názvu klienta
        set clientName to my processClientName(clientName, MAX_CLIENT_LENGTH)
        
    on error errorMessage
        -- Return empty values on parsing error - Vrácení prázdných hodnot při chybě
        set orderNumber to ""
        set clientName to ""
        set technology to ""
    end try
    
    return {orderNumber:orderNumber, clientName:clientName, technology:technology}
end parseOrderData

-- Main execution - Hlavní spuštění
set orderData to my extractOrderData()

if orderData is not missing value then
    set parsedData to my parseOrderData(orderData)
    set orderNumber to orderNumber of parsedData
    set clientName to clientName of parsedData
    set technology to technology of parsedData
    
    -- Validate extracted data - Validace extrahovaných dat
    if orderNumber is not "" and clientName is not "" and technology is not "" then
        -- Generate and copy header - Generování a kopírování hlavičky
        set yearSuffix to my getCurrentYearSuffix()
        set bridgeHeader to my createBridgeHeader(clientName, technology, orderNumber, yearSuffix)
        set the clipboard to bridgeHeader
        
        -- Show success dialog - Zobrazení potvrzovacího dialogu
        activate
        display dialog "Extrahovaná data ze Safari:" & return & return & "Číslo: " & orderNumber & return & "Klient: " & clientName & return & "Technologie: " & technology & return & return & "Hlavička zkopírována do schránky!" buttons {"OK"} default button "OK"
    else
        activate
        display dialog "Nepodařilo se extrahovat všechna data:" & return & return & "Číslo: '" & orderNumber & "'" & return & "Klient: '" & clientName & "'" & return & "Technologie: '" & technology & "'" buttons {"OK"} default button "OK"
    end if
else
    activate
    display dialog "Nebyla získána žádná data. Skript bude ukončen." buttons {"OK"} default button "OK"
end if