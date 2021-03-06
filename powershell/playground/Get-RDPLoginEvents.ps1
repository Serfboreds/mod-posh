Function Get-RDPLoginEvents
{
    <#
        .SYNOPSIS
            Return Remote Desktop login attempts
        .DESCRIPTION
            This function returns login attempts from the Microsoft Windows TerminalServices RemoteConnectionManager 
            log. The specific events are logged as EventID 1149, and they are logged whether or not the user actually
            gets to the desktop.
        .PARAMETER ComputerName
            This is the NetBIOS name of the computer to pull events from.
        .PARAMETER Credentials
            A user account with the ability to retreive these events.
        .EXAMPLE
            Get-RDPLoginEvents -Credentials $Credentials |Export-Csv -Path C:\logfiles\RDP-Attempts.csv
            
            Description
            -----------
            This example show piping the output of the function to Export-Csv to create a file suitable for import
            into Excel, or some other spreadsheet software.
        .EXAMPLE
            Get-RDPLoginEvents -Credentials $Credentials -ComputerName MyPC |Format-Table

            SourceNetworkAddress        Domain           TimeCreated                User
            --------------------        ------           -----------                ----
            192.168.1.1                 MyPC...          4/30/2011 8:20:02 AM       Administrator...
            192.168.1.1                 MyPC...          4/28/2011 4:53:01 PM       Administrator...
            192.168.1.1                 MyPC...          4/21/2011 2:01:42 PM       Administrator...
            192.168.1.1                 MyPC...          4/19/2011 11:42:59 AM      Administrator...
            192.168.1.1                 MyPC...          4/19/2011 10:30:52 AM      Administrator...

            Description
            -----------
            This example shows piping the output to Format-Table
        .NOTES
            The Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational needs to be enabled
            The user account supplied in $Credentials needs to have permission to view this log
            No output is returned if the log is empty.
        .LINK
    #>
    [cmdletbinding()]    
    Param
        (
            [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
            $ComputerName,
            $Credentials,
            $EventID = 1149,
            $LogName = 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'
        )
    Begin
    {
        $LoginAttempts = @()
        }
    Process
    {
        Foreach ($Computer in $ComputerName)
        {
            Write-Verbose "Checking $($Computer)"
            try
            {
                if (Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue)
                {
                    $Events = Get-WinEvent -LogName $LogName -ComputerName $ComputerName -Credential $Credentials  -ErrorAction SilentlyContinue `
                        |Where-Object {$_.ID -eq $EventID}
                    if ($Events.Count -ne $null)
                    {
                        foreach ($Event in $Events)
                        {
                            $LoginAttempt = New-Object -TypeName PSObject -Property @{
                                ComputerName = $Computer
                                User = $Event.Properties[0].Value
                                Domain = $Event.Properties[1].Value
                                SourceNetworkAddress = [net.ipaddress]$Event.Properties[2].Value
                                TimeCreated = $Event.TimeCreated
                                }
                            $LoginAttempts += $LoginAttempt
                            }
                        }
                    }
                }
            catch
            {
                }
            }
        }
    End
    {
        Return $LoginAttempts
        }
    }