function Invoke-Query {
  <#
      .SYNOPSIS
        Invoke a SQL command against a database
      .DESCRIPTION
        Run queries against a database. Mainly used for insert statements
      .PARAMETER sql
        The query or statement to execute. Takes value from pipeline
      .PARAMETER Database
        Database name
      .PARAMETER Server
        Server name, IP address, or DNS
      .EXAMPLE
        ConvertFrom-ExcelToSQLInsert -TableName "RptCommon.dbo.Names" -Path C:\Users\zacharyburditt\Downloads\test.xlsx -UseMSSQLSyntax | Invoke-Query -server "webtools-new" -database "RptCommon""
    #>

    [CmdletBinding()]
    param(
      [Parameter(ValueFromPipeLine = $true, Mandatory = $true)]$sql,
      [Parameter(Mandatory = $true)]$database,
      [Parameter(Mandatory = $true)]$server
    )

    BEGIN {}

    PROCESS {
      Write-Verbose "Creating SQL Object"
      $conn = New-Object System.Data.SqlClient.SqlConnection
    
      Write-Verbose "Set Connection String"
      $conn.ConnectionString = "server=$server;database=$database;Trusted_Connection=True;"

      Write-Verbose "Opening connection"
      $conn.Open()

      Write-Verbose "Creating SQL Client Command"
      $cmd = New-Object System.Data.SqlClient.SqlCommand
  
      Write-Verbose "Set Connection"
      $cmd.Connection = $conn

      #Run each sql statement fed to cmdlet
      foreach ($query in $sql) {
        Write-Verbose "Set command text"
        $cmd.CommandText = $sql

        Write-Verbose "Execute query"
        $cmd.ExecuteNonQuery() | Out-Null
      }
      Write-Verbose "Closing connection" 
      $conn.Close()
    }

    END {}
}