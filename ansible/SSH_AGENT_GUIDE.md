# SSH Agent Auto-Configuration Guide

This Ansible setup automatically configures SSH agent to start and load your SSH keys in WSL2.

## Features

- **Auto-start SSH Agent**: Automatically starts ssh-agent when you open a new shell
- **Persistent Agent**: Reuses the same agent across multiple shell sessions
- **Auto-load Keys**: Automatically loads all SSH private keys on first shell startup
- **Smart Loading**: Only loads keys if they aren't already loaded (prevents duplicates)

## How It Works

### 1. SSH Agent Auto-Start

When you open a new bash shell, the configuration:

1. Checks if an SSH agent is already running
2. If running, connects to the existing agent
3. If not running, starts a new agent and saves the connection details

The agent information is stored in `~/.ssh/agent-environment` and persists across shell sessions.

### 2. Automatic Key Loading

On shell startup, if no keys are loaded:

1. Scans `~/.ssh/` for private keys (`id_*`, `*_rsa`, `*_ed25519`)
2. Adds each key to the ssh-agent
3. Displays which keys were loaded

## Manual Commands

### List Currently Loaded Keys

```bash
ssh-add -l
```

### Manually Load Keys

```bash
~/.ssh/load-keys.sh
```

### Add a Specific Key

```bash
ssh-add ~/.ssh/id_ed25519
```

### Remove All Keys

```bash
ssh-add -D
```

### Remove a Specific Key

```bash
ssh-add -d ~/.ssh/id_ed25519
```

## Configuration

Edit `vars/user_environment.yml`:

```yaml
# Enable/disable ssh-agent auto-start
ssh_agent_autostart: true

# Enable/disable automatic key loading
ssh_agent_autoload_keys: true
```

## Troubleshooting

### Keys Not Loading Automatically

1. Check if ssh-agent is running:

   ```bash
   echo $SSH_AUTH_SOCK
   ```

2. Reload your shell:

   ```bash
   source ~/.bashrc
   ```

3. Manually load keys:

   ```bash
   ~/.ssh/load-keys.sh
   ```

### "SSH agent not running" Error

```bash
source ~/.bashrc
```

This will re-initialize the ssh-agent.

### Check Agent Status

```bash
ps aux | grep ssh-agent
```

### Force Restart Agent

```bash
rm -f ~/.ssh/agent-environment
source ~/.bashrc
```

## Security Notes

- The agent runs only in your user context
- Agent socket is protected by filesystem permissions
- Keys are loaded from `~/.ssh/` which has 0700 permissions
- Private keys must have 0600 permissions (automatically set by Ansible)

## Files Created

- `~/.ssh/load-keys.sh` - Script to load SSH keys
- `~/.ssh/agent-environment` - SSH agent connection details
- `~/.bashrc` - Contains ssh-agent startup and key loading logic

## Password-Protected Keys

If your SSH keys are password-protected:

- You'll be prompted for the password when keys are loaded
- Consider using `ssh-add -t <seconds>` for time-limited key loading
- Or use `ssh-add -c` for confirmation before each use

Example:

```bash
# Add key for 8 hours (28800 seconds)
ssh-add -t 28800 ~/.ssh/id_ed25519_github
```

## Integration with Other Tools

The ssh-agent works seamlessly with:

- Git operations
- SSH connections
- SCP/RSYNC file transfers
- Any tool that uses SSH authentication

## Verification

After running the Ansible playbook and reloading your shell:

```bash
# Should show your loaded keys
ssh-add -l

# Should show agent is running
echo $SSH_AUTH_SOCK

# Test SSH connection (example with GitHub)
ssh -T git@github.com
```
