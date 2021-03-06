<#
    .SYNOPSIS
        This script will copy the EOD XML receipts from the Central IT File Server to a local destination.
    .DESCRIPTION
        This script copies the School of Engineering's E-Commerce EOD XML receipts from the Central IT
        file server on campus to our local file server. These files contain a record of all transactions
        for the various events that the School hosts and has a fee for. A seperate script on the web
        server currently processes the files to send out email's to the respective event co-ordinators.
        
        This script is triggered from a daily task that runs on the management server. Currently the 
        management server is mgmt.company.com and the name of the task is Get EOD Report. The task
        is set to run at 9a Monday through Friday. Currently the Unviersity does not process transactions
        on the weekend, so it's possible you will receive error notifications over the weekend, these
        can be ignored.
    .PARAMETER Path
        This is the path to where the files are stored on the CFS server. The default
        path is \\cfs.company.com\share\department\ and was established for our use
        March 13, 2012.
    .PARAMETER Destination
        This is the path where the files are archived. As of this date, March 28, 2012, this location
        is on our file server \\fs.company.com\share\folder\. If this location changes either
        change the default in the script, or pass in the new location when the script is called.
    .PARAMETER EmailTo
        This is the email address of the admin when a problem is encountered. The email contains 
        information on what the problem is, and where to look in the logs to find the actual error
        message. Please update this to reflect the current administrator, or pass in the value
        when the script is called.
    .PARAMETER EmailSMTP
        This is the campus SMTP server, if the name of the server changes, please update this
        to reflect the current SMTP server name.
    .EXAMPLE
        .\Get-EodXml.ps1
        
        Description
        -----------
        This is the basic syntax of the script, all defaults are used in this instance. This would be
        the preferred method of calling the script.
    .EXAMPLE
        .\Get-EodXml.ps1 -Path \\new-fs.company.com\new-share\new-folder\ -Destination \\new-fs.company.com\new-share\new-folder\
        
        Description
        -----------
        This example shows passing an alternate path and destination into the script, this could be for testing
        purposes, it is recommended that you update the actual script with the new path and destination in the
        event of a change.
    .NOTES
        ScriptName : Get-EodXml.ps1
        Created By : jspatton
        Date Coded : 03/28/2012 09:06:05
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        This script is run under the context of our service account in the HOME domain, ecs-auto.
        This account has permissions to update the destination path on the file server. If the
        share changes, or server moves, please remember to add COMPANY\svc-acct to the list of accounts
        with permissions to modify, otherwise this script will fail.
        
        Several test's are performed as the script is run. At each stage, if there is a problem an
        event is generated on the host server, with the error message. Each entry will have a log
        source that is identical to the name of this script, which makes the errors easy to find. At
        the end of the script, each test is checked and a warning message is written if there was a failure
        and an email is sent to the deisgnated administrator to notify of the issue.
        
        This script is attached to a task, that is run at 9a each day. There will be errors most likely
        on Saturday and Sunday as the University doesn't process any transactions on those days. I did not
        adjust the code for the script to handle that, in case their policy changes. If you want, you could 
        limit the task to only run Monday through Friday to avoid the weekend errors that will appear, but
        again, if the University changes their policy you may not be notified of a potential issue.
        
        See the email below for details regarding the CFS location and contact information as of March 28, 2012.
        
        From: DeBoard, Jeremy Allen 
        Sent: Tuesday, March 13, 2012 9:27 AM
        To: Patton, Jeffrey S
        Subject: cfs info
 
        The server name is cfs.company.com. It’s a windows 2008 server OS. You can either ssh into it or use sftp. 
        Mapping the drive/folder is also possible.
 
        I’ve placed you in the schl_engineering group (your AD account) so you can access the file share. If anyone 
        else needs to be added, please let us know and we can get them added as well.
 
        There are two sides to the server – test and production. Below are the full paths to the folders you’ll have access to use:
 
        F:\tst_share\tst_drop_box – used for dropping off test files for processing. This is write only.
        F:\tst_share\schl_engineering_test – used for test file retrieval and short term storage. This is read/write.
        G:\prd_share\prd_drop_box – used for dropping off production files for processing. This is write only.
        G:\prd_share\schl_engineering – used for production file retrieval and short term storage. This is read/write.
 
        For mapping purposes, you may use the tst_share and prd_share folders. Files will be deleted from the both file 
        shares after 90 days. If you wish to keep any files longer than that, you’ll need to retrieve them and save them 
        locally. We will be continuing our archiving of files on the batch servers as before, so we’ll have any files that 
        are saved beyond 90 days.
 
        Jeremy DeBoard
        Computer Technician
        Network Operations Center
        KU Information Technology
        (785)864-0103
        www.technology.ku.edu

    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-EodXml.ps1
