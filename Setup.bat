::An attempt to run on single click
::@ECHO OFF
::PowerShell.exe -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1'"
@Powershell.exe Setup.ps1 -base "F:\Code\Presentation-Layer" -projName "Bestest" -projUrl "the-best.com"
::Powershell.exe -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1'" -base "D:\all\Code\Mine" -proj "the-best.comss"
PAUSE