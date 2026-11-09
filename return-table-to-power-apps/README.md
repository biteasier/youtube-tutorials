# Return a Table from Power Automate to Power Apps (SharePoint, ParseJSON)

A Power Apps button that calls a Power Automate flow, gets **SharePoint list items** back as a **table**, and shows them in a gallery.
The flow sends the items as JSON text, and Power Apps turns them into a collection with **ParseJSON** and **Type()**.

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Options](#options)
- [How it works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## Features

- Returns a whole table from a flow to Power Apps, not just one value
- Sends only the columns you choose, with clean names
- Loads the data into a collection with proper types (Number, Text)
- App users don't need access to the SharePoint list (see [Options](#let-users-run-it-without-sharepoint-access))
- Short Power Fx: one `OnSelect` formula and four gallery formulas

## Requirements

- **Power Apps** and **Power Automate** with a work or school account
- A **SharePoint** site where you can create a list
- `ParseJSON` with a `Type()` argument. This is available in current Power Apps Studio.

## Quick start

### 1. Create the SharePoint list

Create a list named **Leave Requests Demo** with these columns, or import [`Leave Requests demo data.csv`](Leave%20Requests%20demo%20data.csv):

| Column | Type |
|---|---|
| Title | Single line of text (built in) |
| EmployeeEmail | Single line of text |
| EmployeeName | Single line of text |
| StartDate | Date |
| EndDate | Date |
| Days | Number |
| Status | Single line of text |

### 2. Build the flow

Create an **Instant cloud flow** with the trigger **When Power Apps calls a flow (V2)**. Name it `GetRequestsFromList`. It doesn't need inputs.

| Step | Action | Settings |
|---|---|---|
| 1 | **Get items** (SharePoint) | Site address: your site. List name: `Leave Requests Demo` |
| 2 | **Select** (Data Operation) | From: `value` from Get items. Map: the table below |
| 3 | **Respond to a Power App or flow** | Add an output › **Text**. Name: `requests`. Value: **Output** from Select |

Select map (pick each value from dynamic content):

| Key | Value | Same as expression |
|---|---|---|
| ID | ID | `item()?['ID']` |
| Title | Title | `item()?['Title']` |
| Employee Email | EmployeeEmail | `item()?['EmployeeEmail']` |
| Employee Name | EmployeeName | `item()?['EmployeeName']` |
| Start Date | StartDate | `item()?['StartDate']` |
| End Date | EndDate | `item()?['EndDate']` |
| Days | Days | `item()?['Days']` |
| Status | Status | `item()?['Status']` |

Save the flow. The warning about Get items without a filter is fine to ignore for this demo.

### 3. Build the app

1. Create a **blank canvas app**.
2. In the left bar, open **Power Automate › Add flow** and pick `GetRequestsFromList`.
3. Insert a **button** with the text `Refresh`, and paste the `OnSelect` formula from [`Power Apps formulas.txt`](Power%20Apps%20formulas.txt).
4. Insert a **vertical gallery**, set **Layout** to *Title, subtitle, and body*, and paste the Items, Title, Subtitle and Body formulas from the same file.
5. Press **F5** (or hold **Alt**, or **Option** on Mac) and click **Refresh**.

The Refresh button's `OnSelect`:

```
Set(theVar, GetRequestsFromList.Run());
ClearCollect(
    colMYCollection,
    ParseJSON(
        theVar.requests,
        Type(
            [
                {
                    ID: Number,
                    Title: Text,
                    'Employee Email': Text,
                    'Employee Name': Text,
                    'Start Date': Text,
                    'End Date': Text,
                    Days: Number,
                    Status: Text
                }
            ]
        )
    )
)
```

## Options

### Let users run it without SharePoint access

In Power Automate, open the flow's details page. Under **Run-only users**, click **Edit**. Under **Connections Used**, set SharePoint to **Use this connection**. The flow then reads the list with your connection, so app users don't need access to the list or the flow.

Every app user then sees **every item** the flow returns. If they should only see their own rows, use the next option.

### Show only the signed-in user's items

*Not shown in the video.* In **Get items › Filter Query**, enter:

```
EmployeeEmail eq '@{triggerOutputs()?['headers']?['x-ms-user-email']}'
```

The trigger knows who is using the app, so you don't need to send the email from Power Apps.

### Get more than 100 items

Get items returns **100 items** by default. In **Get items › Advanced parameters**, set **Top Count** (for example 5000). For more than that, turn on **Pagination** in the action's settings.

### Load the data when the screen opens

Set the screen's **OnVisible** to `Select(Button1)`, using your button's name.

### Use real date types

The demo reads dates as `Text`. To sort or filter by date, change them to `'Start Date': Date` and `'End Date': Date` in `Type()`.

## How it works

1. The **Refresh** button runs the flow with `GetRequestsFromList.Run()` and stores the result in `theVar`.
2. **Get items** reads the list. **Select** keeps only the columns you need and gives them clean names.
3. **Respond to a Power App or flow** can't return a table, only text, numbers and similar values. So the table is sent back as **JSON text** in the `requests` output.
4. `ParseJSON(theVar.requests, Type([...]))` turns that text back into a table. Square brackets mean "a table", and the curly brackets list each column and its type.
5. `ClearCollect` stores the table in `colMYCollection`, and the gallery shows it.

## Troubleshooting

| Problem | Fix |
|---|---|
| *"The function 'ParseJSON' has some invalid arguments"* | Finish the whole formula, including `Type(...)` and every closing bracket. The error shows while you're still typing. |
| A column is blank in the gallery | The name in `Type()` must match the Select key exactly, including spaces and capitals (`'Start Date'`, not `StartDate`). |
| Status is blank | Your Status column is a **Choice** column. In Select, use **Status Value** (`item()?['Status']?['Value']`) instead of Status. |
| Only 100 items come back | Set **Top Count** in Get items (see [Options](#get-more-than-100-items)). |
| `theVar.requests` doesn't exist | The output name in **Respond to a Power App or flow** must be `requests`. Check its spelling. |
| You changed the flow but the app doesn't see it | In Power Apps, remove the flow from the app and add it again. |
| *"Flow run failed"* | Open the flow's run history in Power Automate to see which action failed. |

## FAQ

**Why not connect Power Apps to SharePoint directly?**
You can. Going through a flow is useful when users shouldn't have access to the list, when you want to combine or clean up data first, or when you want the app to get only the columns it needs.

**Why is the table sent as text?**
**Respond to a Power App or flow** has no table or array output type. Text is the standard way around it, and `ParseJSON` turns it back into a table.

**Can I use a Person or Choice column?**
Yes. Return the part you need in Select, for example `item()?['Status']?['Value']` for a Choice column, or `item()?['Manager']?['Email']` for a Person column.

**Does it work with other data sources?**
Yes. Replace **Get items** with any action that returns a list, such as Excel **List rows present in a table** or Dataverse **List rows**. Keep the Select and Respond steps the same.

## Video

Step-by-step walkthrough on YouTube: [Return a Table from Power Automate to Power Apps](https://youtu.be/Lx8Uvl4_Ezs)

Related: [Call a Power Automate flow from Power Apps](https://youtu.be/vTrgZ3qZs4I)

[All tutorials](../) · [MIT License](../LICENSE)
