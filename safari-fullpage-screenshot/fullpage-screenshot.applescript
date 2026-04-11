-- ===========================================================================
-- Script:      Full-Page Safari Screenshot (standalone test)
-- Version:     0.4.0
-- Author:      Osva1d
-- Updated:     2026-04-11
-- Description: Captures full-page screenshot of the active Safari tab.
--              Mono script — compiles stitch binary on first run, caches in /tmp.
--              Zero external dependencies.
-- Usage:       Open any page in Safari, then run this script.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

property TILE_DIR : "/tmp/safari_tiles"
property STITCH_CACHE : "/tmp/safari_stitch"
property SCROLL_DELAY : 0.5
property CAPTURE_DELAY : 0.3


-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Ensure stitch binary exists (compiles from inline source on first run).
-- Cached in /tmp — recompiles only after reboot.
on ensureStitchBinary()
	try
		do shell script "test -x " & quoted form of STITCH_CACHE
		return STITCH_CACHE
	on error
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

on extractStr(jsonStr, keyName)
	set searchKey to "\"" & keyName & "\":\""
	set AppleScript's text item delimiters to searchKey
	if (count of text items of jsonStr) < 2 then
		set AppleScript's text item delimiters to ""
		return ""
	end if
	set afterKey to text item 2 of jsonStr
	set AppleScript's text item delimiters to "\""
	set strVal to text item 1 of afterKey
	set AppleScript's text item delimiters to ""
	return strVal
end extractStr

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

on sanitizeFilename(inputText)
	set badChars to {"/", "\\", ":", "*", "?", "<", ">", "|", "\""}
	set cleanedText to inputText
	repeat with ch in badChars
		set AppleScript's text item delimiters to ch
		set parts to text items of cleanedText
		set AppleScript's text item delimiters to "_"
		set cleanedText to parts as string
	end repeat
	set AppleScript's text item delimiters to ""
	if length of cleanedText > 60 then
		set cleanedText to text 1 thru 60 of cleanedText
	end if
	return cleanedText
end sanitizeFilename


-- ---------------------------------------------------------------------------
-- Main capture routine
-- ---------------------------------------------------------------------------

on captureFullPage(outputFolder)
	set stitchBin to my ensureStitchBinary()

	-- Clean tile directory
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
				dpr:      window.devicePixelRatio,
				pageTitle: document.title
			});
		" in front document
	end tell

	set scrollH to my extractNum(jsResult, "scrollH")
	set viewH to my extractNum(jsResult, "viewH")
	set outerH to my extractNum(jsResult, "outerH")
	set dpr to my extractNum(jsResult, "dpr")
	set pageTitle to my extractStr(jsResult, "pageTitle")
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

	-- Capture raw window tiles
	set tilePaths to {}
	try
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
	on error errMsg
		my restoreStickyElements()
		my scrollTo(originalScroll)
		error "Tile capture failed: " & errMsg
	end try

	-- Restore page state
	my restoreStickyElements()
	my scrollTo(originalScroll)

	-- Output filename
	set safeName to my sanitizeFilename(pageTitle)
	if safeName is "" then set safeName to "screenshot"
	set outputPath to outputFolder & "/" & safeName & ".jpg"
	set pngPath to outputFolder & "/" & safeName & ".png"

	-- Stitch tiles
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

	-- Cleanup tiles
	do shell script "rm -rf " & quoted form of TILE_DIR

	return outputPath
end captureFullPage


-- ---------------------------------------------------------------------------
-- Entry Point
-- ---------------------------------------------------------------------------

on run argv
	if class of argv is not list then set argv to {}

	tell application "Safari"
		if not (exists front document) then
			display dialog "Safari nema otevreny zadny dokument." buttons {"OK"} default button "OK" with icon caution
			return
		end if
	end tell

	set outputFolder to POSIX path of (path to desktop folder)
	if outputFolder ends with "/" then
		set outputFolder to text 1 thru -2 of outputFolder
	end if

	tell application "Safari" to activate
	delay 0.5

	set resultPath to my captureFullPage(outputFolder)

	display dialog "Screenshot ulozen:" & return & return & resultPath buttons {"OK"} default button "OK" with title "Full-Page Screenshot"
end run
