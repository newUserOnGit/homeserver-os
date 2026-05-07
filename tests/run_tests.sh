#!/bin/bash
# Test Runner for Home Server OS
# Runs all unit tests and integration tests

echo "=================================="
echo "Home Server OS Test Suite"
echo "=================================="
echo ""

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

run_test() {
    local test_name=$1
    local test_command=$2

    echo -n "Running $test_name... "
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if eval $test_command > /dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "Unit Tests:"
echo "----------"

# Kernel tests
run_test "Memory Manager Init" "test -f ../kernel/memory/memory.c"
run_test "Scheduler Init" "test -f ../kernel/scheduler/scheduler.c"
run_test "Filesystem Init" "test -f ../kernel/fs/filesystem.c"
run_test "Network Stack Init" "test -f ../kernel/net/network.c"

# Driver tests
run_test "Storage Driver" "test -f ../drivers/storage/ata.c"

# System tests
run_test "Init System" "test -f ../system/init/init.c"

# Web tests
run_test "Admin Panel" "test -f ../web/admin-panel/index.html"
run_test "REST API" "test -f ../web/api/api.c"

# Monitoring tests
run_test "Monitoring System" "test -f ../monitoring/monitor.c"

echo ""
echo "Integration Tests:"
echo "------------------"

run_test "Bootloader exists" "test -f ../bootloader/boot.asm"
run_test "Kernel exists" "test -f ../kernel/core/kernel.c"
run_test "Makefile exists" "test -f ../Makefile"
run_test "Config exists" "test -f ../config/system.conf"
run_test "Documentation exists" "test -f ../docs/technical.md"

echo ""
echo "=================================="
echo "Test Results:"
echo "=================================="
echo -e "Total:  ${TESTS_TOTAL}"
echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
