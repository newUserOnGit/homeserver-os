#!/bin/bash
# System Check Script
# Verifies system integrity and configuration

echo "=================================="
echo "Home Server OS - System Check"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

check_item() {
    local name=$1
    local command=$2
    local type=${3:-"error"}  # error or warning

    echo -n "Checking $name... "

    if eval $command > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        if [ "$type" = "warning" ]; then
            echo -e "${YELLOW}⚠ WARNING${NC}"
            CHECKS_WARNING=$((CHECKS_WARNING + 1))
        else
            echo -e "${RED}✗ FAILED${NC}"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        return 1
    fi
}

echo "File Structure Checks:"
echo "---------------------"

check_item "Kernel core" "test -f kernel/core/kernel.c"
check_item "Memory manager" "test -f kernel/memory/memory.c"
check_item "Scheduler" "test -f kernel/scheduler/scheduler.c"
check_item "Filesystem" "test -f kernel/fs/filesystem.c"
check_item "Network stack" "test -f kernel/net/network.c"
check_item "Bootloader" "test -f bootloader/boot.asm"
check_item "Storage driver" "test -f drivers/storage/ata.c"
check_item "Init system" "test -f system/init/init.c"
check_item "Web interface" "test -f web/admin-panel/index.html"
check_item "REST API" "test -f web/api/api.c"
check_item "Monitoring" "test -f monitoring/monitor.c"
check_item "Backup system" "test -f backup/backup.c"
check_item "Firewall" "test -f security/firewall/firewall.c"
check_item "Container manager" "test -f virtualization/containers/container.c"
check_item "VM manager" "test -f virtualization/vms/vm.c"

echo ""
echo "Configuration Checks:"
echo "--------------------"

check_item "System config" "test -f config/system.conf"
check_item "Makefile" "test -f Makefile"
check_item "Linker script" "test -f linker.ld"
check_item "GRUB config" "test -f grub.cfg"

echo ""
echo "Documentation Checks:"
echo "--------------------"

check_item "README" "test -f README.md"
check_item "Technical docs" "test -f docs/technical.md"
check_item "User guide" "test -f docs/user-guide.md"
check_item "Contributing guide" "test -f CONTRIBUTING.md"
check_item "Changelog" "test -f CHANGELOG.md"
check_item "License" "test -f LICENSE"

echo ""
echo "Tool Checks:"
echo "-----------"

check_item "Build script" "test -f tools/build.sh"
check_item "Install script" "test -f tools/install.sh"
check_item "Test runner" "test -f tests/run_tests.sh"
check_item "Quick start" "test -f quickstart.sh"

echo ""
echo "Build System Checks:"
echo "-------------------"

check_item "Build directory" "test -d build" "warning"
check_item "GCC compiler" "command -v gcc" "warning"
check_item "NASM assembler" "command -v nasm" "warning"
check_item "Linker" "command -v ld" "warning"
check_item "QEMU" "command -v qemu-system-x86_64" "warning"
check_item "GRUB" "command -v grub-mkrescue" "warning"

echo ""
echo "=================================="
echo "Check Results:"
echo "=================================="
echo -e "Passed:   ${GREEN}${CHECKS_PASSED}${NC}"
echo -e "Failed:   ${RED}${CHECKS_FAILED}${NC}"
echo -e "Warnings: ${YELLOW}${CHECKS_WARNING}${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ System check passed!${NC}"
    echo ""
    echo "Your Home Server OS installation is complete and ready."
    echo ""
    echo "Next steps:"
    echo "  1. Build the project: ${BLUE}make all${NC}"
    echo "  2. Run tests: ${BLUE}cd tests && ./run_tests.sh${NC}"
    echo "  3. Test in QEMU: ${BLUE}make run${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ System check failed!${NC}"
    echo ""
    echo "Please fix the failed checks before proceeding."
    echo ""
    if [ $CHECKS_WARNING -gt 0 ]; then
        echo -e "${YELLOW}Note: Warnings indicate missing optional tools.${NC}"
        echo "You can still build the project, but some features may not work."
        echo ""
    fi
    exit 1
fi
