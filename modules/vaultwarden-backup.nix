{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.vaultwarden-backup;

  backupScript = pkgs.writeShellScript "vaultwarden-backup" ''
    #!/bin/bash

    # Vaultwarden Backup Script
    # Backs up Vaultwarden data using SQLite .backup command and copies additional files
    # Stores backups in Syncthing folder for automatic replication

    set -euo pipefail

    # Configuration
    VAULTWARDEN_DATA_DIR="${cfg.dataDir}"
    BACKUP_BASE_DIR="${cfg.backupDir}"
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_DIR="''${BACKUP_BASE_DIR}/''${TIMESTAMP}"
    RETENTION_DAYS=${toString cfg.retentionDays}
    LOG_FILE="''${BACKUP_BASE_DIR}/backup.log"

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
        echo -e "$1"
    }

    error() {
        log "''${RED}ERROR: $1''${NC}"
        exit 1
    }

    success() {
        log "''${GREEN}SUCCESS: $1''${NC}"
    }

    warning() {
        log "''${YELLOW}WARNING: $1''${NC}"
    }

    # Create backup directory structure
    log "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR" || error "Failed to create backup directory"

    # Check if Vaultwarden data directory exists
    if [[ ! -d "$VAULTWARDEN_DATA_DIR" ]]; then
        error "Vaultwarden data directory not found: $VAULTWARDEN_DATA_DIR"
    fi

    # Check if SQLite database exists
    if [[ ! -f "$VAULTWARDEN_DATA_DIR/db.sqlite3" ]]; then
        error "Vaultwarden database not found: $VAULTWARDEN_DATA_DIR/db.sqlite3"
    fi

    log "Starting Vaultwarden backup..."

    # 1. Backup SQLite database using .backup command (safe while running)
    log "Backing up SQLite database..."
    ${pkgs.sqlite}/bin/sqlite3 "$VAULTWARDEN_DATA_DIR/db.sqlite3" ".backup '$BACKUP_DIR/db.sqlite3'" || error "Failed to backup database"
    success "Database backup completed"

    # 2. Copy encryption key
    if [[ -f "$VAULTWARDEN_DATA_DIR/rsa_key.pem" ]]; then
        log "Backing up RSA key..."
        cp "$VAULTWARDEN_DATA_DIR/rsa_key.pem" "$BACKUP_DIR/" || error "Failed to backup RSA key"
        success "RSA key backup completed"
    else
        warning "RSA key file not found"
    fi

    # 3. Copy attachments directory
    if [[ -d "$VAULTWARDEN_DATA_DIR/attachments" ]]; then
        log "Backing up attachments directory..."
        cp -r "$VAULTWARDEN_DATA_DIR/attachments" "$BACKUP_DIR/" || error "Failed to backup attachments"
        success "Attachments backup completed"
    else
        warning "Attachments directory not found"
    fi

    # 4. Copy sends directory
    if [[ -d "$VAULTWARDEN_DATA_DIR/sends" ]]; then
        log "Backing up sends directory..."
        cp -r "$VAULTWARDEN_DATA_DIR/sends" "$BACKUP_DIR/" || error "Failed to backup sends"
        success "Sends backup completed"
    else
        warning "Sends directory not found"
    fi

    # 5. Copy icon cache (optional but useful)
    if [[ -d "$VAULTWARDEN_DATA_DIR/icon_cache" ]]; then
        log "Backing up icon cache..."
        cp -r "$VAULTWARDEN_DATA_DIR/icon_cache" "$BACKUP_DIR/" || warning "Failed to backup icon cache (non-critical)"
    fi

    # Set proper ownership for backup files
    chown -R ${cfg.user}:${cfg.group} "$BACKUP_DIR" || warning "Failed to set ownership on backup files"

    # Verify backup integrity
    log "Verifying backup integrity..."
    if ${pkgs.sqlite}/bin/sqlite3 "$BACKUP_DIR/db.sqlite3" "PRAGMA integrity_check;" | grep -q "ok"; then
        success "Database integrity check passed"
    else
        error "Database integrity check failed"
    fi

    # Calculate backup size
    BACKUP_SIZE=$(${pkgs.coreutils}/bin/du -sh "$BACKUP_DIR" | cut -f1)
    success "Backup completed successfully. Size: $BACKUP_SIZE"

    # Clean up old backups (keep last RETENTION_DAYS days)
    log "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    ${pkgs.findutils}/bin/find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null || true

    # Count remaining backups
    BACKUP_COUNT=$(${pkgs.findutils}/bin/find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "20*" | wc -l)
    log "Cleanup completed. $BACKUP_COUNT backups retained."

    # Create a 'latest' symlink for easy access
    ln -sfn "$BACKUP_DIR" "$BACKUP_BASE_DIR/latest" || warning "Failed to create latest symlink"

    log "=== Backup Summary ==="
    log "Backup location: $BACKUP_DIR"
    log "Backup size: $BACKUP_SIZE"
    log "Total backups retained: $BACKUP_COUNT"
    log "Syncthing will replicate this backup across all devices"
    log "========================"

    success "Vaultwarden backup completed successfully!"
  '';

  testRestoreScript = pkgs.writeShellScript "test-vaultwarden-restore" ''
    #!/bin/bash

    # Vaultwarden Restore Testing Script
    # Uses Docker to test restore functionality without affecting production
    # Allows you to click around and verify backup integrity

    set -euo pipefail

    # Configuration
    BACKUP_BASE_DIR="${cfg.backupDir}"
    TEST_PORT=''${1:-8223}
    CONTAINER_NAME="vaultwarden-test"
    TEST_DATA_DIR="/tmp/vaultwarden-test-data"

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    log() {
        echo -e "$1"
    }

    error() {
        log "''${RED}ERROR: $1''${NC}"
        exit 1
    }

    success() {
        log "''${GREEN}SUCCESS: $1''${NC}"
    }

    warning() {
        log "''${YELLOW}WARNING: $1''${NC}"
    }

    info() {
        log "''${BLUE}INFO: $1''${NC}"
    }

    cleanup() {
        log "Cleaning up test environment..."
        ${pkgs.docker}/bin/docker stop "$CONTAINER_NAME" 2>/dev/null || true
        ${pkgs.docker}/bin/docker rm "$CONTAINER_NAME" 2>/dev/null || true
        rm -rf "$TEST_DATA_DIR" 2>/dev/null || true
        success "Cleanup completed"
    }

    show_usage() {
        cat << EOF
    Usage: $0 [PORT] [BACKUP_PATH]

    Test Vaultwarden backup restore using Docker

    ARGUMENTS:
        PORT         Test port (default: 8223)
        BACKUP_PATH  Path to backup or 'latest' (default: latest)

    EXAMPLES:
        $0                           # Use latest backup on port 8223
        $0 8224                      # Use latest backup on port 8224
        $0 8223 2024-07-02_10-30-00  # Use specific backup
    EOF
    }

    # Parse arguments
    if [[ "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        show_usage
        exit 0
    fi

    BACKUP_PATH="''${2:-latest}"

    # Check if Docker is available
    if ! command -v ${pkgs.docker}/bin/docker &> /dev/null; then
        error "Docker is not available"
    fi

    # Determine backup path
    if [[ "$BACKUP_PATH" == "latest" ]]; then
        FULL_BACKUP_PATH="$BACKUP_BASE_DIR/latest"
    else
        FULL_BACKUP_PATH="$BACKUP_BASE_DIR/$BACKUP_PATH"
    fi

    # Verify backup directory exists
    if [[ ! -d "$FULL_BACKUP_PATH" ]]; then
        error "Backup directory not found: $FULL_BACKUP_PATH"
    fi

    if [[ ! -f "$FULL_BACKUP_PATH/db.sqlite3" ]]; then
        error "Database file not found in backup: $FULL_BACKUP_PATH/db.sqlite3"
    fi

    info "Using backup: $FULL_BACKUP_PATH"

    # Cleanup any existing test environment
    cleanup 2>/dev/null || true

    # Create test data directory and copy backup
    mkdir -p "$TEST_DATA_DIR"
    cp -r "$FULL_BACKUP_PATH"/* "$TEST_DATA_DIR/"

    # Start test container
    info "Starting Vaultwarden test container on port $TEST_PORT..."
    ${pkgs.docker}/bin/docker run -d \
        --name "$CONTAINER_NAME" \
        -v "$TEST_DATA_DIR:/data" \
        -p "$TEST_PORT:80" \
        vaultwarden/server:latest

    # Wait for startup
    for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -s "http://localhost:$TEST_PORT" &>/dev/null; then
            break
        fi
        sleep 1
    done

    success "Test instance ready at http://localhost:$TEST_PORT"
    info "Run 'docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME' when done testing"
  '';
in
{
  options.services.vaultwarden-backup = {
    enable = mkEnableOption "Vaultwarden backup service";

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/bitwarden_rs";
      description = "Directory where Vaultwarden stores its data";
    };

    backupDir = mkOption {
      type = types.str;
      default = "/home/denis/Sync/backups/vaultwarden";
      description = "Directory where backups will be stored";
    };

    user = mkOption {
      type = types.str;
      default = "denis";
      description = "User that will own the backup files";
    };

    group = mkOption {
      type = types.str;
      default = "users";
      description = "Group that will own the backup files";
    };

    retentionDays = mkOption {
      type = types.int;
      default = 30;
      description = "Number of days to keep backups";
    };

    schedule = mkOption {
      type = types.str;
      default = "daily";
      description = "When to run backups (systemd timer format)";
    };
  };

  config = mkIf cfg.enable {
    # Create backup directory
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 0755 ${cfg.user} ${cfg.group} -"
    ];

    # Backup service
    systemd.services.vaultwarden-backup = {
      description = "Backup Vaultwarden data";
      serviceConfig = {
        Type = "oneshot";
        User = "root"; # Need root to access vaultwarden data
        ExecStart = "${backupScript}";
      };
    };

    # Backup timer
    systemd.timers.vaultwarden-backup = {
      description = "Run Vaultwarden backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };

    # Add scripts to system PATH for manual use
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "vaultwarden-backup" ''
        exec ${backupScript} "$@"
      '')
      (pkgs.writeShellScriptBin "test-vaultwarden-restore" ''
        exec ${testRestoreScript} "$@"
      '')
    ];
  };
}
