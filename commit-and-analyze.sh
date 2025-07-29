#!/bin/bash

# Real-time CI/CD Pipeline Analysis Tool
# Usage: 
#   ./commit-and-analyze.sh                    # Interactive commit message
#   ./commit-and-analyze.sh "your message"     # Direct commit message
#   ./commit-and-analyze.sh                    # Analyze recent pipeline if no changes

echo "🚀 CI/CD Pipeline Analysis Workflow"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to analyze pipeline results
analyze_results() {
    local run_id="$1"
    echo -e "\n${BLUE}🔬 PIPELINE ANALYSIS${NC}"
    echo "===================="
    
    # Get detailed logs
    echo -e "${YELLOW}📋 Collecting logs...${NC}"
    gh run view "$run_id" --log > pipeline_results.log
    
    # Analyze different types of issues
    echo -e "\n${YELLOW}🔍 Security Scan Results:${NC}"
    if grep -q "TruffleHog\|Semgrep\|CodeQL" pipeline_results.log; then
        grep -A 10 -B 5 "TruffleHog\|Semgrep\|CodeQL\|Secret\|Vulnerability" pipeline_results.log | head -50
    else
        echo "No security scan output found"
    fi
    
    echo -e "\n${YELLOW}🔍 ShellCheck Results:${NC}"
    if grep -q "shellcheck" pipeline_results.log; then
        grep -A 10 -B 5 "shellcheck\|warning\|error" pipeline_results.log | head -30
    else
        echo "No ShellCheck issues found"
    fi
    
    echo -e "\n${YELLOW}🔍 Test Failures:${NC}"
    if grep -q "FAILED\|Error\|❌" pipeline_results.log; then
        grep -A 5 -B 5 "FAILED\|Error\|❌" pipeline_results.log | head -40
    else
        echo "No test failures found"
    fi
    
    # Summary
    echo -e "\n${BLUE}📊 ANALYSIS SUMMARY${NC}"
    echo "==================="
    local total_errors=$(grep -c "Error\|FAILED\|❌" pipeline_results.log || echo "0")
    local total_warnings=$(grep -c "warning\|⚠️" pipeline_results.log || echo "0")
    
    echo -e "Errors: ${RED}$total_errors${NC}"
    echo -e "Warnings: ${YELLOW}$total_warnings${NC}"
    
    if [ "$total_errors" -gt 0 ]; then
        echo -e "\n${RED}🚨 ACTION REQUIRED: Fix the errors above${NC}"
        return 1
    elif [ "$total_warnings" -gt 0 ]; then
        echo -e "\n${YELLOW}⚠️  WARNINGS FOUND: Review recommended${NC}"
        return 0
    else
        echo -e "\n${GREEN}✅ ALL CHECKS PASSED${NC}"
        return 0
    fi
}

# Commit and trigger pipeline
echo -e "${BLUE}📝 Preparing to commit changes...${NC}"

# Check if there are changes to commit
if git diff --cached --quiet && git diff --quiet; then
    echo -e "${YELLOW}⚠️  No changes detected. Checking recent pipeline...${NC}"
    RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)
    if [ -n "$RUN_ID" ]; then
        echo -e "${BLUE}🔬 Analyzing most recent pipeline...${NC}"
        analyze_results "$RUN_ID"
        exit $?
    else
        echo -e "${RED}❌ No changes to commit and no recent pipelines found${NC}"
        exit 1
    fi
fi

# Get commit message
if [ "$1" ]; then
    COMMIT_MSG="$1"
else
    echo -e "${YELLOW}📝 Enter commit message (or press Enter for default):${NC}"
    read -r USER_INPUT
    if [ -n "$USER_INPUT" ]; then
        COMMIT_MSG="$USER_INPUT"
    else
        COMMIT_MSG="chore: update rclone-gdrive-sync configuration"
    fi
fi

echo -e "${BLUE}💾 Committing with message: '$COMMIT_MSG'${NC}"
git add .
git commit -m "$COMMIT_MSG"

echo -e "\n${BLUE}🚀 Pushing to trigger pipeline...${NC}"
git push origin main

echo -e "\n${YELLOW}⏳ Waiting for pipeline to start...${NC}"
sleep 10

# Get the latest run
RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)

if [ -z "$RUN_ID" ]; then
    echo -e "${RED}❌ Pipeline not started yet. Try: ./monitor-pipeline.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Pipeline started! Run ID: $RUN_ID${NC}"

# Watch the pipeline
echo -e "\n${BLUE}👀 Watching pipeline progress...${NC}"
gh run watch "$RUN_ID" || true

# Analyze results when complete
echo -e "\n${BLUE}🔬 Analyzing results...${NC}"
analyze_results "$RUN_ID"
