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
- Accepts Git name/email as optional command-line arguments
- Creates a virtual environment in `~/cs580/.venv`
- Uses `cs580` as the displayed virtual environment prompt name when activated manually
- Installs dependencies from remote requirements files
- Installs CPU-only PyTorch separately when no GPU is detected
- Configures VS Code workspace settings and opens `~/cs580` using the `cs580` profile
- Verifies installation by importing core libraries

Requirements
------------
- WSL2 + Ubuntu 24.04 LTS
- Sudo privileges (user must be in sudoers)
- Internet connection
- Optional: NVIDIA GPU with drivers installed (for GPU path)
- VS Code already installed on the Windows host
- VS Code `code` command available in the WSL shell PATH

Usage
-----
1. Make the script executable:
   chmod +x setup_cs580.sh

2. Run the script as a regular user:
   ./setup_cs580.sh

3. Optional: provide Git name and email as arguments:
   ./setup_cs580.sh --name "Your Name" --email "you@example.com"

Do NOT run this script with sudo.

Configuration
-------------
- CRS_ID: Course ID used for the course folder, venv prompt, and VS Code profile
- PY_VER: Python version to install
- BASE_DIR: Root course directory created in the user's home directory
- REPO: Base URL for remote requirements files
- CPU_REQS: Requirements file for CPU-only setup
- GPU_REQS: Requirements file for GPU-enabled setup

Behavior
--------
1. Verifies script is not run as root
2. Parses optional command-line arguments
3. Confirms sudo access
4. Detects GPU availability once and stores the result
5. Updates system packages and installs dependencies
6. Installs Python and pip
7. Prompts user for Git configuration if not provided by CLI
8. Creates `~/cs580` and clones starter repo `0-0`
9. Creates a virtual environment in `~/cs580/.venv`
10. Installs:
    - CPU path: PyTorch (CPU-only) via custom index + CPU requirements
    - GPU path: All dependencies from GPU requirements file
11. Configures VS Code workspace settings and opens `~/cs580`
12. Verifies installation via import test and GPU-aware checks

Assumptions
-----------
- requirements_cpu.txt does NOT include torch/torchvision
- requirements_gpu.txt DOES include torch/torchvision
- Remote requirements files are accessible via the REPO URL
- VS Code is already installed on Windows and reachable from WSL via `code`

Notes
-----
- The virtual environment is created in `~/cs580/.venv`
- The activated prompt displays as `(cs580)` when the venv is activated manually
- All user-level configurations (Git, venv, VS Code profile usage)
  are owned by the invoking user
- System packages are installed via sudo and may prompt for a password
- PyTorch CPU wheels require a custom index and are installed separately
- To activate the virtual environment manually, run:
  `source ~/cs580/.venv/bin/activate`

Exit Behavior
-------------
- Script exits immediately on any error (`set -euo pipefail`)
- Clear status messages are printed throughout execution

DOC

set -euo pipefail

# === Script Constants ===
CRS_ID="cs580"
PY_VER="3.12"
BASE_DIR="$HOME/$CRS_ID"

REPO="https://raw.githubusercontent.com/cs580dl/0-1/refs/heads/main/wsl/"
CPU_REQS="requirements_cpu.txt"
GPU_REQS="requirements_gpu.txt"

# === Script State ===
HAS_GPU="false"
REQS_FILE=""
GIT_NAME=""
GIT_EMAIL=""

# === Define Script Functions ===
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)
        if [[ $# -lt 2 ]]; then
          echo "❌ Missing value for --name"
          exit 1
        fi
        GIT_NAME="$2"
        shift 2
        ;;
      --email)
        if [[ $# -lt 2 ]]; then
          echo "❌ Missing value for --email"
          exit 1
        fi
        GIT_EMAIL="$2"
        shift 2
        ;;
      -h|--help)
        echo "Usage: ./setup_cs580.sh [--name \"Your Name\"] [--email \"you@example.com\"]"
        exit 0
        ;;
      *)
        if [[ -z "$GIT_NAME" ]]; then
          GIT_NAME="$1"
        elif [[ -z "$GIT_EMAIL" ]]; then
          GIT_EMAIL="$1"
        else
          echo "❌ Unknown argument: $1"
          echo "Usage: ./setup_cs580.sh [--name \"Your Name\"] [--email \"you@example.com\"]"
          exit 1
        fi
        shift
        ;;
    esac
  done
}

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

detect_gpu() {
  if command -v nvidia-smi &>/dev/null; then
    HAS_GPU="true"
    REQS_FILE="$GPU_REQS"
    echo ">> NVIDIA GPU detected. Setting up GPU environment..."
  else
    HAS_GPU="false"
    REQS_FILE="$CPU_REQS"
    echo ">> No NVIDIA GPU detected. Setting up CPU environment..."
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
    bzip2 \
    curl \
    git \
    gzip \
    p7zip-full \
    tar \
    unrar \
    unzip \
    wget \
    xz-utils \
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

  if [[ -z "$GIT_NAME" ]]; then
    read -r -p "Enter your GitHub user name: " GIT_NAME
  else
    echo ">> Using provided GitHub user name: $GIT_NAME"
  fi

  if [[ -z "$GIT_EMAIL" ]]; then
    read -r -p "Enter your GitHub email: " GIT_EMAIL
  else
    echo ">> Using provided GitHub email: $GIT_EMAIL"
  fi

  if [[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]]; then
    echo "❌ Git user name and email are required."
    exit 1
  fi

  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"

  echo ">> Git configured with name: $GIT_NAME and email: $GIT_EMAIL"
}

