function Format-ExcelSpreadsheet {
    <#
    .SYNOPSIS
    Formats an excel spreadsheet to be processed
    .DESCRIPTION
    Replaces ' with '' for names such as O'Doyle. This is due to an exception error with an unclosed quotation on insert. Double apostrophe results in normal names
    .PARAMETER Path
    Path to excel spreadsheet
    .PARAMETER Find
    String to locate in document
    .PARAMETER Replace
    String to replace with
    .EXAMPLE
    Format-ExcelSpreadsheet -path C:\Users\zacharyburditt\Downloads\FINAID_PS\Finaid_Test2.xlsx -find "/" -replace "-"
    #>

    [CmdletBinding()]
    Param( 
    [Parameter(Mandatory = $true)]$path,
    [Parameter(Mandatory = $true)]$find,
    [Parameter(Mandatory = $true)]$replace
    )
    BEGIN{}
    
    #I created this to simply replace values in an excel spreadsheet
    PROCESS{
        Write-Verbose "Create new excel object"
        $Excel = New-Object -ComObject Excel.Application

        Write-Verbose "Open workbook"
        $Workbook=$Excel.Workbooks.Open($path)

        Write-Verbose "Set sheet to first page"
        $WorkSheet = $Workbook.Sheets.Item(1)

        Write-Verbose "Replace values"
        $WorkSheet.Columns.Replace("'","''")

        Write-Verbose "Save changes"
        $Workbook.save()

        Write-Verbose "Close workbook"
        $Workbook.close()

        Write-Verbose "Quite excel"
        $Excel.quit()
    }#PROCESS
    
    END{}#End

}#Format-ExcelSpreadsheet