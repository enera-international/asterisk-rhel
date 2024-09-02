# Define the installation paths
$sshfsWinInstallPath = "C:\Program Files\SSHFS-Win\bin"
$winfspInstallPath = "C:\Program Files (x86)\WinFsp"

# Stop any running SSHFS or WinFsp processes
Write-Output "Stopping any running SSHFS-Win or WinFsp processes..."
Get-Process -Name sshfs, sshfs-win, winfsp, ssh -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Uninstall SSHFS-Win
Write-Output "Uninstalling SSHFS-Win..."
$sshfsWinUninstaller = "$sshfsWinInstallPath\uninstall.exe"
if (Test-Path $sshfsWinUninstaller) {
    Start-Process -FilePath $sshfsWinUninstaller -ArgumentList "/S" -Wait
} else {
    Write-Output "SSHFS-Win uninstaller not found."
}

# Uninstall WinFsp
Write-Output "Uninstalling WinFsp..."
$winfspUninstaller = "$winfspInstallPath\uninstall.exe"
if (Test-Path $winfspUninstaller) {
    Start-Process -FilePath $winfspUninstaller -ArgumentList "/S" -Wait
} else {
    Write-Output "WinFsp uninstaller not found."
}

# Remove SSHFS-Win from the system PATH
Write-Output "Removing SSHFS-Win from the system PATH..."
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($existingPath.Contains($sshfsWinInstallPath)) {
    $newPath = $existingPath -replace [Regex]::Escape(";$sshfsWinInstallPath"), ""
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Output "SSHFS-Win has been removed from the PATH."
} else {
    Write-Output "SSHFS-Win was not found in the PATH."
}

# Clean up any leftover files or directories
Write-Output "Cleaning up leftover files and directories..."

# Remove SSHFS-Win directory
if (Test-Path $sshfsWinInstallPath) {
    Write-Output "Attempting to remove SSHFS-Win directory..."
    Try {
        Remove-Item -Path $sshfsWinInstallPath -Recurse -Force -ErrorAction Stop
        Write-Output "SSHFS-Win directory removed."
    } Catch {
        Write-Output "Failed to remove SSHFS-Win directory. Error: $_"
    }
}

# Remove WinFsp directory
if (Test-Path $winfspInstallPath) {
    Write-Output "Attempting to remove WinFsp directory..."
    Try {
        Remove-Item -Path $winfspInstallPath -Recurse -Force -ErrorAction Stop
        Write-Output "WinFsp directory removed."
    } Catch {
        Write-Output "Failed to remove WinFsp directory. Error: $_"
    }
}

Write-Output "Uninstallation completed."
