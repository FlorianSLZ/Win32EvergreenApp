function Add-EvergreenApp()
{
    
    <#
    .SYNOPSIS
        Add and update local Evergreen Win32 Packages

    .DESCRIPTION
        Add and update local Evergreen Win32 Packages
        
    .PARAMETER UpdateApp
        Local Evergreen APp to update, which you can get with Get-LatesInstaller.

    .PARAMETER RepoPath
        Local Evergreen APp to update, which you can get with Get-LatesInstaller.


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Local Evergreen App to update, which you can get with Get-LatesInstaller.")]
        [ValidateNotNullOrEmpty()]
        [array]$UpdateApp, 

        [parameter(Mandatory = $false, HelpMessage = "Local repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = "$([Environment]::GetFolderPath("MyDocuments"))\Win32EvergreenApp",

        [parameter(Mandatory = $false, HelpMessage = "GitHub template URL")]
        [ValidateNotNullOrEmpty()]
        [string]$TemplateURL = "https://github.com/FlorianSLZ/Win32EvergreenApp/raw/main/_template/_template.zip"
    )

    $global:RepoPath = $RepoPath

    Write-Verbose "RepoPath set to: $RepoPath"
    
    if($Update)
    {
        $App2Add = $UpdateApp
    }
    else
    {
        if(!$(Test-Path "$RepoPath\_template"))
        {
            $localZIP = "$env:temp\_template.zip"
            (New-Object System.Net.WebClient).DownloadFile($TemplateURL, $localZIP)
            Expand-Archive $localZIP "$RepoPath\_template"
            Remove-Item $localZIP
        }
        $AppInfo = Get-Content "$RepoPath\_template\AppInfo.json" -Raw | ConvertFrom-Json
    
        $App2search = Read-Host "Which App would you like to add?"
        $AppAviable = Find-EvergreenApp -Name $App2search
        $App2addAll = $AppAviable | Out-GridView -OutputMode Single -Title "Which one do you want to add?"

        $AppInfo.Name          = $App2addAll.Application
        $AppInfo.EvergreenName = $App2addAll.Name

        $App2Add = Get-EvergreenApp -Name $App2addAll.Name | Out-GridView -OutputMode Single -Title "Which Version would you like to add?"
    }
    

    $AppInfo.Version = $App2Add.Version
    $AppInfo.Platform = $App2Add.Platform
    $AppInfo.Channel = $App2Add.Channel
    $AppInfo.Ring = $App2Add.Ring
    $AppInfo.Release = $App2Add.Release
    $AppInfo.Architecture = $App2Add.Architecture
    $AppInfo.Type = $App2Add.Type
    $AppInfo.Language = $App2Add.Language

    if($AppInfo.Language){$Language = $AppInfo.Language}
    else{$Language = "MUI"}
    $AppSavePath = "$RepoPath\$($AppInfo.Name) $($AppInfo.Architecture) $Language"

    New-Item -Type Directory -Path $AppSavePath -Force | Out-Null
    Copy-Item -Path "$RepoPath\_template\*" -Destination "$AppSavePath\" -Recurse -Container -Force

    # Safe Installer
    $AppInstaller = $App2Add | Save-EvergreenApp -CustomPath "$AppSavePath\Files"
    $AppInfo.Installer = $AppInstaller.Name

    $AppInfo | ConvertTo-Json | Out-File "$AppSavePath\AppInfo.json" -Force 



}
