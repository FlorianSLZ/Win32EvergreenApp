function Get-LatesInstaller()
{
    <#
    .SYNOPSIS
        Get lates installer from Evergreen

    .DESCRIPTION
        Get lates installer from Evergreen
        
    .PARAMETER EvergreenApp
        EvergreenApp you can get by callin Get-EvergreenApp -Name AppName


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "EvergreenApp you can get by callin Get-EvergreenApp -Name AppName")]
        [ValidateNotNullOrEmpty()]
        [array]$EvergreenApp,

        [parameter(Mandatory = $false, HelpMessage = "Local repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = "$([Environment]::GetFolderPath("MyDocuments"))\Win32EvergreenApp"

    )

    if(!$EvergreenApp)
    {
        $AppFolder = Get-LocalEvergreenApp
        $AppInfo = Get-Content -Raw -Path "$($AppFolder.FullName)\AppInfo.json" | ConvertFrom-Json

        $EvergreenApp = Get-EvergreenApp -Name $AppInfo.EvergreenName | Where-Object { 
            $_.Type -eq $AppInfo.Type `
            -and $_.Ring -eq $AppInfo.Ring `
            -and $_.Channel -eq $AppInfo.Channel `
            -and $_.Platform -eq $AppInfo.Platform `
            -and $_.Release -eq $AppInfo.Release `
            -and $_.Architecture -eq $AppInfo.Architecture `
            -and $_.Language -eq $AppInfo.Language 
        }
    }

    if($EvergreenApp.Version -gt $AppInfo.Version){
        Write-Verbose "Newer Version aviable. 
        Current:    $($AppInfo.Version) 
        New:        $($EvergreenApp.Version)"

        if($Update)
        {
            Add-EvergreenApp -UpdateApp $EvergreenApp
        }
        else
        {
            return $EvergreenApp
        }
        
    }
    else
    {
        Write-Waring "No new Version aviable."
    }

}
