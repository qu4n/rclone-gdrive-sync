#!/bin/bash

# Google Drive Bidirectional Sync Script using rclone bisync
# Usage: ./sync_script.sh [folder_name] [--init]

# Configuration
GDRIVE_REMOTE="gdrive:"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOCAL_BASE_DIR="$SCRIPT_DIR/synced_folders"
LOG_FILE="$SCRIPT_DIR/sync.log"
BISYNC_WORKDIR="$SCRIPT_DIR/bisync_workdir"

# Function to display usage
usage() {
    echo "Usage: $0 [folder_name] [--init] [--preview]"
    echo "Examples:"
    echo "  $0 my_documents --init       # Initialize bidirectional sync"
    echo "  $0 my_documents              # Run bidirectional sync (after initialization)"
    echo "  $0 my_documents --preview    # Preview changes before syncing"
    echo ""
    echo "Options:"
    echo "  --init     Initialize bisync (required for first run)"
    echo "  --preview  Show what would change without actually syncing"
    echo ""
    echo "Available folders in your Google Drive:"
    rclone lsd gdrive: | awk '{print "  - " $5}'
    exit 1
}

# Function to sync a folder bidirectionally
sync_folder() {
    local folder_name="$1"
    local is_init="$2"
    local is_preview="$3"
    local gdrive_path="${GDRIVE_REMOTE}${folder_name}"
    local local_path="${LOCAL_BASE_DIR}/${folder_name}"
    local workdir="${BISYNC_WORKDIR}/${folder_name}"
    
    echo "$(date): Starting bidirectional sync of '${folder_name}'" | tee -a "$LOG_FILE"
    echo "Remote: ${gdrive_path}"
    echo "Local: ${local_path}"
    echo "Initialize mode: ${is_init}"
    echo "Preview mode: ${is_preview}"
    
    # Create directories if they don't exist
    mkdir -p "$local_path"
    mkdir -p "$workdir"
    mkdir -p "$BISYNC_WORKDIR"
    
    # Build rclone bisync command with safer options
    local rclone_options="--workdir=\"$workdir\" --verbose --log-file=\"$LOG_FILE\" --log-level INFO --create-empty-src-dirs --compare size,modtime --resilient --recover"
    
    if [ "$is_preview" = "true" ]; then
        echo "=== PREVIEW MODE: Showing what would change ==="
        echo ""
        echo "🔍 Running bisync dry-run to show actual changes..."
        
        # Use bisync with dry-run for accurate preview
        rclone bisync "$gdrive_path" "$local_path" \
            --workdir="$workdir" \
            --dry-run \
            --log-level INFO \
            --create-empty-src-dirs \
            --compare size,modtime \
            --resilient \
            --recover \
            --transfers 8 \
            --checkers 16 \
            --drive-chunk-size 64M \
            --fast-list
        
        echo ""
        echo "=== END PREVIEW ==="
        echo "Run without --preview to perform actual sync"
        return 0
    fi
    
    if [ "$is_init" = "true" ]; then
        echo "Initializing bidirectional sync (this may take a while)..."
        rclone bisync "$gdrive_path" "$local_path" \
            --workdir="$workdir" \
            --resync \
            --log-file="$LOG_FILE" \
            --log-level INFO \
            --create-empty-src-dirs \
            --transfers 8 \
            --checkers 16 \
            --drive-chunk-size 64M
    else
        echo "Running bidirectional sync..."
        rclone bisync "$gdrive_path" "$local_path" \
            --workdir="$workdir" \
            --log-file="$LOG_FILE" \
            --log-level INFO \
            --create-empty-src-dirs \
            --compare size,modtime \
            --resilient \
            --recover \
            --transfers 8 \
            --checkers 16 \
            --drive-chunk-size 64M \
            --fast-list
    fi
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "$(date): Bidirectional sync completed successfully" | tee -a "$LOG_FILE"
        if [ "$is_init" = "true" ]; then
            echo "Initialization complete! Future syncs can be run without --init flag."
        fi
    else
        echo "$(date): Bidirectional sync failed with error code $exit_code" | tee -a "$LOG_FILE"
        if [ "$is_init" != "true" ]; then
            echo "If this is the first sync, try running with --init flag"
        fi
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    usage
fi

FOLDER_NAME="$1"
IS_INIT="false"
IS_PREVIEW="false"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --init)
            IS_INIT="true"
            ;;
        --preview)
            IS_PREVIEW="true"
            ;;
    esac
done

# Check if folder exists in your Google Drive
if ! rclone lsd gdrive: | grep -q " ${FOLDER_NAME}$"; then
    echo "Error: Folder '${FOLDER_NAME}' not found in your Google Drive"
    echo ""
    usage
fi

# Perform the bidirectional sync
sync_folder "$FOLDER_NAME" "$IS_INIT" "$IS_PREVIEW"
