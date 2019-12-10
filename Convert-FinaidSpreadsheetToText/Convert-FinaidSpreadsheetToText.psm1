function Convert-FinaidSpreadsheetToText {
    <#
    .SYNOPSIS
    Run the FINAID Conversion process
    .DESCRIPTION
    Project main for custom modules created to run the finaid excel spreadsheet to text conversion process. The table name and output name is autogenerated.
    The output text file will be saved in the same directory as the selected excel spreadsheet.
    .PARAMETER Path
    Path to excel spreadsheet
    .PARAMETER Cycle
    The cycle for the current run: 1, 2, or 3
    .PARAMETER AcademicYear
    Academic year such as 1819 or 1920. No commas and 2 years digit years combined only
    .PARAMETER TestMode
    Runs the script without created the table, inserting data, or outputting the file. Useful for testing that the spreadsheet is formatted properly
    .EXAMPLE
    Convert-FinaidSpreadsheetToText -path C:\Users\zacharyburditt\Downloads\FINAID_PS\Finaid_Test2.xlsx -cycle 1  -academicyear 1819      
    #>

    [CmdletBinding()]
    Param( 
    [Parameter(Mandatory = $true)][Alias('file','name','filename','input')]$path,
    [Parameter(Mandatory = $true)][ValidateSet('1','2','3')]$cycle,
    [Parameter(Mandatory= $true)][Alias('Year')]$academicyear,
    [switch][Alias('WhatIf','test')]$testmode
    )
    BEGIN {}

    PROCESS {
        #Defining variables ahead of time. Essentially a config file
        Write-Verbose "Assign variables and paths"
        $server = "dw-sql-a"
        $database = "LU"
        $table = "FADB$academicyear$cycle`_$(get-date -f yyyyMMdd_HHMM)"
        $output = "$(Split-Path $path)\$table.txt"

        #Backup the original file for safety purposes and copy it to a new file with a new file name since it will be modified
        Write-Verbose "Create a copy of the original file with new file name"
        copy-item $path "$(Split-Path $path)\$table.xlsx"

        #Point the path variable to the newly generated file
        Write-Verbose "Assign the path to the copy of original"
        $path = "$(Split-Path $path)\$table.xlsx"

        Write-Verbose "Create table"
        
        if ($testmode -eq $False)
        {
            New-FinaidTable -server $server -database $database -table $table
        }

        #Replaces ' with '' because of names like O'Darby. SQL interprets '' as ' on import
        #This can be reused for other replacements like replace blank with NULL
        Write-Verbose "Format spreadsheet for import"
        Format-ExcelSpreadsheet -path $path -find "'" -replace "''" | Out-Null
        
        #This module converts each row from a spreadsheet into a SQL insert statement. Module was available on PSgallery https://github.com/dfinke/ImportExcel
        Write-Verbose "Convert spreadsheet to SQL statements"
        $sql = ConvertFrom-ExcelToSQLInsert -TableName $table -Path $path -UseMSSQLSyntax

        #By piping in the SQL inserts we can insert the entire spreadsheet
        Write-Verbose "Insert Data from SQL statements into Table"
        if ($testmode -eq $False)
        {
            $sql | Invoke-Query -server $server -database $database
        }

        #Run the SQL script provided by Tim Shafer. Script returns a single row of data 
        Write-Verbose "Run FINAID Script"
        if ($testmode -eq $False)
        {
            $data = Get-FinaidQuery -server $server -database $database -table $table | ForEach-Object {$_.RowNbr }
        }

        #Pipe the script results to a text file
        Write-Verbose "Generated Text file"

        if ($testmode -eq $False)
        {
        write-output $data > $output
        }
        Write-Verbose "Complete"

        if ($testmode -eq $True)
        {
        remove-item $path
        Write-Host "Test mode complete"
        }
    }#Process
    END{}
}#Function