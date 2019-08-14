function Remove-Outdated {
<#
.SYNOPSIS
Removes archives of files such as logs dating past a certain date
.DESCRIPTION
This command can be fed a path and a number of days and it will recursively 
delete the files that are older than the number of days specified
.PARAMETER Path
Path to the directory
.PARAMETER Days
Designates the starting point for removing files older than X days.
.EXAMPLE
Remove-Outdated -Path <path> -Days 30
This example will remove files older than 30 days from the given path
#>
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True,
                   Mandatory=$True)]
        [Alias('Name')]
        [string[]]$Path,
        
        [Parameter(ValueFromPipeline=$False,
                   Mandatory=$True)]
        [string[]]$Days
    )
 
 BEGIN {}

 PROCESS {
    Write-Verbose "Getting todays date"
    $CurrentDate = Get-Date

    Write-Verbose "Getting date to remove items from"
    $DatetoDelete = $CurrentDate.AddDays($Daysback)

    Write-Verbose "Remove items recursively from days back date"
    Get-ChildItem $Path -Recurse ( Where-Object { $_.LastWriteTime -lt $DatetoDelete }) | Remove-Item
} #PROCESS

END {}

} #function