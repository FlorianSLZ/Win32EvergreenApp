
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# XAML file
$xamlFile = @'
<Window x:Class="WpfApp2.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp2"
        mc:Ignorable="d"
        ResizeMode="NoResize"
        Title="Win32EvergreenApp UI" Height="600" Width="900">
    <Grid Background="#fefefe">
        <Grid.RowDefinitions>
            <RowDefinition Height="33*"/>
            <RowDefinition Height="29*"/>
        </Grid.RowDefinitions>
        <TextBlock HorizontalAlignment="Left" Margin="30,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="356" FontSize="20" TextAlignment="Left" FontWeight="Bold" Text="Win32EvergreenApp"/>
        <Button x:Name="button_help" Content="Help" HorizontalAlignment="Left" Margin="30,50,0,0" VerticalAlignment="Top" Background="White" Width="100"/>
        <Button x:Name="button_settings" Content="Settings" HorizontalAlignment="Left" Margin="140,50,0,0" VerticalAlignment="Top" Background="White" Width="100"/>
        <TextBox x:Name="text_output" HorizontalAlignment="Left" Margin="30,0,0,0" TextWrapping="WrapWithOverflow" VerticalAlignment="Top" Width="332" Height="161" IsReadOnly="True" HorizontalScrollBarVisibility="Visible" VerticalScrollBarVisibility="Visible" Grid.Row="1"/>
        <TextBox x:Name="text_grouptag" HorizontalAlignment="Left" Margin="36,235,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="192" Height="30" FontSize="14" BorderBrush="Black"/>
        <Button x:Name="button_addEvergreenApp" Content="Add Evergreen App" HorizontalAlignment="Left" Margin="234,235,0,0" VerticalAlignment="Top" Height="30" Width="120" BorderBrush="Black" Background="#32CD32" FontWeight="Bold"/>
        <Button x:Name="button_UploadApp" Content="Upload App to Intune" HorizontalAlignment="Right" Margin="0,0,30,50" VerticalAlignment="Bottom" Width="250" Height="26" Background="#FFA1CEFF" Grid.Row="1" FontWeight="Bold" BorderBrush="Black"/>
        <Button x:Name="button_removeEvergreenApp" Content="Remove Evergreen App" HorizontalAlignment="Right" Margin="0,0,310,50" VerticalAlignment="Bottom" Width="250" Height="26" Background="#ff3d40" Grid.RowSpan="2" FontWeight="Bold" BorderBrush="Black"/>
        <TextBlock x:Name="text_copyright" HorizontalAlignment="Right" Margin="0,0,30,10" TextWrapping="Wrap" VerticalAlignment="Bottom" Grid.Row="1"><Run Language="en-us" Text="Author"/></TextBlock>        
    </Grid>
</Window>


'@

#create window
$inputXML = $xamlFile
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




#Time and Date

$timer1 = New-Object 'System.Windows.Forms.Timer'
$timer1_Tick={
    $var_text_time.Text = (Get-Date).ToString("HH:mm:ss")
}

$timer1.Enabled = $True
$timer1.Interval = 1000 # in ms -> 1000 = Update clock every second
$timer1.add_Tick($timer1_Tick)

$var_text_date.Text = (Get-Date).ToString("MM:dd:yyyy")



$var_text_serialnumber.Text = (Get-WmiObject -class win32_bios).SerialNumber
$var_text_devicemodel.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
$var_text_devicename.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$var_text_manufacturer.Text = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$var_text_freespace.Text = (Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }} | Measure-Object -Property 'FreeSpace (GB)' -Sum).Sum






$var_button_addEvergreenApp.Add_Click{
    # call add function
    Add-EvergreenApp

    # load apps for overview
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
    Start-Process popup
}

$var_text_copyright.Text = "Florian Salzmann | scloud.work | v0.1"

# Open GUI

$Null = $window.ShowDialog()