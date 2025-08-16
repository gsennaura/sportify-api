#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BOLD}Checking SportifyAPI prerequisites...${NC}\n"

# Check for .env file
if [ -f "$(pwd)/.env" ]; then
    echo -e "✅ ${GREEN}.env file exists${NC}"
else
    echo -e "❌ ${RED}.env file does not exist${NC}"
    echo -e "   ${YELLOW}Please create one by copying .env.example:${NC}"
    echo -e "   ${BOLD}cp .env.example .env${NC}"
    echo -e "   ${YELLOW}Then edit it with your configuration.${NC}\n"
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python version
check_python_version() {
    if command_exists python3; then
        python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        if [[ $(echo "$python_version >= 3.12" | bc) -eq 1 ]]; then
            echo -e "✅ ${GREEN}Python $python_version is installed${NC}"
            return 0
        else
            echo -e "❌ ${RED}Python $python_version is installed, but version 3.12 or higher is required${NC}"
            return 1
        fi
    else
        echo -e "❌ ${RED}Python 3 is not installed${NC}"
        return 1
    fi
}

# Function to check Docker
check_docker() {
    if command_exists docker; then
        docker_version=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
        echo -e "✅ ${GREEN}Docker $docker_version is installed${NC}"
        return 0
    else
        echo -e "❌ ${RED}Docker is not installed${NC}"
        return 1
    fi
}

# Function to check Docker Compose
check_docker_compose() {
    if command_exists docker-compose; then
        docker_compose_version=$(docker-compose --version | cut -d ' ' -f3 | cut -d ',' -f1)
        echo -e "✅ ${GREEN}Docker Compose $docker_compose_version is installed${NC}"
        return 0
    elif command_exists docker && docker compose version >/dev/null 2>&1; then
        docker_compose_plugin_version=$(docker compose version --short)
        echo -e "✅ ${GREEN}Docker Compose plugin $docker_compose_plugin_version is installed${NC}"
        return 0
    else
        echo -e "❌ ${RED}Docker Compose is not installed${NC}"
        return 1
    fi
}

# Function to check PostgreSQL
check_postgres() {
    if command_exists psql; then
        pg_version=$(psql --version | cut -d ' ' -f3)
        echo -e "✅ ${GREEN}PostgreSQL client $pg_version is installed${NC}"
        return 0
    else
        echo -e "⚠️ ${YELLOW}PostgreSQL client is not installed locally${NC}"
        echo -e "   ${YELLOW}(This is optional as PostgreSQL runs in Docker)${NC}"
        return 0  # Not critical since PostgreSQL runs in Docker
    fi
}

# Function to check Poetry
check_poetry() {
    if command_exists poetry; then
        poetry_version=$(poetry --version | cut -d ' ' -f3)
        echo -e "✅ ${GREEN}Poetry $poetry_version is installed${NC}"
        return 0
    else
        echo -e "❌ ${RED}Poetry is not installed${NC}"
        return 1
    fi
}

# Function to install Poetry
install_poetry() {
    echo -e "\n${BOLD}Installing Poetry...${NC}"
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add Poetry to PATH for the current session
    export PATH="$HOME/.local/bin:$PATH"
    
    if command_exists poetry; then
        echo -e "✅ ${GREEN}Poetry has been installed successfully${NC}"
    else
        echo -e "❌ ${RED}Failed to install Poetry. Please install it manually:${NC}"
        echo -e "   ${YELLOW}https://python-poetry.org/docs/#installation${NC}"
    fi
}

# Function to check Python packages with Poetry
check_python_packages() {
    echo -e "\n${BOLD}Checking if Python packages can be installed...${NC}"
    
    if command_exists poetry; then
        echo -e "Running 'poetry check' to validate pyproject.toml..."
        if poetry check; then
            echo -e "✅ ${GREEN}pyproject.toml is valid${NC}"
        else
            echo -e "⚠️ ${YELLOW}There might be issues with pyproject.toml${NC}"
        fi
        
        echo -e "\nTo install dependencies, run: ${BOLD}poetry install${NC}"
    else
        echo -e "❌ ${RED}Poetry is not installed, cannot verify Python packages${NC}"
    fi
}

