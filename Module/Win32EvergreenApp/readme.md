|Florian Salzmann|[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)|
|----------------|-------------------------------|

# Win32EvergreenAPP 
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Win32EvergreenAPP)

This Module provides a set of functions to manage Evergreen Win32 packages locally and upload them to Intune. The script is designed to simplify the process of adding, updating, and uploading Evergreen Apps to Intune.

## Installing the module from PSGallery

The IntuneWin32App module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/Win32EvergreenAPP). Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name Win32EvergreenAPP
```

## Import the module for testing

As an alternative to installing, you chan download this Repository and import it in a PowerShell Session. 
*The path may be different in your case*
```PowerShell
Import-Module -Name "C:\GitHub\Win32EvergreenAPP\Module\Win32EvergreenAPP" -Verbose -Force
```

## Module dependencies

IntuneDeviceInventory module requires the following modules, which will be automatically installed as dependencies:
- IntuneWin32App
- Evergreen

