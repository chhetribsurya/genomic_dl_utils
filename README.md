# Advanced url download manager

**Author:** Surya B. Chhetri  
**Version:** 2.0

A powerful, feature-rich command-line tool for downloading files from URLs with support for parallel processing, SLURM integration, and MD5 checksum verification.

## 🚀 Features

- ✅ **Parallel Downloads** - Configurable concurrent download jobs
- ✅ **SLURM Integration** - Full HPC cluster support with job arrays
- ✅ **MD5 Verification** - Generate and verify file checksums
- ✅ **Resume Support** - Continue interrupted downloads
- ✅ **Progress Tracking** - Real-time download progress
- ✅ **Comprehensive Logging** - Detailed success/error logs
- ✅ **Interactive Help** - Context-sensitive help system
- ✅ **Error Handling** - Robust retry mechanisms
- ✅ **Flexible Configuration** - Extensive command-line options
- ✅ **Smart Color Detection** - Automatic terminal capability detection
- ✅ **Terminal Compatibility** - Works across different terminal types
- ✅ **Unicode Support** - Symbols with ASCII fallback

## 🎨 Terminal Compatibility

The script automatically detects your terminal's capabilities and adapts accordingly:

### **Color Support**
- **Full Color Terminals** (xterm-256color, modern terminals): Colored output with Unicode symbols
- **Basic Terminals** (xterm, older terminals): Colored output with ASCII symbols  
- **No Color Support** (dumb terminals, pipes): Clean ASCII-only output
- **Manual Override**: Use `--no-color` to force ASCII-only output

### **Terminal Detection**
The script checks for:
- Terminal color capability (`tput colors`)
- UTF-8 encoding support (for Unicode symbols)
- Output redirection (automatically disables colors when piped)
- Terminal type (`$TERM` environment variable)

### **Symbol Fallbacks**
| Feature | Unicode | ASCII Fallback |
|---------|---------|----------------|
| Success | ✓ | [OK] |
| Failure | ✗ | [FAIL] |
| Info | ℹ | [INFO] |
| Arrow | → | --> |
| Download | ⬇ | [DL] |
| SLURM | 🖥 | [HPC] |

### **Examples**
```bash
# Automatic detection (recommended)
./download_manager.sh --help

# Force clean output (for scripts)
./download_manager.sh --help --no-color

# Force UTF-8 if detection fails
LANG=en_US.UTF-8 ./download_manager.sh --help

# Override terminal type
TERM=xterm-256color ./download_manager.sh --help
```

## 📋 Prerequisites

### Required Dependencies
```bash
# Core tools (usually pre-installed)
wget
md5sum

# For SLURM functionality
sbatch
squeue
scancel
```

### Installation Commands
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install wget coreutils

# macOS
brew install wget coreutils

# SLURM (contact your system administrator)
# Usually pre-installed on HPC clusters
```

## 🛠 Installation

1. **Download the script:**
```bash
curl -O https://raw.githubusercontent.com/yourusername/advanced-url-downloader/main/download_manager.sh
# or
wget https://raw.githubusercontent.com/yourusername/advanced-url-downloader/main/download_manager.sh
```

2. **Make executable:**
```bash
chmod +x download_manager.sh
```

3. **Test installation:**
```bash
# Test with colors (should auto-detect terminal capabilities)
./download_manager.sh --version

# Test without colors (clean output)
./download_manager.sh --version --no-color
```

4. **Optional: Install globally:**
```bash
sudo cp download_manager.sh /usr/local/bin/download_manager
download_manager --help
```

### **Terminal Setup (Optional)**
For optimal experience with colors and Unicode symbols:

```bash
# Check current terminal capabilities
echo "Terminal: $TERM"
tput colors
locale | grep UTF

# Set UTF-8 encoding (add to ~/.bashrc or ~/.zshrc)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# For older systems, install modern terminal
# Ubuntu/Debian: sudo apt-get install gnome-terminal
# macOS: Install iTerm2 from https://iterm2.com/
```

## 📖 Quick Start

### Basic Local Download
```bash
# Create a URLs file
echo "https://example.com/file1.zip" > urls.txt
echo "https://example.com/file2.tar.gz" >> urls.txt

# Download files (with automatic color detection)
./download_manager.sh download urls.txt ./downloads

# For automation/scripts (clean output)
./download_manager.sh download urls.txt ./downloads --no-color --quiet
```

### SLURM Download
```bash
# Submit to SLURM with 8 cores and 16GB RAM
./download_manager.sh download urls.txt ./downloads --slurm --cores 8 --memory 16G
```

### Generate and Verify Checksums
```bash
# Generate checksums
./download_manager.sh verify ./downloads --generate

# Verify checksums
./download_manager.sh verify ./downloads
```

### Check Help (with colors)
```bash
# Colored help (auto-detected)
./download_manager.sh --help

