#!/usr/bin/env bash
: <<'DOC'
CS 580 WSL Environment Setup Script

Overview
--------
This script automates the setup of a standardized development environment for
CS 580 (Deep Learning) on a WSL2/Ubuntu system. It installs required system
packages, configures Python, creates an isolated virtual environment, and
installs course-specific Python dependencies for either CPU-only or GPU-enabled
workflows.

The script is designed to be run by a regular user and uses `sudo` only for
system-level package installation.

Features
--------
- Detects NVIDIA GPU presence via `nvidia-smi`
- Selects CPU or GPU dependency set automatically
- Installs specified Python version and common development tools
- Configures Git global username and email
- Creates and activates a virtual environment
- Installs dependencies from remote requirements files
- Installs CPU-only PyTorch separately when no GPU is detected
- Verifies installation by importing core libraries

Requirements
------------
- WSL2 + Ubuntu 24.04 LTS
- Sudo privileges (user must be in sudoers)
- Internet connection
- Optional: NVIDIA GPU with drivers installed (for GPU path)

Usage
-----
1. Make the script executable:
   chmod +x setup_cs580.sh

2. Run the script as a regular user:
   ./setup_cs580.sh

Do NOT run this script with sudo.

Configuration
-------------
- PY_VER: Python version to install (default: 3.12)
- VENV_NAME: Name of the virtual environment directory
- REPO: Base URL for remote requirements files
- CPU_REQS: Requirements file for CPU-only setup
- GPU_REQS: Requirements file for GPU-enabled setup

Behavior
--------
1. Verifies script is not run as root
2. Confirms sudo access
3. Detects GPU availability
4. Updates system packages and installs dependencies
5. Installs Python and pip
6. Prompts user for Git configuration
7. Creates and activates a virtual environment
8. Installs:
   - CPU path: PyTorch (CPU-only) via custom index + CPU requirements
   - GPU path: All dependencies from GPU requirements file
9. Creates a course directory structure
10. Verifies installation via import test

Assumptions
-----------
- requirements_cpu.txt does NOT include torch/torchvision
- requirements_gpu.txt DOES include torch/torchvision
- Remote requirements files are accessible via the REPO URL

Notes
-----
- The virtual environment is created in the current working directory
- All user-level configurations (Git, venv) are owned by the invoking user
- System packages are installed via sudo and may prompt for a password
- PyTorch CPU wheels require a custom index and are installed separately

Exit Behavior
-------------
- Script exits immediately on any error (set -euo pipefail)
- Clear status messages are printed throughout execution

DOC

set -euo pipefail

# === Script Constants ===
PY_VER="3.12"
VENV_NAME="cs580"

REPO="https://raw.githubusercontent.com/cs580dl/0-1/refs/heads/main/wsl/"
CPU_REQS="requirements_cpu.txt"
GPU_REQS="requirements_gpu.txt"

# === Define Script Functions ===
check_not_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "⚠️  Please run this script as your normal user, not with sudo."
    echo "   Example: ./setup_cs580.sh"
    exit 1
  fi
}

check_sudo_access() {
  echo ">> Checking sudo access..."
  sudo -v
}

has_gpu() {
  if command -v nvidia-smi &>/dev/null; then
    echo ">> NVIDIA GPU detected. Setting up GPU environment..."
    return 0
  else
    echo ">> No NVIDIA GPU detected. Setting up CPU environment..."
    return 1
  fi
}

update_system() {
  echo ">> Updating APT package index..."
  sudo apt-get update -y

  echo ">> Installing repository tools..."
  sudo apt-get install -y software-properties-common

  echo ">> Adding deadsnakes PPA repository..."
  sudo add-apt-repository ppa:deadsnakes/ppa -y

  echo ">> Updating APT package index again..."
  sudo apt-get update -y

  echo ">> Upgrading installed packages..."
  sudo apt-get upgrade -y
}

install_common_tools() {
  echo ">> Installing common tools..."
  sudo apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    bzip2 \
    gzip \
    p7zip-full \
    unrar \
    tar \
    xz-utils \
    unzip \
    zip
}

install_python() {
  echo ">> Installing Python $PY_VER and pip..."
  sudo apt-get install -y \
    "python${PY_VER}-full" \
    python3-pip
}

configure_git() {
  echo ">> Configuring Git..."

  read -r -p "Enter your GitHub user name: " github_name
  read -r -p "Enter your GitHub email: " github_email

  git config --global user.name "$github_name"
  git config --global user.email "$github_email"

  echo ">> Git configured with name: $github_name and email: $github_email"
}

create_venv() {
  echo ">> Creating virtual environment in $VENV_NAME..."
  "python${PY_VER}" -m venv "$VENV_NAME"

  echo ">> Activating virtual environment..."
  # shellcheck disable=SC1091
  source "$VENV_NAME/bin/activate"
}

setup_venv() {
  echo ">> Upgrading pip in virtual environment..."
  python -m pip install --upgrade pip

  if [[ "$reqs_file" == "$CPU_REQS" ]]; then
    echo ">> Installing CPU-only PyTorch..."
    python -m pip install torch torchvision \
      --index-url https://download.pytorch.org/whl/cpu
  fi

  echo ">> Downloading Python dependencies from ${REPO}${reqs_file}..."
  curl -fsSL "${REPO}${reqs_file}" -o /tmp/requirements.txt

  echo ">> Installing Python dependencies from ${reqs_file}..."
  python -m pip install -r /tmp/requirements.txt

  rm -f /tmp/requirements.txt
}

create_dir_structure() {
  echo ">> Creating directory structure..."
  mkdir -p cs580
}

verify_venv() {
  echo ">> Verifying virtual environment setup..."
  python -c "import transformers; import datasets; import sklearn; import torch; import tensorflow; print('All imports successful!')"
}

# === Main Script Execution ===
check_not_root
check_sudo_access

if has_gpu; then
  reqs_file="$GPU_REQS"
else
  reqs_file="$CPU_REQS"
fi

update_system
install_common_tools
configure_git
install_python
create_venv
setup_venv
create_dir_structure
verify_venv
cd cs580

echo "✅ CS 580 WSL environment setup complete!"