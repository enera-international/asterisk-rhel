# PowerShell Script to Install SSHFS-Win and Add to PATH

# Variables
$installerUrl = "https://github.com/winfsp/sshfs-win/releases/download/v3.5.20357/SSHFS-Win-3.5.20357-x64.msi"
$installerPath = "$env:TEMP\SSHFS-Win.msi"
$installDir = "C:\Program Files\SSHFS-Win\bin"

# Download the installer
Write-Host "Downloading SSHFS-Win installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install SSHFS-Win
Write-Host "Installing SSHFS-Win..."
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

# Add SSHFS-Win to PATH
Write-Host "Adding SSHFS-Win to system PATH..."
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($path -notlike "*$installDir*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$path;$installDir", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "SSHFS-Win has been added to the system PATH."
} else {
    Write-Host "SSHFS-Win is already in the system PATH."
}

# Cleanup
Remove-Item $installerPath -Force
Write-Host "Installation complete."
