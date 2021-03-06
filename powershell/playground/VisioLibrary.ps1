Function Connect-VisioObject
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER FirstObj
        .PARAMETER SecondObj
        .EXAMPLE
        .NOTES
            FunctionName : Connect-VisioObject
            Created by   : jspatton
            Date Coded   : 01/04/2012 16:30:49
        .LINK
            http://scripts.patton-tech.com/wiki/PowerShell/Untitled1#Connect-VisioObject
    #>
    [cmdletbinding()]
    Param
        (
        $FirstObj, 
        $SecondObj
        )
    Begin
    {
        }
    Process
    {
        $shpConn = $pagObj.Drop($pagObj.Application.ConnectorToolDataObject, 0, 0)

        Write-Verbose "Connect its Begin to the 'From' shape:"
        $connectBegin = $shpConn.CellsU("BeginX").GlueTo($FirstObj.CellsU("PinX"))
        	
        Write-Verbose "Connect its End to the 'To' shape:"
        $connectEnd = $shpConn.CellsU("EndX").GlueTo($SecondObj.CellsU("PinX"))
        }
    End
    {
        }
    }

Function Add-VisioObject
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER MasterObj
        .PARAMETER Item
        .EXAMPLE
        .NOTES
            FunctionName : Add-VisioObject
            Created by   : jspatton
            Date Coded   : 01/04/2012 16:34:51
        .LINK
            http://scripts.patton-tech.com/wiki/PowerShell/Untitled1#Add-VisioObject
    #>
    [cmdletbinding()]
    Param
        (
        $MasterObj, 
        $Item
        )
    Begin
    {
        }
    Process
    {
        Write-Verbose "Adding $item"
        # Drop the selected stencil on the active page, with the coordinates x, y
        $shpObj = $pagObj.Drop($MasterObj, $x, $y)
        # Enter text for the object
        $shpObj.Text = $Item
        #Return the visioobject to be used
         }
    End
    {
       return $shpObj
       }
    }