# Capstone: Bash Scripting Suite for System Maintenance (v1.0.0)

A complete, ready-to-submit project implementing the **Bash Scripting Suite** assignment:

- Automated **Backups** with rotation and logging
- **System Updates & Cleanup** across APT/DNF/pacman
- **Log Monitoring** (disk usage, failed SSH logins, top CPU procs) with an optional watch mode
- Integrated **Menu** to run all tasks
- Centralized **config**, **error handling**, and **logging**

This repo maps 1:1 to the assignment's day-wise breakdown (Design → Scripts → Menu → Tests).

## Project Structure
```
.
├── README.md
├── LICENSE
├── .gitignore
├── config.env.example
├── exclude.example.txt
├── suite.log                # created at runtime
└── scripts/
    ├── backup.sh
    ├── log_monitor.sh
    ├── menu.sh
    ├── updates.sh
    └── utils.sh
```

## Quick Start
```bash
git clone <your-repo-url>.git
cd <repo>
cp config.env.example config.env
# Edit config.env as needed; optionally edit exclude.example.txt and set BACKUP_EXCLUDES_FILE
chmod +x scripts/*.sh

# Recommended (to allow update/log reads where needed):
sudo -E bash scripts/menu.sh
```

## Day-wise mapping
- **Day 1**: Implement `backup.sh` (incremental rsync, rotation, logging).  
- **Day 2**: Implement `updates.sh` (package manager detection, update/cleanup).  
- **Day 3**: Implement `log_monitor.sh` (disk usage threshold, failed SSH logins, top CPU; `--follow`).  
- **Day 4**: Integrate via `menu.sh` and shared `utils.sh` (config, logging, helpers).  
- **Day 5**: Test, add error handling/logging improvements and README polish.

## Features
- **Incremental backups** using `--link-dest` (space-efficient). `--dry-run` supported.
- **Retention policy**: delete backup-* folders older than `BACKUP_RETAIN_DAYS`.
- **System updates & cleanup** for Debian/Ubuntu, Fedora/RHEL, and Arch.
- **Log monitor** scans disk usage ≥ threshold, recent failed SSH attempts, and top CPU processes; watch mode refreshes periodically.
- **Unified config** via `config.env`; all scripts write to `suite.log` with timestamps and levels.
- **Menu** for easy operation and demonstration.

## Configuration (`config.env`)
See `config.env.example` for all variables with safe defaults. Key ones:
- `BACKUP_SRC` — space-separated source paths (default: `$HOME`)
- `BACKUP_DEST` — destination directory (default: `/tmp/backups`)
- `BACKUP_EXCLUDES_FILE` — path to exclude patterns file (e.g. `exclude.example.txt`)
- `BACKUP_RETAIN_DAYS` — retention in days (default: 14)
- `DISK_USAGE_WARN` — percent threshold for warnings (default: 85)
- `TOP_CPU_N` — number of CPU-heavy processes to show (default: 5)
- `WATCH_INTERVAL` — seconds between checks in watch mode (default: 10)
- `UPDATES_YES` — attempt non-interactive updates where supported (default: true)
- `SUITE_LOG` — path to suite log (default: `./suite.log`)

## Demo Commands
```bash
# Dry-run backup (no changes) for demo:
bash scripts/backup.sh --dry-run

# Actual backup:
bash scripts/backup.sh

# System update & cleanup (may prompt for sudo):
bash scripts/updates.sh

# One-shot log scan:
bash scripts/log_monitor.sh

# Watch mode (Ctrl+C to exit):
bash scripts/log_monitor.sh --follow
```

## Cron examples
Edit with `crontab -e`:
```
# Nightly backup at 2:05
5 2 * * *  SUITE_LOG="$HOME/suite.log" BACKUP_DEST="/mnt/backup" bash /path/to/scripts/backup.sh

# Weekly updates Sunday 3:15
15 3 * * 0 SUITE_LOG="$HOME/suite.log" bash /path/to/scripts/updates.sh

# Log scan every 6 hours
0 */6 * * * SUITE_LOG="$HOME/suite.log" bash /path/to/scripts/log_monitor.sh
```

## Notes
- Review/adjust `sudo` usage per your environment.
- Ensure `BACKUP_DEST` exists and is writable/mounted.
- For distros without `/var/log/auth.log`, the monitor falls back to `journalctl`.

## License
MIT © 2025-11-05


## Screenshots / Sample Output

### Menu
```
==== Bash Maintenance Suite ====
Repo: capstone-bash-scripting-suite
Log: ./suite.log

1) Backup now
2) Update & clean system
3) Scan logs & system
4) Watch system (follow mode)
5) Show suite log (last 200 lines)
6) Exit
```

### Dry-run Backup
```
$ bash scripts/backup.sh --dry-run
[2025-11-05 10:15:09] [INFO] Starting backup to /tmp/backups/backup-20251105-101509
[2025-11-05 10:15:09] [INFO] Backing up /home/user/Documents -> /tmp/backups/backup-20251105-101509/Documents (dry-run=true)
[2025-11-05 10:15:12] [INFO] Backing up /home/user/Pictures -> /tmp/backups/backup-20251105-101509/Pictures (dry-run=true)
[2025-11-05 10:15:12] [INFO] Backup routine finished.
```

### Log Monitor (scan)
```
$ bash scripts/log_monitor.sh
[2025-11-05 10:18:21] [INFO] Checking disk usage...
[2025-11-05 10:18:21] [WARN] High disk usage: 92% on /
[2025-11-05 10:18:21] [INFO] Scanning for failed SSH logins (last 24h)...
[2025-11-05 10:18:21] [INFO] Listing top 5 processes by CPU...
[2025-11-05 10:18:21] [INFO] CPU:  1234     1 /usr/bin/python3 ...  1.2  35.1
```
