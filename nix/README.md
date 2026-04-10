# CS 580 – Linux Setup

These instructions have been tested on **Ubuntu 22.04 LTS** and **Fedora 38**. Commands for other distributions may differ slightly; adjust as needed.

---

## 1. Update Your Package Manager

**Ubuntu / Debian:**
```bash
sudo apt update && sudo apt upgrade -y
```

**Fedora / RHEL:**
```bash
sudo dnf upgrade -y
```

---

## 2. Install Git

**Ubuntu / Debian:**
```bash
sudo apt install -y git
```

**Fedora / RHEL:**
```bash
sudo dnf install -y git
```

Verify:
```bash
git --version
```

---

## 3. Install Python 3.10+

**Ubuntu / Debian:**
```bash
sudo apt install -y python3 python3-pip python3-venv
```

**Fedora / RHEL:**
```bash
sudo dnf install -y python3 python3-pip
```

Verify:
```bash
python3 --version   # should be 3.10 or higher
pip3 --version
```

---

## 4. Install Docker Engine

Follow the official instructions for your distribution:

- Ubuntu: <https://docs.docker.com/engine/install/ubuntu/>
- Fedora: <https://docs.docker.com/engine/install/fedora/>

After installation, add your user to the `docker` group so you can run Docker without `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify:
```bash
docker --version
docker run --rm hello-world
```

---

## 5. Install VS Code (Optional but Recommended)

Download the `.deb` or `.rpm` package from <https://code.visualstudio.com/download> and install it, or use your distribution's package manager / snap:

```bash
# Ubuntu snap
sudo snap install --classic code
```

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
