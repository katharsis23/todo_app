#!/bin/bash

# !IMPORTANT: This script only checks for tests and linters
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" 

echo -e "${BLUE}Running pre-push checks...${NC}"

cd ../todo_app || { echo -e "${RED}Directory not found!${NC}"; exit 1; }

echo -e "${BLUE}Running flutter analyze...${NC}"
if flutter analyze; then
    echo -e "${GREEN}Flutter analyze passed${NC}"
else
    echo -e "${RED}Flutter analyze failed. Fix linting issues before pushing.${NC}"
    exit 1
fi

echo -e "${BLUE}Running flutter test...${NC}"
if flutter test; then
    echo -e "${GREEN}Flutter test passed${NC}"
else
    echo -e "${RED}Flutter test failed. Fix tests before pushing.${NC}"
    exit 1
fi

echo -e "${GREEN}All checks passed! Ready to push.${NC}"