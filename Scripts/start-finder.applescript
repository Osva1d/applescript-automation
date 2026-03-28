-- ===========================================================================
-- Script:      Start Finder
-- Version:     14.4.1
-- Author:      Osva1d
-- Updated:     2026-03-26
-- Description: Login Finder setup - network volumes and tab panels for print production.
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

-- Network server for availability check
property CHECK_SERVER : "fileserver.local"

-- Connection timeout (seconds)
property NETWORK_TIMEOUT : 60

-- Delay between tab creation (increase on slower machines)
property TAB_DELAY : 0.6

-- WINDOW_BOUNDS je nastaveno pro konkrétní rozlišení monitoru.
-- Upravte hodnoty {left, top, right, bottom} podle své konfigurace.
-- Pro zjištění rozměrů obrazovky: tell application "Finder" to get bounds of window of desktop
property WINDOW_BOUNDS : {50, 50, 1600, 1000}

-- Network volumes to mount {dName, dAddr}
-- NOTE: Keys use "dName/dAddr" to avoid collision with Finder's "name" keyword
property SERVER_LIST : {¬
	{dName:"PrintData", dAddr:"afp://fileserver.local/PrintData"}, ¬
	{dName:"Print", dAddr:"afp://fileserver.local/Print"}, ¬
	{dName:"Studio", dAddr:"afp://fileserver.local/Studio"}, ¬
	{dName:"Production", dAddr:"afp://fileserver.local/Production"}, ¬
	{dName:"Macintosh HD", dAddr:"smb://user-workstation.local/Macintosh HD"}, ¬
	{dName:"HD Workstation Three", dAddr:"smb://workstation-three.local/HD Workstation Three"}}

-- Folder paths for Finder tab panels (first item = main tab)
property PANEL_PATHS : {¬
	"/Volumes/PrintData", ¬
	"/Volumes/Print", ¬
	"/Volumes/Print/CutterA", ¬
	"/Volumes/Studio/CutterB", ¬
	"/Volumes/Studio/NESTING TEMPLATES", ¬
	"/Volumes/PrintServer/Projects/Print Production"}


-- ---------------------------------------------------------------------------
-- Main Entry Point
-- ---------------------------------------------------------------------------

on run argv
	-- Accept both Shortcuts.app {input, parameters} and direct invocation (no args)
	if class of argv is not list then set argv to {}
	set AppleScript's text item delimiters to ""
	try
		-- Wait for network availability (exits on timeout)
		waitForNetwork(CHECK_SERVER)

		-- Mount network volumes
		set failedMounts to mountVolumes(SERVER_LIST)

		-- Create Finder window with tab panels
		set skippedPaths to createPanels(PANEL_PATHS)

		-- Build summary notification
		set summaryParts to {}
		set AppleScript's text item delimiters to ", "
		if (count of failedMounts) > 0 then
			set end of summaryParts to "Nepřipojené: " & (failedMounts as string)
		end if
		if (count of skippedPaths) > 0 then
			set end of summaryParts to "Přeskočené: " & (skippedPaths as string)
		end if

		if (count of summaryParts) > 0 then
			set AppleScript's text item delimiters to return
			display notification (summaryParts as string) with title "Start Finder"
		else
			display notification "Všechny složky načteny." with title "Start Finder"
		end if
	on error errMsg number errNum
		set AppleScript's text item delimiters to ""
		if errNum is -128 then error number -128
		error errMsg number errNum
	end try
	set AppleScript's text item delimiters to ""
	return argv
end run


-- ---------------------------------------------------------------------------
-- Network
-- ---------------------------------------------------------------------------

