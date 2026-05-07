# Home Server OS - Project Structure

Date: 2026-05-07
Version: 0.2.0 (Linux-based)

## Overview

Home Server OS is now based on Linux kernel 6.12.28. The project structure has been reorganized to support real OS development.

## Directory Structure

```
C:\NewProject\
│
├── linux-kernel/              # Linux 6.12.28 source (symlink to c:\core\linux-6.12.28)
│   ├── arch/                  # Architecture-specific code
│   ├── drivers/               # Device drivers
│   ├── fs/                    # Filesystems
│   ├── kernel/                # Core kernel
│   ├── net/                   # Network stack
│   └── ...
│
├── config/                    # Kernel and system configuration
│   ├── kernel.config          # Custom kernel configuration
│   ├── buildroot.config       # Userspace build configuration
│   └── system.config          # System settings
│
├── userspace/                 # Home Server OS userspace applications
│   ├── init/                  # Init system
│   ├── services/              # System services
│   ├── tools/                 # Command-line tools
│   └── libraries/             # Shared libraries
│
├── web-panel/                 # Web management interface
│   ├── frontend/              # HTML/CSS/JavaScript
│   │   ├── index.html
│   │   ├── css/
│   │   ├── js/
│   │   └── assets/
│   ├── backend/               # REST API server
│   │   ├── api/
│   │   ├── auth/
│   │   └── handlers/
│   └── config/
│
├── build/                     # Build system
│   ├── scripts/               # Build scripts
│   ├── toolchain/             # Cross-compilation tools
│   ├── rootfs/                # Root filesystem template
│   └── iso/                   # ISO creation
│
├── docs/                      # Documentation
│   ├── architecture/          # System architecture
│   ├── api/                   # API documentation
│   ├── user-guide.md          # User guide
│   ├── technical.md           # Technical documentation
│   └── educational/           # Educational materials (old kernel code)
│       ├── kernel/
│       ├── memory/
│       └── scheduler/
│
├── kernel/                    # OLD educational kernel (moved to docs/educational/)
├── bootloader/                # OLD educational bootloader
├── drivers/                   # OLD educational drivers
│
├── tools/                     # Development tools
│   ├── git-push.bat           # Git push script
│   ├── simple-git-push.ps1    # PowerShell git script
│   └── github-setup.ps1       # GitHub setup
│
├── tests/                     # Test suite
│   ├── unit/
│   ├── integration/
│   └── system/
│
├── README.md                  # Project overview
├── INTEGRATION_PLAN.md        # Linux integration plan
├── PROJECT_STRUCTURE.md       # This file
├── CHANGELOG.md               # Change log
├── Makefile                   # Main build file
└── .gitignore                 # Git ignore rules
```

## Key Components

### 1. Linux Kernel (linux-kernel/)
- **Source**: Linux 6.12.28 "Baby Opossum Posse"
- **Type**: Symbolic link to c:\core\linux-6.12.28
- **Purpose**: Stable, production-ready kernel base
- **License**: GPL v2

### 2. Configuration (config/)
- Custom kernel configuration optimized for home servers
- Buildroot configuration for userspace
- System-wide settings

### 3. Userspace (userspace/)
- Custom init system or systemd
- Home Server OS specific services
- Management tools
- System utilities

### 4. Web Panel (web-panel/)
- Modern web-based management interface
- REST API for programmatic access
- Real-time monitoring dashboard
- Container/VM management UI

### 5. Build System (build/)
- Cross-compilation toolchain
- Automated build scripts
- Root filesystem generation
- Bootable ISO creation

## Development Workflow

### 1. Kernel Configuration
```bash
cd linux-kernel
make menuconfig
cp .config ../config/kernel.config
```

### 2. Build Kernel
```bash
cd build/scripts
./build-kernel.sh
```

### 3. Build Userspace
```bash
./build-userspace.sh
```

### 4. Create ISO
```bash
./create-iso.sh
```

### 5. Test in VM
```bash
./test-vm.sh
```

## Technology Stack

### Kernel Layer
- **Kernel**: Linux 6.12.28
- **Architecture**: x86_64
- **Compiler**: GCC 11+ or Clang 13+

### Userspace Layer
- **Init**: systemd or OpenRC
- **Shell**: Bash
- **Core Utils**: GNU coreutils or BusyBox
- **Package Manager**: Custom or APK

### Web Layer
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla or Vue.js)
- **Backend**: Go, Rust, or Python
- **API**: RESTful
- **Web Server**: Nginx or custom

### Virtualization
- **Containers**: Docker/containerd or custom
- **VMs**: QEMU/KVM
- **Orchestration**: Custom management layer

## Build Requirements

### Host System
- Linux (Ubuntu 22.04+ recommended) or WSL2
- Windows with MinGW/MSYS2 (limited support)

### Tools
- GCC 11+ or Clang 13+
- GNU Make 4.0+
- Binutils 2.35+
- Git
- Python 3.8+
- QEMU (for testing)

### Disk Space
- Source: ~2 GB
- Build: ~10 GB
- ISO: ~500 MB

## Next Steps

1. ✅ Integrate Linux kernel (DONE)
2. ⏳ Create kernel configuration
3. ⏳ Set up build system
4. ⏳ Develop userspace tools
5. ⏳ Build web panel
6. ⏳ Create bootable ISO
7. ⏳ Test and iterate

## Migration Notes

### Old Educational Code
The original educational kernel code has been preserved in `docs/educational/` for reference:
- `docs/educational/kernel/` - Original kernel.c
- `docs/educational/memory/` - Memory manager
- `docs/educational/scheduler/` - Task scheduler
- `docs/educational/fs/` - Filesystem
- `docs/educational/net/` - Network stack

This code serves as learning material and architectural reference.

### New Linux-Based Approach
- Real, production-ready kernel
- Full hardware support
- Active security updates
- Proven stability
- Large community support

## License

- **Linux Kernel**: GPL v2
- **Home Server OS Userspace**: MIT (or GPL v2 for compatibility)
- **Documentation**: CC BY 4.0

## Resources

- Linux Kernel: https://kernel.org/
- Buildroot: https://buildroot.org/
- Linux From Scratch: https://www.linuxfromscratch.org/
- Kernel Documentation: https://www.kernel.org/doc/html/latest/

---

**Status**: Integration Phase
**Last Updated**: 2026-05-07
**Next Milestone**: Kernel Configuration