create_dir_structure() {
  echo ">> Creating course directory structure..."
  mkdir -p "$BASE_DIR"
  cd "$BASE_DIR"

  if [[ ! -d "$BASE_DIR/0-0/.git" ]]; then
    echo ">> Cloning starter repo into $BASE_DIR/0-0..."
    git clone --depth 1 https://github.com/cs580dl/0-0.git
  else
    echo ">> Starter repo already exists at $BASE_DIR/0-0. Skipping clone."
  fi
}

create_venv() {
  echo ">> Creating virtual environment in $BASE_DIR/.venv..."
  cd "$BASE_DIR"
  "python${PY_VER}" -m venv --prompt "$CRS_ID" .venv

  echo ">> Activating virtual environment..."
  # shellcheck disable=SC1091
  source "$BASE_DIR/.venv/bin/activate"
}

setup_venv() {
  echo ">> Upgrading pip in virtual environment..."
  python -m pip install --upgrade pip

  if [[ "$HAS_GPU" == "false" ]]; then
    echo ">> Installing CPU-only PyTorch..."
    python -m pip install torch torchvision \
      --index-url https://download.pytorch.org/whl/cpu
  fi

  echo ">> Downloading Python dependencies from ${REPO}${REQS_FILE}..."
  curl -fsSL "${REPO}${REQS_FILE}" -o /tmp/requirements.txt

  echo ">> Installing Python dependencies from ${REQS_FILE}..."
  python -m pip install -r /tmp/requirements.txt

  rm -f /tmp/requirements.txt
}

set_cuda_paths() {
  if [[ "$HAS_GPU" == "true" ]]; then
    echo ">> Configuring CUDA library paths for the virtual environment..."

    local site_packages
    site_packages="$(python -c "import site; print(site.getsitepackages()[0])")"

    local cuda_ld_path
    cuda_ld_path="${site_packages}/nvidia/cuda_nvrtc/lib:${site_packages}/nvidia/cuda_runtime/lib:${site_packages}/nvidia/cudnn/lib:${site_packages}/nvidia/cublas/lib:${site_packages}/nvidia/cusolver/lib:${site_packages}/nvidia/cusparse/lib:\${LD_LIBRARY_PATH:-}"

    if ! grep -q "cuda_nvrtc" "$VIRTUAL_ENV/bin/activate"; then
      echo "export LD_LIBRARY_PATH=${cuda_ld_path}" >> "$VIRTUAL_ENV/bin/activate"
    fi
  fi
}

configure_vscode() {
  echo ">> Configuring VS Code workspace settings..."

  if ! command -v code &>/dev/null; then
    echo "⚠️  VS Code 'code' command not found in WSL PATH."
    echo "   Skipping VS Code configuration."
    echo "   Make sure VS Code is installed on Windows and the WSL 'code' command is available."
    return 0
  fi

  mkdir -p "$BASE_DIR/.vscode"

  cat > "$BASE_DIR/.vscode/settings.json" <<EOF
{
  "python.defaultInterpreterPath": "\${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "jupyter.notebookFileRoot": "\${workspaceFolder}"
}
EOF

  echo ">> Opening VS Code in $BASE_DIR with profile '$CRS_ID'..."
  code --profile "$CRS_ID" "$BASE_DIR"
}

verify_venv() {
  echo ">> Verifying virtual environment setup..."

  if [[ "$HAS_GPU" == "true" ]]; then
    python -c "
import transformers
import datasets
import sklearn
import torch
import tensorflow as tf

print('All imports successful!')
print(f'PyTorch version: {torch.__version__}')
print(f'TensorFlow version: {tf.__version__}')
print(f'PyTorch CUDA available: {torch.cuda.is_available()}')
print(f'TensorFlow GPUs detected: {len(tf.config.list_physical_devices(\"GPU\"))}')

if not torch.cuda.is_available():
    raise SystemExit('Expected GPU setup, but PyTorch CUDA is not available.')

if len(tf.config.list_physical_devices('GPU')) == 0:
    raise SystemExit('Expected GPU setup, but TensorFlow did not detect a GPU.')
"
  else
    python -c "
import transformers
import datasets
import sklearn
import torch
import tensorflow as tf

print('All imports successful!')
print(f'PyTorch version: {torch.__version__}')
print(f'TensorFlow version: {tf.__version__}')
print(f'PyTorch CUDA available: {torch.cuda.is_available()}')
print(f'TensorFlow GPUs detected: {len(tf.config.list_physical_devices(\"GPU\"))}')
print('CPU environment verification complete.')
"
  fi
}

# === Main Script Execution ===
parse_args "$@"
check_not_root
check_sudo_access
detect_gpu

update_system
install_common_tools
install_python
configure_git
create_dir_structure
create_venv
setup_venv
set_cuda_paths
configure_vscode
verify_venv

echo "✅ CS 580 WSL environment setup complete!"
echo ">> To activate the CS 580 virtual environment manually, run:"
echo ">> source ~/$CRS_ID/.venv/bin/activate"
echo ">> VS Code workspace settings have been configured for '$CRS_ID'."