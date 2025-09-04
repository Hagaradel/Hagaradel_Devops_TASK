# Secure Backup/Restore Tool

## Usage

### Backup
```bash
chmod +x ./backup.sh 
chmod +x ./restore.sh
chmod +x ./backup_restore_lib
```
```bash
./backup.sh <source_dir> <backup_dir> <encryption_key> <days>
```

### Restore
```bash
./restore.sh <backup_dir> <restore_dir> <decryption_key>
```

## Example
```bash
./backup.sh /tmp/source /tmp/backups mypassword 7
./restore.sh /tmp/backups/2025-09-03_12-00-00 /tmp/restore mypassword
```

## Scheduling with Cron
Add to crontab for daily backups (2 AM):
```
0 2 * * * /path/to/backup.sh /source /backups mysecretkey 2
```


# Design Document

## Assumptions
- GnuPG (`gpg`) is installed on the system.
- Remote server copy uses `scp`. User should configure SSH key-based authentication.
- Passphrase-based symmetric encryption is used (`gpg -c`).
- Incremental backups use `find -mtime -n`.
- Cron is available for scheduling backups.


## Design Decisions
- Separate library `backup_restore_lib.sh` for modular functions.
- Backup script creates per-directory tar.gz archives, then encrypts with gpg.
- Original unencrypted archives are removed after encryption.
- Restore decrypts archives into a temp dir, then extracts them back to restore dir.
##also
i install on my vms made two use ssh to make sure the ssh is establish and running corrrectly 
