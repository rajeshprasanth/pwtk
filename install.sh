#!/bin/bash
set -e

# Function to display banner
display_banner() {
    echo "*************************************"
    echo "*          Installation Script      *"
    echo "*************************************"
    echo
}

# Function to get installation directory
get_installation_directory() {
    echo "Enter the installation directory path:"
    read INSTALL_DIR
    # Remove trailing slashes if any
    INSTALL_DIR=$(echo "$INSTALL_DIR" | sed 's:/*$::')
    echo "Installation directory set to: $INSTALL_DIR"
}

# Function to confirm installation
confirm_installation() {
    echo "Do you want to proceed with the installation? (yes/no)"
    read choice
    case "$choice" in
        yes|YES|y|Y) echo "Installing...";;
        *) echo "Installation aborted."; exit 1;;
    esac
}

# Function to create installation directory if not exist
create_installation_directory() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo "Creating installation directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi
}

# Function to copy files
copy_files() {
    echo "Copying files to installation directory..."
    cp -r * "$INSTALL_DIR"/
}

# Function to add utils directory to PATH variable for all shells
add_utils_to_path() {
    echo "export PATH=\$PATH:$INSTALL_DIR/utils"
    echo "Note: To permanently add the 'utils' directory to your PATH variable,"
    echo "      please add the above line to the appropriate configuration file:"
    echo "      For Bash, append to ~/.bashrc or ~/.bash_profile."
    echo "      For Zsh, append to ~/.zshrc."
    echo "      For Fish, add the following line to ~/.config/fish/config.fish:"
    echo "          set -gx PATH \$PATH $INSTALL_DIR/utils"
    echo "      After adding, you can restart your shell or run 'source <config_file>' to apply the changes."
}

create_environment_file() {
    cat << EOF > environment
INSTALL_DIR=$INSTALL_DIR
ASSETS_DIR=\$INSTALL_DIR/assets
TESTS_DIR=\$INSTALL_DIR/tests
UTILS_DIR=\$INSTALL_DIR/utils
SCRIPTS_DIR=\$INSTALL_DIR/scripts
TEMPLATES_DIR=\$INSTALL_DIR/templates
EOF
}

# Main function
main() {
    display_banner
    get_installation_directory
    confirm_installation
    create_installation_directory
    copy_files
    create_environment_file
    add_utils_to_path

    echo "Installation completed successfully."
}

# Run main function
main
