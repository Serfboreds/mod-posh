Function Set-ShutdownMethod
{
    <#
    #>
    
    PARAM
    (
    [string]$UserName,
    [string]$ServerName,
    [string]$ShutdownMethod
    )
    
    Begin
    {
    }
    
    Process
    {
    “(gwmi win32_operatingsystem -ComputerName ComputerName -cred (get-credential)).Win32Shutdown(4)”
    (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ServerName -Credential $Credentials).
    }
    
    End
    {
    }
}