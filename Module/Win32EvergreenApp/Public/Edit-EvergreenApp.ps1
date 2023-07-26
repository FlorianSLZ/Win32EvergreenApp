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
        [parameter(Mandatory = $true, HelpMessage = "Local Evergreen App to edit, which you can get with Get-LatesInstaller.")]
        [ValidateNotNullOrEmpty()]
        [array]$App, 
        
        [parameter(Mandatory = $true, HelpMessage = "JSON with all variables for the App")]
        [ValidateNotNullOrEmpty()]
        [array]$JSON, 

        [parameter(Mandatory = $false, HelpMessage = "Local repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = "$([Environment]::GetFolderPath("MyDocuments"))\Win32EvergreenApp"
    )

    $global:RepoPath = $RepoPath

    Write-Verbose "RepoPath set to: $RepoPath"
    
    

    $JSON | ConvertTo-Json | Out-File "$AppSavePath\AppInfo.json" -Force 



}
