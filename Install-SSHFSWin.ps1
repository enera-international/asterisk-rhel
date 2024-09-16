# Define the URLs for downloading SSHFS-Win and WinFsp

$sshfsWinUrl = "https://github.com/enera-international/asterisk-rhel/blob/main/assets/sshfs-win-3.7.21011-x64.msi"
$winfspUrl = "https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi"

# Define the paths where the installers will be downloaded
$sshfsWinInstaller = "$env:TEMP\sshfs-win.exe"
$winfspInstaller = "$env:TEMP\winfsp.msi"

# Download SSHFS-Win installer
Write-Output "Downloading SSHFS-Win..."
Invoke-WebRequest -Uri $sshfsWinUrl -OutFile $sshfsWinInstaller

# Download WinFsp installer
Write-Output "Downloading WinFsp..."
Invoke-WebRequest -Uri $winfspUrl -OutFile $winfspInstaller

# Install WinFsp silently
Write-Output "Installing WinFsp..."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$winfspInstaller`" /quiet /norestart" -Wait

# Install SSHFS-Win silently
Write-Output "Installing SSHFS-Win..."
Start-Process -FilePath $sshfsWinInstaller -ArgumentList "/S" -Wait

# Define the installation path for SSHFS-Win (the default installation path)
$sshfsWinInstallPath = "C:\Program Files\SSHFS-Win\bin"

# Add SSHFS-Win to the system PATH environment variable
Write-Output "Adding SSHFS-Win to the system PATH..."
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if (-not $existingPath.Contains($sshfsWinInstallPath)) {
    $newPath = $existingPath + ";" + $sshfsWinInstallPath
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Output "SSHFS-Win has been added to the PATH."
} else {
    Write-Output "SSHFS-Win is already in the PATH."
}

# Cleanup downloaded installers
Write-Output "Cleaning up..."
Remove-Item -Path $sshfsWinInstaller
Remove-Item -Path $winfspInstaller

Write-Output "Installation completed. You may need to restart your session for PATH changes to take effect."
