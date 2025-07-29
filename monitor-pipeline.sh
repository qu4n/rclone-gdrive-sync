#!/bin/bash

# GitHub Actions Pipeline Monitor for rclone-gdrive-sync
# Usage: ./monitor-pipeline.sh [run_id]

echo "🔍 GitHub Actions Pipeline Monitor"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$1" ]; then
    RUN_ID="$1"
    echo -e "${BLUE}📊 Checking specific run: $RUN_ID${NC}"
else
    echo -e "${YELLOW}📋 Getting latest pipeline runs...${NC}"
    gh run list --limit 5
    
    echo -e "\n${BLUE}🔄 Getting latest run details...${NC}"
    RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
fi

if [ -z "$RUN_ID" ]; then
    echo -e "${RED}❌ No pipeline runs found${NC}"
    exit 1
fi

echo -e "\n${YELLOW}🚀 Pipeline Run Details:${NC}"
gh run view "$RUN_ID"

echo -e "\n${YELLOW}📝 Job Logs:${NC}"
gh run view "$RUN_ID" --log

echo -e "\n${YELLOW}📊 Run Status Summary:${NC}"
STATUS=$(gh run view "$RUN_ID" --json status,conclusion --jq '.status + " - " + .conclusion')
echo -e "Status: ${BLUE}$STATUS${NC}"

if gh run view "$RUN_ID" --json conclusion --jq '.conclusion' | grep -q "failure"; then
    echo -e "\n${RED}❌ PIPELINE FAILED - Analyzing errors...${NC}"
    echo -e "${YELLOW}Failed Job Details:${NC}"
    gh run view "$RUN_ID" --log | grep -A 5 -B 5 "Error\|FAIL\|❌"
elif gh run view "$RUN_ID" --json conclusion --jq '.conclusion' | grep -q "success"; then
    echo -e "\n${GREEN}✅ PIPELINE PASSED${NC}"
else
    echo -e "\n${YELLOW}⏳ PIPELINE RUNNING${NC}"
fi

echo -e "\n${BLUE}💡 To monitor in real-time: gh run watch $RUN_ID${NC}"
