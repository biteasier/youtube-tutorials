# Export each Numbers sheet as a separate PDF

Numbers can only export a whole document to PDF. This AppleScript exports every sheet as its own PDF, named after the sheet.

![Before: one Numbers file with three sheets. After: a folder with one PDF per sheet](assets/before-after.svg)

## Files

- `Export Sheets to PDF.applescript`: the script
- `Demo Invoices.numbers`: a demo file to try it on

## Use

1. Open your Numbers file. It must be saved.
2. Open the script in Script Editor and click **Run**.
3. The PDFs are saved in a `<file name> PDFs` folder next to your file.

The first time, macOS asks whether Script Editor may control Numbers. Click **OK**.

**Free Numbers app:** the script is set to Numbers Creator Studio. Change `tell application "Numbers Creator Studio"` to `tell application "Numbers"`.

**Skip sheets:** list them at the top of the script, e.g. `property sheetsToSkip : {"Input"}`.

## How it works

For each sheet, the script copies your file, replaces formulas with their values, deletes the other sheets, and exports the copy as PDF. Your original file is not changed, and totals that come from other sheets stay correct.

## Notes

- Running it again replaces PDFs with the same name.
- `/`, `:` and `\` in sheet names become `-`.
- Tested with Numbers Creator Studio 15.4 on macOS.

[Video](https://www.youtube.com/@biteasier): coming soon · [All tutorials](../)
