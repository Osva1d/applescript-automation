-- ===========================================================================
-- Script:      Create Project Folders
-- Version:     1.4.0
-- Author:      Osva1d
-- Updated:     2026-04-11
-- Description: Creates project folder structure from Safari order page data.
--              Captures full-page screenshot of the order sheet into "pracovni".
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

property PROJECT_BASE_PATH : "/Volumes/PrintServer/Projects/Print Production"
property SUBFOLDER_NAMES : {"pracovni", "zdroje"}
property DANGEROUS_CHARS : {"/", "\\", ":", "*", "?", "<", ">", "|"}
property TILE_DIR : "/tmp/safari_tiles"
property SCROLL_DELAY : 0.5
property CAPTURE_DELAY : 0.3
property STITCH_CACHE : "/tmp/safari_stitch"


-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Ensure stitch binary exists (compiles from inline source on first run, cached in /tmp).
-- Recompiles only after reboot (when /tmp is cleared).
on ensureStitchBinary()
	try
		do shell script "test -x " & quoted form of STITCH_CACHE
		return STITCH_CACHE
	on error
		-- Compile inline Swift source
		set swiftSrc to "#!/usr/bin/swift
import AppKit
guard CommandLine.arguments.count >= 6 else { fputs(\"Usage: stitch <out> <totalH> <tileH> <cropTop> <tiles...>\\n\", stderr); exit(1) }
let outputPath = CommandLine.arguments[1]
let totalH = Double(CommandLine.arguments[2])!
let tileH = Double(CommandLine.arguments[3])!
let cropTopPx = Int(CommandLine.arguments[4])!
let tilePaths = Array(CommandLine.arguments.dropFirst(5))
var croppedImages: [CGImage] = []
var contentWidth = 0; var contentHeight = 0
for (i, path) in tilePaths.enumerated() {
    guard let dp = CGDataProvider(filename: path), let cgImg = CGImage(pngDataProviderSource: dp, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { fputs(\"ERROR: \\(path)\\n\", stderr); exit(1) }
    let cr = CGRect(x: 0, y: cropTopPx, width: cgImg.width, height: cgImg.height - cropTopPx)
    guard let cropped = cgImg.cropping(to: cr) else { exit(1) }
    croppedImages.append(cropped); contentWidth = max(contentWidth, cropped.width); contentHeight = cropped.height
}
if croppedImages.count == 1 {
    let url = URL(fileURLWithPath: outputPath) as CFURL
    guard let d = CGImageDestinationCreateWithURL(url, \"public.png\" as CFString, 1, nil) else { exit(1) }
    CGImageDestinationAddImage(d, croppedImages[0], nil); CGImageDestinationFinalize(d); print(outputPath); exit(0)
}
let scale = Double(contentHeight) / tileH; let canvasW = contentWidth; let canvasH = Int((totalH * scale).rounded())
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: canvasW, height: canvasH, bitsPerComponent: 8, bytesPerRow: canvasW * 4, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }
var yOff = canvasH
for (i, tile) in croppedImages.enumerated() {
    var drawH = tile.height
    if i == croppedImages.count - 1 && croppedImages.count > 1 {
        let covered = i * contentHeight; let overlap = tile.height - (canvasH - covered)
        if overlap > 0 { let cr2 = CGRect(x: 0, y: overlap, width: tile.width, height: tile.height - overlap); if let t = tile.cropping(to: cr2) { drawH = t.height; yOff -= drawH; ctx.draw(t, in: CGRect(x: 0, y: yOff, width: t.width, height: drawH)); continue } }
    }
    yOff -= drawH; ctx.draw(tile, in: CGRect(x: 0, y: yOff, width: tile.width, height: drawH))
}
guard let img = ctx.makeImage() else { exit(1) }
let url = URL(fileURLWithPath: outputPath) as CFURL
guard let d = CGImageDestinationCreateWithURL(url, \"public.png\" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(d, img, nil); CGImageDestinationFinalize(d); print(outputPath)
"
		set srcPath to "/tmp/safari_stitch.swift"
		do shell script "cat > " & quoted form of srcPath & " << 'SWIFTEOF'
" & swiftSrc & "
SWIFTEOF
swiftc -O -o " & quoted form of STITCH_CACHE & " " & quoted form of srcPath & " && rm " & quoted form of srcPath
		return STITCH_CACHE
	end try
end ensureStitchBinary

on checkVolumeAvailable(basePath)
	try
		POSIX file basePath as alias
		return true
	on error
		return false
	end try
end checkVolumeAvailable

on cleanText(inputText)
	set cleanedText to inputText
	try
		repeat while cleanedText starts with " " or cleanedText starts with tab or cleanedText starts with return
			if length of cleanedText > 1 then
				set cleanedText to text 2 thru -1 of cleanedText
			else
				set cleanedText to ""
				exit repeat
			end if
		end repeat
		repeat while cleanedText ends with " " or cleanedText ends with tab or cleanedText ends with return
			if length of cleanedText > 1 then
				set cleanedText to text 1 thru -2 of cleanedText
			else
				set cleanedText to ""
				exit repeat
			end if
		end repeat
		set AppleScript's text item delimiters to " "
		set nonEmptyParts to {}
		repeat with part in (text items of cleanedText)
			if part as string is not "" then
				set end of nonEmptyParts to (part as string)
			end if
		end repeat
		set cleanedText to nonEmptyParts as string
		set AppleScript's text item delimiters to ""
		set replacementChar to "_"
		repeat with dangerousChar in DANGEROUS_CHARS
			set AppleScript's text item delimiters to dangerousChar
			set textParts to text items of cleanedText
			set AppleScript's text item delimiters to replacementChar
			set cleanedText to textParts as string
		end repeat
		set AppleScript's text item delimiters to ""
		repeat while cleanedText contains "__"
			set AppleScript's text item delimiters to "__"
			set textParts to text items of cleanedText
			set AppleScript's text item delimiters to "_"
			set cleanedText to textParts as string
		end repeat
		set AppleScript's text item delimiters to ""
		repeat while cleanedText starts with "."
			if length of cleanedText > 1 then
				set cleanedText to text 2 thru -1 of cleanedText
			else
				set cleanedText to ""
				exit repeat
			end if
		end repeat
	on error errMsg
		set AppleScript's text item delimiters to ""
		error errMsg
	end try
	return cleanedText
end cleanText

on getCurrentYearSuffix()
	set currentYear to year of (current date)
	return text -2 thru -1 of (currentYear as string)
end getCurrentYearSuffix


-- ---------------------------------------------------------------------------
-- Safari Data Extraction
-- ---------------------------------------------------------------------------

on extractOrderData()
	tell application "Safari"
		if not (exists front document) then
			return missing value
		end if
		try
			set extractedData to do JavaScript "
                var orderNumber = '';
                var clientName = '';
                var projectName = '';
                var orderSpan = document.querySelector('span.Header1');
                if (orderSpan) {
                    var text = orderSpan.textContent;
                    var match = text.match(/Zakázka\\s*číslo:\\s*([\\d\\.]+)/);
                    if (match) {
                        var rawNum = match[1].replace(/\\./g, '');
                        while (rawNum.length < 4) {
                            rawNum = '0' + rawNum;
                        }
                        orderNumber = rawNum;
                    }
                }
                var allHeaders = document.querySelectorAll('td.TabColHead');
                for (var i = 0; i < allHeaders.length; i++) {
                    var headerText = allHeaders[i].textContent.trim();
                    var nextCell = allHeaders[i].nextElementSibling;
                    if (nextCell && nextCell.classList.contains('TabValue')) {
                        if (headerText === 'Projekt:') {
                            projectName = nextCell.textContent.trim();
                        } else if (headerText === 'Klient:') {
                            clientName = nextCell.textContent.trim();
                        }
                    }
                }
                orderNumber + '\\t' + clientName + '\\t' + projectName;
            " in front document
			return extractedData
		on error errorMessage
			activate
			set dialogResult to display dialog "Chyba při čtení dat ze Safari. Zadejte údaje ručně:" & return & "Formát: číslo - klient - název projektu" default answer "" buttons {"Zrušit", "OK"} default button "OK"
			if button returned of dialogResult is "Zrušit" then
				return missing value
			end if
			return "manual:" & (text returned of dialogResult)
		end try
	end tell
end extractOrderData

on parseOrderData(rawData)
	set orderNumber to ""
	set projectName to ""
	set clientName to ""
	try
		if rawData starts with "manual:" then
			set manualData to text 8 thru -1 of rawData
			set AppleScript's text item delimiters to " - "
			set dataParts to text items of manualData
			set AppleScript's text item delimiters to ""
			if (count of dataParts) ≥ 3 then
				set orderNumber to item 1 of dataParts
				set clientName to item 2 of dataParts
				set projectName to item 3 of dataParts
				repeat with i from 4 to (count of dataParts)
					set projectName to projectName & " - " & item i of dataParts
				end repeat
			else
				activate
				display dialog "Nesprávný formát zadání:" & return & return & "Zadáno: " & manualData & return & return & "Očekávaný formát: číslo - klient - název projektu" & return & "(odděleno " & quote & " - " & quote & ")" buttons {"OK"} default button "OK" with icon caution
			end if
		else
			set AppleScript's text item delimiters to tab
			set dataParts to text items of rawData
			set AppleScript's text item delimiters to ""
			if (count of dataParts) ≥ 3 then
				set orderNumber to item 1 of dataParts
				set clientName to item 2 of dataParts
				set projectName to item 3 of dataParts
			end if
		end if
		set orderNumber to my cleanText(orderNumber)
		set clientName to my cleanText(clientName)
		set projectName to my cleanText(projectName)
	on error
		set orderNumber to ""
		set clientName to ""
		set projectName to ""
	end try
	return {orderNumber:orderNumber, clientName:clientName, projectName:projectName}
end parseOrderData


-- ---------------------------------------------------------------------------
-- Project Creation
-- ---------------------------------------------------------------------------

on createProjectFolders(orderNumber, clientName, projectName)
	set yearSuffix to my getCurrentYearSuffix()
	set projectInfo to orderNumber & " - " & clientName & " - " & projectName
	try
		set folderLocation to PROJECT_BASE_PATH as POSIX file as alias
		set mainFolderPath to (folderLocation as string) & projectInfo & ":"
		tell application "Finder"
			if exists folder mainFolderPath then
				error "Složka \"" & projectInfo & "\" již existuje."
			end if
			make new folder at folderLocation with properties {name:projectInfo}
			repeat with subfolderName in SUBFOLDER_NAMES
				make new folder at folder mainFolderPath with properties {name:subfolderName}
			end repeat
			set finalFolderName to yearSuffix & "_" & orderNumber
			make new folder at folder mainFolderPath with properties {name:finalFolderName}
		end tell
		return true
	on error errorMessage
		activate
		display dialog "Chyba při vytváření složek: " & errorMessage buttons {"OK"} default button "OK" with icon caution
		return false
	end try
end createProjectFolders


-- ---------------------------------------------------------------------------
-- Full-Page Screenshot Capture
-- ---------------------------------------------------------------------------

on extractNum(jsonStr, keyName)
	set searchKey to "\"" & keyName & "\":"
	set AppleScript's text item delimiters to searchKey
	set afterKey to text item 2 of jsonStr
	set AppleScript's text item delimiters to ""
	set numStr to ""
	repeat with ch in characters of afterKey
		set c to ch as string
		if c is in {",", "}", "]", " ", "\"", return, linefeed} then exit repeat
		set numStr to numStr & c
	end repeat
	try
		return numStr as number
	on error
		return 0
	end try
end extractNum

on hideStickyElements()
	tell application "Safari"
		do JavaScript "
			(function() {
				var all = document.querySelectorAll('*');
				for (var i = 0; i < all.length; i++) {
					var pos = window.getComputedStyle(all[i]).position;
					if (pos === 'fixed' || pos === 'sticky') {
						all[i].setAttribute('data-screenshot-display', all[i].style.display);
						all[i].style.display = 'none';
					}
				}
			})();
		" in front document
	end tell
end hideStickyElements

on restoreStickyElements()
	tell application "Safari"
		do JavaScript "
			(function() {
				var all = document.querySelectorAll('[data-screenshot-display]');
				for (var i = 0; i < all.length; i++) {
					all[i].style.display = all[i].getAttribute('data-screenshot-display');
					all[i].removeAttribute('data-screenshot-display');
				}
			})();
		" in front document
	end tell
end restoreStickyElements

on scrollTo(yOffset)
	tell application "Safari"
		do JavaScript ("window.scrollTo(0, " & yOffset & ");") in front document
	end tell
end scrollTo

-- Capture full-page screenshot of the current Safari tab.
-- Saves as JPEG (72 DPI, 1x resolution) to the specified path.
--
-- Parameters:
--   outputPath (string) - POSIX path for output JPEG file
--
-- Returns:
--   (boolean) - true on success, false on error
--
on captureOrderSheet(outputPath)
	try
		do shell script "rm -rf " & quoted form of TILE_DIR & " && mkdir -p " & quoted form of TILE_DIR

		-- Get Safari window ID
		tell application "Safari"
			set winID to id of front window
		end tell

		-- Get page geometry
		tell application "Safari"
			set jsResult to do JavaScript "
				JSON.stringify({
					scrollH:  document.documentElement.scrollHeight,
					viewH:    window.innerHeight,
					outerH:   window.outerHeight,
					dpr:      window.devicePixelRatio
				});
			" in front document
		end tell

		set scrollH to my extractNum(jsResult, "scrollH")
		set viewH to my extractNum(jsResult, "viewH")
		set outerH to my extractNum(jsResult, "outerH")
		set dpr to my extractNum(jsResult, "dpr")
		set toolbarH to outerH - viewH
		set cropTopPx to (toolbarH * dpr) as integer

		-- Tile count
		if scrollH is less than or equal to viewH then
			set tileCount to 1
		else
			set tileCount to (scrollH div viewH)
			if (scrollH mod viewH) > 0 then set tileCount to tileCount + 1
		end if

		-- Save scroll position, hide sticky elements
		tell application "Safari"
			set originalScroll to do JavaScript "window.pageYOffset" in front document
		end tell
		my hideStickyElements()

		-- Bring Safari to front for screencapture
		tell application "Safari" to activate
		delay 0.3

		-- Capture tiles
		set tilePaths to {}
		repeat with i from 0 to (tileCount - 1)
			set scrollOffset to i * viewH
			if i = (tileCount - 1) and tileCount > 1 then
				set scrollOffset to scrollH - viewH
			end if

			my scrollTo(scrollOffset)
			delay SCROLL_DELAY

			set tilePath to TILE_DIR & "/tile_" & (text -4 thru -1 of ("0000" & i)) & ".png"
			do shell script "screencapture -l " & winID & " -x -o " & quoted form of tilePath
			delay CAPTURE_DELAY

			set end of tilePaths to tilePath
		end repeat

		-- Restore page state
		my restoreStickyElements()
		my scrollTo(originalScroll)

		-- Stitch tiles (crop toolbar + combine)
		set pngPath to TILE_DIR & "/stitched.png"
		set stitchBin to my ensureStitchBinary()
		set stitchCmd to quoted form of stitchBin
		set stitchCmd to stitchCmd & " " & quoted form of pngPath
		set stitchCmd to stitchCmd & " " & (scrollH as integer as string)
		set stitchCmd to stitchCmd & " " & (viewH as integer as string)
		set stitchCmd to stitchCmd & " " & (cropTopPx as string)
		repeat with tp in tilePaths
			set stitchCmd to stitchCmd & " " & quoted form of tp
		end repeat
		do shell script stitchCmd

		-- Convert to JPEG 50% (keep Retina 2x for sharp text)
		do shell script "sips -s format jpeg -s formatOptions 50 " & quoted form of pngPath & " --out " & quoted form of outputPath & " && rm " & quoted form of pngPath

		-- Cleanup
		do shell script "rm -rf " & quoted form of TILE_DIR

		return true
	on error errMsg
		try
			my restoreStickyElements()
		end try
		try
			do shell script "rm -rf " & quoted form of TILE_DIR
		end try
		return false
	end try
end captureOrderSheet


-- ---------------------------------------------------------------------------
-- Entry Point
-- ---------------------------------------------------------------------------

on run argv
	if class of argv is not list then set argv to {}

	-- Guard: verify volume is mounted
	if not my checkVolumeAvailable(PROJECT_BASE_PATH) then
		display notification "Disk není připojen." with title "Projektové složky"
		return argv
	end if

	set orderData to my extractOrderData()

	if orderData is missing value then
		display notification "Safari nemá otevřenou stránku zakázky." with title "Projektové složky"
		return argv
	end if

	set parsedData to my parseOrderData(orderData)
	set orderNumber to orderNumber of parsedData
	set clientName to clientName of parsedData
	set projectName to projectName of parsedData

	if orderNumber is "" or clientName is "" or projectName is "" then
		activate
		display dialog "Nepodařilo se extrahovat všechna data:" & return & return & "Zakázka: " & orderNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName buttons {"OK"} default button "OK" with title "Projektové složky" with icon caution
		return argv
	end if

	-- Single preview dialog
	set projectInfo to orderNumber & " - " & clientName & " - " & projectName
	set previewMsg to "Zakázka: " & orderNumber & return & "Klient: " & clientName & return & "Projekt: " & projectName & return & return & "Složka: " & projectInfo

	activate
	set userChoice to button returned of (display dialog previewMsg with title "Projektové složky" buttons {"Zrušit", "Vytvořit"} default button "Vytvořit")
	if userChoice is "Zrušit" then return argv

	-- Create folders
	set folderCreated to my createProjectFolders(orderNumber, clientName, projectName)

	-- Capture order sheet screenshot into "pracovni" subfolder
	if folderCreated then
		set pracovniPath to PROJECT_BASE_PATH & "/" & projectInfo & "/pracovni"
		set screenshotPath to pracovniPath & "/zakazkovy_list.jpg"
		my captureOrderSheet(screenshotPath)
	end if

	return argv
end run
