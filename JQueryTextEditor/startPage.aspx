<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="startPage.aspx.cs" Inherits="JQueryTextEditor.startPage" %>

<!--
 * FILE: startPage.aspx
 * PROJECT: PROG2001 - Assignment #5
 * PROGRAMMER: Rordrigo & Bibi
 * DATE: 2025-12-01
 * DESCRIPTION:This page is the interface for the text editor.It lets the user choose a file, open it, edit it, and save it.
 * The user can also save the text as a new file.jQuery and JSON are used to communicate with FileHandler.ashx.
 -->

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Online Text Editor</title>

    <!--jQuery library used for ajax calls -->
    <script src="Scripts/jquery-3.7.0.min.js"></script>

    <!--css file for styling the page -->
    <link rel="stylesheet" type="text/css" href="Content/Site.css" />

    <script>

        /*
         * FUNCTION: reloadFiles
         * PURPOSE: Refresh the dropdown list after a new file is created.
         * RETURNS: void
         */
        function reloadFiles() {
            $.getJSON("FileHandler.ashx", { action: "getFiles" }, function (data) {
                var select = $("#fileList");
                select.empty();

                $.each(data.files, function (i, f) {
                    select.append($("<option></option>").val(f).text(f));
                });
            });
        }

        /*
         * FUNCTION: Document Ready
         * PURPOSE: Runs when page finishes loading. Loads file list and sets up button events.
         */
        $(document).ready(function () {

            //Loading file list
            $.getJSON("FileHandler.ashx", { action: "getFiles" }, function (data) {
                var select = $("#fileList")
                select.empty()

                //populate dropdown
                if (data.files && data.files.length > 0) {
                    $.each(data.files, function (i, file) {
                        select.append($("<option></option>").attr("value", file).text(file))
                    })
                    $("#status").text("File list loaded")
                } else {
                    select.append($("<option></option>").text("No files found"))
                    $("#status").text("No files found in MyFiles folder")
                }
            }).fail(function (xhr) {
                $("#status").text("Error loading files " + xhr.status)
            })

            /*
             * EVENT: Open Button Click
             * PURPOSE: Load selected file content into the text area.
             */
            $("#btnOpen").click(function () {
                var fileName = $("#fileList").val()
                if (!fileName) {
                    $("#status").text("Please select a file")
                    return
                }

                //AJAX call to get file content
                $.getJSON("FileHandler.ashx", { action: "getFile", filename: fileName }, function (data) {
                    if (data.content !== undefined) {
                        $("#editor").val(data.content)
                        $("#status").text("Loaded " + fileName)
                    } else if (data.error) {
                        $("#status").text(data.error)
                    }
                }).fail(function (xhr) {
                    $("#status").text("Error opening file " + xhr.status)
                })
            })

            /*
            * EVENT: Save Button Click
            * PURPOSE: Save the text to the same file.
            */
            $("#btnSave").click(function () {
                var fileName = $("#fileList").val()
                var newContent = $("#editor").val()

                if (!fileName) {
                    $("#status").text("Please select a file first")
                    return
                }

                //AJAX call to save file
                $.ajax({
                    url: "FileHandler.ashx",
                    type: "POST",
                    data: JSON.stringify({action: "saveFile",filename: fileName,content: newContent}),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.status === "success") {
                            $("#status").text("File saved successfully")
                        } else if (response.error) {
                            $("#status").text(response.error)
                        }
                    },
                    error: function (xhr) {
                        $("#status").text("Save failed " + xhr.status)
                    }
                })
            })

            /*
            * EVENT: Save As Button Click
            * PURPOSE: Save the text as a new file name.
            */
            $("#btnSaveAs").click(function () {
                var newName = $("#newFileName").val();
                var newContent = $("#editor").val();

                //check user entered a filename
                if (!newName) {
                    $("#saveAsError").text("Enter a new filename first");
                    return;
                } else {
                    $("#saveAsError").text(""); 
                }


                // AJAX call to save as a new file
                $.ajax({
                    url: "FileHandler.ashx",
                    type: "POST",
                    data: JSON.stringify({action: "saveFile",filename: newName,content: newContent }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.status === "success") {
                            $("#status").text("Saved as " + newName);

                            // Refresh dropdown so new file appears
                            reloadFiles();
                        } else if (response.error) {
                            $("#status").text(response.error);
                        }
                    },
                    error: function () {
                        $("#status").text("Save As failed");
                    }
                });
            });
        })
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="editor-container">
            <h2>Online Text Editor</h2>

            <!--file list and open/save buttons -->
            <select id="fileList"></select>
            <button type="button" id="btnOpen">Open</button>
            <button type="button" id="btnSave">Save</button>

            <br /><br />

            <!-- Save As area -->
            <div class="saveas-row">
                <input type="text" id="newFileName" placeholder="New filename (Save As)">
                <button type="button" id="btnSaveAs">Save As</button>
            </div>
            <div id="saveAsError"></div>
            <br /><br />

            <textarea id="editor" placeholder="File content will appear here"></textarea>

            <p id="status"></p>
        </div>
    </form>
</body>
</html>
