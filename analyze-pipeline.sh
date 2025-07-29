#!/bin/bash

# Quick Pipeline Analysis Tool
# Usage: ./analyze-pipeline.sh [run_id]

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🔬 GitHub Actions Pipeline Analyzer"
echo "==================================="

# Function to analyze pipeline results
analyze_results() {
    local run_id="$1"
    
    echo -e "${YELLOW}📋 Fetching pipeline logs...${NC}"
    if ! gh run view "$run_id" --log > pipeline_results.log 2>/dev/null; then
        echo -e "${RED}❌ Failed to fetch logs for run $run_id${NC}"
        return 1
    fi
    
    echo -e "\n${BLUE}🔍 ANALYSIS RESULTS${NC}"
    echo "==================="
    
    # Security scan results
    echo -e "\n${YELLOW}🛡️  Security Scans:${NC}"
    if grep -q "TruffleHog\|Semgrep\|CodeQL" pipeline_results.log; then
        echo "✅ Security tools executed"
        if grep -q "secret.*found\|vulnerability.*found\|security.*issue" pipeline_results.log; then
            echo -e "${RED}🚨 Security issues detected:${NC}"
            grep -A 5 -B 2 "secret.*found\|vulnerability.*found\|security.*issue" pipeline_results.log | head -20
        else
            echo -e "${GREEN}✅ No security issues found${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Security scans not found in logs${NC}"
    fi
    
    # ShellCheck results
    echo -e "\n${YELLOW}🔧 Code Quality (ShellCheck):${NC}"
    if grep -q "shellcheck" pipeline_results.log; then
        if grep -q "warning\|error" pipeline_results.log; then
            echo -e "${YELLOW}⚠️  ShellCheck warnings/errors:${NC}"
            grep -A 3 -B 1 "warning\|error" pipeline_results.log | head -15
        else
            echo -e "${GREEN}✅ No ShellCheck issues${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  ShellCheck results not found${NC}"
    fi
    
    # Test results
    echo -e "\n${YELLOW}🧪 Test Results:${NC}"
    if grep -q "PASSED\|FAILED" pipeline_results.log; then
        local passed=$(grep -c "✅ PASSED" pipeline_results.log || echo "0")
        local failed=$(grep -c "❌ FAILED" pipeline_results.log || echo "0")
        echo -e "Tests Passed: ${GREEN}$passed${NC}"
        echo -e "Tests Failed: ${RED}$failed${NC}"
        
        if [ "$failed" -gt 0 ]; then
            echo -e "\n${RED}Failed Tests:${NC}"
            grep -B 2 -A 2 "❌ FAILED" pipeline_results.log | head -20
        fi
    else
        echo -e "${YELLOW}⚠️  Test results not found${NC}"
    fi
    
    # Overall status
    echo -e "\n${BLUE}📊 OVERALL STATUS${NC}"
    echo "=================="
    local status=$(gh run view "$run_id" --json status,conclusion --jq '.status + " - " + (.conclusion // "running")')
    echo -e "Pipeline Status: ${BLUE}$status${NC}"
    
    # Count total issues
    local errors
    local warnings
    errors=$(grep -c "Error\|FAILED\|❌" pipeline_results.log 2>/dev/null || echo "0")
    warnings=$(grep -c "warning\|⚠️" pipeline_results.log 2>/dev/null || echo "0")
    echo -e "Total Errors: ${RED}$errors${NC}"
    echo -e "Total Warnings: ${YELLOW}$warnings${NC}"
    
    if [ "$errors" -gt 0 ]; then
        echo -e "\n${RED}🚨 ACTION REQUIRED: Fix errors above${NC}"
        return 1
    elif [ "$warnings" -gt 0 ]; then
        echo -e "\n${YELLOW}⚠️  REVIEW RECOMMENDED: Check warnings${NC}"
        return 0
    else
        echo -e "\n${GREEN}🎉 ALL CHECKS PASSED!${NC}"
        return 0
    fi
}

# Main logic
if [ "$1" ]; then
    RUN_ID="$1"
    echo -e "${BLUE}📊 Analyzing specific run: $RUN_ID${NC}"
else
    echo -e "${YELLOW}📋 Getting latest pipeline run...${NC}"
    RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)
    
    if [ -z "$RUN_ID" ]; then
        echo -e "${RED}❌ No pipeline runs found${NC}"
        echo -e "${YELLOW}💡 Try: gh run list${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Found latest run: $RUN_ID${NC}"
fi

# Run analysis
analyze_results "$RUN_ID"
exit_code=$?

echo -e "\n${BLUE}💡 Useful commands:${NC}"
echo "gh run list                    # List all runs"
echo "gh run watch $RUN_ID          # Watch run progress"
echo "gh run view $RUN_ID           # View run details"
echo "./analyze-pipeline.sh $RUN_ID # Re-analyze this run"

exit $exit_code
