<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Get-UserLogonTimes.ps1
        Created By : jspatton
        Date Coded : 12/16/2011 14:15:36
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Get-UserLogonTimes.ps1
#>
[cmdletBinding()]
Param
    (
        $SqlUser ,
        $SqlPass ,
        $SqlServer ,
        $SqlDatabase ,
        $SqlTable ,
        $Query = "SELECT * FROM [dbo].[$($SqlTable)]",
        [switch]$IntegratedSecurity
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        }
Process
    {
        try
        {
            $ErrorActionPreference = 'Stop'
            if ($IntegratedSecurity)
            {
                $SqlConn = New-Object System.Data.SqlClient.SqlConnection("Server=$($SqlServer);Integrated Security=true")
                }
            else
            {
                $SqlConn = New-Object System.Data.SqlClient.SqlConnection("Server=$($SqlServer);Database=$($SqlDatabase);Uid=$($SqlUser);Pwd=$($SqlPass)")
                }
            $SqlConn.Open()
            $DataSet = New-Object System.Data.DataSet
            $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter ($Query, $SqlConn)
            $Adapter.Fill($DataSet) |Out-Null
            $Table = New-Object System.Data.DataTable $SqlTable
            $Table = $DataSet.Tables[0]
            $SqlConn.Close()
            }
        catch
        {
            Write-Verbose $Error[0].Exception.Message
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Error[0].Exception.Message
            }
       }
End
    {
        Return $Table
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }
