
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$SettingsFile = ".\settings.json"


#create window
$inputXML = Get-Content ".\xaml\main.xaml"
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
   }
}

# Get-Variable var_*
############################################ Functions ####################################################

function Show-AppGridView(){
    # Populate the DataGrid
    $AllLocalEvergreenApps = Get-LocalEvergreenApp -All
    $var_dataGrid_EvergreenApps.ItemsSource = $AllLocalEvergreenApps
}


function Show-SettingsPopup {
    # XAML for the popup window
    $popupXaml = Get-Content ".\xaml\settings.xaml"

    if(!$(Test-Path $SettingsFile))
    {
        # initali settings
        $AppSettings = @{
            "RepoPath" = "$([Environment]::GetFolderPath("MyDocuments"))\Win32EvergreenApp"
            "IntuneTenant" = "YourPrefix.onmicrosoft.com"
        }
    }
    else {
        $AppSettings = Get-Content -Raw -Path $SettingsFile | ConvertFrom-Json
    }

    # Convert the XAML to a WPF Window object
    $xamlContext = [Windows.Markup.XamlReader]::Parse($popupXaml)

    # Get controls from the XAML
    $input_repoPath = $xamlContext.FindName('input_repoPath')
    $input_tenantID = $xamlContext.FindName('input_tenantID')
    $btn_Save = $xamlContext.FindName('btn_Save')

    # Event handler for the OK button
    $btn_Save.Add_Click({
        # You can access the input values using $input_repoPath.Text and $input_tenantID.Text here.
        # Add your logic to handle the input fields.
        $AppSettings.RepoPath = $input_repoPath.Text
        $AppSettings.IntuneTenant = $input_tenantID.Text

        $AppSettings | ConvertTo-Json | Out-File $SettingsFile -Force 

        $xamlContext.Close()
    })

    $input_repoPath.Text = $AppSettings.RepoPath
    $input_tenantID.Text = $AppSettings.IntuneTenant

    # Show the popup
    $null = $xamlContext.ShowDialog()
}

function Show-JsonEditor {
    param (
        [string]$AppInfo
    )

    # Read the XAML content from the file
    $xamlFilePath = ".\xaml\editApp.xaml"
    $xamlContent = Get-Content -Path $xamlFilePath -Raw

    # Load the XAML content and create a form object
    $JsonEditorWindow = [Windows.Markup.XamlReader]::Parse($xamlContent)

    # Function to handle the Save button click event
    $buttonSave_Click = {
        # Get the JSON properties from the textboxes and convert them to a PowerShell object
        $jsonObject = @{
            "Name" = $JsonEditorWindow.textbox_Name.Text
            "EvergreenName" = $JsonEditorWindow.textbox_EvergreenName.Text
            # Add other JSON properties here
        }

        # Convert the PowerShell object back to JSON format
        $updatedJson = $jsonObject | ConvertTo-Json -Depth 10

        # Do something with the updated JSON, e.g., write to a file, display, etc.
        Write-Host $updatedJson
    }

    # Assign the script block to the Save button click event
    $JsonEditorWindow.button_Save.Add_Click($buttonSave_Click)

    # Show the form
    $JsonEditorWindow.ShowDialog()
}


  
###########################################################################################################



$var_button_addEvergreenApp.Add_Click{
    # call add function
    Add-EvergreenApp -Search $var_text_addApp.Text

    # re-load apps for overview
    Show-AppGridView
}

$var_button_UploadApp.Add_Click{
    # select app
    
    # upload to intune
    Publish-LocalEvergreenApp -choose selected
}

$var_button_help.Add_Click{
    Start-Process "https://scloud.work/Win32EvergreenApp"
}

$var_button_settings.Add_Click{
    Show-SettingsPopup
}

$var_button_settings.Add_Click{
    $AppInfo = Get-LocalEvergreenApp -AppName $($selectedName) -Meta
    Show-editApp -AppInfo $AppInfo
}


$var_text_copyright.Text = "Florian Salzmann | scloud.work | v0.1"


# First Run
if(!$(Test-Path $SettingsFile))
{
    # open settings
    Show-SettingsPopup
}

# Open GUI
Show-AppGridView
$Null = $window.ShowDialog()