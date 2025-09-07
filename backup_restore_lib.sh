#!/bin/bash


helpMessage() {
    echo "Hello, here is a bash script for backup files"
    echo ""
    echo "============================================="
    echo ""
    echo "You have to enter 4 valid parameters:"
    echo "" 
    echo " 1. backup directory (where you want to backup)"
    echo ""
    echo " 2. backup source directory (what you want to backup)"
    echo "" 
    echo " 3. key you choose to encrypt"
    echo ""
    echo " 4. choose days to backup"
    echo ""
    echo "============================================="
}

validinput() {
    BACKUPDIST=''
    BACKUPSRC=''
    Key=''
    day=''
    date=$(date +%Y%m%d)

    if [ $# -ne 4 ]; then
        echo "Error: Missing input parameters"
        helpMessage
        exit 1
    fi

    if [ ! -d "$2" ]; then
        echo "Error: Source directory '$2' does not exist"
        helpMessage
        exit 1
    fi

    BACKUPDIST="$1"
    BACKUPSRC="$2"
    Key="$3"
    day="$4"

    echo "Parameters validated successfully"
    echo "Backup destination: $BACKUPDIST"
    echo "Backup source: $BACKUPSRC" 
    echo "Encryption key: $Key"
    echo "Days: $day"
}

tarfunction() {
    echo "Starting backup process..."

    # Create necessary directories
    mkdir -p "temp/$date"
    mkdir -p "$BACKUPDIST/$date"

    # Copy source to both temp and backup directories
    cp -r "$BACKUPSRC"/* "temp/$date/" 2>/dev/null || {
        echo "Warning: No files to copy or copy failed"
    }
    cp -r "$BACKUPSRC"/* "$BACKUPDIST/$date/" 2>/dev/null || {
        echo "Warning: No files to copy or copy failed"
    }

    # Change to backup directory
    cd "$BACKUPDIST/$date" || {
        echo "Error: Cannot change to backup directory"
        return 1
    }

    # Compress and encrypt subdirectories
    for subdir in */ ; do
        if [ -d "$subdir" ]; then
            echo "Processing directory: $subdir"
            subdir_name="${subdir%/}"

            # Create tar.gz file
            tar -czf "${subdir_name}.tar.gz" "$subdir" || {
                echo "Error: Failed to create tar file for $subdir"
                continue
            }

            # Remove original directory
            rm -rf "$subdir"
            
            # Encrypt the tar.gz file
            gpg --batch --yes --symmetric --passphrase "$Key" "${subdir_name}.tar.gz" || {
                echo "Warning: GPG encryption failed for ${subdir_name}.tar.gz - continuing without encryption"
            }

            # Remove unencrypted tar file if encryption succeeded
            if [ -f "${subdir_name}.tar.gz.gpg" ]; then
                rm -f "${subdir_name}.tar.gz"
                echo "Successfully compressed and encrypted: $subdir_name"
            else
                echo "Compressed (no encryption): $subdir_name"
            fi
        fi
    done

    # Go back to original directory
    cd - > /dev/null

    # Create final backup archive
    echo "Creating final backup archive..."
    tar -czf "$BACKUPDIST/${date}.tar.gz" -C "$BACKUPDIST" "$date" || {
        echo "Error: Failed to create final backup archive"
        return 1
    }

    # Encrypt final archive
    gpg --batch --yes --symmetric --passphrase "$Key" "$BACKUPDIST/${date}.tar.gz" || {
        echo "Warning: GPG encryption failed for final archive - continuing without encryption"
    }

    # Remove unencrypted final archive if encryption succeeded
    if [ -f "$BACKUPDIST/${date}.tar.gz.gpg" ]; then
        rm -f "$BACKUPDIST/${date}.tar.gz"
        echo "Final backup created and encrypted: ${date}.tar.gz.gpg"
    else
        echo "Final backup created (no encryption): ${date}.tar.gz"
    fi
}

schedule() {
    echo "Checking for changes..."

    if [ ! -d "temp/$date" ]; then
        echo "No previous backup found, creating new backup"
        tarfunction
        return
    fi

    diff -qr "temp/$date/" "$BACKUPSRC/" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Changes detected, updating backup..."
        rm -rf "temp/$date"/*
        cp -r "$BACKUPSRC"/* "temp/$date/" 2>/dev/null
        tarfunction
    else
        echo "No changes detected, backup is up to date"
    fi
}

transfer() {
    echo "Starting file transfer..."

    # Determine which file to transfer
    if [ -f "$BACKUPDIST/${date}.tar.gz.gpg" ]; then
        transfer_file="$BACKUPDIST/${date}.tar.gz.gpg"
    elif [ -f "$BACKUPDIST/${date}.tar.gz" ]; then
        transfer_file="$BACKUPDIST/${date}.tar.gz"
    else
        echo "Error: No backup file found to transfer"
        return 1
    fi

    echo "Transferring: $transfer_file"
    scp "$transfer_file" hagar@192.168.1.29:/home/hagar/ || {
        echo "Error: Transfer failed"
        return 1
    }

    echo "Transfer completed successfully"
    
    # Clean up transferred file
    rm -f "$transfer_file"
    echo "Local backup file removed after successful transfer"
}
validrestore(){
 if [ $# -ne 3 ]; then
        echo "Error: Missing input parameters"
        echo " 1st parameter backup directory"
        echo "2nd parameter restore directory"
        echo "3rd parameter key "
        exit 1
    fi

if [ ! -z "$3" ]; then
        echo "Error: key is empty !"
        exit 1
fi

}
restore(){
backup_dir="$1"
restored_dir="$2"
key="$3"
mkdir -p "$restored_dir/temp"

    # Restore the files inside the backup_directory on the remote server to the temp_dir
scp -i /root/.ssh/id_rsa  -r hagar@192.168.1.29:$backup_dir/* $restored_dir/temp_restore

# Check and decrypt the encrypted backup files inside temp_restor


encrypted_files=("$restored_dir/temp"/*.tar.gz.gpg)
if [ ${#encrypted_files[@]} -gt 0 ]; then

        # Loop over the encrypted files
        for encrypted_file in "${encrypted_files[@]}"; do
            # Decrypt the file using the provided decryption_key
            decrypted_file="${encrypted_file%.gpg}"
            gpg --output "$decrypted_file" --decrypt --recipient "$decryption_key" "$encrypted_file"

            # Extract the decrypted tar file
            tar -xzf "$decrypted_file" -C "${decrypted_file%/*}"

            # Remove the decrypted tar file and the encrypted file
            rm "$decrypted_file" "$encrypted_file"
        done
fi
for content in "$restored_dir/temp_restore"/*; do
        if [ -f "$content" ]; then

            # Decrypt the file using the provided decryption_key
            decrypted_file="${content%.gpg}"
            gpg --output "$decrypted_file" --decrypt --recipient "$decryption_key" "$content"

            # Check if the decrypted file is a tar.gz file
            if [[ "$decrypted_file" == *.tgz ]]; then

                # Create a directory with the same name as the decrypted file
                extraction_dir="${decrypted_file%.tgz}"
                mkdir "$extraction_dir"

                # Extract the decrypted tar file into the extraction directory


                tar -xzf "$decrypted_file" -C "$extraction_dir"

                # Remove the decrypted tar file and the encrypted file
                rm "$decrypted_file" "$content"
            fi
        fi
done
                                                                                                       49,1          Bot

}
