-- Automatizace zalo?en� projektov?ch slo?ek
-- Autor: AppleScript pro zak�zkov? syst�m
-- Verze: 1.0

-- Z�sk�n� aktu�ln�ho roku a posledn�ch dvoj?�sl�
set currentYear to year of (current date)
set currentYearStr to currentYear as string
set lastTwoDigits to text -2 thru -1 of currentYearStr

-- Dialogov� okno pro zad�n� �daj? projektu
display dialog "Zadejte �daje projektu:" & return & return & "Form�t: ?�slo projektu - klient - n�zev projektu" default answer "" with title "Nov? projekt"
set projectInfo to text returned of result

-- Kontrola, zda bylo n?co zad�no
if projectInfo is "" then
    display dialog "Nebyla zad�na ?�dn� data. Skript bude ukon?en." buttons {"OK"} default button "OK"
    return
end if

-- Extrakce ?�sla projektu (prvn� ?�st p?ed prvn� poml?kou)
set AppleScript's text item delimiters to " - "
set projectParts to text items of projectInfo
set AppleScript's text item delimiters to ""

if (count of projectParts) < 3 then
    display dialog "Chybn? form�t! Pou?ijte: ?�slo projektu - klient - n�zev projektu" buttons {"OK"} default button "OK"
    return
end if

set projectNumber to item 1 of projectParts

-- V?b?r um�st?n� pro hlavn� slo?ku projektu
set folderLocation to choose folder with prompt "Vyberte um�st?n� pro slo?ku projektu:"

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