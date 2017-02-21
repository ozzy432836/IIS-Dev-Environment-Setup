::An attempt to run on single click
::@ECHO OFF
::PowerShell.exe -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1'"
Powershell.exe .\Setup.ps1 -base "D:\all\Code\Mine" -proj "the-best.comsddds"
::Powershell.exe -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1'" -base "D:\all\Code\Mine" -proj "the-best.comss"
PAUSE