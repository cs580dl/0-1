# CS 580 – Windows Setup

These instructions cover setting up a native Windows development environment on **Windows 10 (21H2+)** or **Windows 11**.

> **Recommendation:** Windows users are encouraged to use **Windows Subsystem for Linux (WSL)** instead of a purely native setup, because it provides a Linux environment that closely matches the course's target deployment environment. See [../wsl/README.md](../wsl/README.md) for those instructions.

---

## 1. Install Git for Windows

1. Download the installer from <https://git-scm.com/download/win>.
2. Run the installer. Accept the defaults, but on the **"Adjusting your PATH environment"** step select **"Git from the command line and also from 3rd-party software"**.
3. Open **PowerShell** or **Command Prompt** and verify:

```powershell
git --version
```

### Configure Git

```powershell
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

---

## 2. Install Python 3.10+

1. Download the latest Python 3 installer from <https://www.python.org/downloads/windows/>.
2. Run the installer. **Check the box "Add Python to PATH"** before clicking Install.
3. Verify in PowerShell:

```powershell
python --version   # should be 3.10 or higher
pip --version
```

---

## 3. Install Docker Desktop

1. Download **Docker Desktop for Windows** from <https://www.docker.com/products/docker-desktop/>.
2. Run the installer. When prompted, choose the **WSL 2 backend** if you have WSL installed; otherwise use the Hyper-V backend.
3. Launch Docker Desktop from the Start menu and wait for it to show "Docker Desktop is running."

Verify in PowerShell:

```powershell
docker --version
docker run --rm hello-world
```

> **Note:** Docker Desktop requires virtualization to be enabled in your BIOS/UEFI and either Hyper-V or WSL 2 to be enabled in Windows.

---

## 4. Install VS Code (Optional but Recommended)

Download and install from <https://code.visualstudio.com/download>.

Recommended extensions:
- **Python** (`ms-python.python`)
- **Docker** (`ms-azuretools.vscode-docker`)
- **GitLens** (`eamodio.gitlens`)

---

## Verification Checklist

Open **PowerShell** and run each command, confirming it prints a version string:

```powershell
git --version
python --version
pip --version
docker --version
```
