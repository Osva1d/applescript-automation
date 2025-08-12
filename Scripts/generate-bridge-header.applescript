-- Test skriptu pro vytvoření centrované hlavičky Bridge
-- Funkce pro vytvoření centrované hlavičky
on createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
    set totalWidth to 133
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

-- Testovací data
set testClient to "CrossCafe original"
set testTechnology to "ARIZONA"
set testProjectNumber to "7511"
set testLastTwoDigits to "25"

-- Vytvoření hlavičky
set bridgeHeader to my createBridgeHeader(testClient, testTechnology, testProjectNumber, testLastTwoDigits)

-- Zobrazení výsledku
display dialog "Testovací hlavička:" & return & return & bridgeHeader & return & return & "Délka: " & (length of bridgeHeader) & " znaků" & return & return & "Zkopírovat do schránky?" buttons {"Ne", "Ano"} default button "Ano"

if button returned of result is "Ano" then
    set the clipboard to bridgeHeader
    display dialog "Hlavička byla zkopírována do schránky!" & return & return & "Můžete ji vložit do Adobe Bridge pomocí Cmd+V" buttons {"OK"} default button "OK"
end if

-- Debug informace
set debugInfo to "=== DEBUG INFO ===" & return
set debugInfo to debugInfo & "Klient: '" & testClient & "' (" & (length of testClient) & " znaků)" & return
set debugInfo to debugInfo & "Technologie: '" & testTechnology & "' (" & (length of testTechnology) & " znaků)" & return
set debugInfo to debugInfo & "Číslo: '" & testLastTwoDigits & "_" & testProjectNumber & "' (" & (length of (testLastTwoDigits & "_" & testProjectNumber)) & " znaků)" & return
set debugInfo to debugInfo & "Celková délka: " & (length of bridgeHeader) & " znaků" & return
set debugInfo to debugInfo & "Cílová délka: 133 znaků"

display dialog debugInfo buttons {"OK"} default button "OK"