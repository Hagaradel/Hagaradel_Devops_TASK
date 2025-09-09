# Secure Backup/Restore Tool

## Usage
i made it on vms so make sure ssh is working and keys are exchanged
### Backup
```bash
chmod +x ./backup.sh 
chmod +x ./restore.sh
chmod +x ./backup_restore_lib.sh
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

