# Enera Asterisk on Red Hat Enterprise Linux (RHEL)
## Online and Offline Installation and Management Scripts

This repository contains scripts to facilitate the downloading, installation, and uninstallation of various features on both online and offline Red Hat Enterprise Linux (RHEL) hosts.

## Files Overview

- **install_online_features.sh**: A script to install selected features directly on an online RHEL host. It downloads and installs the necessary packages and dependencies from the internet.
- **uninstall_features.sh**: A script to uninstall previously installed features from the offline RHEL host. It displays a list of installed features and allows the user to select which ones to remove.
- **download_features.sh**: A script to download selected features and their dependencies on an online RHEL host. The downloaded files are organized into separate directories and compressed into a single archive for easy transfer to the offline host.
- **install_features.sh**: A script to install the downloaded features on the offline RHEL host. It checks for previously installed features and prompts whether to reinstall them.
- **Feature-specific scripts** (`download_asterisk.sh`, `download_enera_asterisk_api.sh`, `download_rdp.sh`, `download_vscode.sh`, `download_rhel_security_updates.sh`, `download_rhel_all_updates.sh`): These scripts are called by `download_features.sh` to download the necessary packages and dependencies for each feature.

## Prerequisites

- **Online RHEL Host**: Access to a RHEL machine with internet connectivity to download packages and dependencies or perform direct installations. When used to download packages for offline installation on another host both should run the same RHEL version.
- **Offline RHEL Host**: The target machine where the downloaded features will be installed. This machine does not have internet connectivity.
- **Git and other tools**: Ensure the necessary tools are installed on the online host for downloading and packaging dependencies.

## Usage

### Online Installation

1. Clone this repository to your online RHEL host:

    ```bash
    sudo dnf install git -y
    git clone https://github.com/enera-international/asterisk-rhel.git
    cd asterisk-rhel
    ```

2. Make the `install_online_features.sh` script executable:

    ```bash
    chmod +x install_online_features.sh
    ```

3. Run the script to install the desired features directly on the online host:

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

1. Transfer the `install_features.sh` script and the `offline_installation.tar.gz` file to the offline RHEL host.

2. Make the `install_features.sh` script executable:

    ```bash
    chmod +x install_features.sh
    ```

3. Run the script to install the features:

    ```bash
    ./install_features.sh /path/to/offline_installation.tar.gz
    ```

    If the TAR file is in the same directory as the script, you can omit the path:

    ```bash
    ./install_features.sh
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

## Notes

- **Feature-Specific Information**: The `install_online_features.sh` script includes MongoDB and two npm packages: `enera-international/asterisk-api-server` and `enera-international/asterisk-web-server`. Ensure that you have `git` and `npm` installed on the online host to clone and package these dependencies.
- **Uninstallation Limitations**: Uninstalling system updates (like `RHEL_Security_Updates` or `RHEL_All_Updates`) via the provided script is not recommended. These updates should be managed carefully, and rolling back updates may require a different approach.

## Troubleshooting

- **Missing Dependencies**: Ensure all necessary tools (e.g., `dnf`, `git`) are installed on the online host.
- **Permission Issues**: If you encounter permission errors, ensure you are running the scripts with the appropriate privileges (e.g., using `sudo` where necessary).
