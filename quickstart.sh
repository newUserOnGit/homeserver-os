#!/bin/bash
# Quick Start Development Script
# Sets up development environment for Home Server OS

set -e

echo "=================================="
echo "Home Server OS - Quick Start"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running on supported OS
check_os() {
    echo "Checking operating system..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${GREEN}✓ Linux detected${NC}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${GREEN}✓ macOS detected${NC}"
    else
        echo -e "${YELLOW}⚠ Unsupported OS: $OSTYPE${NC}"
        echo "This script is designed for Linux and macOS"
        read -p "Continue anyway? (yes/no): " CONTINUE
        if [ "$CONTINUE" != "yes" ]; then
            exit 1
        fi
    fi
    echo ""
}

# Install dependencies
install_dependencies() {
    echo "Installing dependencies..."

    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        echo "Detected Debian/Ubuntu"
        sudo apt-get update
        sudo apt-get install -y build-essential nasm qemu-system-x86 grub-pc-bin xorriso
    elif command -v yum &> /dev/null; then
        # RedHat/CentOS
        echo "Detected RedHat/CentOS"
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y nasm qemu-system-x86 grub2-tools xorriso
    elif command -v brew &> /dev/null; then
        # macOS
        echo "Detected macOS"
        brew install nasm qemu grub xorriso
    else
        echo -e "${YELLOW}⚠ Package manager not detected${NC}"
        echo "Please install manually:"
        echo "  - GCC"
        echo "  - NASM"
        echo "  - QEMU"
        echo "  - GRUB"
        echo "  - xorriso"
        return
    fi

    echo -e "${GREEN}✓ Dependencies installed${NC}"
    echo ""
}

# Setup development environment
setup_environment() {
    echo "Setting up development environment..."

    # Create build directory
    mkdir -p build
    mkdir -p build/iso/boot/grub

    # Make scripts executable
    chmod +x tools/*.sh
    chmod +x tests/*.sh

    echo -e "${GREEN}✓ Environment ready${NC}"
    echo ""
}

# Build project
build_project() {
    echo "Building project..."

    if make all; then
        echo -e "${GREEN}✓ Build successful${NC}"
    else
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi

    echo ""
}

# Run tests
run_tests() {
    echo "Running tests..."

    cd tests
    if ./run_tests.sh; then
        echo -e "${GREEN}✓ All tests passed${NC}"
    else
        echo -e "${RED}✗ Some tests failed${NC}"
    fi
    cd ..

    echo ""
}

# Display next steps
show_next_steps() {
    echo "=================================="
    echo -e "${GREEN}Setup Complete!${NC}"
    echo "=================================="
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Test in QEMU:"
    echo "   ${BLUE}make run${NC}"
    echo ""
    echo "2. Clean build:"
    echo "   ${BLUE}make clean${NC}"
    echo ""
    echo "3. Rebuild:"
    echo "   ${BLUE}make all${NC}"
    echo ""
    echo "4. Read documentation:"
    echo "   ${BLUE}docs/technical.md${NC} - Technical documentation"
    echo "   ${BLUE}docs/user-guide.md${NC} - User guide"
    echo ""
    echo "5. Start developing:"
    echo "   - Check ${BLUE}CONTRIBUTING.md${NC} for guidelines"
    echo "   - Create a new branch: ${BLUE}git checkout -b feature/my-feature${NC}"
    echo "   - Make changes and test"
    echo "   - Commit: ${BLUE}git commit -m 'feat: my feature'${NC}"
    echo ""
    echo "6. Get help:"
    echo "   - GitHub: https://github.com/homeserver-os"
    echo "   - Forum: https://forum.homeserver-os.org"
    echo "   - Discord: https://discord.gg/homeserver-os"
    echo ""
    echo "Happy coding! 🚀"
}

# Main menu
main_menu() {
    echo "What would you like to do?"
    echo ""
    echo "1) Full setup (install dependencies, build, test)"
    echo "2) Install dependencies only"
    echo "3) Build project only"
    echo "4) Run tests only"
    echo "5) Exit"
    echo ""
    read -p "Enter choice [1-5]: " CHOICE

    case $CHOICE in
        1)
            check_os
            install_dependencies
            setup_environment
            build_project
            run_tests
            show_next_steps
            ;;
        2)
            check_os
            install_dependencies
            ;;
        3)
            setup_environment
            build_project
            ;;
        4)
            run_tests
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

# Run main menu
main_menu
