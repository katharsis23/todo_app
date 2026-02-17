#!/bin/bash

# Simple web preview without Docker
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FLUTTER_DIR="$PROJECT_DIR/todo_app"

show_help() {
    echo -e "${BLUE}Web preview for todo_app${NC}"
    echo ""
    echo "Usage: $0 [mode]"
    echo ""
    echo "Modes:"
    echo "  debug     Debug mode"
    echo "  release  Release mode [default]"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 release"
    echo "  $0 debug"
}

check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}Error: Flutter is not installed${NC}"
        exit 1
    fi
}

build_and_serve() {
    local mode=${1:-release}
    local port=8080
    
    echo -e "${BLUE}Building and serving web app ($mode mode)...${NC}"
    cd "$FLUTTER_DIR"
    
    # Clean previous build
    rm -rf build/web
    
    # Build
    echo -e "${BLUE}Building web app...${NC}"
    flutter build web --$mode
    
    # Check if build succeeded
    if [ ! -d "build/web" ]; then
        echo -e "${RED}Build failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Build completed${NC}"
    
    # Serve with Python
    echo -e "${BLUE}Starting web server on port $port...${NC}"
    echo -e "${GREEN}🚀 Preview ready at: http://localhost:$port${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
    
    cd build/web
    
    # Try Python 3, then Python 2
    if command -v python3 &> /dev/null; then
        python3 -m http.server $port
    elif command -v python &> /dev/null; then
        python -m SimpleHTTPServer $port
    else
        echo -e "${RED}Error: Python is not installed${NC}"
        exit 1
    fi
}

# Parse arguments
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

MODE=${1:-release}

# Validate mode
if [ "$MODE" != "debug" ] && [ "$MODE" != "release" ]; then
    echo -e "${RED}Error: Invalid mode '$MODE'. Use 'debug' or 'release'${NC}"
    show_help
    exit 1
fi

check_flutter
build_and_serve $MODE
