#!/bin/bash

# =============================================================================
# phone_backup.sh — ADB-based Android backup script
# =============================================================================

# --- Configuration (defaults) ------------------------------------------------

# BASE="$HOME/Backups"       # Root folder where all backups are stored
BASE="/mnt/storage"        # Root folder where all backups are stored
PHONE="Fairfoin"           # Phone name (used as subfolder, change per device)

# --- Argument parsing ---------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --PHONE)  PHONE="$2";  shift 2 ;;
        --BASE)   BASE="$2";   shift 2 ;;
        *)
            echo "[ERROR] Unknown argument: $1"
            echo "Usage: $0 [--PHONE name] [--BASE path]"
            exit 1
            ;;
    esac
done

# Folders to back up, relative to /sdcard/ on the phone.
# Their content will be copied into BASE/PHONE/YYYYMMDD_backup/<folder_name>/
FOLDERS=(
    "Music"
    "Documents"
    "Download"
    "Pictures"
    "Sauvegardes"
    # Add or remove folders as needed
)

# Camera folder on the phone — gets special treatment (incremental, no duplicates)
CAMERA_SRC="/sdcard/DCIM/Camera"

# Local folder where camera photos are accumulated across backups (no date subfolder)
CAMERA_DEST="$BASE/$PHONE/Photos"


# --- Setup --------------------------------------------------------------------

DATE=$(date +%Y%m%d)
BACKUP_ROOT="$BASE/$PHONE/${DATE}_backup"

echo "========================================"
echo " Phone Backup — $(date '+%Y-%m-%d %H:%M')"
echo " Device : $PHONE"
echo " Dest   : $BACKUP_ROOT"
echo "========================================"
echo ""

# Check ADB connection
if ! adb get-state &>/dev/null; then
    echo "[ERROR] No device detected via ADB. Make sure your phone is connected and USB Debugging is enabled."
    exit 1
fi

echo "[OK] Device detected."
echo ""

# --- Regular folders ----------------------------------------------------------

for FOLDER in "${FOLDERS[@]}"; do

    PHONE_PATH="/sdcard/$FOLDER"
    LOCAL_PATH="$BACKUP_ROOT/$FOLDER"

    # Check folder exists on phone
    if ! adb shell "[ -d '$PHONE_PATH' ]" &>/dev/null; then
        echo "[WARNING] Folder not found on phone, skipping: $PHONE_PATH"
        continue
    fi

    # Create local destination if needed
    if [ ! -d "$LOCAL_PATH" ]; then
        mkdir -p "$LOCAL_PATH"
        echo "[INFO] Created local folder: $LOCAL_PATH"
    fi

    echo "[PULLING] $PHONE_PATH  →  $LOCAL_PATH"
    adb pull -a "$PHONE_PATH/." "$LOCAL_PATH"
    echo ""

done

# --- Camera photos (incremental) ----------------------------------------------

echo "----------------------------------------"
echo "[CAMERA] Incremental sync: $CAMERA_SRC → $CAMERA_DEST"
echo "----------------------------------------"

# Check camera folder exists on phone
if ! adb shell "[ -d '$CAMERA_SRC' ]" &>/dev/null; then
    echo "[WARNING] Camera folder not found on phone: $CAMERA_SRC"
else
    # Create local Photos folder if needed
    if [ ! -d "$CAMERA_DEST" ]; then
        mkdir -p "$CAMERA_DEST"
        echo "[INFO] Created Photos folder: $CAMERA_DEST"
    fi

    # List files in camera folder on phone
    FILES=$(adb shell "ls '$CAMERA_SRC'" | tr -d '\r')

    NEW=0
    SKIPPED=0

    while IFS= read -r FILE; do
        [ -z "$FILE" ] && continue

        LOCAL_FILE="$CAMERA_DEST/$FILE"

        if [ -e "$LOCAL_FILE" ]; then
            SKIPPED=$((SKIPPED + 1))
        else
            echo "[NEW] $FILE"
            adb pull -a "$CAMERA_SRC/$FILE" "$CAMERA_DEST/$FILE"
            NEW=$((NEW + 1))
        fi
    done <<< "$FILES"

    echo ""
    echo "[CAMERA] Done — $NEW new file(s) added, $SKIPPED already present and skipped."
fi

# --- Summary ------------------------------------------------------------------

echo ""
echo "========================================"
echo " Backup complete!"
echo " Regular backups : $BACKUP_ROOT"
echo " Camera photos   : $CAMERA_DEST"
echo "========================================"
