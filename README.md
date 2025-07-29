# Google Drive Bidirectional Sync with rclone

A powerful bash script for bidirectional synchronization between Google Drive folders and local directories using rclone bisync.

## Features

- ✅ **Bidirectional sync** - Changes sync in both directions
- ✅ **Fast performance** - Optimized with parallel transfers
- ✅ **Conflict handling** - Safe conflict resolution
- ✅ **Easy setup** - Simple initialization and usage
- ✅ **Logging** - Comprehensive sync logging
- ✅ **Error recovery** - Resilient sync with recovery options

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

This project is open source. Feel free to use and modify as needed.

## Changelog

### v1.0.0
- Initial release with bidirectional sync
- Performance optimizations
- Comprehensive error handling
- Logging and recovery features
