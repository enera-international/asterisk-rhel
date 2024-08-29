#!/bin/bash

# Define the directory and file for tracking installation state
STATE_DIR="$HOME/.enera"
STATE_FILE="$STATE_DIR/installation_state.txt"

# Check if the state file exists
if [ ! -f "$STATE_FILE" ]; then
    echo "No features have been installed or the state file is missing."
    exit 1
fi

# Function to uninstall a package
uninstall_packages() {
    feature_name=$1

    echo "Uninstalling $feature_name..."
    case $feature_name in
        "Asterisk")
            sudo dnf remove -y asterisk
            ;;
        "Enera_Asterisk_API")
            sudo dnf remove -y nodejs nginx mongodb-org
            ;;
        "Samba")
            ./utilities/uninstall_samba.sh
            ;;
        "RDP")
            sudo dnf remove -y xrdp
            ;;
        "VSCode")
            sudo dnf remove -y code
            ;;
        "VSCode-extensions")
            # This assumes you want to uninstall all installed VSCode extensions
            for ext in $(code --list-extensions); do
                code --uninstall-extension "$ext"
            done
            ;;
        "RHEL_Security_Updates")
            echo "Uninstalling RHEL security updates is not recommended via this script."
            ;;
        "RHEL_All_Updates")
            echo "Uninstalling all RHEL updates is not recommended via this script."
            ;;
        "Enera_Asterisk_API-asterisk-api-server")
            # Uninstall npm dependencies manually if necessary
            echo "Manually remove the asterisk-api-server dependencies if required."
            ;;
        "Enera_Asterisk_API-asterisk-web-server")
            echo "Manually remove the asterisk-web-server dependencies if required."
            ;;
        *)
            echo "Unknown feature: $feature_name"
            ;;
    esac

    # Remove the feature from the state file
    sed -i "/^$feature_name$/d" "$STATE_FILE"
}

# Display the list of installed features
echo "Installed features:"
installed_features=($(cat "$STATE_FILE"))
for i in "${!installed_features[@]}"; do
    echo "$((i + 1))) ${installed_features[$i]}"
done

# Prompt the user for selection
echo "Select the features to uninstall by entering the numbers separated by spaces (e.g., 1 3 5)."
echo "Enter 'all' to uninstall all features."
read -p "> " selection

# Process the selection
if [ "$selection" == "all" ]; then
    for feature in "${installed_features[@]}"; do
        uninstall_packages "$feature"
    done
else
    for i in $selection; do
        index=$((i - 1))
        if [ $index -ge 0 ] && [ $index -lt ${#installed_features[@]} ]; then
            uninstall_packages "${installed_features[$index]}"
        else
            echo "Invalid selection: $i"
        fi
    done
fi

echo "Uninstallation complete."
