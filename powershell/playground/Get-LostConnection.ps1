<#
    .SYNOPSIS
        Create an XML file noting the time the computer lost network connectivity.
    .DESCRIPTION
        This script works in conjunction with an Event Trigger on a Windows
        Server 2008 box. The code is designed for Windows Server 2008 R2, but can run
        against a vanilla Windows Server 2008 install.
        
        The output of this script is an XML file that notes the time at which the 
        server lost network connectivity. The assumption is that when the server
        comes back online, a second trigger will read in this file and build a new
        file noting that time the server came online, and the amount of time the
        server was offline.
        
        If you are running this on an Windows Server installation that is not at
        least 2008 R2, please see the "OS Version Notes" in the Notes section of
        this help file. You will need to pass in the EventID and EventLog 
        parameters at runtime as in Example #2.
    .PARAMETER EventID
        The EventID that represents when the network connection was lost.
    .PARAMETER LogPath
        A path to where the XML files should be stored. This path will be created
        if it doesn't exist.
    .PARAMETER EventLog
        The name of the EventLog to query.
    .EXAMPLE
        .\Get-LostConnection.ps1
        
        Description
        -----------
        This is the syntax of the command as run against a Windows Server 2008 R2 Server
    .EXAMPLE
        .\Get-LostConnection.ps1 -EventID 4202 -LogName System
        
        Description
        -----------
        This is the syntax of the command as run against a Windows Server 2003 Server.
    .NOTES
        ScriptName : Get-LostConnection.ps1
        Created By : jspatton
        Date Coded : 10/27/2011 13:35:50
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        OS Version Notes
        ----------------
        Windows Server 2003
            EventID = 4202
            LogName = System
        Windows Server 2008
            EventID = 4202 *
            LogName = System
        Windows Server 2008 R2
            EventID = 10001
            LogName = Microsoft-Windows-NetworkProfile/Operational
            
        * - Unable to confirm that 4202 (Disconnect) actually exists on vanilla Windows 2008
        
        Originally script was set to check EventID 4, but it seems that may be a Dell specific
        event code. I was unable to locate a definition of the Event Source l2nd, but all
        references point to Broadcom Network gear in Dell PowerEdge servers. After I realized
        this minor issue, I found the Networkprofile log, and should be able to use it, although
        that log doesn't actually exist in vanilla Windows Server 2008.
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Get-LostConnection.ps1
#>
Param
    (
        $EventID = 10001,
        $LogPath = 'C:\LogFiles',
        $EventLog = 'Microsoft-Windows-NetworkProfile/Operational'
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
        try
        {
            $Events = Get-WinEvent -LogName $EventLog |Where-Object {$_.id -eq $EventID}
            }
        catch
        {
            }
        }
Process
    {
        if ($Events.Count -eq $null)
        {
            $Report = New-Object -TypeName PSobject -Property @{
                }
            }
        else
        {
            $Report = New-Object -TypeName PSobject -Property @{
                }
            }
        $FileName = "EventID-$($EventID)-$((get-date -format "yyyMMdd-hhmmss")).xml"
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        if ((Test-Path -Path $LogPath) -eq $false)
        {
            New-Item $LogPath -ItemType Directory 
            }
        Export-Clixml -Path "$((Get-Item $LogPath).FullName)$FileName"
        }