# GPG Keys Management Guide

This Ansible setup automatically copies GPG keys from your backup location to WSL2.

## Features

- **Automatic Copy**: Copies all GPG keys from backup location
- **Proper Permissions**: Sets correct file and directory permissions (0700/0600)
- **Selective Exclusion**: Excludes temporary and lock files
- **GPG Agent Support**: Optional SSH support via GPG agent

## How It Works

### 1. GPG Keys Copy

The role:
1. Checks if the source directory exists
2. Copies all GPG keyring files and configuration
3. Sets proper ownership and permissions
4. Excludes temporary files (*.lock, *.tmp, random_seed, etc.)

### 2. Directory Structure

The following directories/files are copied:
- `pubring.kbx` - Public keyring
- `trustdb.gpg` - Trust database
- `private-keys-v1.d/` - Private keys
- `openpgp-revocs.d/` - Revocation certificates
- GPG configuration files

## Configuration

Edit `vars/user_environment.yml`:

```yaml
# Enable/disable GPG key copying
copy_gpg_keys: true

# Source directory for GPG keys
gpg_keys_source: "/path/to/GPG/source"

# Enable GPG agent SSH support (use GPG keys for SSH authentication)
gpg_enable_ssh_support: false
```

## Manual Commands

### List GPG Keys
```bash
# List public keys
gpg --list-keys

# List secret (private) keys
gpg --list-secret-keys

# List keys with fingerprints
gpg --fingerprint
```

### Import Additional Keys
```bash
# Import a public key
gpg --import public-key.asc

# Import a private key
gpg --import private-key.asc
```

### Export Keys
```bash
# Export public key
gpg --armor --export your-email@example.com > public-key.asc

# Export private key (keep secure!)
gpg --armor --export-secret-keys your-email@example.com > private-key.asc
```

### Trust Level
```bash
# Edit key trust
gpg --edit-key your-email@example.com
# Then type: trust
# Select trust level (5 for ultimate)
# Then type: quit
```

### Sign and Encrypt
```bash
# Sign a file
gpg --sign file.txt

# Encrypt a file
gpg --encrypt --recipient your-email@example.com file.txt

# Sign and encrypt
gpg --encrypt --sign --recipient your-email@example.com file.txt

# Decrypt a file
gpg --decrypt file.txt.gpg > file.txt
```

## Git Commit Signing

### Configure Git to Use GPG
```bash
# Set your GPG key for Git
gpg --list-secret-keys --keyid-format=long
# Copy the key ID (after sec   rsa4096/)

git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

### Sign Commits
```bash
# Commits will be signed automatically if commit.gpgsign is true
git commit -m "Your commit message"

# Or sign manually
git commit -S -m "Your commit message"

# Verify signatures
git log --show-signature
```

## GPG Agent Configuration

The GPG agent is automatically configured with:
- Cache TTL: 600 seconds (10 minutes)
- Max cache TTL: 7200 seconds (2 hours)
- Optional SSH support (if enabled)

### Manual GPG Agent Commands
```bash
# Reload GPG agent
gpgconf --kill gpg-agent
gpg-agent --daemon

# Check GPG agent status
gpgconf --list-dirs

# Clear cached passphrases
gpgconf --reload gpg-agent
```

## Using GPG Keys for SSH (Optional)

If you enable `gpg_enable_ssh_support: true`, you can use GPG keys for SSH authentication:

### Setup
1. Enable in config:
   ```yaml
   gpg_enable_ssh_support: true
   ```

2. Add to `.bashrc`:
   ```bash
   export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
   ```

3. Add your GPG authentication subkey:
   ```bash
   ssh-add -L
   ```

## Troubleshooting

### "No secret key" Error
```bash
# Check if keys were copied
ls -la ~/.gnupg/

# Check key permissions
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*
```

### GPG Agent Not Running
```bash
# Start GPG agent
gpg-agent --daemon

# Reload configuration
gpgconf --reload gpg-agent
```

### "Inappropriate ioctl for device" Error
```bash
# Set GPG TTY
export GPG_TTY=$(tty)

# Add to .bashrc for persistence
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
```

### Git Commit Signing Fails
```bash
# Check GPG key
gpg --list-secret-keys

# Test signing
echo "test" | gpg --clearsign

# Set GPG program for Git
git config --global gpg.program gpg
```

## Security Notes

- GPG directory permissions: 0700 (owner only)
- Private key permissions: 0600 (owner read/write only)
- Never share private keys
- Keep backups of revocation certificates
- Use strong passphrases for private keys

## Files Created/Modified

- `~/.gnupg/` - Main GPG directory
- `~/.gnupg/pubring.kbx` - Public keyring
- `~/.gnupg/trustdb.gpg` - Trust database
- `~/.gnupg/private-keys-v1.d/` - Private keys directory
- `~/.gnupg/gpg-agent.conf` - GPG agent configuration (if SSH support enabled)

## Verification

After running the Ansible playbook:

```bash
# Check directory permissions
ls -ld ~/.gnupg

# List installed keys
gpg --list-secret-keys

# Test signing
echo "test" | gpg --clearsign

# Test with Git (if configured)
git commit --allow-empty -m "Test GPG signing"
git log --show-signature -1
```

## Running the Playbook

### Copy GPG keys only
```bash
cd ~/development/moshpitcodes.wsl/ansible
ansible-playbook -K --tags "gpg" playbooks/main.yml
```

### Copy both SSH and GPG keys
```bash
ansible-playbook -K --tags "ssh,gpg" playbooks/main.yml
```

### Run full playbook
```bash
ansible-playbook -K playbooks/main.yml
```