# Clean help for scripts/documentation
./download_manager.sh --help --no-color
```

## 🎯 Command Reference

### Main Commands

| Command | Description |
|---------|-------------|
| `download` | Download URLs from a file |
| `verify` | Generate or verify MD5 checksums |
| `slurm` | SLURM-specific operations |
| `help` | Show help information |
| `version` | Show version information |

### Output Modes

The script automatically adapts to your environment, but you can override:

| Mode | When to Use | Example |
|------|-------------|---------|
| **Auto-detect** (default) | Interactive terminal use | `./download_manager.sh --help` |
| **No-color** | Scripts, automation, old terminals | `./download_manager.sh --help --no-color` |
| **Quiet** | Background jobs, logging | `./download_manager.sh download urls.txt ./downloads --quiet` |
| **Verbose** | Debugging, detailed monitoring | `./download_manager.sh download urls.txt ./downloads --verbose` |

### Global Options

| Option | Description |
|--------|-------------|
| `--help, -h` | Show help message |
| `--version, -v` | Show version information |
| `--verbose` | Enable verbose output |
| `--quiet` | Suppress non-error output |
| `--no-color` | Disable colored output and Unicode symbols |

## 📥 Download Command

### Syntax
```bash
./download_manager.sh download <url_file> <target_directory> [options]
```

### Local Download Options

| Option | Default | Description |
|--------|---------|-------------|
| `--jobs, -j <num>` | 4 | Number of parallel downloads |
| `--timeout <seconds>` | 3600 | Download timeout |
| `--retries <num>` | 3 | Number of retry attempts |
| `--user-agent <string>` | Advanced-Downloader/3.0 | Custom User-Agent |
| `--resume` | enabled | Resume partial downloads |
| `--no-resume` | - | Disable resume functionality |
| `--progress` | enabled | Show progress bars |
| `--no-progress` | - | Hide progress bars |

### SLURM Options

| Option | Default | Description |
|--------|---------|-------------|
| `--slurm` | - | Enable SLURM mode |
| `--cores <num>` | 4 | Number of CPU cores |
| `--memory <size>` | 8G | Memory allocation |
| `--time <duration>` | 4:00:00 | Time limit |
| `--partition <name>` | auto-detect | SLURM partition |
| `--account <account>` | - | SLURM account |
| `--job-name <name>` | url-download | SLURM job name |
| `--array` | - | Submit as job array |
| `--interactive` | - | Interactive SLURM session |
| `--sbatch-args <args>` | - | Additional sbatch arguments |

### Examples

#### Local Downloads
```bash
# Basic download (with auto-detected colors)
./download_manager.sh download urls.txt ./downloads

# High-performance local download
./download_manager.sh download urls.txt ./downloads --jobs 16 --timeout 7200

# Custom User-Agent for restrictive sites
./download_manager.sh download urls.txt ./downloads \
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Download without progress bars (for scripting)
./download_manager.sh download urls.txt ./downloads --no-progress --quiet --no-color

# Automation-friendly download with clean output
./download_manager.sh download urls.txt ./downloads --no-color --quiet > download.log 2>&1
```

#### SLURM Downloads
```bash
# Basic SLURM download
./download_manager.sh download urls.txt ./downloads --slurm --cores 8 --memory 16G

# High-memory SLURM job
./download_manager.sh download urls.txt ./downloads \
    --slurm --cores 16 --memory 64G --time 8:00:00

# SLURM job array (one job per URL)
./download_manager.sh download urls.txt ./downloads \
    --slurm --array --cores 2 --memory 4G

# Interactive SLURM session
./download_manager.sh download urls.txt ./downloads \
    --slurm --interactive --cores 4

# Custom partition and account
./download_manager.sh download urls.txt ./downloads \
    --slurm --partition gpu --account myproject --cores 8

# SLURM with additional sbatch arguments
./download_manager.sh download urls.txt ./downloads \
    --slurm --cores 8 --sbatch-args "--mail-type=ALL --mail-user=user@domain.com"
```

## 🛡 Verify Command

### Syntax
```bash
./download_manager.sh verify <directory> [checksum_file] [options]
```

### Options

| Option | Description |
|--------|-------------|
| `--generate, -g` | Generate MD5 checksums |
| `--file-pattern <pattern>` | File pattern to match (default: *) |
| `--exclude-pattern <pattern>` | Exclude files matching pattern |
| `--output <file>` | Output checksum file |
| `--strict` | Fail on first checksum mismatch |
| `--slurm` | Use SLURM for checksum generation |
| `--cores <num>` | SLURM cores (default: 4) |
| `--memory <size>` | SLURM memory (default: 8G) |

### Examples

```bash
# Generate checksums locally (with colors)
./download_manager.sh verify ./downloads --generate

# Generate checksums with SLURM
./download_manager.sh verify ./downloads --generate --slurm --cores 8

