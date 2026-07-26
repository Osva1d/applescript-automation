-- ===========================================================================
-- Script:      <Název Skriptu>
-- Version:     1.0.0
-- Author:      Ladislav Osvald
-- Updated:     RRRR-MM-DD
-- Description: <Jedna věta: co skript dělá.>
-- ===========================================================================

-- ===========================================================================
-- KONFIGURACE — po vložení do Shortcutu přepiš hodnoty na své a nastav
-- CONFIG_DONE na true. Skript se jinak odmítne spustit (viz guard v on run).
-- ===========================================================================
property CONFIG_DONE : false

property EXAMPLE_PATH : "/Volumes/PrintServer/Projects/Print Production"
-- ===========================================================================
-- KONEC KONFIGURACE
-- ===========================================================================


-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- <handlery>


-- ---------------------------------------------------------------------------
-- Main Entry Point
-- ---------------------------------------------------------------------------

on run argv
	-- Accept both Shortcuts.app {input, parameters} and direct invocation (no args)
	if class of argv is not list then set argv to {}

	-- Guard: refuse to run until the configuration block has been filled in
	if not CONFIG_DONE then
		display notification "Nejdřív vyplň konfigurační blok a nastav CONFIG_DONE na true." with title "<Název Skriptu>"
		return argv
	end if

	try
		-- <telo>
		return argv
	on error errMsg number errNum
		if errNum is -128 then error number -128
		error errMsg number errNum
	end try
end run
