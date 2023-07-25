Evergreen App Management Script (Win32EvergreenApp)
===============================

This script provides a set of functions to manage Evergreen Win32 packages locally and upload them to Intune. The script is designed to simplify the process of adding, updating, and uploading Evergreen Apps to Intune.

Prerequisites
-------------

Before using the script, make sure you have the following:

-   PowerShell 5.1 or later.
-   Intune tenant with appropriate permissions to upload Win32 apps.
-   PowerShell Modules:
Install-Module -Name "IntuneWin32App"
Install-Module -Name "Evergreen"

Function Details
----------------

### Add-EvergreenApp

This function allows you to add and update local Evergreen Win32 packages. It accepts the following parameters:

-   UpdateApp (optional): The local Evergreen App to update, which can be obtained using the `Get-LatesInstaller` function.
-   RepoPath (optional): The local repository path where the Apps and templates are stored. If not provided, it defaults to `MyDocuments\Win32EvergreenApp`.

### Get-LocalEvergreenApp

This function retrieves the local Evergreen Apps. It accepts the following parameter:

-   Multiple (optional): Allows selecting multiple Apps instead of just one.

### Get-LatesInstaller

This function retrieves the latest installer from Evergreen. It accepts the following parameter:

-   EvergreenApp (optional): The EvergreenApp you can get by calling `Get-EvergreenApp -Name AppName`.

### Upload-LocalEvergreenApp

This function uploads local Evergreen Apps to Intune. It accepts the following parameters:

-   LocalEvergreenApp (optional): The local Evergreen App to upload. If not provided, you can interactively select one or multiple Apps using the `-Multiple` switch.

How to Use
----------------
Place the script in your PowerShell environment or load it using the dot source method.

Call the functions based on your requirements. Below are some examples:
```
# Example 1: Add and update a single Evergreen App
Add-EvergreenApp -UpdateApp (Get-LatesInstaller)

# Example 2: Add and update a specific Evergreen App
$appToUpdate = Get-EvergreenApp -Name "YourApp"
Add-EvergreenApp -UpdateApp $appToUpdate

# Example 3: Get local Evergreen Apps and upload to Intune
Upload-LocalEvergreenApp

# Example 4: Get multiple local Evergreen Apps and upload to Intune
Upload-LocalEvergreenApp -Multiple
```


# Disclaimer
This script is provided as-is and without warranty. Use it at your own risk. The authors are not responsible for any damages or issues that may arise from using this script.
