# Export Each Numbers Sheet as a Separate PDF (Mac)

An AppleScript that exports **every sheet of an Apple Numbers file as its own PDF**, named after the sheet, in one click.

Numbers has no built-in way to do this: **File › Export To › PDF** always puts all sheets into one PDF, and **Print › This Sheet** only does one sheet at a time.

![Before: one Numbers file with three sheets. After: a folder with one PDF per sheet](assets/before-after.svg)

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Options](#options)
- [How it works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## Features

- One PDF per sheet, named after the sheet
- Formulas that use other sheets still show the right values
- Creates a `<file name> PDFs` folder next to your Numbers file
- Never changes your original file
- Shows progress while it runs
- Lets you skip sheets you don't want exported

## Requirements

- A Mac with **Numbers** (free) or **Numbers Creator Studio**
- **Script Editor**, which comes with macOS (Applications › Utilities)
- The Numbers file must be **saved** at least once

## Quick start

1. Download [`Export Sheets to PDF.applescript`](Export%20Sheets%20to%20PDF.applescript) and open it in **Script Editor**.
2. If you use the free **Numbers** app, change this line:

   ```applescript
   tell application "Numbers Creator Studio"
   ```

   to:

   ```applescript
   tell application "Numbers"
   ```

3. Open your Numbers file. Close any other Numbers documents, because the script uses the front one.
4. In Script Editor, click **Run**.
5. The first time, macOS asks whether Script Editor may control Numbers. Click **OK**.

When it finishes, your PDFs are in the new folder:

```
My Folder/
├── Demo Invoices.numbers
└── Demo Invoices PDFs/
    ├── Invoice 002.pdf
    ├── Invoice- ACME-01.pdf
    └── Rates.pdf
```

To try it safely first, use [`Demo Invoices.numbers`](Demo%20Invoices.numbers). Its invoice totals come from the "Rates" sheet, so you can see that the formulas keep working.

## Options

### Skip sheets

List sheet names at the top of the script:

```applescript
property sheetsToSkip : {"Input", "Settings"}
```

### Run it with a double-click

In Script Editor choose **File › Export…**, set **File Format** to **Application**, and save it. Then open your Numbers file and double-click the app.

### Run it from the menu bar

In Script Editor open **Settings › General**, turn on **Show Script menu in menu bar**, and save the script in `~/Library/Scripts`.

## How it works

Numbers can't export a single sheet, so for each sheet the script:

1. Copies your file into a hidden temporary folder
2. Replaces every formula on that sheet with its current value
3. Deletes all the other sheets in the copy
4. Exports the copy as `<sheet name>.pdf`
5. Deletes the copy

Step 2 matters because a formula that points at a deleted sheet would break. Values keep their number, currency, percentage and date formats.

## Troubleshooting

| Problem | Fix |
|---|---|
| Script Editor asks *"Where is Numbers Creator Studio?"* | You have the free Numbers app. Click Cancel and change the `tell application` line (Quick start, step 2). |
| *"Open a Numbers document first"* | Open your file in Numbers, then run the script. |
| *"Save the document first"* | Save the file once (⌘S) and run again. |
| *"Not allowed to send Apple events"* | System Settings › Privacy & Security › Automation: allow Script Editor to control Numbers. |
| A PDF has several pages | That sheet is longer than one page. It still gets its own file. |
| It's slow | The script opens one copy per sheet, so big files take longer. Don't click in Numbers while it runs. |

## FAQ

**Does it change my original file?**
No. It only saves the file if it has unsaved changes, so the copies include your latest edits. All the changes happen on temporary copies.

**What happens if I run it twice?**
PDFs with the same name are replaced.

**What about special characters in sheet names?**
`/`, `:` and `\` aren't allowed in file names, so they become `-`. For example, `Invoice: ACME/01` becomes `Invoice- ACME-01.pdf`.

**Which versions does it work with?**
Tested with Numbers Creator Studio 15.4. The free Numbers app uses the same scripting commands.

## Video

Step-by-step walkthrough on YouTube: [@biteasier](https://www.youtube.com/@biteasier) (coming soon).

[All tutorials](../) · [MIT License](../LICENSE)
