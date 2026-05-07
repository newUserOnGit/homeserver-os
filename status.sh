#!/bin/bash
# Home Server OS - Quick Status Check
# Shows project status and available commands

clear

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Load version
if [ -f "VERSION" ]; then
    source VERSION
fi

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          🖥️  HOME SERVER OS - PROJECT STATUS 🖥️          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}Version:${NC} ${VERSION_FULL}"
echo -e "${BLUE}Build Date:${NC} ${BUILD_DATE}"
echo -e "${BLUE}Architecture:${NC} ${SYSTEM_ARCH}"
echo ""

# Check project structure
echo -e "${YELLOW}📊 Project Structure:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_component() {
    local name=$1
    local path=$2

    if [ -f "$path" ] || [ -d "$path" ]; then
        echo -e "  ${GREEN}✓${NC} $name"
    else
        echo -e "  ${RED}✗${NC} $name"
    fi
}

check_component "Kernel Core" "kernel/core/kernel.c"
check_component "Memory Manager" "kernel/memory/memory.c"
check_component "Task Scheduler" "kernel/scheduler/scheduler.c"
check_component "Filesystem" "kernel/fs/filesystem.c"
check_component "Network Stack" "kernel/net/network.c"
check_component "Bootloader" "bootloader/boot.asm"
check_component "Storage Driver" "drivers/storage/ata.c"
check_component "Init System" "system/init/init.c"
check_component "Web Interface" "web/admin-panel/index.html"
check_component "REST API" "web/api/api.c"
check_component "Container Manager" "virtualization/containers/container.c"
check_component "VM Manager" "virtualization/vms/vm.c"
check_component "Firewall" "security/firewall/firewall.c"
check_component "Monitoring" "monitoring/monitor.c"
check_component "Backup System" "backup/backup.c"

echo ""
echo -e "${YELLOW}📚 Documentation:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_component "README" "README.md"
check_component "Technical Docs" "docs/technical.md"
check_component "User Guide" "docs/user-guide.md"
check_component "FAQ" "docs/FAQ.md"
check_component "Contributing Guide" "CONTRIBUTING.md"
check_component "Security Policy" "SECURITY.md"

echo ""
echo -e "${YELLOW}🛠️  Available Commands:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${CYAN}Build & Test:${NC}"
echo -e "  ${GREEN}make all${NC}              - Build entire project"
echo -e "  ${GREEN}make clean${NC}            - Clean build artifacts"
echo -e "  ${GREEN}make run${NC}              - Run in QEMU"
echo -e "  ${GREEN}./tests/run_tests.sh${NC}  - Run all tests"
echo ""
echo -e "${CYAN}Development:${NC}"
echo -e "  ${GREEN}./quickstart.sh${NC}       - Quick start setup"
echo -e "  ${GREEN}./tools/build.sh${NC}      - Build with checks"
echo -e "  ${GREEN}./tools/check_system.sh${NC} - System check"
echo -e "  ${GREEN}./tools/integrity_check.sh${NC} - Integrity check"
echo ""
echo -e "${CYAN}Installation:${NC}"
echo -e "  ${GREEN}./tools/install.sh${NC}    - Install to disk"
echo ""
echo -e "${CYAN}Release:${NC}"
echo -e "  ${GREEN}./tools/release.sh${NC}    - Create release package"
echo ""
echo -e "${CYAN}Documentation:${NC}"
echo -e "  ${GREEN}cat README.md${NC}         - Project overview"
echo -e "  ${GREEN}cat docs/technical.md${NC} - Technical docs"
echo -e "  ${GREEN}cat docs/user-guide.md${NC} - User guide"
echo -e "  ${GREEN}cat docs/FAQ.md${NC}       - FAQ"
echo ""

# Statistics
echo -e "${YELLOW}📈 Project Statistics:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count files
C_FILES=$(find . -name "*.c" 2>/dev/null | wc -l)
H_FILES=$(find . -name "*.h" 2>/dev/null | wc -l)
ASM_FILES=$(find . -name "*.asm" 2>/dev/null | wc -l)
SH_FILES=$(find . -name "*.sh" 2>/dev/null | wc -l)
MD_FILES=$(find . -name "*.md" 2>/dev/null | wc -l)

echo -e "  C files:        ${BLUE}$C_FILES${NC}"
echo -e "  Header files:   ${BLUE}$H_FILES${NC}"
echo -e "  Assembly files: ${BLUE}$ASM_FILES${NC}"
echo -e "  Shell scripts:  ${BLUE}$SH_FILES${NC}"
echo -e "  Documentation:  ${BLUE}$MD_FILES${NC}"
echo ""

# Features
echo -e "${YELLOW}✨ Features:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${GREEN}✓${NC} Web-based administration"
echo -e "  ${GREEN}✓${NC} REST API"
echo -e "  ${GREEN}✓${NC} Container support (max ${MAX_CONTAINERS})"
echo -e "  ${GREEN}✓${NC} Virtual machine support (max ${MAX_VMS})"
echo -e "  ${GREEN}✓${NC} Automated backup"
echo -e "  ${GREEN}✓${NC} Built-in firewall"
echo -e "  ${GREEN}✓${NC} Real-time monitoring"
echo -e "  ${GREEN}✓${NC} TCP/IP networking"
echo ""

# Quick links
echo -e "${YELLOW}🔗 Quick Links:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  GitHub:        ${BLUE}${REPO_URL}${NC}"
echo -e "  Documentation: ${BLUE}${DOCS_URL}${NC}"
echo -e "  Support:       ${BLUE}${SUPPORT_URL}${NC}"
echo ""

# Next steps
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  1. Build the project:  ${GREEN}make all${NC}"
echo -e "  2. Run tests:          ${GREEN}cd tests && ./run_tests.sh${NC}"
echo -e "  3. Test in QEMU:       ${GREEN}make run${NC}"
echo -e "  4. Read documentation: ${GREEN}cat docs/user-guide.md${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Home Server OS is ready for development!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
