function Get-FinaidQuery {
  <#
      .SYNOPSIS
        Run a SQL Query and return results to pipeline
      .DESCRIPTION
        Runs a query against a SQL database and puts it back into the pipeline without formatting
      .PARAMETER table
        The query or statement to execute. Takes value from pipeline
      .PARAMETER Database
        Database name
      .PARAMETER Server
        Server name, IP address, or DNS
      .EXAMPLE
        ConvertFrom-ExcelToSQLInsert -TableName "RptCommon.dbo.Names" -Path C:\Users\zacharyburditt\Downloads\test.xlsx -UseMSSQLSyntax | Invoke-Query -server "webtools-new" -database "RptCommon"
    #>

    [CmdletBinding()]
    Param( [Parameter(ValueFromPipeLine = $true, Mandatory = $true)]$table,
    [Parameter(Mandatory = $true)]$database,
    [Parameter(Mandatory = $true)]$server
    )

        Write-Verbose "Creating SQL Connection Object"
        $conn = New-Object System.Data.SqlClient.SqlConnection

        Write-Verbose "Setting connection string"
        $SqlConnection = "server=$server;database=$database;Trusted_Connection=True;"
        $conn.ConnectionString = $SqlConnection
        
        Write-Verbose "Open connection"
        $conn.Open()

        Write-Verbose "Creating SQL Command Object"
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $conn

        #Financial Aid SQL script provided by Tim Shafer 
        #TO DO: read script from external file
        Write-Verbose "Define query"
        $sql = @"
        IF (SELECT OBJECT_ID('TEMPDB..#tblParameters_EOY')) Is Not NULL DROP TABLE #tblParameters_EOY
        CREATE TABLE #tblParameters_EOY(
             RowNbr Int Identity( 1, 1)
            ,FICE VarChar(6)
            ,yr VarChar(4)
            ,ReportCycle VarChar(1)
        )
        INSERT INTO #tblParameters_EOY
        SELECT 
             FICE = '003584'
            ,yr = Convert(VarChar(4), DatePart(year, GetDate()))
            ,CASE WHEN DATEPART(Month, GetDate()) < 5 THEN '1'
                  WHEN DATEPART(Month, GetDate()) < 9 THEN '2'
                  ELSE '3' END
        
        
        
        IF (SELECT OBJECT_ID('tempdb..#tblList')) Is Not NULL DROP TABLE #tblList
        CREATE TABLE #tblList(
             FADB_RECORD Char(441)
        )
        
        
        --  Detail Records
        INSERT INTO #tblList(
            FADB_RECORD
        )
        SELECT
            FADB_RECORD =
            'F' +
            tblP.FICE +
            tblP.ReportCycle +
            tblP.yr +
            --Right('000000000' + LTrim(Convert(VarChar(9), Replace(C005_SSN, '-', ''))), 9) +
            Right('000000000' + LTrim(Convert(VarChar(9), Convert(Int, C005_SSN) )), 9) +
            Right('0000000' + LTrim(Convert(VarChar(7), Convert(Int, IsNull(fadb.C006_Stdnt_Spouse_AGI, '0')))), 7) +
            Right('0000000' + LTrim(Convert(VarChar(7), Convert(Int, fadb.C007_Parent_AGI))), 7) +
            '00000' +                                                                   --  C008_TOP10PCT_SCHOLARSHIP = Nothing for LETU. Only Public schools.
            Right('00' + RTrim(LTrim(C009_Unmatched_Reason)), 2) +
            '00000' +                                                                   --  C010_TUIT_EXEMPT_AWD1 = Set to zeroes
            '00' +                                                                      --  C011_TUIT_EXEMPT_CODE1 = Set to zeroes
            '0' +                                                                       --  C012_TUIT_EXEMPT_IMPACT1 = Set to zeroes
            '00000' +                                                                   --  C013_TUIT_EXEMPT_AWD2 = Set to zeroes
            '00' +                                                                      --  C014_TUIT_EXEMPT_CODE2 = Set to zeroes
            '0' +                                                                       --  C015_TUIT_EXEMPT_IMPACT2 = Set to zeroes
            '00000' +                                                                   --  C016_TUIT_EXEMPT_AWD3 = Set to zeroes
            '00' +                                                                      --  C017_TUIT_EXEMPT_CODE3 = Set to zeroes
            '0' +                                                                       --  C018_TUIT_EXEMPT_IMPACT3 = Set to zeroes
            '00000' +                                                                   --  C019_TUIT_EXEMPT_AWD4 = Set to zeroes
            '00' +                                                                      --  C020_TUIT_EXEMPT_CODE4 = Set to zeroes
            '0' +                                                                       --  C021_TUIT_EXEMPT_IMPACT4 = Set to zeroes
            Right(' ' + IsNull(C022_Program_Level, ''), 1) +
            Right(' ' + IsNull(C023_Need_Analysis, ''), 1) +
            Right(' ' + IsNull(C024_Living_Arrangement, ''), 1) +
            Right(' ' + IsNull(C025_Ethnic_Origin, ''), 1) +
            Right(' ' + IsNull(C026_Race_1_White, ''), 1) +
            Right(' ' + IsNull(C027_Race_2_Black, ''), 1) +
            Right(' ' + IsNull(C028_Race_4_Asian, ''), 1) +
            Right(' ' + IsNull(C029_Race_5_Indian, ''), 1) +
            Right(' ' + IsNull(C030_Race_6_International, ''), 1) +
            Right(' ' + IsNull(C031_Race_7_Unknown, ''), 1) +
            Right(' ' + IsNull(C032_Race_8_Hawaiian, ''), 1) +
            Right(' ' + IsNull(C033_Classification, ''), 1) +
            Right(' ' + IsNull(C034_Dependency_Status, ''), 1) +
            SubString(Convert(VarChar(8), Convert(Int, fadb.C035_Date_Of_Birth)), 5, 2) +
                Right(Convert(VarChar(8), Convert(Int, fadb.C035_Date_Of_Birth)), 2) +
                 Left(Convert(VarChar(8), Convert(Int, fadb.C035_Date_Of_Birth)), 4) +
            --Replace(Convert(VarChar(10), Convert(Date, C035_Date_Of_Birth)), '-', '') +
            --SubString(Replace(Convert(VarChar(10), Convert(Date, C035_Date_Of_Birth)), '-', ''), 5, 4) +
            --SubString(Replace(Convert(VarChar(10), Convert(Date, C035_Date_Of_Birth)), '-', ''), 1, 4) +
            --SubString(fadb.C035_Date_Of_Birth, 5, 4) + SubString(fadb.C035_Date_Of_Birth, 1, 4) +
            Right(' ' + IsNull(C036_Residency, ''), 1)  +                                           --   SELECT C037_9Month_EFC FROM LETU_FADB1_20180216_0830 WHERE C037_9Month_EFC = '999999'
            Right('0000000' + LTrim(Convert(VarChar(7), IsNull(Convert(Int, IsNull(fadb.C037_9Month_EFC, '0')), 0))), 7) + --   UPDATE LETU_FADB1_20180216_0830 SET C037_9Month_EFC = '9999999' WHERE C037_9Month_EFC = '999999'
            Left(LTrim(RTrim(IsNull(C038_LastName, ''))) + SPACE(25), 25) +
            Left(LTrim(RTrim(IsNull(C039_FirstName, ''))) + SPACE(25), 20)+
            Left(LTrim(IsNull(C040_MiddleInit, '')) + ' ', 1) +
            CASE WHEN C041_Zip_Address Is Not Null And IsNumeric(C041_Zip_Address) = 1 THEN Left(RTrim(Convert(VarChar(9), Convert(Int, C041_Zip_Address))) + '000000000', 9) 
                 ELSE '000000000' END +
            Left(IsNull(C042_Enrollment_Status, '') + ' ', 1) + 
            Left(IsNull(C043_Gender, '') + ' ', 1) +
            Left(IsNull(C044_Mother_High_Grade, '') + ' ', 1) +
            Left(IsNull(C045_Father_High_Grade, '') + ' ', 1) +
            Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, fadb.C046_Cost_Of_Attend))), 6) +
            Right('0000000' + LTrim(Convert(VarChar(7), Convert(Int, fadb.C047_Exp_Family_Cont))), 7) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C048_Tuit_Exempt_Waiv))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C049_Categorical_Aid))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C050_Federal_PELL))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C051_Federal_SEOG))), 5) +
            '00000' +                                                                 --  C052_TPEG Not at LETU
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C053_Tuition_Differential))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C054_TEG))), 5) +
            Left(IsNull(C055_Awd_Type, '') + ' ', 1) +
            Left(IsNull(C056_MinistryRelated_Deg, '') + ' ', 1) + 
            Left(IsNull(C057_Sem_Of_Init_Awd, '') + ' ', 1) + 
            Left(IsNull(C058_Justification, '') + ' ', 1) + 
            Left(IsNull(C059_Hardship, '') + ' ', 1) +
            '00000' +                                                                   --  C060_HB3015_GandS   Use zero, per TW.           --  TEG NEED Survey: C31g_HB3015_GandS  = Not at LETU.
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C061_Restricted_Endowed))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C062_GSF_Unrestricted))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C063_Fed_VA_Ed_Benefits))), 5) +
            '00000' +                                                                   --  C064_Athletic_Amts
            '00000' +                                                                   --  C065_Stu_Dep_Schlr = FADB: C31l_STUDENT_DEP_SCHLR = Not at LETU. This is for Public schools.
            '00000' +                                                                   --  C066_Othr_Fed_SchlrNot at LETU, per WIT 198251 reply on 11/21/2017
            '00000' +                                                                   --  C067_Other_State_SchlrNot at LETU, per TW.    Othr_Schlr_Grant = IsNull(OtherSchlrGrant.AmtSum, 0)
            '00000' +                                                                   --  C068_Texas_Grant FADB: C31o_TEXAS_GRANT_PGM = Not at LETU. We do not have Texas Grant here.
            '00000' +                                                                   --  C069_TEOG   FADB: C31p_TEOG = Not at LETU.
            '0' +                                                                       --  C070_TEOG_TYPENot at LETU, per WIT 198251 reply on 11/21/2017
            '0' +                                                                       --  C071_Toward_TX_Awd Not at LETU, per WIT 198251 reply on 11/21/2017
            '0' +                                                                       --  C072_Toward_TX_Pthwy Not at LETU, per WIT 198251 reply on 11/21/2017
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C073_FED_Wk_Study))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C074_TX_Wk_Study))), 5) +
            '00000' + -- C075_Need_Based_Inst = ''                                                --  FADB: C32c_NEED_BASED_INST = Not at LETU.
            '00000' + -- C076_Americorps = ''                                                     --  FADB: C32d_AMERICORPS = Not at LETU.
            '00000' + -- C077_HB3015_WS = ''                                                      --  FADB: C32e_HB3015_WS = Not at LETU.
            '00000' + -- C078_TXWS_Mentorship = ''                                                --  FADB: C32f_TXWS_MENTORSHIP = Not at LETU.
            '00000' + -- C079_TASSP = ''                                                          --  FADB: C33a_TASSP = Not at LETU.
            '00000' + -- C080_Filler = ''                                                         --  FADB: C33b_FILLER = 
            '00000' + -- C081_Perkins_Loan …as of 1819, Fed Congress discontinued so this will always be zero in the future.    Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C081_Perkins_Loan))), 5) +
            '00000' + -- C082_Filler                                                              --  FADB: C33d_FILLER = 
            Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, fadb.C083_CAL))), 6) +
            '00000' + -- C084_Filler = ''
            Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, fadb.C085_PLUS_FEDERAL_DIRECT))), 6) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C086_SUB_FED_DIR_LNS))), 5) +
            Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, fadb.C087_OTHER_LT_LOANS))), 6) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C088_UNSUB_FED_DIR_LNS))), 5) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C089_BOT))), 5) +
            '000000' +  --  Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, fadb.C090_HB3015_Loans))), 6) +
            Right('00000' + LTrim(Convert(VarChar(5), Convert(Int, fadb.C091_TEACH_GRANT))), 5) +
            Right('000000' + IsNull(LTrim(Convert(VarChar(6), Convert(Int, fadb.C092_XFER_Or_FT))), '999999'), 6) +
            '000' +         --  C093_Enroll_Adj_COA = ''
            '000' +         --  C094_Enroll_Adj_TFC = ''
            Right('000000000' + LTrim(Convert(VarChar(9), Convert(Int, fadb.C095_StudentID))), 9)  +
            '0' +                           -- C096_Ctrl_Subst = '0'                                --  Zero. Not at LETU.
            Right('0' + IsNull(fadb.C097_Sel_Srv_Reg, ''), 1) +
            Right('0' + IsNull(fadb.C098_Defaulted, ''), 1) +
            Right('000' + LTrim(Convert(VarChar(3), Convert(Int, fadb.C099_FA_AH))), 3) +           --  Hold off on this. TW may be fixing these.   187 errors for just Fall. Zero errors for SP & SU.
            Right('000' + LTrim(Convert(VarChar(3), Convert(Int, fadb.C100_SP_AH))), 3) +
            Right('000' + LTrim(Convert(VarChar(3), Convert(Int, fadb.C101_SU_AH))), 3) +
            Right('0000' + LTrim(Convert(VarChar(4), Convert(Int, fadb.C099_FA_AH) + Convert(Int, fadb.C100_SP_AH) + Convert(Int, fadb.C101_SU_AH))), 4) +
            Right('00000' + LTrim(RTrim(Convert(VarChar, IsNull(C103_TCWS_And_AIF, '')))), 5) +                    --  Newly used 1st time 6/22/2018
            Left(LTrim(IsNull(C104_TCWS_Loc, '0')) + ' ', 1) +
            '0' +       --  C105_TCWS_MLoc = ''                                                     --  Not at LETU, per WIT 198251 reply on 11/21/2017
            --CASE WHEN C106_FAFSA_Date <> '00000000'
                 --THEN SubString(Replace(Convert(VarChar(10), Convert(Date, C106_FAFSA_Date)), '-', ''), 5, 4) +
                 --     SubString(Replace(Convert(VarChar(10), Convert(Date, C106_FAFSA_Date)), '-', ''), 1, 4)
                 --ELSE '00000000' END +
            --fadb.C106_FAFSA_Date +
            Right('00000000' + Convert(VarChar(8), Convert(Int, C106_FAFSA_Date)), 8) + 
            Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, IsNull(fadb.C107_FA_Tuit_Fees, '0')))), 6) +
            Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, IsNull(fadb.C108_SP_Tuit_Fees, '0')))), 6) +
            Right('000000' + LTrim(Convert(VarChar(6), Convert(Int, IsNull(fadb.C109_SU_Tuit_Fees, '0')))), 6) + 
            CASE WHEN tblP.ReportCycle = '1' THEN '0' ELSE '0' END + -- C110_TEG_SAP = ''                                     --  Not at LETU, per WIT 198251 reply on 11/21/2017
            CASE WHEN tblP.ReportCycle = '1' THEN '0' ELSE '0' END + -- C111_TEOG_SAP = ''                                    --  Not at LETU, per WIT 198251 reply on 11/21/2017
            --CASE WHEN tblP.ReportCycle = '1' And Convert(Int, fadb.C054_TEG) = 0 THEN '0'
            --     WHEN tblP.ReportCycle In ( '2', '3' ) THEN fadb.C112_TEG_SAP
            --     ELSE '0' END +
            RTrim(LTrim(Convert(VarChar(1), Convert(Int, IsNull(fadb.C112_TEG_SAP, 0.00))))) +
            '0'                                                                                                            --  Not at LETU. C113_Top_Ten_Pct
        --  SELECT fadb.* --    UPDATE FADB SET C047_Exp_Family_Cont = '9999999'
        FROM [$table] As fadb --group by fadb.C054_TEG order by fadb.C054_TEG
            INNER JOIN #tblParameters_EOY As tblP On tblP.RowNbr = tblP.RowNbr
        WHERE 1 = 1
            --  TW 2019-04-01 16:47 - Orange lines are students that need to be deleted from the report.
            And fadb.ID Not In ( 3119774,3126484,2128530,3132072,3119764,3014880,3134611,2128721,3120093,3137146,3134440,2091287,3127859,3123640,2112669,3095007,2112598,2124437,2124761 )
            --  TW 2019-04-02 11:07 - …I have already corrected the one error we had in the new spreadsheet (LETU_FADB1_20190402_1300.xlsx)… the student needs to be deleted, and it is a blue line through all his data…
            And fadb.ID Not In ( 2113531 )
        ORDER BY IsNull(fadb.C038_LastName, ''), IsNull(C039_FirstName, ''), IsNull(C040_MiddleInit, ''), Convert(VarChar(9), Convert(Int, fadb.C095_StudentID))
        --  SELECT * FROM #tblList ORDER BY SubString(FADB_RECORD, 104, 46), SubString(FADB_RECORD, 380, 8)-- WHERE FADB_RECORD Is NULL
        
        
        
        
        --  Header Record
        --  003584FAD00122018C044102681
        INSERT INTO #tblList(
            FADB_RECORD
        )
        SELECT
            FADB_RECORD =
            'HY2K' +        --  Header row indicator
            tblP.FICE +     --  FICE Code/6-digit school identifier
            'FAD001' +
            tblP.ReportCycle +
            Convert(VarChar(4), tblP.yr) +    --  Reporing year/must be the calendar year of the three reports
            'C0441' +
            Right('00000' + LTrim(Convert(VarChar(5), fadb.[RowCount])), 5)
        FROM #tblParameters_EOY As tblP
            LEFT JOIN ( SELECT
                             RowNbr = 1
                            ,[RowCount] = Count(*)
                        FROM #tblList ) As fadb On fadb.RowNbr = fadb.RowNbr
        
        
        
        --  
        --  Trailer Record
        INSERT INTO #tblList(      --  DELETE FROM #tblList WHERE TEG_RECORD Like N'EOF1%'
            FADB_RECORD
        )
        SELECT
            FADB_RECORD =
            'EOF1' +     --  Must be "EOF"
            Right('00000' + LTrim(Convert(VarChar(5), fadb.[RowCount])), 5)
        FROM #tblParameters_EOY As tblP
            LEFT JOIN ( SELECT
                             RowNbr = 1
                            ,[RowCount] = Count(*)
                        FROM #tblList
                        WHERE Left(FADB_RECORD, 1) Not In ( 'H', 'E' ) ) As fadb On fadb.RowNbr = fadb.RowNbr
        
        
        
        SELECT FADB_RECORD
        FROM #tblList
        ORDER BY CASE WHEN LEFT(FADB_RECORD, 1) = 'H' THEN '0'
                      WHEN LEFT(FADB_RECORD, 1) = 'F' THEN '1'
                      WHEN LEFT(FADB_RECORD, 1) = 'E' THEN '2'
                 END + 
                 SubString(FADB_RECORD, 104, 46) +
                 SubString(FADB_RECORD, 380, 9)
"@
        Write-Verbose "Set command text to sql statement"
        $cmd.CommandText = $sql

        Write-Verbose "Reading from query"
        $reader = $cmd.ExecuteReader()

        #Loop through results
        Write-Verbose "Spinning through the results"
        while ($reader.read()) {
            Write-Verbose "Assign column name"
            $props = @{'RowNbr' = $reader['FADB_RECORD']}

            write-verbose "Setting new object to columns"
            New-Object -TypeName PSObject -Property $props
        }#while
        Write-Verbose "Closing connection"
        $conn.Close()

}#Get-FinaidQuery