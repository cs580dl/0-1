1. Set script constants
2. Check for sudo
   1. Present, run script
   2. Not present, exit with message to run with sudo
3. Set GPU flag
4. Update and upgrade packages
5. Install common tools
6. Configure Git
7. Install user Python and pip
8. Create and activate venv
9.  Install requirements
    1.  If GPU, install from GPU_REQS_FILE
    2.  If CPU, install from CPU_REQS_FILE and CPU PyTorch
10. Create cs580 directory structure
11. Verify installation