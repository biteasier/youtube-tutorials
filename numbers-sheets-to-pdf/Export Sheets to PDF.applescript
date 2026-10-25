-- Export Sheets to PDF
-- Exports every sheet of the front Numbers document as its own PDF,
-- named after the sheet, into a "<document name> PDFs" subfolder that is
-- created automatically next to the document.
--
-- Numbers can only export the whole document, so for each sheet this script:
--   1. duplicates the file into a temporary folder
--   2. replaces formulas on that sheet with their values
--   3. deletes every other sheet
--   4. exports the copy as PDF and throws the copy away
-- The original document is never changed (it is only saved first).
--
-- If you use the free Numbers app, change "Numbers Creator Studio" below to "Numbers".

-- Sheets with these names are not exported, e.g. {"Input", "Settings"}
property sheetsToSkip : {}

-- Big files can take a while to open and export
with timeout of 600 seconds
	tell application "Numbers Creator Studio"
		if (count of documents) is 0 then
			display alert "Open a Numbers document first."
			return
		end if
		
		set theDoc to front document
		set docFile to file of theDoc
		if docFile is missing value then
			display alert "Save the document first, then run this script again."
			return
		end if
		
		-- Save so the copies include your latest changes
		if modified of theDoc then save theDoc
		
		set docName to name of theDoc
		if docName ends with ".numbers" then set docName to text 1 thru -9 of docName
		
		set sheetNames to {}
		repeat with s in sheets of theDoc
			if sheetsToSkip does not contain (name of s) then set end of sheetNames to (name of s)
		end repeat
		
		-- Output subfolder next to the document: "<document name> PDFs"
		set sourcePOSIX to POSIX path of (docFile as alias)
		set docFolderPOSIX to do shell script "dirname " & quoted form of sourcePOSIX
		set outputPOSIX to docFolderPOSIX & "/" & docName & " PDFs/"
		do shell script "mkdir -p " & quoted form of outputPOSIX

		-- Hidden working folder for the copies. It sits inside the output folder
		-- because Numbers is sandboxed and cannot open files from the system temp folder.
		-- mktemp gives it a unique name, so it never touches an existing folder.
		set tempPOSIX to do shell script "mktemp -d " & quoted form of (outputPOSIX & ".work-XXXXXX")
		
		set totalSheets to count of sheetNames
		
		repeat with i from 1 to totalSheets
			set sheetName to item i of sheetNames
			my showProgress(i - 1, totalSheets, "Sheet " & i & " of " & totalSheets & ": " & sheetName)
			
			-- 1. Duplicate the file (.numbers can be a package, so copy recursively)
			set copyName to "export-copy-" & i & ".numbers"
			set copyPOSIX to tempPOSIX & "/" & copyName
			do shell script "cp -R " & quoted form of sourcePOSIX & " " & quoted form of copyPOSIX
			-- Pass an alias, not a path: the sandboxed Numbers app only opens files handed to it this way
			open ((POSIX file copyPOSIX) as alias)
			
			-- "open" does not always return the document, so wait for it by name
			set tempDoc to missing value
			repeat 100 times
				try
					set tempDoc to (first document whose name is copyName)
					exit repeat
				end try
				delay 0.2
			end repeat
			if tempDoc is missing value then error "Numbers could not open the copy of sheet \"" & sheetName & "\"."
			
			tell tempDoc
				-- 2. Replace every formula with its current value, otherwise formulas
				--    that point at other sheets break when those sheets are deleted.
				--    (Numbers shows references by header name, e.g. "=Price Design",
				--    so you cannot tell from the text which ones point elsewhere.)
				tell (first sheet whose name is sheetName)
					repeat with t in tables
						tell t
							set theFormulas to formula of every cell
							set theValues to value of every cell
							repeat with c from 1 to count of theFormulas
								if item c of theFormulas is not missing value then
									try
										set value of cell c to (item c of theValues)
									end try
								end if
							end repeat
						end tell
					end repeat
				end tell
				
				-- 3. Keep only this sheet
				delete (every sheet whose name is not sheetName)
			end tell
			
			-- 4. Export as "<sheet name>.pdf" and discard the copy
			set pdfPOSIX to outputPOSIX & my safeFileName(sheetName) & ".pdf"
			export tempDoc to (POSIX file pdfPOSIX) as PDF
			close tempDoc saving no
			do shell script "rm -rf " & quoted form of copyPOSIX
		end repeat
		my showProgress(totalSheets, totalSheets, "Done")
		
		do shell script "rm -rf " & quoted form of tempPOSIX
		
		display dialog "Exported " & totalSheets & " sheets to \"" & docName & " PDFs\", next to the document." buttons {"Show in Finder", "OK"} default button "OK"
		if button returned of result is "Show in Finder" then do shell script "open " & quoted form of outputPOSIX
	end tell
end timeout

-- Progress bar (must be set outside the Numbers tell block)
on showProgress(doneSteps, totalSteps, theText)
	set progress total steps to totalSteps
	set progress completed steps to doneSteps
	set progress description to "Exporting sheets to PDF..."
	set progress additional description to theText
end showProgress

-- Replace characters that are not allowed in file names
on safeFileName(theName)
	set theName to theName as string
	repeat with badChar in {"/", ":", "\\"}
		set AppleScript's text item delimiters to (badChar as string)
		set theParts to text items of theName
		set AppleScript's text item delimiters to "-"
		set theName to theParts as string
	end repeat
	set AppleScript's text item delimiters to ""
	return theName
end safeFileName
