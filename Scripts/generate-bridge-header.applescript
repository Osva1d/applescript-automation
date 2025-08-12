-- Test skriptu pro vytvoření centrované hlavičky Bridge
-- Funkce pro vytvoření centrované hlavičky
on createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)
    set totalWidth to 50  -- Opravená šířka podle mono fontu
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

-- Dialogové okno pro zadání živých dat
display dialog "Zadejte název klienta:" default answer "" with title "Bridge Header Generator"
set clientName to text returned of result

display dialog "Zadejte technologii:" default answer "" with title "Bridge Header Generator"
set technology to text returned of result

display dialog "Zadejte číslo projektu:" default answer "" with title "Bridge Header Generator"
set projectNumber to text returned of result

display dialog "Zadejte rok (2 číslice):" default answer "25" with title "Bridge Header Generator"
set lastTwoDigits to text returned of result

-- Vytvoření hlavičky s živými daty
set bridgeHeader to my createBridgeHeader(clientName, technology, projectNumber, lastTwoDigits)

-- Zobrazení výsledku
display dialog "Vygenerovaná hlavička:" & return & return & bridgeHeader & return & return & "Délka: " & (length of bridgeHeader) & " znaků (cíl: 50)" & return & return & "Zkopírovat do schránky?" buttons {"Ne", "Ano"} default button "Ano"

if button returned of result is "Ano" then
    set the clipboard to bridgeHeader
    display dialog "Hlavička byla zkopírována do schránky!" & return & return & "Můžete ji vložit do Adobe Bridge pomocí Cmd+V" buttons {"OK"} default button "OK"
end if

-- Debug informace
set debugInfo to "=== DEBUG INFO ===" & return
set debugInfo to debugInfo & "Klient: '" & clientName & "' (" & (length of clientName) & " znaků)" & return
set debugInfo to debugInfo & "Technologie: '" & technology & "' (" & (length of technology) & " znaků)" & return
set debugInfo to debugInfo & "Číslo: '" & lastTwoDigits & "_" & projectNumber & "' (" & (length of (lastTwoDigits & "_" & projectNumber)) & " znaků)" & return
set debugInfo to debugInfo & "Celková délka: " & (length of bridgeHeader) & " znaků" & return
set debugInfo to debugInfo & "Cílová délka: 50 znaků"

display dialog debugInfo buttons {"OK"} default button "OK"