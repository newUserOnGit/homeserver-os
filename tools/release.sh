#!/bin/bash
# Release Script
# Creates a release package for Home Server OS

set -e

# Load version information
source VERSION

echo "=================================="
echo "Home Server OS - Release Builder"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RELEASE_DIR="release"
PACKAGE_NAME="homeserver-os-${VERSION}"

echo -e "${BLUE}Building release: ${VERSION_FULL}${NC}"
echo ""

# Clean previous release
clean_release() {
    echo "Cleaning previous release..."
    rm -rf $RELEASE_DIR
    mkdir -p $RELEASE_DIR
    echo -e "${GREEN}✓ Clean complete${NC}"
    echo ""
}

# Build project
build_project() {
    echo "Building project..."
    make clean
    make all

    if [ ! -f "build/homeserver.iso" ]; then
        echo -e "${RED}✗ Build failed - ISO not found${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Build complete${NC}"
    echo ""
}

# Run tests
run_tests() {
    echo "Running tests..."
    cd tests
    if ./run_tests.sh; then
        echo -e "${GREEN}✓ All tests passed${NC}"
    else
        echo -e "${RED}✗ Tests failed${NC}"
        read -p "Continue anyway? (yes/no): " CONTINUE
        if [ "$CONTINUE" != "yes" ]; then
            exit 1
        fi
    fi
    cd ..
    echo ""
}

# Create release package
create_package() {
    echo "Creating release package..."

    # Create package directory
    mkdir -p "$RELEASE_DIR/$PACKAGE_NAME"

    # Copy ISO
    cp build/homeserver.iso "$RELEASE_DIR/$PACKAGE_NAME/"

    # Copy documentation
    mkdir -p "$RELEASE_DIR/$PACKAGE_NAME/docs"
    cp README.md "$RELEASE_DIR/$PACKAGE_NAME/"
    cp LICENSE "$RELEASE_DIR/$PACKAGE_NAME/"
    cp CHANGELOG.md "$RELEASE_DIR/$PACKAGE_NAME/"
    cp CONTRIBUTING.md "$RELEASE_DIR/$PACKAGE_NAME/"
    cp VERSION "$RELEASE_DIR/$PACKAGE_NAME/"
    cp docs/technical.md "$RELEASE_DIR/$PACKAGE_NAME/docs/"
    cp docs/user-guide.md "$RELEASE_DIR/$PACKAGE_NAME/docs/"

    # Copy tools
    mkdir -p "$RELEASE_DIR/$PACKAGE_NAME/tools"
    cp tools/install.sh "$RELEASE_DIR/$PACKAGE_NAME/tools/"
    cp quickstart.sh "$RELEASE_DIR/$PACKAGE_NAME/"

    # Create checksums
    cd "$RELEASE_DIR/$PACKAGE_NAME"
    sha256sum homeserver.iso > SHA256SUMS
    md5sum homeserver.iso > MD5SUMS
    cd ../..

    echo -e "${GREEN}✓ Package created${NC}"
    echo ""
}

# Create release notes
create_release_notes() {
    echo "Creating release notes..."

    cat > "$RELEASE_DIR/$PACKAGE_NAME/RELEASE_NOTES.md" << EOF
# Home Server OS ${VERSION_FULL} Release Notes

**Release Date:** ${BUILD_DATE}

## Overview

This is the ${RELEASE_TYPE} release of Home Server OS version ${VERSION}.

## What's New

See [CHANGELOG.md](CHANGELOG.md) for detailed changes.

## Installation

### Quick Start

1. Download \`homeserver.iso\`
2. Create bootable USB:
   \`\`\`bash
   sudo dd if=homeserver.iso of=/dev/sdX bs=4M status=progress
   \`\`\`
3. Boot from USB and follow installation wizard

### Automated Installation

\`\`\`bash
chmod +x quickstart.sh
./quickstart.sh
\`\`\`

## System Requirements

### Minimum
- CPU: x86_64 (64-bit)
- RAM: ${MIN_RAM_MB} MB
- Disk: ${MIN_DISK_GB} GB
- Network: Ethernet

### Recommended
- CPU: ${REC_CPU_CORES}+ cores x86_64
- RAM: ${REC_RAM_MB} MB
- Disk: ${REC_DISK_GB} GB
- Network: Gigabit Ethernet

## Features

- ✅ Web-based administration panel
- ✅ REST API for automation
- ✅ Container support (max ${MAX_CONTAINERS})
- ✅ Virtual machine support (max ${MAX_VMS})
- ✅ Automated backup system
- ✅ Built-in firewall
- ✅ Real-time monitoring
- ✅ TCP/IP networking

## Known Issues

- Limited to x86_64 architecture
- Basic TCP/IP implementation
- Simple filesystem without journaling

## Upgrade Notes

This is the first release. No upgrade path available yet.

## Documentation

- [Technical Documentation](docs/technical.md)
- [User Guide](docs/user-guide.md)
- [Contributing Guide](CONTRIBUTING.md)

## Support

- GitHub: ${REPO_URL}
- Documentation: ${DOCS_URL}
- Forum: ${SUPPORT_URL}

## Checksums

See \`SHA256SUMS\` and \`MD5SUMS\` files for verification.

## License

MIT License - See [LICENSE](LICENSE) file.

---

**Thank you for using Home Server OS!**
EOF

    echo -e "${GREEN}✓ Release notes created${NC}"
    echo ""
}

# Create archives
create_archives() {
    echo "Creating archives..."

    cd $RELEASE_DIR

    # Create tar.gz
    tar -czf "${PACKAGE_NAME}.tar.gz" "$PACKAGE_NAME"
    echo -e "${GREEN}✓ Created ${PACKAGE_NAME}.tar.gz${NC}"

    # Create zip
    zip -r "${PACKAGE_NAME}.zip" "$PACKAGE_NAME" > /dev/null
    echo -e "${GREEN}✓ Created ${PACKAGE_NAME}.zip${NC}"

    # Create checksums for archives
    sha256sum "${PACKAGE_NAME}.tar.gz" > "${PACKAGE_NAME}.tar.gz.sha256"
    sha256sum "${PACKAGE_NAME}.zip" > "${PACKAGE_NAME}.zip.sha256"

    cd ..
    echo ""
}

# Display summary
display_summary() {
    echo "=================================="
    echo -e "${GREEN}Release Complete!${NC}"
    echo "=================================="
    echo ""
    echo "Release: ${BLUE}${VERSION_FULL}${NC}"
    echo "Date: ${BUILD_DATE}"
    echo ""
    echo "Files created:"
    echo "  - $RELEASE_DIR/${PACKAGE_NAME}.tar.gz"
    echo "  - $RELEASE_DIR/${PACKAGE_NAME}.zip"
    echo "  - $RELEASE_DIR/${PACKAGE_NAME}/homeserver.iso"
    echo ""
    echo "Package contents:"
    ls -lh "$RELEASE_DIR/${PACKAGE_NAME}/" | tail -n +2
    echo ""
    echo "Archive sizes:"
    ls -lh "$RELEASE_DIR"/*.tar.gz "$RELEASE_DIR"/*.zip 2>/dev/null | awk '{print "  - " $9 ": " $5}'
    echo ""
    echo "Next steps:"
    echo "  1. Test the release package"
    echo "  2. Upload to GitHub releases"
    echo "  3. Update documentation"
    echo "  4. Announce the release"
    echo ""
}

# Main execution
main() {
    clean_release
    build_project
    run_tests
    create_package
    create_release_notes
    create_archives
    display_summary
}

# Run main
main
