$DestPath = "c:\offline.xml"
$webClient = new-object System.Net.WebClient
$webClient.DownloadFile("http://www.microsoft.com/web/webpi/2.0/WebProductList.xml",$DestPath)
[xml]$WebPIFeed = Get-Content $DestPath
foreach($entry in $WebPIFeed.feed.entry)
{
    Write-Host $entry.productid 

        foreach($installer in $entry.installers.installer)
        {
            if($installer.installerFile.installerURL)
            {
                if($installer.languageId -eq "en")
                {
                    [string]$url = $installer.installerFile.installerURL
                    $lastslash = $url.LastIndexOf("/")+1
                    $filenamelen = $url.Length-$lastslash
                    $filename = $url.Substring($lastslash,$filenamelen)
                    $filename = "D:\OfflineWebPI\$filename"
                    Write-Host "Downloading $filename"
#                    $clnt = New-Object System.Net.WebClient
#                    $clnt.DownloadFile($url,$filename)
                    
                    $installer.installerFile.installerURL = $filename
                }
            }
        }
}
$WebPIFeed.Save("C:\WebProductListNew.xml") 
