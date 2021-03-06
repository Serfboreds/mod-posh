<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Get-LogonEvents.ps1
        Created By : jspatton
        Date Coded : 12/15/2011 17:03:48
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Get-LogonEvents.ps1
#>
Param
    (
    [string]$ComputerName
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
        $SecurityLogs = Get-WinEvent -LogName Security -Credential (Get-Credential) -ComputerName $ComputerName
        $LogonEvents = $SecurityLogs |Where-Object {$_.Id -eq 4624} 
        $FilteredEvents = @()
        foreach ($LogonEvent in $LogonEvents)
        {
            $ThisEvent = New-Object -TypeName PSObject -Property @{
                SecurityID = $LogonEvent.Properties[4].Value
                AccountName = $LogonEvent.Properties[5].Value
                AccountDomain = $LogonEvent.Properties[6].Value
                LogonType = $LogonEvent.Properties[8].Value
                Workstation = $LogonEvent.Properties[17].Value
                IPAddress = $LogonEvent.Properties[18].Value
                TimeCreated = $LogonEvent.TimeCreated
                }
            $FilteredEvents += $ThisEvent
            }
        $FilteredEvents |Where-Object {$_.AccountDomain -eq "HOME"} |Format-Table -AutoSize
        foreach ($FilteredEvent in $FilteredEvents)
        {
            [string]$Workstation = nslookup $FilteredEvent.IPAddress |Select-String Name
            $Workstation.Replace('Name:    ','')
            New-Object -TypeName PSObject -Property @{
                AccountName = $FilteredEvent.AccountName
                Workstation = $Workstation
                IP = $FilteredEvent.IPAddress
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }