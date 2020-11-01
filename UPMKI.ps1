<#
.SYNOPSIS
Reads a Citrix User Profile Management (UPM) file and displays the logon and logoff times.
.PARAMETER UPMLogfile
Path to the UPM logfile 
.EXAMPLE
& '.\UPMKI.ps1' -UPMLogfile upm.log

Reads upm.log and outputs login and logoff times. Default threshold is 20 seconds.
.EXAMPLE
& '.\UPMKI.ps1' -UPMLogfile upm.log -ThresholdLogin 15

Reads upm log and outputs login and logoff times. Every login above 15 seconds appears in red. 
.EXAMPLE
& '.\UPMKI.ps1' -UPMLogfile upm.log -ThresholdLogin 15 -ThresholdLogin 20

Reads upm log and outputs login and logoff times. Every login above 15 seconds and every logoff above 20 seconds appears in red.
.NOTES
Author: Patrick Matula (@p_matula) 01.11.2020
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory,HelpMessage="Path to UPM logfile")]
    [string]$UPMLogfile,
    [Parameter(Mandatory=$false, HelpMessage="Threshold for a good login time")]
    [int]$ThresholdLogin = 20,
    [Parameter(Mandatory=$false, HelpMessage="Threshold for a good logoff time")]
    [int]$ThresholdLogoff = 20
)

# verify file exists
if (Test-Path $UPMLogfile)
{
    [array]$results = @()
    Write-Debug -Message "The file: $UPMLogfile exists."

    try{
        foreach ($line in Get-Content $UPMLogfile)
        {
            
            if ($line -match "Finished Logon Processing|Finished Logoff Processing")
            {
                Write-Debug "The line: $line matches."
                $results += $line
            }
        }
    } Catch {
        Write-Output "This file is not readable."
    }

    #displays the results
    foreach ($line in $results)
    {
        if ($line -Match "Finished logon")
        {
            Write-Debug "Login threshold $ThresholdLogin"
            Write-Debug "Login Line: $line"
            $loginValue = $line.Split("<")[1].Split(">")[0]
            Write-Debug "Login value: $loginValue"
            if ([int]$loginValue -gt $ThresholdLogin)
            {
                Write-Host $line -ForegroundColor Red
            }
            else {
                Write-Host $line -ForegroundColor Green
            }
        }
        if ($line -match "Finished logoff")
        {
            Write-Debug "Logoff threshold $ThresholdLogoff"
            Write-Debug "Logoff Line: $line"
            $logoffValue = $line.Split("<")[1].Split(">")[0]
            Write-Debug "Logoff value: $logoffValue"
            if ([int]$logoffValue -gt $ThresholdLogoff)
            {
                Write-Host $line -ForegroundColor DarkRed
            }
            else {
                Write-Host $line -ForegroundColor DarkGreen
            }
        }
    }
}
else {
    Write-Output "This file does not exist."
    Write-Debug -Message "The file: $UPMLogfile does not exist."
}