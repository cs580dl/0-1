# CS 580 – macOS Setup

These instructions apply to **macOS Ventura (13)** and later, on both Apple Silicon (M-series) and Intel Macs.

---

## 1. Install Xcode Command-Line Tools

Open **Terminal** and run:

```bash
xcode-select --install
```

Follow the on-screen prompts. This installs Git, clang, and other essential developer tools.

Verify:
```bash
git --version
```

---

## 2. Install Homebrew

[Homebrew](https://brew.sh/) is the recommended package manager for macOS.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, follow any instructions printed to your terminal to add `brew` to your `PATH` (especially important on Apple Silicon).

Verify:
```bash
brew --version
```

---

## 3. Install Python 3.10+

The course requires Python 3.10 or higher. The command below installs Python 3.12 (the current stable Homebrew formula), which satisfies that requirement.

```bash
brew install python@3.12
```

Homebrew installs Python as `python3`. Verify:

```bash
python3 --version   # should be 3.10 or higher
pip3 --version
```

---

## 4. Install Docker Desktop

1. Download **Docker Desktop for Mac** from <https://www.docker.com/products/docker-desktop/>.  
   - Choose the **Apple Silicon** or **Intel** installer to match your Mac.
2. Open the downloaded `.dmg` and drag Docker to your Applications folder.
3. Launch Docker from Applications and complete the onboarding wizard.

Verify (after Docker has started):
```bash
docker --version
docker run --rm hello-world
```

---

## 5. Install VS Code (Optional but Recommended)

```bash
brew install --cask visual-studio-code
```

Or download directly from <https://code.visualstudio.com/download>.

---

## 6. Configure Git

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

---

## Verification Checklist

Run each command and confirm it prints a version string:

```bash
git --version
python3 --version
pip3 --version
docker --version
```
