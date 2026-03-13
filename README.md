# Online Text Editor – ASP.NET, jQuery, AJAX

This project is a simple web‑based text editor built with **ASP.NET Web Forms**, **C#**, and **jQuery**.  
Users can open, edit, and save text files that are stored on the server in a `MyFiles` folder.

## Features

- **File browser**
  - Loads the list of available files from the server into a dropdown.
  - Refreshes automatically after using “Save As” to create a new file.

- **Open and edit**
  - Opens the selected file and loads its content into a large text area.
  - Allows users to freely edit the text in the browser.

- **Save and Save As**
  - **Save**: writes changes back to the currently selected file.
  - **Save As**: saves the text under a new file name and updates the file list.
  - Shows clear status messages for success and error cases.

- **AJAX API (`FileHandler.ashx`)**
  - `getFiles`: returns a JSON list of file names in the `MyFiles` directory.
  - `getFile`: returns the contents of a given file as JSON.
  - `saveFile`: accepts JSON (`filename`, `content`) and writes the file on the server.
  - Handles both query‑string and JSON body requests, with basic error validation.

## Technologies Used

- ASP.NET Web Forms (C#)
- HTTP handlers (`IHttpHandler`) for a JSON API
- jQuery and AJAX (`$.getJSON`, `$.ajax`)
- HTML/CSS for the editor layout

## How to use

1. Deploy the site and ensure the `MyFiles` folder is accessible to the application.  
2. Browse to `startPage.aspx`.  
3. Choose a file from the dropdown and click **Open** to load it.  
4. Edit the text and click **Save**, or enter a new file name and click **Save As**.  
5. Watch the status message area for feedback on each operation.