-- Wait for network server to become reachable.
-- Shows a progress notification after 5 seconds of waiting.
--
-- Parameters:
--   serverAddress (string) - Hostname or IP to ping
--
-- Behavior:
--   Exits script with dialog if server is unreachable after NETWORK_TIMEOUT
--
on waitForNetwork(serverAddress)
	repeat with i from 1 to NETWORK_TIMEOUT
		try
			do shell script "ping -c 1 -W 1000 " & quoted form of serverAddress
			return
		on error
			if i = 5 then
				display notification "Čekám na síť (" & serverAddress & ")..." with title "Start Finder"
			end if
			delay 1
		end try
	end repeat

	display dialog "Server " & serverAddress & " neodpovídá. Skript ukončen." ¬
		buttons {"OK"} default button "OK" with icon stop
	error "Síť nedostupná: " & serverAddress number -10000
end waitForNetwork


-- ---------------------------------------------------------------------------
-- Volume Mounting
-- ---------------------------------------------------------------------------

-- Mount network volumes that are not already connected.
-- Uses mount volume return value (synchronous) instead of polling Finder disk list,
-- so mount succeeds even when the actual mount point name differs from dName.
-- Returns list of volume names that failed to mount.
--
-- Parameters:
--   volumeList (list of records) - Each record has {dName, dAddr}
--
-- Returns:
--   (list of strings) - Names of volumes that failed to mount
--
on mountVolumes(volumeList)
	set failedVolumes to {}
	repeat with oneVolume in volumeList
		-- Read record keys OUTSIDE tell Finder to avoid "name" keyword collision
		set volName to dName of oneVolume
		set volAddr to dAddr of oneVolume

		-- Check if already mounted (inside tell Finder for disk query)
		set alreadyMounted to false
		tell application "Finder" to set alreadyMounted to (exists disk volName)

		if not alreadyMounted then
			try
				-- mount volume returns alias of actual mount point (may differ from dName)
				mount volume volAddr
			on error errMsg
				set end of failedVolumes to volName
			end try
		end if
	end repeat
	return failedVolumes
end mountVolumes


-- ---------------------------------------------------------------------------
-- Finder Panels
-- ---------------------------------------------------------------------------

-- Create Finder window with tabs for each folder path.
-- Returns list of paths that were skipped (unavailable or error).
--
-- Parameters:
--   pathList (list of strings) - POSIX paths for each tab
--
-- Returns:
--   (list of strings) - Paths that could not be opened
--
on createPanels(pathList)
	set skippedPaths to {}
	if (count of pathList) = 0 then return skippedPaths

	-- Open main window with first path
	tell application "Finder"
		activate
		delay 0.3
		close every window
		delay 0.5

		try
			set firstPath to POSIX file (item 1 of pathList) as alias
			set mainWindow to make new Finder window to firstPath
			set bounds of mainWindow to WINDOW_BOUNDS
			set current view of mainWindow to list view
		on error
			set mainWindow to make new Finder window to home
			set bounds of mainWindow to WINDOW_BOUNDS
			set end of skippedPaths to item 1 of pathList
		end try
	end tell

	-- Add remaining paths as tabs
	tell application "System Events" to tell process "Finder"
		-- Guard: ensure Finder is frontmost before sending keystrokes
		if not frontmost then
			set frontmost to true
			delay 0.3
		end if

		repeat with i from 2 to count of pathList
			set currentPath to item i of pathList

			-- Verify path exists before opening tab
			set folderAlias to my safeAlias(currentPath)

			if folderAlias is not false then
				-- Open new tab via keyboard shortcut
				keystroke "t" using command down
				delay TAB_DELAY

				tell application "Finder"
					try
						set target of front window to folderAlias
						set current view of front window to list view
					on error errMsg
						set end of skippedPaths to currentPath
					end try
				end tell
			else
				set end of skippedPaths to currentPath
			end if
		end repeat
	end tell

	return skippedPaths
end createPanels


-- ---------------------------------------------------------------------------
-- Utilities
-- ---------------------------------------------------------------------------

-- Safely convert POSIX path to alias, return false if path doesn't exist
--
-- Parameters:
--   posixPath (string) - POSIX file path to validate
--
-- Returns:
--   (alias|false) - File alias or false if path is unavailable
--
on safeAlias(posixPath)
	try
		return (POSIX file posixPath as alias)
	on error
		return false
	end try
end safeAlias
