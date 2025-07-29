#!/bin/bash

# Basic Functionality Tests for rclone-gdrive-sync
# Heavy security scanning handled by GitHub Actions with professional tools

echo "🧪 rclone-gdrive-sync Basic Functionality Tests"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit_code="${3:-0}"
    
    ((TOTAL_TESTS++))
    echo -e "\n${BLUE}🔍 Testing: $test_name${NC}"
    
    if eval "$test_command"; then
        if [ $? -eq $expected_exit_code ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ FAILED (unexpected exit code)${NC}"
            ((FAILED_TESTS++))
        fi
    else
        if [ $? -eq $expected_exit_code ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ FAILED${NC}"
            ((FAILED_TESTS++))
        fi
    fi
}

echo -e "\n${YELLOW}� FUNCTIONALITY TESTS${NC}"
echo "======================="

# Test 1: Usage Help
run_test "Usage Help Display" "./sync_script.sh 2>&1 | grep -q 'Usage:'" 0

# Test 2: Available Folders List
run_test "Google Drive Folder List" "./sync_script.sh 2>&1 | grep -q 'Available folders'" 0

# Test 3: Script Permissions
run_test "Script Executable" "test -x sync_script.sh"

# Test 4: Input Validation - Injection Protection
run_test "Input Validation (Injection)" "./sync_script.sh 'test;injection' 2>&1 | grep -q 'invalid characters'" 0

# Test 5: Input Validation - Command Injection
run_test "Input Validation (Command)" "./sync_script.sh 'test\$(rm -rf /)' 2>&1 | grep -q 'invalid characters'" 0

# Test 6: Space Support
run_test "Input Validation (Spaces)" "./sync_script.sh 'test spaces' 2>&1 | grep -q 'not found in your Google Drive'" 0

echo -e "\n${YELLOW}📚 DOCUMENTATION TESTS${NC}"
echo "======================="

# Test 7: README exists and has content
run_test "README Exists" "test -f README.md && test -s README.md"

# Test 8: Installation instructions
run_test "Installation Instructions" "grep -q 'git clone' README.md"

# Test 9: Usage examples in script
run_test "Usage Examples" "grep -q 'my_documents' sync_script.sh"

echo -e "\n${YELLOW}🔧 CONFIGURATION TESTS${NC}"
echo "======================="

# Test 10: Configuration section exists
run_test "Configuration Variables" "grep -q 'GDRIVE_REMOTE=' sync_script.sh"

# Test 11: Relative paths used
run_test "Relative Path Usage" "grep -q 'SCRIPT_DIR=' sync_script.sh"

echo -e "\n=============================================="
echo -e "${BLUE}📊 TEST SUMMARY${NC}"
echo "=============================================="
echo -e "Total Tests:  ${TOTAL_TESTS}"
echo -e "Passed:       ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Failed:       ${RED}${FAILED_TESTS}${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL FUNCTIONALITY TESTS PASSED!${NC}"
    echo -e "${GREEN}✅ Security scanning handled by GitHub Actions${NC}"
    exit 0
else
    echo -e "\n${RED}💥 SOME TESTS FAILED!${NC}"
    echo -e "${YELLOW}Please review the failed tests above.${NC}"
    exit 1
fi
