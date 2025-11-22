<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="startPage.aspx.cs" Inherits="JQueryTextEditor.startPage" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Online Text Editor</title>

    <!-- jQuery file -->
    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <link rel="stylesheet" type="text/css" href="Content/Site.css" />

    <script>
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

            //Opens the selected file
            $("#btnOpen").click(function () {
                var fileName = $("#fileList").val()
                if (!fileName) {
                    $("#status").text("Please select a file")
                    return
                }

                //AJAX call to get file content
                $.getJSON("FileHandler.ashx", { action: "getFile", filename: fileName }, function (data) {
                    if (data.content) {
                        $("#editor").val(data.content)
                        $("#status").text("Loaded " + fileName)
                    } else if (data.error) {
                        $("#status").text(data.error)
                    }
                }).fail(function (xhr) {
                    $("#status").text("Error opening file " + xhr.status)
                })
            })

            //Saving file content
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
                    data: JSON.stringify({
                        action: "saveFile",
                        filename: fileName,
                        content: newContent
                    }),
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
        })
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="editor-container">
            <h2>Online Text Editor</h2>

            <select id="fileList"></select>
            <button type="button" id="btnOpen">Open</button>
            <button type="button" id="btnSave">Save</button>

            <br /><br />

            <textarea id="editor" placeholder="File content will appear here"></textarea>

            <p id="status"></p>
        </div>
    </form>
</body>
</html>
