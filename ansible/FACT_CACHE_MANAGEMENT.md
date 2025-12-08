# Ansible Fact Cache Management

## Overview

Ansible uses fact caching to store system information between playbook runs, improving performance by avoiding redundant fact gathering. This document explains how fact caching is configured in this WSL2 DevEnv setup and how to manage it.

## Configuration

### Location
- **Cache Directory**: `~/.ansible/facts_cache`
- **Configuration File**: `ansible.cfg`

### Settings

```ini
gathering = smart
fact_caching = jsonfile
fact_caching_connection = ~/.ansible/facts_cache
fact_caching_timeout = 604800  # 7 days
fact_caching_prefix = wsl2_
```

### Cache Behavior

- **Smart Gathering**: Ansible only gathers facts when needed or when cache is expired
- **Timeout**: 7 days (604800 seconds) - suitable for relatively stable WSL environment
- **Format**: JSON files, one per host
- **Prefix**: `wsl2_` - helps identify cache files for this environment

## Cache Management

### Manual Inspection

View cached facts for localhost:
```bash
cat ~/.ansible/facts_cache/wsl2_local
```

List all cache files:
```bash
ls -lh ~/.ansible/facts_cache/
```

Check cache size:
```bash
du -sh ~/.ansible/facts_cache/
```

### Automated Cleanup

Use the provided cleanup script to remove stale cache files:

#### Basic Usage

```bash
# Preview what would be deleted (dry run)
./cleanup-fact-cache.sh --dry-run

# Delete cache files older than 30 days (default)
./cleanup-fact-cache.sh

# Delete cache files older than 7 days
./cleanup-fact-cache.sh --age 7

# Preview deletion of files older than 14 days
./cleanup-fact-cache.sh --age 14 --dry-run
```

#### Script Options

- `--age DAYS`: Delete files older than specified days (default: 30)
- `--dry-run`: Show what would be deleted without actually deleting
- `--help`: Display help information

### Manual Cache Clearing

Force clear all cached facts:
```bash
rm -rf ~/.ansible/facts_cache/*
```

Clear specific host cache:
```bash
rm ~/.ansible/facts_cache/wsl2_local
```

### Force Fact Gathering

Force Ansible to re-gather facts regardless of cache:
```bash
# Clear cache and run playbook
rm -rf ~/.ansible/facts_cache/*
ansible-playbook -K playbooks/main.yml
```

Or use the `gather_facts: true` directive in your playbook.

## When to Clear Cache

Clear the fact cache when:

1. **System Changes**: Major system upgrades or configuration changes
2. **Incorrect Cached Data**: Stale or incorrect facts causing issues
3. **Debugging**: Troubleshooting playbook behavior
4. **Disk Space**: Cache consuming too much space
5. **Version Upgrades**: After upgrading Ansible or changing fact structure

## Best Practices

### Regular Maintenance

Set up a periodic cleanup routine:

1. **Weekly**: Review cache size and oldest files
   ```bash
   ./cleanup-fact-cache.sh --dry-run
   ```

2. **Monthly**: Clean up files older than 30 days
   ```bash
   ./cleanup-fact-cache.sh --age 30
   ```

3. **After Major Changes**: Clear cache after system upgrades
   ```bash
   rm -rf ~/.ansible/facts_cache/*
   ```

### Adjust Cache Timeout

Modify `ansible.cfg` if your environment changes frequently:

```ini
# For frequently changing environments (1 day)
fact_caching_timeout = 86400

# For stable environments (7 days) - current setting
fact_caching_timeout = 604800

# For very stable environments (30 days)
fact_caching_timeout = 2592000
```

### Automate Cleanup

Add cleanup to cron (optional):

```bash
# Add to crontab (run monthly)
0 0 1 * * /path/to/ansible/cleanup-fact-cache.sh --age 30 >> ~/.ansible/fact_cache_cleanup.log 2>&1
```

## Troubleshooting

### Cache Not Being Used

**Symptoms**: Facts gathered on every run

**Solutions**:
1. Check cache directory exists and is writable
   ```bash
   mkdir -p ~/.ansible/facts_cache
   chmod 755 ~/.ansible/facts_cache
   ```

2. Verify `ansible.cfg` is being used
   ```bash
   ansible-config dump --only-changed | grep fact_caching
   ```

3. Check gathering mode in playbook
   ```yaml
   gather_facts: true  # Will use cache if valid
   ```

### Stale Facts Causing Issues

**Symptoms**: Playbook behaves unexpectedly, uses old system information

**Solutions**:
1. Clear specific host cache
   ```bash
   rm ~/.ansible/facts_cache/wsl2_local
   ```

2. Run with fresh facts
   ```bash
   rm -rf ~/.ansible/facts_cache/*
   ansible-playbook -K playbooks/main.yml
   ```

### Cache Growing Too Large

**Symptoms**: Cache directory consuming significant disk space

**Solutions**:
1. Run cleanup script regularly
   ```bash
   ./cleanup-fact-cache.sh --age 7
   ```

2. Reduce cache timeout in `ansible.cfg`
   ```ini
   fact_caching_timeout = 86400  # 1 day instead of 7
   ```

3. Use cache prefix to identify and remove old entries
   ```bash
   find ~/.ansible/facts_cache -name "wsl2_*" -mtime +30 -delete
   ```

## Monitoring

### Check Cache Statistics

View current cache status:
```bash
echo "Cache files: $(find ~/.ansible/facts_cache -type f | wc -l)"
echo "Cache size: $(du -sh ~/.ansible/facts_cache | cut -f1)"
echo "Oldest file: $(find ~/.ansible/facts_cache -type f -printf '%T+ %p\n' | sort | head -1)"
echo "Newest file: $(find ~/.ansible/facts_cache -type f -printf '%T+ %p\n' | sort -r | head -1)"
```

### Verify Facts

Check what facts are cached:
```bash
# Pretty print cached facts
python3 -m json.tool ~/.ansible/facts_cache/wsl2_local | less
```

## Security Considerations

- **Permissions**: Cache files should be readable only by the user (0600)
- **Sensitive Data**: Facts may contain system information; protect cache directory
- **Backup**: Include cache directory in backup exclusions (not critical data)

## Additional Resources

- [Ansible Fact Caching Documentation](https://docs.ansible.com/ansible/latest/plugins/cache.html)
- [Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)
- [Setup Module (Facts)](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html)
