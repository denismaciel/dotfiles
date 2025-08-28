#!/run/current-system/sw/bin/bash

# Local Vaultwarden Restore Testing Script
# Uses Docker to test restore functionality without affecting production
# Run from chris machine to test backups synced via Syncthing

set -euo pipefail

# Configuration
BACKUP_BASE_DIR="/home/denis/Sync/backups/vaultwarden"
TEST_PORT=${1:-8223}
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
    log "${RED}ERROR: $1${NC}"
    exit 1
}

success() {
    log "${GREEN}SUCCESS: $1${NC}"
}

warning() {
    log "${YELLOW}WARNING: $1${NC}"
}

info() {
    log "${BLUE}INFO: $1${NC}"
}

cleanup() {
    log "Cleaning up test environment..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    rm -rf "$TEST_DATA_DIR" 2>/dev/null || true
    success "Cleanup completed"
}

show_usage() {
    cat << EOF
Usage: $0 [PORT] [BACKUP_PATH]

Test Vaultwarden backup restore using Docker (local version)

ARGUMENTS:
    PORT         Test port (default: 8223)
    BACKUP_PATH  Path to backup or 'latest' (default: latest)

EXAMPLES:
    $0                           # Use latest backup on port 8223
    $0 8224                      # Use latest backup on port 8224
    $0 8223 2025-07-02_06-04-35  # Use specific backup

CLEANUP:
    $0 cleanup                   # Only cleanup existing test container
EOF
}

# Handle cleanup command
if [[ "${1:-}" == "cleanup" ]]; then
    cleanup
    exit 0
fi

# Parse arguments
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

BACKUP_PATH="${2:-latest}"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    error "Docker is not installed or not in PATH"
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    error "Docker daemon is not running"
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
log "Checking for existing test environment..."
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    warning "Existing test container found. Cleaning up..."
    cleanup
fi

# Check if test port is available
if ss -tuln | grep -q ":$TEST_PORT "; then
    error "Port $TEST_PORT is already in use. Choose a different port."
fi

# Create temporary test data directory
log "Creating test data directory..."
mkdir -p "$TEST_DATA_DIR" || error "Failed to create test data directory"

# Copy backup files to test directory
log "Copying backup files to test directory..."
cp -r "$FULL_BACKUP_PATH"/* "$TEST_DATA_DIR/" || error "Failed to copy backup files"

# Verify database integrity before testing
log "Verifying database integrity..."
if ! sqlite3 "$TEST_DATA_DIR/db.sqlite3" "PRAGMA integrity_check;" | grep -q "ok"; then
    error "Database integrity check failed. Backup may be corrupted."
fi
success "Database integrity check passed"

# Pull latest Vaultwarden Docker image
log "Pulling latest Vaultwarden Docker image..."
docker pull vaultwarden/server:latest || error "Failed to pull Docker image"

# Start Vaultwarden test container
log "Starting Vaultwarden test container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -v "$TEST_DATA_DIR:/data" \
    -p "$TEST_PORT:80" \
    -e ROCKET_PORT=80 \
    -e ROCKET_ADDRESS=0.0.0.0 \
    vaultwarden/server:latest || error "Failed to start container"

# Wait for container to be ready
log "Waiting for Vaultwarden to start..."
for i in {1..30}; do
    if curl -s "http://localhost:$TEST_PORT" &>/dev/null; then
        break
    fi
    if [[ $i -eq 30 ]]; then
        error "Vaultwarden failed to start within 30 seconds"
    fi
    sleep 1
done

success "Vaultwarden test instance is running!"

# Show container logs for debugging (last 10 lines)
log "Recent container logs:"
docker logs --tail 10 "$CONTAINER_NAME" | sed 's/^/  /'

# Display access information
cat << EOF

${GREEN}=== VAULTWARDEN TEST INSTANCE READY ===${NC}

${BLUE}Access your restored Vaultwarden at:${NC}
  http://localhost:$TEST_PORT

${BLUE}Test Instructions:${NC}
  1. Open the URL above in your browser
  2. Try logging in with your existing credentials
  3. Verify your vault items are present
  4. Check that attachments work (if any)
  5. Test basic functionality (add/edit items)

${BLUE}Backup Information:${NC}
  Source: $FULL_BACKUP_PATH
  Database: $(find "$FULL_BACKUP_PATH" -name "db.sqlite3" -exec ls -lh {} \; | awk '{print $5}')
  Files: $(find "$FULL_BACKUP_PATH" -type f | wc -l) files total

${YELLOW}Commands:${NC}
  View logs:     docker logs -f $CONTAINER_NAME
  Stop test:     docker stop $CONTAINER_NAME
  Full cleanup:  $0 cleanup

${RED}IMPORTANT:${NC} This is a TEST instance. Changes made here will NOT
affect your production Vaultwarden instance on ben.

Press Ctrl+C to stop monitoring, or run '$0 cleanup' when done testing.

EOF

# Monitor container (optional - can be interrupted)
trap cleanup EXIT
log "Monitoring test container. Press Ctrl+C to stop monitoring (container will keep running)..."
docker logs -f "$CONTAINER_NAME" 2>/dev/null || true