# Function to provide Docker installation instructions
docker_install_instructions() {
    echo -e "\n${BOLD}Docker Installation Instructions:${NC}"
    echo -e "Please follow the official Docker installation guide:"
    echo -e "${YELLOW}https://docs.docker.com/get-docker/${NC}"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "\n${BOLD}Quick install for Ubuntu/Debian:${NC}"
        echo -e "sudo apt update"
        echo -e "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common"
        echo -e "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
        echo -e "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\""
        echo -e "sudo apt update"
        echo -e "sudo apt install -y docker-ce docker-compose"
        echo -e "sudo usermod -aG docker \$USER"
        echo -e "newgrp docker"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "\n${BOLD}For macOS:${NC}"
        echo -e "Install Docker Desktop from: ${YELLOW}https://docs.docker.com/docker-for-mac/install/${NC}"
    fi
}

# Function to provide Python installation instructions
python_install_instructions() {
    echo -e "\n${BOLD}Python 3.12 Installation Instructions:${NC}"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "\n${BOLD}For Ubuntu/Debian:${NC}"
        echo -e "sudo apt update"
        echo -e "sudo apt install -y software-properties-common"
        echo -e "sudo add-apt-repository ppa:deadsnakes/ppa"
        echo -e "sudo apt update"
        echo -e "sudo apt install -y python3.12 python3.12-venv python3.12-dev"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "\n${BOLD}For macOS (using Homebrew):${NC}"
        echo -e "brew update"
        echo -e "brew install python@3.12"
    fi
    
    echo -e "\n${BOLD}Alternatively, you can use pyenv to manage Python versions:${NC}"
    echo -e "curl https://pyenv.run | bash"
    echo -e "pyenv install 3.12.0"
    echo -e "pyenv global 3.12.0"
}

# Main execution
missing_deps=0
env_file_missing=0

# Check for .env file
if [ ! -f "$(pwd)/.env" ]; then
    env_file_missing=1
fi

# Perform checks
check_python_version || ((missing_deps++))
check_docker || ((missing_deps++))
check_docker_compose || ((missing_deps++))
check_postgres
check_poetry || ((missing_deps++))

echo -e "\n${BOLD}Summary:${NC}"
if [ $missing_deps -eq 0 ] && [ $env_file_missing -eq 0 ]; then
    echo -e "✅ ${GREEN}All core dependencies are installed!${NC}"
else
    if [ $missing_deps -gt 0 ]; then
        echo -e "❌ ${RED}$missing_deps core dependencies are missing.${NC}"
    fi
    
    if [ $env_file_missing -eq 1 ]; then
        echo -e "❌ ${RED}.env file is missing. Please create it from .env.example${NC}"
    fi
    
    # Offer installation options
    if ! command_exists python3 || [[ $(python3 -c 'import sys; print(sys.version_info[0] >= 3 and sys.version_info[1] >= 12)') != "True" ]]; then
        python_install_instructions
    fi
    
    if ! command_exists docker || ! command_exists docker-compose; then
        docker_install_instructions
    fi
    
    if ! command_exists poetry; then
        echo -e "\n${BOLD}Would you like to install Poetry now? (y/n)${NC}"
        read -r install_poetry_response
        if [[ "$install_poetry_response" =~ ^[Yy]$ ]]; then
            install_poetry
        else
            echo -e "You can install Poetry later by following: ${YELLOW}https://python-poetry.org/docs/#installation${NC}"
        fi
    fi
fi

# Add useful next steps guidance if everything is set up
if [ $missing_deps -eq 0 ] && [ $env_file_missing -eq 0 ]; then
    echo -e "\n${BOLD}Next steps:${NC}"
    echo -e "1. Make sure all dependencies are installed"
    echo -e "2. Run: ${BOLD}make docker-up${NC} to start the application with Docker"
    echo -e "3. Visit ${BOLD}http://localhost:8000/docs${NC} to access the API documentation"
fi

# Check Python packages regardless of whether we're missing dependencies
check_python_packages

echo -e "\n${BOLD}Next steps:${NC}"
echo -e "1. Make sure all dependencies are installed"
echo -e "2. Run: ${BOLD}make docker-up${NC} to start the application with Docker"
echo -e "3. Visit http://localhost:8000/docs to access the API documentation"
