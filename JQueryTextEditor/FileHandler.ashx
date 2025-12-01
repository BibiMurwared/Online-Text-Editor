<%@ WebHandler Language="C#" Class="FileHandler" %>

/* 
 * FILE: FileHandler.ashx
 * PROJECT: PROG2001 - Assignment #5
 * PROGRAMMER: Rodrigo Gomes
 * FIRST VERSION: 2025-12-01
 * DESCRIPTION: This handler receives AJAX requests from the web page.It reads the action sent by the client and chooses what to do.
 * It can return the list of files, return file text, or save a file. All information sent back to the page is formatted as json.
 */

using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;

public class FileHandler : IHttpHandler
{
    private readonly string fileDir = HttpContext.Current.Server.MapPath("~/MyFiles/");
    private readonly JavaScriptSerializer js = new JavaScriptSerializer();

    /// <summary>
    /// Processes incoming HTTP requests
    /// </summary>
    /// <param name="context"></param>
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        string action = context.Request["action"];


        //Attempt to read action from JSON body if not found in query string
        if (string.IsNullOrEmpty(action) && context.Request.HttpMethod == "POST")
        {
            try
            {
                context.Request.InputStream.Position = 0;
                string json = new StreamReader(context.Request.InputStream).ReadToEnd();
                var data = js.Deserialize<Dictionary<string, object>>(json);

                //Check if action exists
                if (data != null && data.ContainsKey("action"))
                    action = data["action"].ToString();
                context.Request.InputStream.Position = 0;
            }
            catch { }
        }

        //Change to appropriate method based on action
        switch (action)
        {
            case "getFiles":
                GetFiles(context);
                break;
            case "getFile":
                GetFile(context);
                break;
            case "saveFile":
                SaveFile(context);
                break;
            default:
                context.Response.Write(js.Serialize(new { error = "Invalid action" }));
                break;
        }
    }

    /// <summary>
    /// Lists all files in the MyFiles directory
    /// </summary>
    /// <param name="context"></param>
    private void GetFiles(HttpContext context)
    {
        try
        {
            if (!Directory.Exists(fileDir))
                Directory.CreateDirectory(fileDir);

            var files = Directory.GetFiles(fileDir);
            var fileNames = new List<string>();

            //Extract just the file names
            foreach (var f in files)
                fileNames.Add(Path.GetFileName(f));

            context.Response.Write(js.Serialize(new { files = fileNames }));
        }
        catch (Exception ex)
        {
            context.Response.Write(js.Serialize(new { error = ex.Message }));
        }
    }

    /// <summary>
    /// Gets the content of a specified file
    /// </summary>
    /// <param name="context"></param>
    private void GetFile(HttpContext context)
    {
        string fileName = context.Request["filename"];
        string filePath = Path.Combine(fileDir, fileName);

        if (File.Exists(filePath))
        {
            string content = File.ReadAllText(filePath);
            context.Response.Write(js.Serialize(new { content = content }));
        }
        else
        {
            context.Response.Write(js.Serialize(new { error = "File not found" }));
        }
    }

    /// <summary>
    /// Saves content to a specified file
    /// </summary>
    /// <param name="context"></param>
    private void SaveFile(HttpContext context)
    {
        try
        {
            context.Request.InputStream.Position = 0;
            string json = new StreamReader(context.Request.InputStream).ReadToEnd();
            var data = js.Deserialize<Dictionary<string, object>>(json);

            //Validating input
            if (data == null || !data.ContainsKey("filename") || !data.ContainsKey("content"))
            {
                context.Response.Write(js.Serialize(new { error = "Invalid JSON data received." }));
                return;
            }

            string fileName = data["filename"].ToString();
            string content = data["content"].ToString();

            string filePath = Path.Combine(fileDir, fileName);
            File.WriteAllText(filePath, content);

            context.Response.Write(js.Serialize(new { status = "success" }));
        }
        catch (Exception ex)
        {
            context.Response.Write(js.Serialize(new { error = ex.Message }));
        }
    }

    public bool IsReusable => false;
}
