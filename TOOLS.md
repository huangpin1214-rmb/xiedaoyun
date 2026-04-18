# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Script Creation - Execute Permission (2026-04-18)

`write` tool and `cp` create files with 644 permissions (rw-r--r--), **no execute bit**.

**Problem:** Scripts without execute permission fail silently in crontab:
```
Permission denied
```

**Rule:** After creating any script via `write`/`cp` that will be run by crontab, always `chmod +x /path/to/script.sh`.

**Better approach:** Use `exec` with heredoc + chmod in one step:
```bash
cat > /path/to/script.sh << 'EOF'
#!/bin/bash
...
EOF
chmod +x /path/to/script.sh
```
