echo "Starting backup script..."
source backup_restore_lib.sh
# Validate input parameters

validinput "$@"

# Perform backup
tarfunction

# Transfer backup
transfer

echo "Backup script completed!"
                                    
