# AI Tools Role

This Ansible role installs and configures AI-powered CLI tools for development environments.

## Installed Tools

### 1. **Gemini CLI** (`@google/gemini-cli`)

Google's AI assistant CLI with access to the Gemini model directly from your terminal.

**Features:**

- 1M token context window
- Built-in Google Search grounding
- File operations, shell commands, and web fetching
- Free tier: 60 requests/minute, 1,000 requests/day

**Authentication Methods:**

- Interactive: Run `gemini` and login with Google
- API Key: `export GEMINI_API_KEY="your_key"`
- Vertex AI: Set `GOOGLE_API_KEY` and `GOOGLE_GENAI_USE_VERTEXAI=true`

**Requirements:**

- Node.js 20 or higher

### 2. **Claude Code** (`@anthropic-ai/claude-code`)


Anthropic's official CLI for Claude AI coding assistant.

**Features:**

- Interactive coding assistance
- Code generation and refactoring
- Multi-file context awareness
- Direct terminal integration

**Documentation:** <https://code.claude.com/docs>

### 3. **Opencode** (`opencode-ai`)


Open-source AI-powered coding assistant from SST.

**Features:**

- AI-assisted code completion
- Context-aware suggestions
- Multiple AI model support
- Lightweight and fast

**Installation Methods:**

- `script`: Install via official install script (recommended)
- `npm`: Install via npm globally

**Documentation:** <https://opencode.ai/docs>

## Usage

### Running the Role

Install all AI tools (default):

```bash
ansible-playbook -K playbooks/main.yml --tags ai-tools
```

Install specific tools by modifying `vars/user_environment.yml`:

```yaml
install_ai_tools: true
install_gemini_cli: true
install_claude_code: true
install_opencode: true
```

### Individual Tool Tags

Run specific tool installations:

```bash
# Install only Gemini CLI
ansible-playbook -K playbooks/main.yml --tags gemini

# Install only Claude Code
ansible-playbook -K playbooks/main.yml --tags claude

# Install only Opencode
ansible-playbook -K playbooks/main.yml --tags opencode
```

## Configuration Variables

### Main Toggle

```yaml
install_ai_tools: true  # Master switch for the role
```

### Individual Tool Toggles

```yaml
install_gemini_cli: true
install_claude_code: true
install_opencode: true
```

### Version Configuration

```yaml
# Gemini CLI version
gemini_cli_version: "latest"  # Options: latest, preview, nightly

# Opencode installation method
opencode_install_method: "script"  # Options: script, npm
opencode_version: "latest"  # Only used with npm method
```

### Advanced Configuration

See `roles/ai-tools/defaults/main.yml` for all available options:

```yaml
# Gemini CLI
gemini_cli_package: "@google/gemini-cli"

# Claude Code
claude_code_package: "@anthropic-ai/claude-code"

# Opencode
opencode_install_script: "https://opencode.ai/install"
opencode_package: "opencode-ai"
opencode_bin_directory: "/usr/local/bin"  # Used with script method
```

## Post-Installation

After installation, the tools are immediately available:

```bash
# Launch Gemini CLI
gemini

# Launch Claude Code
claude

# Launch Opencode
opencode
```

### First Run Setup

**Gemini CLI:**
On first run, you'll be prompted to authenticate via:

1. Google OAuth (interactive browser login)
2. API key (set `GEMINI_API_KEY` environment variable)
3. Vertex AI (for enterprise users)

**Claude Code:**
Follow the on-screen authentication prompts when first running `claude`.

**Opencode:**
Configuration options are available at <https://opencode.ai/docs>

## Shell Integration

The role automatically adds helpful comments to your `.bashrc` with usage instructions for each tool.

After installation, reload your shell:

```bash
source ~/.bashrc
```

## Dependencies

This role requires:

- Node.js (installed via the `development` role)
- npm (comes with Node.js)
- curl (for Opencode script installation)

Ensure the `development` role is run before this role, or that Node.js is already installed.

## Troubleshooting

### Command not found after installation

Reload your shell or open a new terminal:

```bash
source ~/.bashrc
# or
exec bash
```

### Gemini CLI: Node.js version error

Ensure Node.js 20+ is installed:

```bash
node --version  # Should be v20.0.0 or higher
```

Update Node.js version in `vars/user_environment.yml`:

```yaml
nodejs_version: "24.11.1"  # or latest LTS
```

### Opencode: Permission denied

If using script installation method, ensure the binary is executable:

```bash
sudo chmod +x /usr/local/bin/opencode
```

### npm installation issues

If global npm installation fails, try with sudo:

```bash
sudo npm install -g @google/gemini-cli
sudo npm install -g @anthropic-ai/claude-code
sudo npm install -g opencode-ai
```

## Examples

### Using Gemini CLI

```bash
# Start interactive session
gemini

# Ask a question directly
gemini "Explain what this script does" < script.sh

# With API key
export GEMINI_API_KEY="your_key_here"
gemini "Write a Python function to sort a list"
```

### Using Claude Code

```bash
# Start interactive coding session
claude

# Get help
claude --help
```

### Using Opencode

```bash
# Launch Opencode
opencode

# With specific configuration
opencode --config /path/to/config
```

## Updating Tools

To update to the latest versions:

**npm-based tools (Gemini CLI, Claude Code):**

```bash
sudo npm update -g @google/gemini-cli
sudo npm update -g @anthropic-ai/claude-code
```

**Opencode (script method):**
Re-run the playbook:

```bash
ansible-playbook -K playbooks/main.yml --tags opencode
```

## Uninstallation

To remove the tools:

**npm-based tools:**

```bash
sudo npm uninstall -g @google/gemini-cli
sudo npm uninstall -g @anthropic-ai/claude-code
sudo npm uninstall -g opencode-ai
```

**Opencode (script method):**

```bash
sudo rm /usr/local/bin/opencode
```

## Tags

- `ai-tools`: All AI tools
- `gemini`: Gemini CLI only
- `claude`: Claude Code only
- `opencode`: Opencode only

## License

This role follows the same license as the parent Ansible project.

## References

- [Gemini CLI GitHub](https://github.com/google-gemini/gemini-cli)
- [Gemini CLI Codelabs](https://codelabs.developers.google.com/gemini-cli-hands-on)
- [Claude Code Documentation](https://code.claude.com/docs)
- [Opencode GitHub](https://github.com/sst/opencode)
- [Opencode Documentation](https://opencode.ai/docs)
