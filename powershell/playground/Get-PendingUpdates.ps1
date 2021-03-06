Function Get-PendingUpdates
    {
        <#
            .SYNOPSIS
                Retrieves the updates waiting to be installed from WSUS
            .DESCRIPTION
                Retrieves the updates waiting to be installed from WSUS
            .PARAMETER ComputerName
                Computer or computers to find updates for.
            .EXAMPLE
                Get-PendingUpdates 
                Description
                -----------
                Retrieves the updates that are available to install on the local system
            .NOTES
                Author: Boe Prox
                Date Created: 05Mar2011
                RPC Dynamic Ports need to be enabled on inbound remote servers.
        #> 

        Param
            (
                [Parameter(ValueFromPipeline = $True)]
                [string]$ComputerName
            )
        
        Begin 
            {
            }
        Process 
            {
                ForEach ($Computer in $ComputerName) 
                    {
                        If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) 
                            {
                                Try 
                                {
                                    $Updates =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$Computer))
                                    $Searcher = $Updates.CreateUpdateSearcher() 
                                    $searchresult = $Searcher.Search("IsInstalled=0")     
                                }
                                Catch 
                                {
                                Write-Warning "$($Error[0])"
                                Break
                                } 
                            }
                    }
            }
        End 
            {
                Return $SearchResult.Updates
            }
    }