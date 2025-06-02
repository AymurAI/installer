Function ExecCommand(cmd)
    Const WshRunning = 0
    Const WshFinished = 1

    Dim objWshShell : Set objWshShell = CreateObject("WScript.Shell")
    Dim oExec : Set oExec = objWshShell.Exec(cmd)
    Dim outputText
    Do
        'sleep in the loop before reading pipelines and reading finished state
        WScript.Sleep 50

        ' We must read these, or it seems to block execution after 700 lines out output,
        ' probably because VBScript is blocking the pipeline, because script completes if VBScirpt is stoped with Ctrl-C
        While oExec.StdOut.AtEndOfStream <> True
            outputText = oExec.StdOut.ReadLine()
            For i = 1 To Len(outputText) - 1 Step 1024
                WScript.StdOut.WriteLine(Mid(outputText, i, 1024))
            next
        Wend

        While oExec.StdErr.AtEndOfStream <> True
            outputText = oExec.StdErr.ReadLine()
            WScript.StdErr.Write("ERROR: ")
            For i = 1 To Len(outputText) - 1 Step 1024
                WScript.StdErr.WriteLine(Mid(outputText, i, 1024))
            next
        Wend

        Finished = ( oExec.Status = WshFinished )
    Loop Until Finished
    
    WScript.StdOut.WriteLine("ExitCode: " & oExec.ExitCode)
    WScript.Quit(oExec.ExitCode) ' Optionally sets exit-code and exits this VbScript (but does not stop the executing sub-shell)
End Function

ExecCommand(WScript.Arguments.Item(0))
