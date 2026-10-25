# Numbers: Export Each Sheet as a Separate PDF

Apple Numbers can only export a whole document to PDF. This AppleScript exports **every sheet as its own PDF**, named after the sheet, in one click.

📺 Video: *coming soon*

## What it does

For each sheet, the script:

1. makes a temporary copy of your file
2. replaces formulas on that sheet with their values, so totals that come from **other sheets** still show correctly
3. deletes all the other sheets in the copy
4. exports the copy as `<sheet name>.pdf` and deletes the copy

The PDFs go into a **`<file name> PDFs`** folder, created automatically next to your Numbers file:

```
Demo Invoices.numbers
Demo Invoices PDFs/
├── Invoice 002.pdf
├── Invoice- ACME-01.pdf
└── Rates.pdf
```

Your original file is not changed. Characters that aren't allowed in file names (`/ : \`) become `-`.

## Files

| File | What it is |
|---|---|
| `Export Sheets to PDF.applescript` | The script |
| `Demo Invoices.numbers` | A small example file (3 sheets, with formulas that use another sheet) to try it on |

## How to use

1. Download `Export Sheets to PDF.applescript` and open it in **Script Editor** (Applications › Utilities).
2. **Check which Numbers app you have.** The script is set to **Numbers Creator Studio**. If you use the free **Numbers** app, change this line:
   ```applescript
   tell application "Numbers Creator Studio"
   ```
   to:
   ```applescript
   tell application "Numbers"
   ```
3. Open your Numbers file. It must be saved, and it should be the only document open (the script uses the front document).
4. In Script Editor, click **Run** (▶).
5. The first time, macOS asks whether Script Editor may control Numbers. Click **OK**.

The progress shows at the bottom of the Script Editor window. Don't click around in Numbers while it runs.

### Skip some sheets

To leave out sheets like "Input" or "Settings", list their names at the top of the script:

```applescript
property sheetsToSkip : {"Input", "Settings"}
```

### Run it with one click

- **As an app:** in Script Editor choose **File › Export…**, set **File Format** to **Application**, and save it. Then open your Numbers file and double-click the app.
- **From the menu bar:** in Script Editor › Settings › General, turn on **Show Script menu in menu bar**, then put the script in `~/Library/Scripts`.

## Good to know

- Running it again replaces PDFs with the same name in the `PDFs` folder.
- A sheet longer than one page simply makes a PDF with more pages.
- Big files take longer, because the script opens one copy per sheet.
- Tested on macOS with Numbers Creator Studio 15.4. The free Numbers app uses the same scripting commands.
