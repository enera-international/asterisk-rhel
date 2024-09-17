# Enera Asterisk on Red Hat Enterprise Linux (RHEL)
## Online and Offline Installation and Management Scripts

The GitHub repository [enera-international/asterisk-rhel](https://github.com/enera-international/asterisk-rhel) repository contains scripts to facilitate the downloading, installation, and uninstallation of various features on both online and offline Red Hat Enterprise Linux (RHEL) hosts.

## Files Overview

- **install_online_features.sh**: A script to install selected features directly on an online RHEL host. It downloads and installs the necessary packages and dependencies from the internet.
- **uninstall_features.sh**: A script to uninstall previously installed features from the offline RHEL host. It displays a list of installed features and allows the user to select which ones to remove.
- **download_features.sh**: A script to download selected features and their dependencies on an online RHEL host. The downloaded files are organized into separate directories and compressed into a single archive for easy transfer to the offline host.
- **install_downloaded_features.sh**: A script to install the downloaded features on the offline RHEL host. It checks for previously installed features and prompts whether to reinstall them.
- **Feature-specific scripts** (`download_asterisk.sh`, `download_enera_asterisk_api.sh`, `download_rdp.sh`, `download_vscode.sh`, `download_rhel_security_updates.sh`, `download_rhel_all_updates.sh`): These scripts are called by `download_features.sh` to download the necessary packages and dependencies for each feature.
- **Install-SSHFSWin.ps1**: A PowerShell script for the MC Windows Server to create a network drive connected to Asterisk.
- **Uninstall-SSHFSWin.ps1**: A PowerShell script to uninstall SSHFS-Win if needed.

## Prerequisites

- **Online RHEL Host**: Access to a RHEL machine with internet connectivity to download packages and dependencies or perform direct installations. When used to download packages for offline installation on another host both should run the same RHEL version.
- **Offline RHEL Host**: The target machine where the downloaded features will be installed. This machine does not have internet connectivity.
- **Git and other tools**: Ensure the necessary tools are installed on the online host for downloading and packaging dependencies:
    ```bash
    sudo dnf install git
    ```
- **MC**: Access to the Enera MC host(s).

## Usage

### Online Installation

1. Clone this repository to your online RHEL host:

    ```bash
    sudo dnf install git -y
    git clone https://github.com/enera-international/asterisk-rhel.git
    cd asterisk-rhel
    ```

2. Run the script to install the desired features directly on the online host:

    ```bash
    ./install_online_features.sh
    ```

    You will be prompted to select the features you want to install. The script will automatically download and install the necessary packages and dependencies.

### Offline Installation

#### Step 1: Downloading Features on the Online Host

1. Download scripts and make the `download_features.sh` script executable:

    ```bash
    sudo dnf install git -y
    git clone https://github.com/enera-international/asterisk-rhel.git
    cd asterisk-rhel
    chmod +x download_features.sh
    ```

2. Run the script to download the desired features:

    ```bash
    ./download_features.sh
    ```

    You will be prompted to select the features you want to download. The script will download the necessary packages and dependencies, organize them into directories, and compress them into a `offline_installation.tar.gz` file.

3. Transfer the `offline_installation.tar.gz` file to your offline RHEL host.

#### Step 2: Installing Features on the Offline Host

1. Transfer the `install_downloaded_features.sh` script and the `offline_installation.tar.gz` file to the offline RHEL host.

2. Make the `install_downloaded_features.sh` script executable:

    ```bash
    chmod +x install_features.sh
    ```

3. Run the script to install the features:

    ```bash
    ./install_downloaded_features.sh /path/to/offline_installation.tar.gz
    ```

    If the TAR file is in the same directory as the script, you can omit the path:

    ```bash
    ./install_downloaded_features.sh
    ```

    The script will check the installation state and prompt you if a feature has already been installed. The installation state is tracked in the hidden directory `$HOME/.enera/installation_state.txt`.

### Uninstallation

1. Ensure the `uninstall_features.sh` script is on the RHEL host (online or offline).

2. Make the script executable:

    ```bash
    chmod +x uninstall_features.sh
    ```

3. Run the script to uninstall features:

    ```bash
    ./uninstall_features.sh
    ```

    The script will display a list of installed features based on the `installation_state.txt` file in the `$HOME/.enera` directory. You can select which features to uninstall or choose to uninstall all of them.

## Directory Structure

- **$HOME/.enera**: A hidden directory in the user's home folder that stores the `installation_state.txt` file, tracking the features that have been installed.

## Access the Asterisk CLI

Once the Asterisk service is running, you can access the Asterisk CLI with the following command:

    ```bash
    sudo asterisk -r
    ```
The -r flag stands for "remote console," which connects you to the running instance of Asterisk. This will give you access to the interactive Asterisk CLI where you can run commands like sip show peers, core show channels, etc.

## Stopping or Restarting the Asterisk Service

- Stop Asterisk:

    ```bash
    sudo systemctl stop asterisk
    ```

- Restart Asterisk:

    ```bash
    sudo systemctl restart asterisk
    ```

## Optional: Run Asterisk in Debug Mode

If you want to start Asterisk with full logging output (for debugging purposes), you can run:

    ```bash
    sudo asterisk -rvvvvv
    ```

The number of vs increases the verbosity of the output.

- Troubleshooting

If Asterisk doesn’t start, you can view the logs to see what’s going wrong:

    ```bash
    sudo journalctl -xe
    sudo tail -f /var/log/asterisk/messages
    ```

## Notes

- **Feature-Specific Information**: The `install_online_features.sh` script includes MongoDB and two npm packages: `enera-international/asterisk-api-server` and `enera-international/asterisk-web-server`. Ensure that you have `git` and `npm` installed on the online host to clone and package these dependencies.
- **Uninstallation Limitations**: Uninstalling system updates (like `RHEL_Security_Updates` or `RHEL_All_Updates`) via the provided script is not recommended. These updates should be managed carefully, and rolling back updates may require a different approach.

## Troubleshooting

- **Missing Dependencies**: Ensure all necessary tools (e.g., `dnf`, `git`) are installed on the online host.
- **Permission Issues**: If you encounter permission errors, ensure you are running the scripts with the appropriate privileges (e.g., using `sudo` where necessary).

## Using the SSHFS-Win Install/Uninstall Scripts on an Enera MC Server

### Overview
The purpose of these scripts is to install and configure SSHFS-Win on an Enera MC server to create a file system link to an Enera Asterisk host. This setup allows the Enera MC server to access files on the Asterisk host as if they were local, leveraging SSHFS-Win for secure and efficient file sharing over the network.

### Prerequisites
- **Enera MC Server** running a compatible version of Windows.
- **Enera Asterisk Host** with SSH access configured.
- **PowerShell** with Administrator privileges.

### Installation Instructions

1. **Download and Save the Installation Script:**
   Save the provided `Install-SSHFSWin.ps1` script to a location on the Enera MC server.

2. **Run the Installation Script:**
   Open a PowerShell window with Administrator privileges and navigate to the directory where you saved the installation script. Run the script by executing:

   ```powershell
   .\Install-SSHFSWin.ps1
   ```

3. **Configure the File System Link:**
   After installation, use the following command format to map a network drive to the Asterisk host:

   ```powershell
   net use X: \\sshfs\REMOTEUSER@ASTERISK_HOST\linehandler /persistent:yes
   ```

   Replace `REMOTEUSER` with your SSH username and `ASTERISK_HOST` with the IP address or hostname of the Asterisk server.

4. **Verify the Connection:**
   Confirm that the drive appears in `This PC` or `My Computer` and that you can access the files on the Asterisk host.

### Uninstallation Instructions

1. **Download and Save the Uninstallation Script:**
   Save the provided `Uninstall-SSHFSWin.ps1` script to a location on the Enera MC server.

2. **Run the Uninstallation Script:**
   Open a PowerShell window with Administrator privileges and navigate to the directory where you saved the uninstallation script. Run the script by executing:

   ```powershell
   .\Uninstall-SSHFSWin.ps1
   ```

3. **Remove the Network Drive:**
   If you had mapped a drive using SSHFS-Win, unmap it using:

   ```powershell
   net use X: /delete
   ```

   Replace `X:` with the drive letter you assigned to the network drive.

### Notes
- **Security Considerations:** Ensure that the SSH credentials used for connecting to the Asterisk host are securely managed and do not compromise the security of the Asterisk server.
- **Performance:** While SSHFS provides a convenient method for accessing remote files, the performance may vary depending on network conditions and the configuration of the Asterisk host.

This setup is ideal for scenarios where direct access to the Asterisk host's file system is required for operations such as log analysis, configuration management, or backup purposes.