# Generate checksums for specific files
./download_manager.sh verify ./downloads --generate --file-pattern "*.tar.gz"

# Generate checksums excluding logs
./download_manager.sh verify ./downloads --generate --exclude-pattern "*.log"

# Verify existing checksums (with colored output)
./download_manager.sh verify ./downloads checksums.md5

# Auto-detect and verify checksums
./download_manager.sh verify ./downloads

# Strict verification (fail fast)
./download_manager.sh verify ./downloads --strict

# Automation-friendly verification
./download_manager.sh verify ./downloads --no-color --quiet
```

## 🖥 SLURM Command

### Syntax
```bash
./download_manager.sh slurm <subcommand> [options]
```

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `submit` | Submit download job to SLURM |
| `status` | Check status of SLURM jobs |
| `cancel` | Cancel SLURM jobs |
| `logs` | View SLURM job logs |
| `info` | Show SLURM cluster information |

### Examples

```bash
# Submit download job
./download_manager.sh slurm submit urls.txt ./downloads --cores 8 --memory 16G

# Check job status
./download_manager.sh slurm status --job-name url-download

# Check specific job
./download_manager.sh slurm status --job-id 12345

# Cancel all download jobs
./download_manager.sh slurm cancel --job-name url-download

# Cancel specific job
./download_manager.sh slurm cancel --job-id 12345

# View job logs
./download_manager.sh slurm logs --job-id 12345

# Show cluster information
./download_manager.sh slurm info
```

## 📁 File Formats

### URL File Format
Create a text file with one URL per line:
```
# This is a comment
https://example.com/dataset1.tar.gz
https://example.com/dataset2.zip
https://mirror.site.com/data/file.txt

# Another comment
https://download.site.com/large_file.bin
```

### Checksum File Format
Standard MD5 format:
```
d41d8cd98f00b204e9800998ecf8427e  file1.txt
098f6bcd4621d373cade4e832627b4f6  file2.zip
5d41402abc4b2a76b9719d911017c592  subdir/file3.tar.gz
```

## 📊 Output Structure

```
target_directory/
├── downloaded_file1.tar.gz
├── downloaded_file2.zip
├── checksums.md5
├── .download_logs/
│   ├── success_20250612_143022.log
│   └── errors_20250612_143022.log
└── slurm_logs/
    ├── url-download_12345.out
    └── url-download_12345.err
```

## 🔧 Advanced Usage

### Large Dataset Downloads
```bash
# For very large datasets with SLURM job arrays
./download_manager.sh download large_dataset_urls.txt ./large_downloads \
    --slurm --array --cores 4 --memory 8G --time 12:00:00 \
    --partition bigmem --account data_project

# Monitor progress
./download_manager.sh slurm status --job-name url-download

# Generate checksums using SLURM after download
./download_manager.sh verify ./large_downloads --generate --slurm --cores 16
```

### Batch Processing Workflow
```bash
#!/bin/bash
# Complete download and verification workflow

URLS_FILE="dataset_urls.txt"
DOWNLOAD_DIR="./downloads"
CORES=8
MEMORY="16G"

# Step 1: Download files (automation-friendly)
echo "Starting downloads..."
./download_manager.sh download "$URLS_FILE" "$DOWNLOAD_DIR" \
    --slurm --cores $CORES --memory $MEMORY --no-color

# Step 2: Wait for completion (or check manually)
echo "Monitor with: ./download_manager.sh slurm status --job-name url-download"

# Step 3: Generate checksums
echo "Generating checksums..."
./download_manager.sh verify "$DOWNLOAD_DIR" --generate --slurm --cores $CORES --no-color

# Step 4: Verify checksums
echo "Verifying checksums..."
./download_manager.sh verify "$DOWNLOAD_DIR" --strict --no-color
```

### Automation Best Practices
```bash
# For scripts and automation, always use:
# --no-color: Clean output without escape sequences
# --quiet: Minimal output for logging
# Proper error handling with exit codes

#!/bin/bash
set -e  # Exit on any error

# Download with clean output
if ./download_manager.sh download urls.txt ./downloads --no-color --quiet; then
    echo "Download completed successfully"
    
    # Generate and verify checksums
    ./download_manager.sh verify ./downloads --generate --no-color --quiet
    ./download_manager.sh verify ./downloads --no-color --quiet
    
    echo "All files verified successfully"
else
    echo "Download failed" >&2
    exit 1
fi
```

### Error Recovery
```bash
# Check for failed downloads
grep "FAILED:" downloads/.download_logs/errors_*.log

# Extract failed URLs for retry
grep "URL:" downloads/.download_logs/errors_*.log | \
    sed 's/.*URL: //' > retry_urls.txt

