# Google Drive Bidirectional Sync with rclone

[![Quality Assurance](https://github.com/qu4n/rclone-gdrive-sync/actions/workflows/quality.yml/badge.svg)](https://github.com/qu4n/rclone-gdrive-sync/actions/workflows/quality.yml)
[![Security Scan](https://img.shields.io/badge/security-scanned-green?logo=github)](https://github.com/qu4n/rclone-gdrive-sync/actions/workflows/quality.yml)
[![Code Quality](https://img.shields.io/badge/shellcheck-passing-brightgreen?logo=github)](https://github.com/qu4n/rclone-gdrive-sync/actions/workflows/quality.yml)
[![Tests](https://img.shields.io/badge/tests-11%2F11%20passing-brightgreen?logo=github)](https://github.com/qu4n/rclone-gdrive-sync/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful bash script for bidirectional synchronization between Google Drive folders and local directories using rclone bisync.

## Features

- ✅ **Bidirectional sync** - Changes sync in both directions
- ✅ **Fast performance** - Optimized with parallel transfers
- ✅ **Conflict handling** - Safe conflict resolution
- ✅ **Easy setup** - Simple initialization and usage
- ✅ **Logging** - Comprehensive sync logging
- ✅ **Error recovery** - Resilient sync with recovery options
- ✅ **Enterprise security** - Professional vulnerability scanning
- ✅ **Quality assured** - Automated testing and validation

## Quality Assurance

This project maintains enterprise-grade quality standards with automated CI/CD pipeline:

### 🛡️ Security Scanning
- **TruffleHog**: Enterprise secret detection (800+ credential types)
- **Semgrep**: OWASP security vulnerability analysis
- **CodeQL**: GitHub's semantic code analysis

### 🔧 Code Quality  
- **ShellCheck**: Static analysis for shell scripts
- **Syntax validation**: Bash syntax verification
- **Best practices**: Automated coding standard enforcement

### 🧪 Automated Testing
- **11 comprehensive tests**: Functionality, security, documentation
- **Input validation**: Injection protection testing
- **Configuration validation**: Setup verification

### 📊 Monitoring Tools
```bash
./test-quality.sh           # Run local functionality tests
./commit-and-analyze.sh     # Commit with pipeline analysis
./analyze-pipeline.sh       # Detailed pipeline investigation
./monitor-pipeline.sh       # Real-time pipeline monitoring
```

## Prerequisites

- `rclone` installed and configured with Google Drive
- Bash shell (tested on Ubuntu 24.04 LTS, should work on Linux/macOS/WSL)
- Google Drive remote configured in rclone

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/qu4n/rclone-gdrive-sync.git
   cd rclone-gdrive-sync
   ```

2. Make the script executable:
   ```bash
   chmod +x sync_script.sh
   ```

3. Configure rclone with Google Drive (if not already done):
   ```bash
   rclone config
   ```

## Usage

### First Time Setup (Initialization)

```bash
./sync_script.sh [folder_name] --init
```

### Regular Syncing

```bash
./sync_script.sh [folder_name]
```

## Configuration

Edit the script variables at the top of `sync_script.sh`:

```bash
GDRIVE_REMOTE="gdrive:"              # Your rclone Google Drive remote name
LOCAL_BASE_DIR="/path/to/local"      # Local base directory for synced folders
LOG_FILE="/path/to/sync.log"         # Log file location
BISYNC_WORKDIR="/path/to/workdir"    # Bisync working directory
```

## Performance

- **Regular sync**: ~15 seconds for established sync
- **Initialization**: Varies based on folder size
- **Optimizations**: 8 parallel transfers, 16 checkers, 64MB chunks

## Directory Structure

```
rclone/
├── sync_script.sh          # Main sync script
├── synced_folders/         # Local synced folders (excluded from git)
├── bisync_workdir/         # rclone bisync metadata (excluded from git)
├── sync.log                # Sync logs (excluded from git)
├── README.md               # This file
└── .gitignore              # Git ignore rules
```

## Troubleshooting

### Common Issues

1. **"Cannot find prior listings"** - Run with `--init` flag to reinitialize
2. **Sync fails** - Check `sync.log` for detailed error messages
3. **Slow performance** - Ensure good internet connection and check Google Drive API limits

### Reset Sync

If you need to completely reset a sync:

```bash
rm -rf bisync_workdir/[folder_name]
./sync_script.sh [folder_name] --init
```

## Safety Features

- **Resilient mode** - Recovers from transient errors
- **Conflict detection** - Safely handles file conflicts
- **Dry-run capable** - Can be modified for testing
- **Logging** - All operations logged for audit

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Why MIT License?
- ✅ **Freedom to use**: Use in personal and commercial projects
- ✅ **Freedom to modify**: Adapt the code to your needs
- ✅ **Freedom to distribute**: Share your modifications
- ✅ **No warranty**: Clear liability protection
- ✅ **Simple**: Easy to understand and comply with

## Changelog

### v1.0.0
- Initial release with bidirectional sync
- Performance optimizations
- Comprehensive error handling
- Logging and recovery features