#>
[CmdletBinding()]
Param
    (
    [string]$Path = '\\cfs.company.com\share\department\',
    [string]$Destination = '\\fs.company.com\share\folder\',
    [string]$EmailTo = 'jspatton@ku.edu',
    [string]$EmailSMTP = 'smtp.ku.edu'
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
        $EmailFrom = 'ecs-auto@company.com'
        
        if ((Test-Path -Path $Path) -eq $true)
        {
            $SourceExist = $true
            try
            {

                $EODFiles = Get-ChildItem -Path $Path -Filter *.xml -ErrorAction Stop
                $Message = "Found $($EODFiles.Count) file(s) in $($Path)"
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
                $FilesFound = $true
                }
            catch
            {
                $Message = $Error[0].Exception.Message
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                $FilesFound = $false
                }
            }
        else
        {
            $CopyFiles = $false
            $SourceExist = $false
            $Message = "$($Path) not found, please verify that the correct path was used."
            $Message += "`nIf the path is accurate and you are receiving this message, please contact Central IT."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            }
        }
Process
    {
        if ($FilesFound -eq $true)
        {
            $EODFile = ($EODFiles |Sort-Object -Property LastWriteTime -Descending -ErrorAction SilentlyContinue)[0]
            if ((Test-Path -Path $Destination) -eq $true)
            {
                $DestinationExist = $true
                try
                {
                    Copy-Item -Path $EODFile.FullName -Destination $Destination -ErrorAction Stop
                    $Message = "Copied $($EODFile.Name) from $($Path) to $($Destination)"
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
                    $CopyFiles = $true
                    }
                catch
                {
                    $Message = $Error[0].Exception.Message
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                    $CopyFiles = $false
                    }
                }
            else
            {
                $DestinationExist = $false
                $Message = "$($Destination) not found, please verify that the correct path was used."
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                }
            }
        else
        {
            $Message = "No XML files found, skipping processing."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            }
        }
End
    {
        if ($CopyFiles -ne $true)
        {
            $Message = "There was a problem copying $($EODFile.Name) to $($Destination)."
            $Message += "`nPlease see the Application log on $(& hostname) for Event ID 101 with a Source of $($ScriptName) for more details."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "102" -EntryType "Warning" -Message $Message
            $EmailSubject = "$(& hostname) : Unable to copy EDO receipts"
            Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -Body $Message -SmtpServer $EmailSMTP
            }
        if ($FilesFound -ne $true)
        {
            $Message = "Please contact Central IT to determine the cause of the missing EDO XML files."
            $Message += "`nPlease see the Application on $(& hostname) log for Event ID 101 with a Source of $($ScriptName) for more details."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "102" -EntryType "Warning" -Message $Message
            $EmailSubject = "EOD XML Receipts not found"
            Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -Body $Message -SmtpServer $EmailSMTP
            }
        if ($SourceExist -ne $true)
        {
            $Message = "$($Path) not found, please verify that the correct path was used."
            $Message += "`nPlease see the Application log on $(& hostname) for Event ID 101 with a Source of $($ScriptName) for more details."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "102" -EntryType "Warning" -Message $Message
            $EmailSubject = "Source path not found"
            Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -Body $Message -SmtpServer $EmailSMTP
            }
        if ($DestinationExist -ne $true)
        {
            $Message = "$($Destination) not found, please verify that the correct path was used."
            $Message += "`nPlease see the Application log on $(& hostname) for Event ID 101 with a Source of $($ScriptName) for more details."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "102" -EntryType "Warning" -Message $Message
            $EmailSubject = "EOD XML Receipts not found"
            Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -Body $Message -SmtpServer $EmailSMTP
            }
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }