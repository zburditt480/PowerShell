<#
.SYNOPSIS
    This script is used to quickly create a shortcut with powershell
.DESCRIPTION
    The script will ask you a few parameters and create a shortcut based on what you feed it
.NOTES
    File Name      : New-Shortcut.ps1
    Author         : Zachary Burditt zbirdman777@disroot.org
    Prerequisite   : PowerShell V3
.LINK
    Script posted over:
    https://github.com/zburditt480/PowerShell
.EXAMPLE
    Example 1
    .\New-Shortcut.ps1 -path "C:\Users\<user>\Downloads" -targetpath "https://webtools.letu.edu/" -name "Webtools"
#>

param (
    $computername = 'localhost',
    $path = ".\",
    $name = "mylink",
    $targetpath=""
    )

#Combine the parameters into the full path
$fullpath = $path + "\" + $name + ".lnk"

#Create new object in the shell
$Shell = New-Object -ComObject ("WScript.Shell")

#Create a shortcut in the shell
$ShortCut = $Shell.CreateShortCut($fullpath)

#Set the url for the link
$ShortCut.TargetPath=$targetpath;

#Save the shortcut
$ShortCut.Save()