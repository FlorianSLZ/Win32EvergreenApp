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

        [parameter(Mandatory = $false, HelpMessage = "Local Name of the App/Folder")]
        [ValidateNotNullOrEmpty()]
        [switch]$AppName

    )

    if($Multiple)
    {
        $AllAppFolders = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Multiple
    }
    else
    {
        $AllAppFolders = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Single
    }

    return $AllAppFolders
}
