Here is the entire `README.md` content as a single Markdown text block:

# RHEL Feature Installation and Management Scripts

This repository contains Node.js TypeScript scripts to install, manage, and uninstall various features on a Red Hat Enterprise Linux (RHEL) host. The scripts use `zx` for shell command execution and `@inquirer/prompts` for interactive user input.

## Prerequisites

Before using these scripts, ensure the following prerequisites are met:

1. **Node.js and npm**: Install Node.js (v14 or higher) and npm on your RHEL host.
   ```bash
   sudo dnf install -y nodejs npm
   ```
2. **TypeScript**: Install TypeScript globally.
   ```bash
   sudo npm install -g typescript
   ```
3. **zx and @inquirer/prompts**: Install `zx` and `@inquirer/prompts` as dependencies.
   ```bash
   npm install -g zx @inquirer/prompts
   ```

## Scripts Overview

The repository contains three main scripts:

1. **`installOnline.ts`**: Installs features on an online RHEL host.
2. **`installOffline.ts`**: Installs features on an offline RHEL host using pre-downloaded packages.
3. **`uninstallFeatures.ts`**: Uninstalls features from the RHEL host.

## How to Use the Scripts

### 1. Install Features on an Online RHEL Host

To install features on an online RHEL host, use the `installOnline.ts` script.

#### Steps:

1. Clone the repository to your RHEL host.
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Run the script using `ts-node`.
   ```bash
   npx ts-node installOnline.ts
   ```

3. Follow the on-screen prompts to select the features you want to install.

### 2. Install Features on an Offline RHEL Host

If you need to install features on a RHEL host without internet access, use the `installOffline.ts` script. This requires pre-downloaded packages.

#### Steps:

1. Ensure you have a tarball of the required packages.
   
2. Clone the repository to your RHEL host.
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

3. Run the script using `ts-node`.
   ```bash
   npx ts-node installOffline.ts
   ```

4. Provide the path to the tarball when prompted and follow the instructions to install the desired features.

### 3. Uninstall Features

To uninstall features from your RHEL host, use the `uninstallFeatures.ts` script.

#### Steps:

1. Clone the repository to your RHEL host.
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Run the script using `ts-node`.
   ```bash
   npx ts-node uninstallFeatures.ts
   ```

3. Select the features you want to uninstall from the list provided.

## Example Use Cases

- **Install Asterisk from the RHEL repository**:
  - Run `installOnline.ts` and select "Asterisk" from the options.
  
- **Install the Enera Asterisk API on an offline system**:
  - Run `installOffline.ts`, provide the path to the pre-downloaded tarball, and select "Enera Asterisk API".

- **Uninstall VSCode**:
  - Run `uninstallFeatures.ts` and select "VSCode" from the list.

## Additional Notes

- Ensure you run these scripts with sufficient privileges (`sudo`) where necessary, especially when installing or uninstalling system-wide packages.
- The `installOffline.ts` script assumes that the necessary RPMs and other resources are available in a tarball that can be extracted locally.

## Troubleshooting

- **Node.js not found**: Ensure Node.js is installed correctly by running `node -v` and `npm -v`.
- **Permission Denied**: Run the script with `sudo` if you're facing permission issues.
- **Missing Packages**: If using `installOffline.ts`, make sure the tarball contains all required dependencies.

## License

This project is licensed under the MIT License.

---

This is the complete content of the `README.md` file written entirely in Markdown.