# Retry failed downloads
./download_manager.sh download retry_urls.txt ./downloads --slurm --cores 4
```

## 🐛 Troubleshooting

### Common Issues

#### Color/Display Issues
```bash
# If you see escape sequences like \033[0;31m instead of colors:

# 1. Check terminal capabilities
echo $TERM
tput colors

# 2. Force no colors
./download_manager.sh --help --no-color

# 3. Set UTF-8 encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 4. Test with different terminal
TERM=xterm-256color ./download_manager.sh --help

# 5. Update terminal or use different one
# On macOS: Try iTerm2 or upgrade Terminal.app
# On Linux: Try gnome-terminal, konsole, or xterm
```

#### Permission Denied
```bash
# Make script executable
chmod +x download_manager.sh

# Check directory permissions
ls -la target_directory/
```

#### SLURM Job Failures
```bash
# Check SLURM logs
./download_manager.sh slurm logs --job-id <job_id>

# Check cluster status
./download_manager.sh slurm info

# Verify partition access
sinfo -p <partition_name>
```

#### Download Failures
```bash
# Check error logs
cat downloads/.download_logs/errors_*.log

# Test single URL manually
wget --timeout=60 --tries=3 "https://example.com/file.zip"

# Check network connectivity
ping example.com
```

#### Checksum Mismatches
```bash
# Re-download specific files
wget "https://example.com/file.zip" -O downloads/file.zip

# Regenerate checksums
./download_manager.sh verify ./downloads --generate --output new_checksums.md5

# Compare checksums
diff checksums.md5 new_checksums.md5
```

### Debug Mode
```bash
# Enable verbose output
./download_manager.sh download urls.txt ./downloads --verbose

# SLURM debug information
./download_manager.sh download urls.txt ./downloads --slurm --verbose

# Clean output for automation
./download_manager.sh download urls.txt ./downloads --quiet --no-color
```

## 🌍 Environment Considerations

### **SSH/Remote Sessions**
```bash
# Ensure proper terminal forwarding
ssh -t user@server

# Set terminal type if needed
export TERM=xterm-256color

# For automated scripts on remote servers
./download_manager.sh download urls.txt ./downloads --no-color --quiet
```

### **Screen/Tmux Sessions**
```bash
# In screen/tmux, colors might not work properly
./download_manager.sh --help --no-color

# Or set proper terminal in screen/tmux config
# .screenrc: term screen-256color
# .tmux.conf: set -g default-terminal "screen-256color"
```

### **CI/CD Pipelines**
```bash
# Always use --no-color in automated environments
./download_manager.sh download urls.txt ./downloads --no-color --quiet

# Example GitHub Actions
run: |
  chmod +x download_manager.sh
  ./download_manager.sh download urls.txt ./downloads --no-color --jobs 4
```

### **Docker Containers**
```bash
# In Dockerfiles, ensure proper locale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Run with no-color for consistent output
RUN ./download_manager.sh download urls.txt ./downloads --no-color
```

## 📈 Performance Tuning

### Local Downloads
- **CPU-bound**: Increase `--jobs` for more parallel downloads
- **Network-bound**: Optimize `--timeout` and `--retries`
- **Storage-bound**: Consider target directory location (SSD vs HDD)

### SLURM Downloads
- **Small files**: Use job arrays (`--array`) for better parallelization
- **Large files**: Use single job with multiple cores
- **Memory**: Allocate sufficient memory for wget buffers
- **Time limits**: Set realistic time limits based on file sizes

### Recommended Configurations

#### Small Files (< 100MB each)
```bash
# Local
./download_manager.sh download urls.txt ./downloads --jobs 16

# SLURM
./download_manager.sh download urls.txt ./downloads \
    --slurm --array --cores 2 --memory 4G
```

#### Large Files (> 1GB each)
```bash
# Local
./download_manager.sh download urls.txt ./downloads --jobs 4 --timeout 7200

# SLURM
./download_manager.sh download urls.txt ./downloads \
    --slurm --cores 8 --memory 16G --time 8:00:00
```

#### Mixed File Sizes
```bash
# SLURM with balanced resources
./download_manager.sh download urls.txt ./downloads \
    --slurm --cores 8 --memory 16G --time 6:00:00
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### **Common Issues:**
- **Color/display problems**: Use `--no-color` flag or check [Terminal Compatibility](#-terminal-compatibility)
- **SLURM errors**: Check cluster status with `./download_manager.sh slurm info`
- **Download failures**: Review error logs in `target_directory/.download_logs/`
- **Permission issues**: Ensure script is executable with `chmod +x download_manager.sh`

### **For Automation Issues:**
Always include the `--no-color` flag in scripts and provide:
- Full command used
- Expected vs actual output
- Environment details (CI/CD, Docker, etc.)

---

**Author:** Surya B. Chhetri  
**Repository:** https://github.com/chhetribsurya/genomic_dl_utils
**Version:** 2.0
