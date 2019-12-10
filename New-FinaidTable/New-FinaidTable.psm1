function New-FinaidTable {
  <#
      .SYNOPSIS
        Create a new finaid table
      .DESCRIPTION
        Creates a new finaid table. It also verifies that table exists before creating it.
      .PARAMETER Table
        Name of the target database table.
      .PARAMETER Database
        Database name
      .PARAMETER Server
        Server name, IP address, or DNS
      .EXAMPLE
        New-FinaidTable -server sql2008-1 -database RptCommon -Table FinaidTest
    #>

        [CmdletBinding()]
        param(
          [Parameter(Mandatory = $true)]$table,
          [Parameter(Mandatory = $true)]$database,
          [Parameter(Mandatory = $true)]$server,
          [Parameter()][switch]$UseTrusted
        )
    
        BEGIN {}
    
        PROCESS {
          Write-Verbose "Creating SQL Object"
          $conn = New-Object System.Data.SqlClient.SqlConnection
        
          Write-Verbose "Set Connection String"
          $conn.ConnectionString = "server=$server;database=$database;Trusted_Connection=True;"
    
          Write-Verbose "Opening connection"
          $conn.Open()

          Write-Verbose "Creating table"
          $sql = @"
          IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='$Table' AND xtype='U')
     CREATE TABLE [dbo].[$Table](
        [RowNbr] [float] NULL,
        [PrevCycle] [float] NULL,
        [ID] [nvarchar](255) NULL,
        [Prog] [nvarchar](255) NULL,
        [SubProg] [nvarchar](255) NULL,
        [Yr] [float] NULL,
        [Sess] [nvarchar](255) NULL,
        [CurrEnr] [nvarchar](255) NULL,
        [Reg_Hrs] [float] NULL,
        [MET_SAP] [nvarchar](255) NULL,
        [C005_SSN] [nvarchar](255) NULL,
        [C006_Stdnt_Spouse_AGI] [nvarchar](255) NULL,
        [C007_Parent_AGI] [float] NULL,
        [C009_Unmatched_Reason] [float] NULL,
        [C022_Program_Level] [float] NULL,
        [C023_Need_Analysis] [float] NULL,
        [C024_Living_Arrangement] [float] NULL,
        [C025_Ethnic_Origin] [float] NULL,
        [C026_Race_1_White] [float] NULL,
        [C027_Race_2_Black] [float] NULL,
        [C028_Race_4_Asian] [float] NULL,
        [C029_Race_5_Indian] [float] NULL,
        [C030_Race_6_International] [float] NULL,
        [C031_Race_7_Unknown] [float] NULL,
        [C032_Race_8_Hawaiian] [float] NULL,
        [C033_Classification] [float] NULL,
        [C034_Dependency_Status] [float] NULL,
        [C035_Date_Of_Birth] [float] NULL,
        [C036_Residency] [float] NULL,
        [C037_9Month_EFC] [float] NULL,
        [C038_LastName] [nvarchar](255) NULL,
        [C039_FirstName] [nvarchar](255) NULL,
        [C040_MiddleInit] [nvarchar](255) NULL,
        [C041_Zip_Address] [float] NULL,
        [C042_Enrollment_Status] [float] NULL,
        [C043_Gender] [nvarchar](255) NULL,
        [C044_Mother_High_Grade] [float] NULL,
        [C045_Father_High_Grade] [float] NULL,
        [C046_Cost_Of_Attend] [float] NULL,
        [C047_Exp_Family_Cont] [float] NULL,
        [C048_Tuit_Exempt_Waiv] [float] NULL,
        [C049_Categorical_Aid] [float] NULL,
        [C050_Federal_PELL] [float] NULL,
        [C051_Federal_SEOG] [float] NULL,
        [C053_Tuition_Differential] [float] NULL,
        [C054_TEG] [float] NULL,
        [C055_Awd_Type] [float] NULL,
        [C056_MinistryRelated_Deg] [float] NULL,
        [C057_Sem_Of_Init_Awd] [float] NULL,
        [C058_Justification] [float] NULL,
        [C059_Hardship] [float] NULL,
        [C061_Restricted_Endowed] [float] NULL,
        [C062_GSF_Unrestricted] [float] NULL,
        [C063_Fed_VA_Ed_Benefits] [float] NULL,
        [C073_FED_Wk_Study] [float] NULL,
        [C074_TX_Wk_Study] [float] NULL,
        [C083_CAL] [float] NULL,
        [C085_PLUS_FEDERAL_DIRECT] [float] NULL,
        [C086_SUB_FED_DIR_LNS] [float] NULL,
        [C087_OTHER_LT_LOANS] [float] NULL,
        [C088_UNSUB_FED_DIR_LNS] [float] NULL,
        [C089_BOT] [float] NULL,
        [C091_TEACH_GRANT] [float] NULL,
        [C092_XFER_Or_FT] [float] NULL,
        [C095_StudentID] [float] NULL,
        [C097_Sel_Srv_Reg] [float] NULL,
        [C098_Defaulted] [float] NULL,
        [C099_FA_AH] [float] NULL,
        [C100_SP_AH] [float] NULL,
        [C101_SU_AH] [float] NULL,
        [C102_CUM_AH] [float] NULL,
        [C103_TCWS_And_AIF] [nvarchar](255) NULL,
        [C104_TCWS_Loc] [float] NULL,
        [C106_FAFSA_Date] [float] NULL,
        [C107_FA_Tuit_Fees] [float] NULL,
        [C108_SP_Tuit_Fees] [float] NULL,
        [C109_SU_Tuit_Fees] [float] NULL,
        [C112_TEG_SAP] [float] NULL
    )
"@
    
        Write-Verbose "Creating SQL Client Command"
        $cmd = New-Object System.Data.SqlClient.SqlCommand
    
        Write-Verbose "Set Connection"
        $cmd.Connection = $conn   
    
        Write-Verbose "Set command text"
        $cmd.CommandText = $sql

        Write-Verbose "Execute query"
        $cmd.ExecuteNonQuery() | Out-Null

        Write-Verbose "Closing connection" 
        $conn.Close()

        }#Process
    
    END {}#End
    
}#Function