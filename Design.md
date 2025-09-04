
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
