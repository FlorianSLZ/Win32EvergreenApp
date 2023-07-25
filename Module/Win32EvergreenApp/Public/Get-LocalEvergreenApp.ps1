function Get-LocalEvergreenApp()
{
    <#
    .SYNOPSIS
        Get local Evergreen Apps

    .DESCRIPTION
        Get local Evergreen Apps
        
    .PARAMETER Multiple
        Allows to select multiple Apps instead of one. 


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Allows to select multiple Apps instead of one.")]
        [ValidateNotNullOrEmpty()]
        [switch]$Multiple, 

        [parameter(Mandatory = $false, HelpMessage = "Get all local present Apps. ")]
        [ValidateNotNullOrEmpty()]
        [switch]$All, 

        [parameter(Mandatory = $false, HelpMessage = "Local Name of the App/Folder")]
        [ValidateNotNullOrEmpty()]
        [switch]$AppName,

        [parameter(Mandatory = $false, HelpMessage = "Local repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = "$([Environment]::GetFolderPath("MyDocuments"))\Win32EvergreenApp"

    )

    if($All)
    {
        $AllAppFolders = Get-ChildItem $RepoPath -Directory
    }
    elseif($Multiple)
    {
        $AllAppFolders = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Multiple
    }
    else
    {
        $AllAppFolders = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Single
    }

    return $AllAppFolders
}
