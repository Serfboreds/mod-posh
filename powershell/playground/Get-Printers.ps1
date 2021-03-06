# Depends on .Net 3.5 at least.
# If it's not installed, add-type line will throw file not found exception.

$host.Runspace.ThreadOptions = "ReuseThread"
Try
{
    Add-Type -AssemblyName System.Printing
    $permissions = [System.Printing.PrintSystemDesiredAccess]::AdministrateServer
    $queueperms = [System.Printing.PrintSystemDesiredAccess]::AdministratePrinter
    $server = new-object System.Printing.PrintServer -argumentList $permissions
    $queues = $server.GetPrintQueues(@([System.Printing.EnumeratedPrintQueueTypes]::Shared))
    }
Catch
{
    Write-Warning ".Net feature not installed."
    }
$Printers = @()
foreach ($queue in $queues)
{
    Try
    {
        $Result = Test-Connection -ComputerName $queue.QueuePort.Name -Count 1 -ErrorAction Stop
        $ThisPrinter = New-Object -TypeName PSObject -Property @{
            Name = $queue.Name
            Driver = $queue.QueueDriver.Name
            Port = $queue.QueuePort.Name
            IPV4Address = $Result.IPV4Address
            ShareName = $queue.ShareName
            }
        $Printers += $ThisPrinter
        }
    Catch
    {
        }
}