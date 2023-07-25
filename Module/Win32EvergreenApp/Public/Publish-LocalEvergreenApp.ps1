function Publish-LocalEvergreenApp()
{
    <#
    .SYNOPSIS
        Upload local Evergreen Apps to Intune

    .DESCRIPTION
        Upload local Evergreen Apps to Intune
        
    #>

    param (

        [parameter(Mandatory = $false, HelpMessage = "EvergreenApp you can get by callin Get-LocalEvergreenApp")]
        [ValidateNotNullOrEmpty()]
        [array]$LocalEvergreenApp,

        [parameter(Mandatory = $false, HelpMessage = "Allows to select multiple Apps instead of one.")]
        [ValidateNotNullOrEmpty()]
        [switch]$Multiple

    )

    if($LocalEvergreenApp)
    {
        Connect-MSIntuneGraph 

        Write-Host "Processing App: $($LocalEvergreenApp.Name) " -ForegroundColor Cyan 

        # read App info
        $AppInfo = Get-Content -Raw -Path "$($LocalEvergreenApp.FullName)\AppInfo.json" | ConvertFrom-Json

        # Remove old intunwwins
        Remove-Item "$($LocalEvergreenApp.FullName)\*.intunewin"

        # Create intunewin file
        $IntuneWinNEW = New-IntuneWin32AppPackage -SourceFolder $($LocalEvergreenApp.FullName) -SetupFile $($AppInfo.InstallFile) -OutputFolder $($LocalEvergreenApp.FullName) -Force
        Rename-Item -Path $IntuneWinNEW.Path -NewName "$($AppInfo.Name).intunewin"

        $IntuneWinFile = (Get-ChildItem $LocalEvergreenApp.FullName -Filter "*.intunewin").FullName

        # Create requirement rule for all platforms and Windows 10 2004
        $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "x64" -MinimumSupportedWindowsRelease "W10_2004"

        # Registry detection
        if($AppInfo.detection.Registry){
            $DetectionRule = New-IntuneWin32AppDetectionRuleRegistry -StringComparison `
                                -KeyPath $($AppInfo.detection.Registry.KeyPath).replace("AppName", "$($AppInfo.Name)") `
                                -ValueName $($AppInfo.detection.Registry.Name) `
                                -StringComparisonOperator $($AppInfo.detection.Registry.DetectionType) `
                                -StringComparisonValue $($AppInfo.detection.Registry.Value).replace("VersionNumber",$($AppInfo.Version))
        }
        
        
        # install command
        $InstallCommandLine = $AppInfo.InstallCmdLine
        $UninstallCommandLine = $AppInfo.UninstallCmdLine

        # App Description
        $AppDescription = $AppInfo | Select-Object Name, Version, Platform, Channel, Ring, Release, Architecture, Language


        # check for png or jpg
        $Icon_path = (Get-ChildItem "$($LocalEvergreenApp.FullName)\*" -Include "*.jpg", "*.png" | Select-Object -First 1).FullName
        if(!$Icon_path){
            $AppUpload = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $AppInfo.Name -Description $AppDescription -Publisher $AppInfo.Publisher -InstallExperience $($AppInfo.InstallExperience) -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine
        }else{
            $Icon = New-IntuneWin32AppIcon -FilePath $Icon_path
            $AppUpload = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $AppInfo.Name -Description $AppDescription -Publisher $AppInfo.Publisher -InstallExperience $($AppInfo.InstallExperience) -Icon $Icon -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine
        }

        Write-Verbose $AppUpload

        # Sleep to not overload Azure ;)
        Start-Sleep -s 10
    }
    else
    {
        if($Multiple)
        {
            $AllAppFolders = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Multiple
            $AllAppFolders | Publish-LocalEvergreenApp -LocalEvergreenApp $_
        }
        else
        {
            $SingleAppFolder = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Single
            Publish-LocalEvergreenApp -LocalEvergreenApp $SingleAppFolder
        }
    }



}
