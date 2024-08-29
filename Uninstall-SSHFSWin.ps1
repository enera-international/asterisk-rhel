# PowerShell Script to Uninstall SSHFS-Win and Remove from PATH

# Variables
$installDir = "C:\Program Files\SSHFS-Win\bin"

# Uninstall SSHFS-Win
Write-Host "Uninstalling SSHFS-Win..."
Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name = 'SSHFS-Win'" | ForEach-Object {
    $_.Uninstall()
}

# Remove SSHFS-Win from PATH
Write-Host "Removing SSHFS-Win from system PATH..."
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$newPath = $path -replace [RegEx]::Escape(";${installDir}"), ""
[System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)

Write-Host "SSHFS-Win has been uninstalled and removed from the system PATH."
