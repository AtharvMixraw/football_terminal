#!/bin/bash

# install.sh - Football Clubs Terminal Tool Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY_NAME="football-clubs"
SYSTEM_BIN_DIR="/usr/local/bin"
USER_BIN_DIR="$HOME/.local/bin"
SYSTEM_SHARE_DIR="/usr/local/share/football-clubs"
USER_SHARE_DIR="$HOME/.local/share/football-clubs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Nim is installed
check_nim() {
    if ! command -v nim &> /dev/null; then
        print_error "Nim is not installed!"
        echo "Please install Nim from: https://nim-lang.org/install.html"
        exit 1
    fi
    print_status "Nim found: $(nim --version | head -n1)"
}

# Check if chafa is installed
check_chafa() {
    if ! command -v chafa &> /dev/null; then
        print_warning "chafa is not installed!"
        echo "Install it with:"
        echo "  Ubuntu/Debian: sudo apt install chafa"
        echo "  macOS: brew install chafa"
        echo "  Arch: sudo pacman -S chafa"
        echo ""
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_status "chafa found: $(chafa --version | head -n1)"
    fi
}

# Compile the binary
compile_binary() {
    print_status "Compiling football-clubs binary..."
    if [ -f "$SCRIPT_DIR/football_clubs.nim" ]; then
        nim c -d:release --out:"$SCRIPT_DIR/$BINARY_NAME" "$SCRIPT_DIR/football_clubs.nim"
        print_success "Binary compiled successfully"
    else
        print_error "Source file 'football_clubs.nim' not found!"
        exit 1
    fi
}

# Install binary
install_binary() {
    local bin_dir
    local share_dir
    
    # Try system installation first
    if [ -w "$SYSTEM_BIN_DIR" ] 2>/dev/null; then
        bin_dir="$SYSTEM_BIN_DIR"
        share_dir="$SYSTEM_SHARE_DIR"
        print_status "Installing system-wide..."
    else
        bin_dir="$USER_BIN_DIR"
        share_dir="$USER_SHARE_DIR"
        print_status "Installing to user directory..."
        mkdir -p "$bin_dir"
    fi
    
    # Install binary
    cp "$SCRIPT_DIR/$BINARY_NAME" "$bin_dir/"
    chmod +x "$bin_dir/$BINARY_NAME"
    print_success "Binary installed to: $bin_dir/$BINARY_NAME"
    
    # Create share directory and copy logos
    mkdir -p "$share_dir/logos"
    if [ -d "$SCRIPT_DIR/logos" ]; then
        cp -r "$SCRIPT_DIR/logos/"* "$share_dir/logos/"
        print_success "Logos installed to: $share_dir/logos"
    else
        print_warning "No logos directory found. You'll need to add logos manually."
        echo "Place PNG files in: $share_dir/logos"
        echo "Required files:"
        echo "  - barcelona.png"
        echo "  - real_madrid.png"
        echo "  - manchester_united.png"
        echo "  - liverpool.png"
        echo "  - bayern_munich.png"
        echo "  - juventus.png"
    fi
    
    echo "$bin_dir"
}

# Setup shell integration
setup_shell_integration() {
    local bin_path="$1"
    
    echo ""
    print_status "Setting up shell integration..."
    echo "To show a random club on terminal startup, add this line to your shell config:"
    echo ""
    
    # Detect shell and provide instructions
    case "$SHELL" in
        */bash)
            echo -e "${GREEN}For Bash (~/.bashrc):${NC}"
            echo "echo 'football-clubs' >> ~/.bashrc"
            ;;
        */zsh)
            echo -e "${GREEN}For Zsh (~/.zshrc):${NC}"
            echo "echo 'football-clubs' >> ~/.zshrc"
            ;;
        */fish)
            echo -e "${GREEN}For Fish (~/.config/fish/config.fish):${NC}"
            echo "echo 'football-clubs' >> ~/.config/fish/config.fish"
            ;;
        *)
            echo -e "${GREEN}For your shell:${NC}"
            echo "Add 'football-clubs' to your shell's initialization file"
            ;;
    esac
    
    echo ""
    read -p "Do you want to add it automatically? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        case "$SHELL" in
            */bash)
                echo 'football-clubs' >> ~/.bashrc
                print_success "Added to ~/.bashrc"
                ;;
            */zsh)
                echo 'football-clubs' >> ~/.zshrc
                print_success "Added to ~/.zshrc"
                ;;
            */fish)
                mkdir -p ~/.config/fish
                echo 'football-clubs' >> ~/.config/fish/config.fish
                print_success "Added to ~/.config/fish/config.fish"
                ;;
            *)
                print_warning "Couldn't detect shell. Please add manually."
                ;;
        esac
    fi
}

# Download sample logos
download_logos() {
    print_status "Setting up logo directory..."
    mkdir -p "$SCRIPT_DIR/logos"
    
    print_warning "Logo download not implemented."
    echo "Please manually add PNG logo files to: $SCRIPT_DIR/logos/"
    echo "You can find club logos at:"
    echo "  - Official club websites"
    echo "  - Wikipedia (look for SVG versions and convert to PNG)"
    echo "  - Logo repositories on GitHub"
    echo ""
    echo "Required files:"
    echo "  - barcelona.png"
    echo "  - real_madrid.png" 
    echo "  - manchester_united.png"
    echo "  - liverpool.png"
    echo "  - bayern_munich.png"
    echo "  - juventus.png"
}

# Uninstall function
uninstall() {
    print_status "Uninstalling football-clubs..."
    
    # Remove binaries
    for bin_dir in "$SYSTEM_BIN_DIR" "$USER_BIN_DIR"; do
        if [ -f "$bin_dir/$BINARY_NAME" ]; then
            rm "$bin_dir/$BINARY_NAME"
            print_success "Removed binary from: $bin_dir"
        fi
    done
    
    # Remove share directories
    for share_dir in "$SYSTEM_SHARE_DIR" "$USER_SHARE_DIR"; do
        if [ -d "$share_dir" ]; then
            rm -rf "$share_dir"
            print_success "Removed data from: $share_dir"
        fi
    done
    
    print_warning "Don't forget to remove 'football-clubs' from your shell config file!"
}

# Main installation
main() {
    case "${1:-install}" in
        "install")
            echo "⚽ Football Clubs Terminal Installation"
            echo "======================================"
            
            check_nim
            check_chafa
            compile_binary
            bin_path=$(install_binary)
            download_logos
            setup_shell_integration "$bin_path"
            
            echo ""
            print_success "Installation complete! 🎉"
            echo "Try running: football-clubs"
            ;;
        "uninstall")
            uninstall
            ;;
        *)
            echo "Usage: $0 [install|uninstall]"
            exit 1
            ;;
    esac
}

main "$@"