
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

        <!-- Title -->
        <TextBlock HorizontalAlignment="Left" Margin="30,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="356" FontSize="20" TextAlignment="Left" FontWeight="Bold" Text="Win32EvergreenApp"/>
        
        <!-- Help & Settings -->
        <Button x:Name="button_help" Content="Help" HorizontalAlignment="Left" Margin="30,50,0,0" VerticalAlignment="Top" Background="White" Width="100"/>
        <Button x:Name="button_settings" Content="Settings" HorizontalAlignment="Left" Margin="140,50,0,0" VerticalAlignment="Top" Background="White" Width="100"/>
        
        <!-- Upload, Edit, Remove -->
        <Button x:Name="button_UploadApp" Content="Upload App to Intune" HorizontalAlignment="Right" Margin="0,0,30,50" VerticalAlignment="Bottom" Width="150" Height="26" Background="#FFA1CEFF" Grid.Row="1" FontWeight="Bold" BorderThickness="0"/>
        <Button x:Name="button_editApp" Content="Edit App" HorizontalAlignment="Right" Margin="0,0,200,50" VerticalAlignment="Bottom" Width="150" Height="26" Background="#FFA1CEFF" Grid.Row="1" FontWeight="Bold" BorderThickness="0"/>
        <Button x:Name="button_removeEvergreenApp" Content="Remove App" HorizontalAlignment="Right" Margin="0,0,370,50" VerticalAlignment="Bottom" Width="150" Height="26" Background="#ff3d40" Grid.RowSpan="2" FontWeight="Bold" BorderThickness="0"/>

        <!-- Add -->
        <TextBox x:Name="text_addApp" HorizontalAlignment="Left" Margin="30,100,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="192" Height="30" FontSize="14" Background="#b8b8b8" BorderThickness="0"/>
        <Button x:Name="button_addEvergreenApp" Content="Add Evergreen App" HorizontalAlignment="Left" Margin="230,100,0,0" VerticalAlignment="Top" Height="30" Width="120" BorderThickness="0" Background="#32CD32" FontWeight="Bold"/>

        <!-- App GridView -->
        <DataGrid x:Name="dataGrid_processes" HorizontalAlignment="Left" Margin="30,150,0,0" VerticalAlignment="Top" Width="470" AutoGenerateColumns="False" SelectionMode="Single" IsReadOnly="True" CanUserAddRows="False" AlternatingRowBackground="#F2F2F2" RowBackground="#EFEFEF" Grid.RowSpan="2" BorderThickness="0" HeadersVisibility="Column" >
            <DataGrid.Resources>
                <Style TargetType="{x:Type DataGridCell}">
                    <Setter Property="BorderThickness" Value="0" />
                    <Setter Property="Padding" Value="6" />
                </Style>
            </DataGrid.Resources>
            <DataGrid.Columns>
                <DataGridTextColumn Header="Name" Binding="{Binding Name}" />
                <DataGridTextColumn Header="Version" Binding="{Binding Version}" />
                <DataGridTextColumn Header="Language" Binding="{Binding Language}" />
            </DataGrid.Columns>
        </DataGrid>

        <!-- Copyright -->
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

function Show-AppGridView(){
    # Populate the DataGrid
    $AllLocalEvergreenApps = Get-LocalEvergreenApp -All
    $var_dataGrid_EvergreenApps.ItemsSource = $AllLocalEvergreenApps
}

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
    Start-Process popup
}

$var_text_copyright.Text = "Florian Salzmann | scloud.work | v0.1"


# Open GUI
Show-AppGridView
$Null = $window.ShowDialog()