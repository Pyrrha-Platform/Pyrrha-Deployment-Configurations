#!/bin/bash

# Pyrrha Development Startup Script
# This script helps start the development environment consistently

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔥 Starting Pyrrha Development Environment${NC}"

# Check if MDB_PASSWORD is set
if [ -z "$MDB_PASSWORD" ]; then
    echo -e "${RED}❌ Error: MDB_PASSWORD environment variable is not set${NC}"
    echo -e "${YELLOW}💡 Set it with: export MDB_PASSWORD=your_password${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker is not running${NC}"
    echo -e "${YELLOW}💡 Start Docker Desktop and try again${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Environment checks passed${NC}"

# Parse command line arguments
SERVICES="$*"
if [ -z "$SERVICES" ]; then
    echo -e "${YELLOW}🚀 Starting all services...${NC}"
    docker compose up --build
else
    echo -e "${YELLOW}🚀 Starting specific services: $SERVICES${NC}"
    docker compose up --build $SERVICES
fi