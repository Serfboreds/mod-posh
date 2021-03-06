$Members = Get-ADGroupMembers -UserGroup "ENGR Lab Users" -UserDomain "LDAP://DC=home,DC=ku,DC=edu"

$alphabet = @()
$Breakdown = @()  
for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)
{
    $alphabet += [char]$c
    }
foreach($Letter in $alphabet)
{
    $Counter=$null
    foreach($Member in $Members |Where-Object {$_.name -like "$($Letter)*"})
    {
        $Counter++
        }
    $ThisLetter = New-Object -TypeName PSObject -Property @{
        Letter = $Letter
        Count = $Counter
        }
    # Write-Output "$($Letter)'s: $($Counter)"
    $Breakdown += $ThisLetter
    }