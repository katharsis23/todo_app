#!/bin/bash

# Docker wrapper script for todo_app
# Usage: ./docker-wrapper.sh [command] [mode]
# Commands: build, run, stop, clean, lint, test, preview
# Modes: debug, release (default: release)

set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/todo_app"

# Default values
COMMAND=""
MODE="release"
PORT_DEV="8080"
PORT_RELEASE="8081"

show_help() {
    echo -e "${BLUE}Docker wrapper for todo_app${NC}"
    echo ""
    echo "Usage: $0 [command] [mode]"
    echo ""
    echo "Commands:"
    echo "  build     Build Docker image"
    echo "  run       Run Docker container"
    echo "  stop      Stop running containers"
    echo "  clean     Remove images and containers"
    echo "  preview   Build and run for preview"
    echo ""
    echo "Modes:"
    echo "  debug     Debug mode (port $PORT_DEV)"
    echo "  release  Release mode (port $PORT_RELEASE) [default]"
    echo ""
    echo "Examples:"
    echo "  $0 build release"
    echo "  $0 run debug"
    echo "  $0 preview"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        exit 1
    fi
}

get_image_name() {
    local mode=$1
    echo "todo-app:$mode"
}

get_container_name() {
    local mode=$2
    echo "todo-app-$mode"
}

get_port() {
    local mode=$1
    if [ "$mode" = "debug" ]; then
        echo "$PORT_DEV"
    else
        echo "$PORT_RELEASE"
    fi
}

build_image() {
    local mode=$1
    local image_name=$(get_image_name $mode)
    
    echo -e "${BLUE}Building Docker image: $image_name${NC}"
    cd "$DOCKER_DIR"
    
    docker build \
        --build-arg RELEASE_MODE=$mode \
        -t $image_name \
        .
    
    echo -e "${GREEN}✓ Built image: $image_name${NC}"
}

run_container() {
    local mode=$1
    local image_name=$(get_image_name $mode)
    local container_name=$(get_container_name $mode)
    local port=$(get_port $mode)
    
    echo -e "${BLUE}Running container: $container_name on port $port${NC}"
    
    # Stop existing container if running
    docker stop $container_name 2>/dev/null || true
    docker rm $container_name 2>/dev/null || true
    
    # Run new container
    docker run -d \
        --name $container_name \
        -p $port:80 \
        $image_name
    
    echo -e "${GREEN}✓ Container running: http://localhost:$port${NC}"
}

stop_containers() {
    echo -e "${BLUE}Stopping todo-app containers...${NC}"
    
    docker stop todo-app-debug 2>/dev/null || true
    docker stop todo-app-release 2>/dev/null || true
    
    echo -e "${GREEN}✓ Containers stopped${NC}"
}

clean() {
    echo -e "${BLUE}Cleaning Docker resources...${NC}"
    
    # Stop containers
    stop_containers
    
    # Remove containers
    docker rm todo-app-debug 2>/dev/null || true
    docker rm todo-app-release 2>/dev/null || true
    
    # Remove images
    docker rmi todo-app:debug 2>/dev/null || true
    docker rmi todo-app:release 2>/dev/null || true
    
    # Clean up dangling images
    docker image prune -f
    
    echo -e "${GREEN}✓ Cleanup completed${NC}"
}

run_lint() {
    echo -e "${BLUE}Running flutter analyze for web...${NC}"
    cd "$DOCKER_DIR"
    
    docker run --rm \
        -v "$(pwd):/app" \
        -w /app \
        -u $(id -u):$(id -g) \
        -e GIT_CONFIG_GLOBAL=/dev/null \
        -e GIT_CONFIG_NOSYSTEM=1 \
        growerp/flutter-sdk-image:3.35.6 \
        sh -c "
          export FLUTTER_ROOT=/home/mobiledevops/.flutter-sdk &&
          export GIT_DIR=/dev/null &&
          mkdir -p /app/.flutter-plugins-dependencies 2>/dev/null || true &&
          chmod -R 777 /app/.flutter-plugins-dependencies 2>/dev/null || true &&
          chmod -R 777 /app/.dart_tool 2>/dev/null || true &&
          flutter config --enable-web || true &&
          flutter analyze --no-pub
        "
    
    echo -e "${GREEN}✓ Linting completed${NC}"
}

run_test() {
    echo -e "${BLUE}Running flutter test for web...${NC}"
    cd "$DOCKER_DIR"
    
    docker run --rm \
        -v "$(pwd):/app" \
        -w /app \
        -u $(id -u):$(id -g) \
        -e GIT_CONFIG_GLOBAL=/dev/null \
        -e GIT_CONFIG_NOSYSTEM=1 \
        growerp/flutter-sdk-image:3.35.6 \
        sh -c "
          export FLUTTER_ROOT=/home/mobiledevops/.flutter-sdk &&
          export GIT_DIR=/dev/null &&
          mkdir -p /app/.flutter-plugins-dependencies 2>/dev/null || true &&
          chmod -R 777 /app/.flutter-plugins-dependencies 2>/dev/null || true &&
          chmod -R 777 /app/.dart_tool 2>/dev/null || true &&
          flutter config --enable-web || true &&
          flutter test --no-pub
        "
    
    echo -e "${GREEN}✓ Tests completed${NC}"
}

preview() {
    local mode=${1:-release}
    echo -e "${BLUE}Building and running preview ($mode mode)...${NC}"
    
    build_image $mode
    run_container $mode
    
    local port=$(get_port $mode)
    echo -e "${GREEN}🚀 Preview ready at: http://localhost:$port${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop the container${NC}"
    
    # Wait for interrupt
    trap 'stop_containers' EXIT
    sleep infinity
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1

# Set mode if provided
if [ $# -gt 1 ]; then
    MODE=$2
fi

# Validate mode
if [ "$MODE" != "debug" ] && [ "$MODE" != "release" ]; then
    echo -e "${RED}Error: Invalid mode '$MODE'. Use 'debug' or 'release'${NC}"
    exit 1
fi

check_docker

# Execute command
case $COMMAND in
    build)
        build_image $MODE
        ;;
    run)
        run_container $MODE
        ;;
    stop)
        stop_containers
        ;;
    clean)
        clean
        ;;
    lint)
        run_lint
        ;;
    test)
        run_test
        ;;
    preview)
        preview $MODE
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$COMMAND'${NC}"
        show_help
        exit 1
        ;;
esac
