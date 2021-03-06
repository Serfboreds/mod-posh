<#
    .SYNOPSIS
        Get information from an LDAP server
    .DESCRIPTION
        This script performs OpenLdap query against specified Server.
    .PARAMETER user
        This is the full DN of the user to auth with such as:
            CN=user,OU=unit,OU=useraccounts,DC=company,DC=com
    .PARAMETER password
        The password for the user account to auth with
    .PARAMETER filter
        A standard LDAP search filter
    .PARAMETER server
        The hostname of the server which can include the port
    .PARAMETER path
        the LDAP path for the User account to authenticate with
    .PARAMETER base
        Search base path
    .EXAMPLE
        .\Get-OpenLdap.ps1
    .NOTES
        ScriptName : Get-OpenLdap.ps1
        Created By : jspatton
        Date Coded : 02/07/2012 16:43:02
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        I hijacked this code from PoshCode see link 2
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-OpenLdap.ps1
    .LINK
        http://poshcode.org/86
#>
[cmdletBinding()]
Param
    (
        $user,
        $password = $(Read-Host "Enter Password" -asSec),
        $filter,
        $server,
        $path,
        $base
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
        if($verbose)
        {
            $verbosepreference = "Continue"
            }

        $DN = "LDAP://$server/$path"
        $Search = "LDAP://$server/$base"
        Write-Verbose "DN = $DN"
        
        $auth = [System.DirectoryServices.AuthenticationTypes]::FastBind
        Write-Verbose "Auth = FastBind"
        
        $de = New-Object System.DirectoryServices.DirectoryEntry($DN,$user,(GetSecurePass $Password),$auth)
        Write-Verbose $de
        Write-Verbose "Filter: $filter"
        
        $ds = New-Object system.DirectoryServices.DirectorySearcher($de,$filter) 
        Write-Verbose $ds
        
        if($all)
        {
            Write-Verbose "Finding All"
            $ds.FindAll()
            }
        else
        {
            Write-Verbose "Finding One"
            $ds.FindOne()
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }