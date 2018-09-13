<#
.SYNOPSIS
Script to check how in sync the time is on domain controllers and present results in a table.

.DESCRIPTION
Uses the standard W32TM /monitor command and then formats to a table
Can be easily adapted to send an email report. No parameters required
as it just discovers the domain controllers. Does not require special 
permissions, standard domain users account is enough.

#>

$W32TmResults = w32tm.exe /monitor
$w32TmParsed = $W32TmResults -split('[\r\n]')
[array] $TimeStatus = @()

foreach($w32TmLine in $w32TmParsed)
{
    Switch -Wildcard ($w32TmLine)
    {
        '*:123]:'{
            $global:objectTimeStatus = New-Object -TypeName PSCustomObject
            $ServerName = $w32TmLine.Substring(0, $w32TmLine.IndexOf("["))
            $objectTimeStatus | Add-Member -MemberType NoteProperty -Name Server -Value $ServerName
        }
        "*NTP:*"
        {
            if($w32TmLine -notlike '*NTP: error*')
            {
                [array] $StartChar = @("+", "-")
                $StartSub = $w32TmLine.IndexOfAny($StartChar)
                $TimeDrift = $w32TmLine.Substring($StartSub)
                $EndSub = $TimeDrift.IndexOf("s")
                $TimeDrift = $TimeDrift.Substring(0, $EndSub)
                $objectTimeStatus | Add-Member -MemberType NoteProperty -Name TimeDrift -Value $TimeDrift
                $objectTimeStatus | Add-Member -MemberType NoteProperty -Name Connected -Value $true
            }
            else
            {
                $objectTimeStatus | Add-Member -MemberType NoteProperty -Name Connected -Value $false
                $TimeStatus += $objectTimeStatus
            }
        }
        "*RefID:*"
        {
            $SourceTime = $w32TmLine.Substring(14)
            $intDelim = $SourceTime.IndexOf("[") -1
            $SourceTime = $SourceTime.Substring(0, $intDelim)
            $objectTimeStatus | Add-Member -MemberType NoteProperty -Name SourceServer -Value $SourceTime
        }
        "*Stratum:*"
        {
            $TimeStatus += $objectTimeStatus
        }
    }
}

$TimeStatus | sort Server