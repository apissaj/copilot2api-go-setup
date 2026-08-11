' autostart.vbs - CopilotProxy autostart (hidden at boot)
' Taruh di shell:startup (Win+R -> shell:startup) atau Startup folder
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run """C:\Users\TUF Gaming A15\copilot2api-go\start-copilot.bat""", 0, False