#!/bin/bash

# Advanced URL Downloader with MD5 Verification and SLURM Support
# Author: Surya B. Chhetri
# Version: 3.0

# Global variables
SCRIPT_NAME=$(basename "$0")
VERSION="3.0"
AUTHOR="Surya B. Chhetri"

# Color support detection
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ $(tput colors) -ge 8 ]]; then
    # Terminal supports colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    BOLD='\033[1m'
    
    # Unicode symbols (only if UTF-8 is supported)
    if [[ "${LANG:-}" =~ UTF-8 ]] || [[ "${LC_ALL:-}" =~ UTF-8 ]]; then
        CHECKMARK="✓"
        CROSSMARK="✗"
        ARROW="→"
        DOWNLOAD="⬇"
        SHIELD="🛡"
        GEAR="⚙"
        INFO="ℹ"
        CLUSTER="🖥"
    else
        CHECKMARK="[OK]"
        CROSSMARK="[FAIL]"
        ARROW="-->"
        DOWNLOAD="[DL]"
        SHIELD="[SEC]"
        GEAR="[CFG]"
        INFO="[INFO]"
        CLUSTER="[HPC]"
    fi
else
    # No color support
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    NC=''
    BOLD=''
    
    # ASCII-safe symbols
    CHECKMARK="[OK]"
    CROSSMARK="[FAIL]"
    ARROW="-->"
    DOWNLOAD="[DL]"
    SHIELD="[SEC]"
    GEAR="[CFG]"
    INFO="[INFO]"
    CLUSTER="[HPC]"
fi

# Help functions
show_main_help() {
    cat << EOF
${BOLD}${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}
${BOLD}${PURPLE}║               Advanced URL Downloader v${VERSION}                ║${NC}
${BOLD}${PURPLE}║                    by ${AUTHOR}                   ║${NC}
${BOLD}${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}

${BOLD}USAGE:${NC}
    ${SCRIPT_NAME} <command> [options]

${BOLD}COMMANDS:${NC}
    ${GREEN}download${NC}     Download URLs from a file (local or SLURM)
    ${GREEN}verify${NC}       Verify MD5 checksums of downloaded files
    ${GREEN}slurm${NC}        SLURM-specific download operations
    ${GREEN}help${NC}         Show this help message
    ${GREEN}version${NC}      Show version information

${BOLD}EXAMPLES:${NC}
    ${CYAN}# Local download with defaults${NC}
    ${SCRIPT_NAME} download dl.urls.txt ./downloads

    ${CYAN}# SLURM download with 8 cores and 16GB RAM${NC}
    ${SCRIPT_NAME} download dl.urls.txt ./downloads --slurm --cores 8 --memory 16G

    ${CYAN}# SLURM batch job submission${NC}
    ${SCRIPT_NAME} slurm submit dl.urls.txt ./downloads --cores 16 --memory 32G

    ${CYAN}# Verify checksums${NC}
    ${SCRIPT_NAME} verify ./downloads checksums.md5

    ${CYAN}# Show command-specific help${NC}
    ${SCRIPT_NAME} download --help
    ${SCRIPT_NAME} slurm --help

${BOLD}GLOBAL OPTIONS:${NC}
    --help, -h      Show help message
    --version, -v   Show version information
    --verbose       Enable verbose output
    --quiet         Suppress non-error output
    --no-color      Disable colored output

${BOLD}DEPENDENCIES:${NC}
    - wget (for downloading)
    - md5sum (for checksum verification)
    - sbatch, squeue, scancel (for SLURM operations)

EOF
}

show_download_help() {
    cat << EOF
${BOLD}${CYAN}DOWNLOAD COMMAND${NC}

${BOLD}USAGE:${NC}
    ${SCRIPT_NAME} download <url_file> <target_directory> [options]

${BOLD}PARAMETERS:${NC}
    ${GREEN}url_file${NC}          Path to file containing URLs (one per line)
    ${GREEN}target_directory${NC}  Directory to save downloaded files

${BOLD}LOCAL OPTIONS:${NC}
    --jobs, -j <num>      Number of parallel downloads (default: 4)
    --timeout <seconds>   Download timeout in seconds (default: 3600)
    --retries <num>       Number of retry attempts (default: 3)
    --user-agent <string> Custom User-Agent string
    --resume              Resume partial downloads (default: enabled)
    --no-resume           Disable resume functionality
    --progress            Show progress bar (default: enabled)
    --no-progress         Hide progress bar

${BOLD}SLURM OPTIONS:${NC}
    --slurm               Use SLURM for job submission
    --cores <num>         Number of CPU cores (default: 4)
    --memory <size>       Memory allocation (e.g., 8G, 16000M) (default: 8G)
    --time <duration>     Time limit (e.g., 2:00:00, 120) (default: 4:00:00)
    --partition <name>    SLURM partition (default: auto-detect)
    --account <account>   SLURM account
    --job-name <name>     SLURM job name (default: url-download)
    --array               Submit as job array (one job per URL)
    --interactive         Submit interactive SLURM job
    --sbatch-args <args>  Additional sbatch arguments

${BOLD}EXAMPLES:${NC}
    ${CYAN}# Local download${NC}
    ${SCRIPT_NAME} download urls.txt ./downloads --jobs 8

    ${CYAN}# SLURM batch download${NC}
    ${SCRIPT_NAME} download urls.txt ./downloads --slurm --cores 8 --memory 16G

    ${CYAN}# SLURM interactive session${NC}
    ${SCRIPT_NAME} download urls.txt ./downloads --slurm --interactive --cores 4

    ${CYAN}# SLURM job array (parallel URL processing)${NC}
    ${SCRIPT_NAME} download urls.txt ./downloads --slurm --array --cores 2 --memory 4G

    ${CYAN}# SLURM with custom partition and account${NC}
    ${SCRIPT_NAME} download urls.txt ./downloads --slurm --partition gpu --account myproject

${BOLD}URL FILE FORMAT:${NC}
    - One URL per line
    - Lines starting with # are treated as comments
    - Empty lines are ignored
    - Only HTTP/HTTPS URLs are supported

EOF
}

show_slurm_help() {
    cat << EOF
${BOLD}${CYAN}SLURM COMMAND${NC}

${BOLD}USAGE:${NC}
    ${SCRIPT_NAME} slurm <subcommand> [options]

${BOLD}SUBCOMMANDS:${NC}
    ${GREEN}submit${NC}       Submit download job to SLURM
    ${GREEN}status${NC}       Check status of SLURM jobs
    ${GREEN}cancel${NC}       Cancel SLURM jobs
    ${GREEN}logs${NC}         View SLURM job logs
    ${GREEN}info${NC}         Show SLURM cluster information

${BOLD}SUBMIT OPTIONS:${NC}
    <url_file> <target_dir>   Required: URL file and target directory
    --cores <num>             CPU cores (default: 4)
    --memory <size>           Memory allocation (default: 8G)
    --time <duration>         Time limit (default: 4:00:00)
    --partition <name>        SLURM partition
    --account <account>       SLURM account
    --job-name <name>         Job name (default: url-download)
    --array                   Submit as job array
    --dependency <jobid>      Job dependency

${BOLD}STATUS/CANCEL OPTIONS:${NC}
    --job-id <id>            Specific job ID
    --job-name <name>        Jobs with specific name
    --user <username>        Jobs for specific user (default: current user)

${BOLD}EXAMPLES:${NC}
    ${CYAN}# Submit download job${NC}
    ${SCRIPT_NAME} slurm submit urls.txt ./downloads --cores 8 --memory 16G

    ${CYAN}# Check job status${NC}
    ${SCRIPT_NAME} slurm status --job-name url-download

    ${CYAN}# Cancel all download jobs${NC}
    ${SCRIPT_NAME} slurm cancel --job-name url-download

    ${CYAN}# View job logs${NC}
    ${SCRIPT_NAME} slurm logs --job-id 12345

    ${CYAN}# Show cluster info${NC}
    ${SCRIPT_NAME} slurm info

EOF
}

show_verify_help() {
    cat << EOF
${BOLD}${CYAN}VERIFY COMMAND${NC}

${BOLD}USAGE:${NC}
    ${SCRIPT_NAME} verify <directory> [checksum_file] [options]

${BOLD}PARAMETERS:${NC}
    ${GREEN}directory${NC}        Directory containing downloaded files
    ${GREEN}checksum_file${NC}    Optional MD5 checksum file (auto-detected if not provided)

${BOLD}OPTIONS:${NC}
    --generate, -g        Generate MD5 checksums for all files
    --file-pattern <pat>  File pattern to match (default: *)
    --exclude-pattern <pat> Exclude files matching pattern
    --output <file>       Output checksum file (with --generate)
    --strict              Fail on first checksum mismatch
    --slurm               Use SLURM for checksum generation (large datasets)
    --cores <num>         SLURM cores for checksum generation (default: 4)
    --memory <size>       SLURM memory for checksum generation (default: 8G)

${BOLD}EXAMPLES:${NC}
    ${CYAN}# Verify using existing checksum file${NC}
    ${SCRIPT_NAME} verify ./downloads checksums.md5

    ${CYAN}# Generate new checksums locally${NC}
    ${SCRIPT_NAME} verify ./downloads --generate

    ${CYAN}# Generate checksums using SLURM${NC}
    ${SCRIPT_NAME} verify ./downloads --generate --slurm --cores 8

    ${CYAN}# Verify with specific pattern${NC}
    ${SCRIPT_NAME} verify ./downloads --generate --file-pattern "*.tar.gz"

EOF
}

# Utility functions
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")  printf "${CYAN}${INFO} [${timestamp}]${NC} %s\n" "$message" ;;
        "SUCCESS") printf "${GREEN}${CHECKMARK} [${timestamp}]${NC} %s\n" "$message" ;;
        "ERROR") printf "${RED}${CROSSMARK} [${timestamp}]${NC} %s\n" "$message" ;;
        "WARN")  printf "${YELLOW}⚠ [${timestamp}]${NC} %s\n" "$message" ;;
        "SLURM") printf "${PURPLE}${CLUSTER} [${timestamp}]${NC} %s\n" "$message" ;;
    esac
}

check_dependencies() {
    local missing_deps=()
    local slurm_mode="${1:-false}"
    
    command -v wget >/dev/null 2>&1 || missing_deps+=("wget")
    command -v md5sum >/dev/null 2>&1 || missing_deps+=("md5sum")
    
    if [[ "$slurm_mode" == true ]]; then
        command -v sbatch >/dev/null 2>&1 || missing_deps+=("sbatch")
        command -v squeue >/dev/null 2>&1 || missing_deps+=("squeue")
        command -v scancel >/dev/null 2>&1 || missing_deps+=("scancel")
    fi
    
            if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_message "ERROR" "Missing dependencies: ${missing_deps[*]}"
        printf "${YELLOW}Please install missing dependencies:${NC}\n"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                wget|md5sum)
                    printf "  ${CYAN}# For Ubuntu/Debian:${NC} sudo apt-get install %s\n" "$dep"
                    printf "  ${CYAN}# For macOS:${NC} brew install %s\n" "$dep"
                    ;;
                sbatch|squeue|scancel)
                    printf "  ${CYAN}# SLURM tools - contact your system administrator${NC}\n"
                    ;;
            esac
        done
        return 1
    fi
    return 0
}

# SLURM utility functions
get_slurm_partition() {
    local default_partition
    default_partition=$(scontrol show config 2>/dev/null | grep "DefaultPartition" | awk -F= '{print $2}' | tr -d ' ')
    echo "${default_partition:-compute}"
}

submit_slurm_job() {
    local script_content="$1"
    local job_name="$2"
    local cores="$3"
    local memory="$4"
    local time_limit="$5"
    local partition="$6"
    local account="$7"
    local additional_args="$8"
    local array_spec="$9"
    local interactive="${10}"
    
    local temp_script=$(mktemp "/tmp/slurm_download_XXXXXX.sh")
    echo "$script_content" > "$temp_script"
    chmod +x "$temp_script"
    
    local sbatch_cmd="sbatch"
    local sbatch_args=(
        "--job-name=$job_name"
        "--cpus-per-task=$cores"
        "--mem=$memory"
        "--time=$time_limit"
        "--output=${job_name}_%j.out"
        "--error=${job_name}_%j.err"
    )
    
    [[ -n "$partition" ]] && sbatch_args+=("--partition=$partition")
    [[ -n "$account" ]] && sbatch_args+=("--account=$account")
    [[ -n "$array_spec" ]] && sbatch_args+=("--array=$array_spec")
    [[ -n "$additional_args" ]] && sbatch_args+=($additional_args)
    
    if [[ "$interactive" == true ]]; then
        sbatch_cmd="srun"
        sbatch_args+=("--pty")
    fi
    
    local job_id
    if [[ "$interactive" == true ]]; then
        log_message "SLURM" "Starting interactive session..."
        "$sbatch_cmd" "${sbatch_args[@]}" "$temp_script"
        local exit_code=$?
        rm -f "$temp_script"
        return $exit_code
    else
        job_id=$("$sbatch_cmd" "${sbatch_args[@]}" "$temp_script" | awk '{print $4}')
        if [[ -n "$job_id" ]]; then
            log_message "SLURM" "Job submitted successfully: Job ID $job_id"
            echo -e "${CYAN}${ARROW} Job ID:${NC} $job_id"
            echo -e "${CYAN}${ARROW} Script:${NC} $temp_script"
            echo -e "${CYAN}${ARROW} Monitor with:${NC} squeue -j $job_id"
            echo -e "${CYAN}${ARROW} Cancel with:${NC} scancel $job_id"
            return 0
        else
            log_message "ERROR" "Failed to submit SLURM job"
            rm -f "$temp_script"
            return 1
        fi
    fi
}

create_slurm_download_script() {
    local url_file="$1"
    local target_dir="$2"
    local jobs="$3"
    local timeout="$4"
    local retries="$5"
    local user_agent="$6"
    local resume="$7"
    local show_progress="$8"
    local array_mode="$9"
    
    if [[ "$array_mode" == true ]]; then
        cat << EOF
#!/bin/bash
#SBATCH --output=download_%A_%a.out
#SBATCH --error=download_%A_%a.err

# SLURM Array Job for URL Downloads
# Author: $AUTHOR

module load wget 2>/dev/null || true

URL_FILE="$url_file"
TARGET_DIR="$target_dir"
ARRAY_INDEX=\${SLURM_ARRAY_TASK_ID}

# Create target directory
mkdir -p "\$TARGET_DIR"

# Get URL for this array task
URL=\$(sed -n "\${ARRAY_INDEX}p" "\$URL_FILE" | grep '^https\?://')

if [[ -z "\$URL" ]]; then
    echo "No URL found for array index \$ARRAY_INDEX"
    exit 1
fi

# Extract filename
FILENAME=\$(basename "\$URL" | sed 's/[?&].*//')
[[ -z "\$FILENAME" || "\$FILENAME" == "/" ]] && FILENAME="download_\${ARRAY_INDEX}"
FILEPATH="\${TARGET_DIR}/\${FILENAME}"

echo "Downloading: \$URL"
echo "Target: \$FILEPATH"

# Download with wget
wget --timeout=$timeout \\
     --tries=$((retries + 1)) \\
     --user-agent="$user_agent" \\
     --no-check-certificate \\
     $([ "$resume" == true ] && echo "--continue") \\
     $([ "$show_progress" == true ] && echo "--progress=bar:force" || echo "--quiet") \\
     --output-document="\$FILEPATH" \\
     "\$URL"

if [[ \$? -eq 0 ]]; then
    echo "Successfully downloaded: \$FILENAME"
    echo "Size: \$(du -h "\$FILEPATH" | cut -f1)"
else
    echo "Failed to download: \$FILENAME"
    exit 1
fi
EOF
    else
        cat << EOF
#!/bin/bash

# SLURM Batch Job for URL Downloads
# Author: $AUTHOR

module load wget 2>/dev/null || true

URL_FILE="$url_file"
TARGET_DIR="$target_dir"
JOBS=$jobs

# Create target directory
mkdir -p "\$TARGET_DIR"

# Create log directory
LOG_DIR="\${TARGET_DIR}/.download_logs"
mkdir -p "\$LOG_DIR"

SUCCESS_LOG="\${LOG_DIR}/success_\$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="\${LOG_DIR}/errors_\$(date +%Y%m%d_%H%M%S).log"

echo "Starting download job on \$(hostname)"
echo "URLs file: \$URL_FILE"
echo "Target directory: \$TARGET_DIR"
echo "Parallel jobs: \$JOBS"
echo "Started: \$(date)"

# Job control
JOB_SLOTS="/tmp/download_slots_\$\$"
for ((i=1; i<=JOBS; i++)); do echo; done > "\$JOB_SLOTS"

# Download function
download_url() {
    local url="\$1"
    local index="\$2"
    local total="\$3"
    
    read -r slot <&9
    
    {
        local filename=\$(basename "\$url" | sed 's/[?&].*//')
        [[ -z "\$filename" || "\$filename" == "/" ]] && filename="download_\${index}"
        
        local filepath="\${TARGET_DIR}/\${filename}"
        local temp_file="\${filepath}.tmp"
        
        echo "[\$index/\$total] Downloading: \$filename"
        
        if wget --timeout=$timeout \\
                --tries=$((retries + 1)) \\
                --user-agent="$user_agent" \\
                --no-check-certificate \\
                $([ "$resume" == true ] && echo "--continue") \\
                $([ "$show_progress" == true ] && echo "--progress=bar:force" || echo "--quiet") \\
                --output-document="\$temp_file" \\
                "\$url" 2>/dev/null; then
            
            mv "\$temp_file" "\$filepath"
            local file_size=\$(du -h "\$filepath" 2>/dev/null | cut -f1 || echo 'Unknown')
            
            {
                echo "[\$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: \$filename"
                echo "  URL: \$url"
                echo "  Size: \$file_size"
                echo "  Path: \$filepath"
                echo ""
            } >> "\$SUCCESS_LOG"
            
            echo "[\$index/\$total] SUCCESS: \$filename (\$file_size)"
        else
            [[ -f "\$temp_file" ]] && rm -f "\$temp_file"
            
            {
                echo "[\$(date '+%Y-%m-%d %H:%M:%S')] FAILED: \$filename"
                echo "  URL: \$url"
                echo "  Target: \$filepath"
                echo ""
            } >> "\$ERROR_LOG"
            
            echo "[\$index/\$total] FAILED: \$filename"
        fi
        
        echo >&9
    } &
}

# Open job control
exec 9<>"\$JOB_SLOTS"

# Process URLs
index=1
total_urls=\$(grep -c '^https\?://' "\$URL_FILE")

while IFS= read -r url; do
    [[ -z "\$url" || "\$url" =~ ^[[:space:]]*# ]] && continue
    
    if [[ "\$url" =~ ^https?:// ]]; then
        download_url "\$url" "\$index" "\$total_urls"
        ((index++))
    fi
done < <(grep '^https\?://' "\$URL_FILE")

wait
exec 9>&-
rm -f "\$JOB_SLOTS"

echo "Download job completed: \$(date)"
echo "Check logs in: \$LOG_DIR"
EOF
    fi
}

# Download function
download_urls() {
    local url_file=""
    local target_dir=""
    local max_jobs=4
    local timeout=3600
    local retries=3
    local user_agent="Advanced-Downloader/3.0"
    local resume=true
    local show_progress=true
    local verbose=false
    local use_slurm=false
    local cores=4
    local memory="8G"
    local time_limit="4:00:00"
    local partition=""
    local account=""
    local job_name="url-download"
    local array_mode=false
    local interactive=false
    local sbatch_args=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_download_help
                return 0
                ;;
            --jobs|-j)
                max_jobs="$2"
                shift 2
                ;;
            --timeout)
                timeout="$2"
                shift 2
                ;;
            --retries)
                retries="$2"
                shift 2
                ;;
            --user-agent)
                user_agent="$2"
                shift 2
                ;;
            --resume)
                resume=true
                shift
                ;;
            --no-resume)
                resume=false
                shift
                ;;
            --progress)
                show_progress=true
                shift
                ;;
            --no-progress)
                show_progress=false
                shift
                ;;
            --slurm)
                use_slurm=true
                shift
                ;;
            --cores)
                cores="$2"
                shift 2
                ;;
            --memory)
                memory="$2"
                shift 2
                ;;
            --time)
                time_limit="$2"
                shift 2
                ;;
            --partition)
                partition="$2"
                shift 2
                ;;
            --account)
                account="$2"
                shift 2
                ;;
            --job-name)
                job_name="$2"
                shift 2
                ;;
            --array)
                array_mode=true
                shift
                ;;
            --interactive)
                interactive=true
                shift
                ;;
            --sbatch-args)
                sbatch_args="$2"
                shift 2
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            -*)
                log_message "ERROR" "Unknown option: $1"
                return 1
                ;;
            *)
                if [[ -z "$url_file" ]]; then
                    url_file="$1"
                elif [[ -z "$target_dir" ]]; then
                    target_dir="$1"
                else
                    log_message "ERROR" "Too many arguments"
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$url_file" || -z "$target_dir" ]]; then
        log_message "ERROR" "Missing required parameters"
        show_download_help
        return 1
    fi
    
    # Validate inputs
    if [[ ! -f "$url_file" ]]; then
        log_message "ERROR" "URL file '$url_file' not found"
        return 1
    fi
    
    check_dependencies "$use_slurm" || return 1
    
    # Get absolute paths
    url_file=$(readlink -f "$url_file")
    target_dir=$(readlink -f "$target_dir")
    
    if [[ "$use_slurm" == true ]]; then
        # SLURM execution
        echo -e "${BOLD}${PURPLE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${PURPLE}║      SLURM URL Downloader             ║${NC}"
        echo -e "${BOLD}${PURPLE}╚══════════════════════════════════════╝${NC}"
        echo ""
        
        [[ -z "$partition" ]] && partition=$(get_slurm_partition)
        
        local total_urls=$(grep -c '^https\?://' "$url_file")
        
        echo -e "${CYAN}${ARROW} URL file:${NC} $url_file"
        echo -e "${CYAN}${ARROW} Target directory:${NC} $target_dir"
        echo -e "${CYAN}${ARROW} Total URLs:${NC} $total_urls"
        echo -e "${CYAN}${ARROW} SLURM cores:${NC} $cores"
        echo -e "${CYAN}${ARROW} SLURM memory:${NC} $memory"
        echo -e "${CYAN}${ARROW} Time limit:${NC} $time_limit"
        echo -e "${CYAN}${ARROW} Partition:${NC} $partition"
        echo -e "${CYAN}${ARROW} Job name:${NC} $job_name"
        echo -e "${CYAN}${ARROW} Mode:${NC} $([ "$array_mode" == true ] && echo "Job Array" || echo "Batch")"
        echo ""
        
        local array_spec=""
        if [[ "$array_mode" == true ]]; then
            array_spec="1-$total_urls"
            max_jobs="$cores"  # In array mode, cores are used per task
        fi
        
        local script_content
        script_content=$(create_slurm_download_script "$url_file" "$target_dir" "$max_jobs" "$timeout" "$retries" "$user_agent" "$resume" "$show_progress" "$array_mode")
        
        submit_slurm_job "$script_content" "$job_name" "$cores" "$memory" "$time_limit" "$partition" "$account" "$sbatch_args" "$array_spec" "$interactive"
        
    else
        # Local execution (existing code)
        echo -e "${BOLD}${PURPLE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${PURPLE}║        Advanced URL Downloader       ║${NC}"
        echo -e "${BOLD}${PURPLE}╚══════════════════════════════════════╝${NC}"
        echo ""
        
        # Create target directory
        mkdir -p "$target_dir" || {
            log_message "ERROR" "Cannot create directory '$target_dir'"
            return 1
        }
        
        # Setup logging
        local log_dir="${target_dir}/.download_logs"
        mkdir -p "$log_dir"
        local success_log="${log_dir}/success_$(date +%Y%m%d_%H%M%S).log"
        local error_log="${log_dir}/errors_$(date +%Y%m%d_%H%M%S).log"
        
        # Job control
        local job_slots="/tmp/download_slots_$$"
        for ((i=1; i<=max_jobs; i++)); do echo; done > "$job_slots"
        
        # Download function for single URL
        download_single_url() {
            local url="$1"
            local target="$2"
            local index="$3"
            local total="$4"
            
            read -r slot <&9
            
            {
                local filename=$(basename "$url" | sed 's/[?&].*//')
                [[ -z "$filename" || "$filename" == "/" ]] && filename="download_${index}"
                
                local filepath="${target}/${filename}"
                local temp_file="${filepath}.tmp"
                
                log_message "INFO" "[${index}/${total}] Downloading: $filename"
                
                local wget_cmd="wget"
                local wget_args=(
                    "--timeout=$timeout"
                    "--tries=$((retries + 1))"
                    "--user-agent=$user_agent"
                    "--no-check-certificate"
                    "--output-document=$temp_file"
                )
                
                if [[ "$resume" == true ]]; then
                    wget_args+=("--continue")
                fi
                
                if [[ "$show_progress" == true ]]; then
                    wget_args+=("--progress=bar:force")
                else
                    wget_args+=("--quiet")
                fi
                
                if [[ "$verbose" == true ]]; then
                    wget_args+=("--verbose")
                fi
                
                if "$wget_cmd" "${wget_args[@]}" "$url" 2>/dev/null; then
                    mv "$temp_file" "$filepath"
                    
                    local file_size=$(du -h "$filepath" 2>/dev/null | cut -f1 || echo 'Unknown')
                    
                    {
                        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $filename"
                        echo "  URL: $url"
                        echo "  Size: $file_size"
                        echo "  Path: $filepath"
                        echo ""
                    } >> "$success_log"
                    
                    log_message "SUCCESS" "[${index}/${total}] Completed: $filename ($file_size)"
                    
                else
                    [[ -f "$temp_file" ]] && rm -f "$temp_file"
                    
                    {
                        echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILED: $filename"
                        echo "  URL: $url"
                        echo "  Target: $filepath"
                        echo ""
                    } >> "$error_log"
                    
                    log_message "ERROR" "[${index}/${total}] Failed: $filename"
                fi
                
                echo >&9
            } &
        }
        
        local total_urls=$(grep -c '^https\?://' "$url_file")
        
        if [[ $total_urls -eq 0 ]]; then
            log_message "WARN" "No valid URLs found in '$url_file'"
            return 1
        fi
        
        printf "${CYAN}${ARROW} Source file:${NC} %s\n" "$url_file"
        printf "${CYAN}${ARROW} Target directory:${NC} %s\n" "$target_dir"
        printf "${CYAN}${ARROW} Total URLs:${NC} ${BOLD}%s${NC}\n" "$total_urls"
        printf "${CYAN}${ARROW} Parallel jobs:${NC} ${BOLD}%s${NC}\n" "$max_jobs"
        printf "${CYAN}${ARROW} Timeout:${NC} %ss\n" "$timeout"
        printf "${CYAN}${ARROW} Retries:${NC} %s\n" "$retries"
        printf "${CYAN}${ARROW} Resume:${NC} %s\n" "$([ "$resume" == true ] && echo "enabled" || echo "disabled")"
        printf "${CYAN}${ARROW} Started:${NC} %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # Open job control
        exec 9<>"$job_slots"
        
        # Start downloads
        local index=1
        while IFS= read -r url; do
            [[ -z "$url" || "$url" =~ ^[[:space:]]*# ]] && continue
            
            if [[ "$url" =~ ^https?:// ]]; then
                download_single_url "$url" "$target_dir" "$index" "$total_urls"
                ((index++))
            else
                log_message "WARN" "Skipping invalid URL: $url"
            fi
        done < <(grep '^https\?://' "$url_file")
        
        wait
        exec 9>&-
        rm -f "$job_slots"
        
        # Summary
        echo ""
        printf "${BOLD}${PURPLE}╔══════════════════════════════════════╗${NC}\n"
        printf "${BOLD}${PURPLE}║           Download Summary            ║${NC}\n"
        printf "${BOLD}${PURPLE}╚══════════════════════════════════════╝${NC}\n"
        
        local success_count=$(wc -l < "$success_log" 2>/dev/null | awk '{print int($1/4)}' || echo 0)
        local error_count=$(wc -l < "$error_log" 2>/dev/null | awk '{print int($1/4)}' || echo 0)
        
        printf "${GREEN}${CHECKMARK} Successful downloads:${NC} ${BOLD}%s${NC}\n" "$success_count"
        printf "${RED}${CROSSMARK} Failed downloads:${NC} ${BOLD}%s${NC}\n" "$error_count"
        printf "${CYAN}${ARROW} Total size:${NC} %s\n" "$(du -sh "$target_dir" 2>/dev/null | cut -f1 || echo 'Unknown')"
        printf "${CYAN}${ARROW} Completed:${NC} %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
        printf "${CYAN}${ARROW} Success log:${NC} %s\n" "$success_log"
        [[ -s "$error_log" ]] && printf "${CYAN}${ARROW} Error log:${NC} %s\n" "$error_log"
        echo ""
    fi
}

# SLURM management functions
slurm_management() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        submit)
            # This redirects to the main download function with SLURM
            download_urls "$@" --slurm
            ;;
        status)
            local job_id=""
            local job_name=""
            local user="$USER"
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --job-id)
                        job_id="$2"
                        shift 2
                        ;;
                    --job-name)
                        job_name="$2"
                        shift 2
                        ;;
                    --user)
                        user="$2"
                        shift 2
                        ;;
                    *)
                        log_message "ERROR" "Unknown option: $1"
                        return 1
                        ;;
                esac
            done
            
            local squeue_args=("-u" "$user")
            [[ -n "$job_id" ]] && squeue_args+=("-j" "$job_id")
            [[ -n "$job_name" ]] && squeue_args+=("--name=$job_name")
            
            log_message "SLURM" "Checking job status..."
            squeue "${squeue_args[@]}"
            ;;
        cancel)
            local job_id=""
            local job_name=""
            local user="$USER"
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --job-id)
                        job_id="$2"
                        shift 2
                        ;;
                    --job-name)
                        job_name="$2"
                        shift 2
                        ;;
                    --user)
                        user="$2"
                        shift 2
                        ;;
                    *)
                        log_message "ERROR" "Unknown option: $1"
                        return 1
                        ;;
                esac
            done
            
            if [[ -n "$job_id" ]]; then
                log_message "SLURM" "Cancelling job $job_id..."
                scancel "$job_id"
            elif [[ -n "$job_name" ]]; then
                log_message "SLURM" "Cancelling jobs with name '$job_name'..."
                scancel --name="$job_name" --user="$user"
            else
                log_message "ERROR" "Either --job-id or --job-name required"
                return 1
            fi
            ;;
        logs)
            local job_id=""
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --job-id)
                        job_id="$2"
                        shift 2
                        ;;
                    *)
                        log_message "ERROR" "Unknown option: $1"
                        return 1
                        ;;
                esac
            done
            
            if [[ -z "$job_id" ]]; then
                log_message "ERROR" "--job-id required"
                return 1
            fi
            
            log_message "SLURM" "Showing logs for job $job_id..."
            echo -e "${YELLOW}=== STDOUT ===${NC}"
            cat "url-download_${job_id}.out" 2>/dev/null || echo "No stdout log found"
            echo -e "${YELLOW}=== STDERR ===${NC}"
            cat "url-download_${job_id}.err" 2>/dev/null || echo "No stderr log found"
            ;;
        info)
            log_message "SLURM" "Cluster information:"
            echo -e "${CYAN}${ARROW} Partitions:${NC}"
            sinfo -s
            echo -e "${CYAN}${ARROW} Node information:${NC}"
            sinfo -N -l
            ;;
        *)
            log_message "ERROR" "Unknown SLURM subcommand: $subcommand"
            show_slurm_help
            return 1
            ;;
    esac
}

# MD5 verification function (updated with SLURM support)
verify_checksums() {
    local directory=""
    local checksum_file=""
    local generate=false
    local file_pattern="*"
    local exclude_pattern=""
    local output_file=""
    local strict=false
    local use_slurm=false
    local cores=4
    local memory="8G"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_verify_help
                return 0
                ;;
            --generate|-g)
                generate=true
                shift
                ;;
            --file-pattern)
                file_pattern="$2"
                shift 2
                ;;
            --exclude-pattern)
                exclude_pattern="$2"
                shift 2
                ;;
            --output)
                output_file="$2"
                shift 2
                ;;
            --strict)
                strict=true
                shift
                ;;
            --slurm)
                use_slurm=true
                shift
                ;;
            --cores)
                cores="$2"
                shift 2
                ;;
            --memory)
                memory="$2"
                shift 2
                ;;
            -*)
                log_message "ERROR" "Unknown option: $1"
                return 1
                ;;
            *)
                if [[ -z "$directory" ]]; then
                    directory="$1"
                elif [[ -z "$checksum_file" ]]; then
                    checksum_file="$1"
                else
                    log_message "ERROR" "Too many arguments"
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate directory
    if [[ -z "$directory" ]]; then
        log_message "ERROR" "Directory parameter required"
        show_verify_help
        return 1
    fi
    
    if [[ ! -d "$directory" ]]; then
        log_message "ERROR" "Directory '$directory' not found"
        return 1
    fi
    
    echo -e "${BOLD}${PURPLE}╔══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${PURPLE}║         MD5 Checksum Verifier         ║${NC}"
    echo -e "${BOLD}${PURPLE}╚══════════════════════════════════════╝${NC}"
    echo ""
    
    check_dependencies "$use_slurm" || return 1
    
    if [[ "$generate" == true ]]; then
        [[ -z "$output_file" ]] && output_file="${directory}/checksums.md5"
        
        if [[ "$use_slurm" == true ]]; then
            log_message "SLURM" "Submitting checksum generation job..."
            
            local script_content
            script_content=$(cat << EOF
#!/bin/bash

module load coreutils 2>/dev/null || true

DIRECTORY="$directory"
OUTPUT_FILE="$output_file"
FILE_PATTERN="$file_pattern"
EXCLUDE_PATTERN="$exclude_pattern"

echo "Starting MD5 checksum generation on \$(hostname)"
echo "Directory: \$DIRECTORY"
echo "Output: \$OUTPUT_FILE"
echo "Pattern: \$FILE_PATTERN"

> "\$OUTPUT_FILE"
file_count=0

while IFS= read -r -d '' file; do
    relative_path=\$(realpath --relative-to="\$DIRECTORY" "\$file")
    
    if [[ -n "\$EXCLUDE_PATTERN" && "\$relative_path" == \$EXCLUDE_PATTERN ]]; then
        continue
    fi
    
    echo "Processing: \$relative_path"
    md5_hash=\$(md5sum "\$file" | cut -d' ' -f1)
    echo "\${md5_hash}  \${relative_path}" >> "\$OUTPUT_FILE"
    ((file_count++))
    
done < <(find "\$DIRECTORY" -name "\$FILE_PATTERN" -type f -print0)

echo "Generated checksums for \$file_count files"
echo "Output file: \$OUTPUT_FILE"
EOF
)
            
            submit_slurm_job "$script_content" "md5-generate" "$cores" "$memory" "2:00:00" "" "" "" "" false
        else
            # Local execution (existing code)
            log_message "INFO" "Generating MD5 checksums..."
            echo -e "${CYAN}${ARROW} Directory:${NC} $(readlink -f "$directory")"
            echo -e "${CYAN}${ARROW} Pattern:${NC} $file_pattern"
            [[ -n "$exclude_pattern" ]] && echo -e "${CYAN}${ARROW} Exclude:${NC} $exclude_pattern"
            echo -e "${CYAN}${ARROW} Output file:${NC} $output_file"
            echo ""
            
            local file_count=0
            > "$output_file"
            
            while IFS= read -r -d '' file; do
                local relative_path=$(realpath --relative-to="$directory" "$file")
                
                if [[ -n "$exclude_pattern" && "$relative_path" == $exclude_pattern ]]; then
                    continue
                fi
                
                log_message "INFO" "Processing: $relative_path"
                local md5_hash=$(md5sum "$file" | cut -d' ' -f1)
                echo "${md5_hash}  ${relative_path}" >> "$output_file"
                ((file_count++))
                
            done < <(find "$directory" -name "$file_pattern" -type f -print0)
            
            log_message "SUCCESS" "Generated checksums for $file_count files"
            echo -e "${CYAN}${ARROW} Checksum file:${NC} $output_file"
        fi
        
    else
        # Verification logic (existing code)
        if [[ -z "$checksum_file" ]]; then
            local potential_files=(
                "${directory}/checksums.md5"
                "${directory}/checksums.md5sum"
                "${directory}/checksums.checksum"
                "${directory}/"*.md5
                "${directory}/"*.md5sum
                "${directory}/"*.checksum
            )
            
            for file in "${potential_files[@]}"; do
                if [[ -f "$file" ]]; then
                    checksum_file="$file"
                    break
                fi
            done
            
            if [[ -z "$checksum_file" ]]; then
                log_message "ERROR" "No checksum file found. Use --generate to create one."
                return 1
            fi
        fi
        
        if [[ ! -f "$checksum_file" ]]; then
            log_message "ERROR" "Checksum file '$checksum_file' not found"
            return 1
        fi
        
        log_message "INFO" "Verifying MD5 checksums..."
        echo -e "${CYAN}${ARROW} Directory:${NC} $(readlink -f "$directory")"
        echo -e "${CYAN}${ARROW} Checksum file:${NC} $(readlink -f "$checksum_file")"
        echo ""
        
        local total_files=0
        local verified_files=0
        local failed_files=0
        local missing_files=0
        
        while IFS= read -r line; do
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
            
            local expected_hash=$(echo "$line" | cut -d' ' -f1)
            local filename=$(echo "$line" | cut -d' ' -f3-)
            local filepath="${directory}/${filename}"
            
            ((total_files++))
            
            if [[ ! -f "$filepath" ]]; then
                log_message "ERROR" "Missing file: $filename"
                ((missing_files++))
                [[ "$strict" == true ]] && return 1
                continue
            fi
            
            local actual_hash=$(md5sum "$filepath" | cut -d' ' -f1)
            
            if [[ "$expected_hash" == "$actual_hash" ]]; then
                log_message "SUCCESS" "Verified: $filename"
                ((verified_files++))
            else
                log_message "ERROR" "Checksum mismatch: $filename"
                echo -e "  ${RED}Expected:${NC} $expected_hash"
                echo -e "  ${RED}Actual:${NC}   $actual_hash"
                ((failed_files++))
                [[ "$strict" == true ]] && return 1
            fi
            
        done < "$checksum_file"
        
        # Summary
        echo ""
        echo -e "${BOLD}${PURPLE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${PURPLE}║         Verification Summary          ║${NC}"
        echo -e "${BOLD}${PURPLE}╚══════════════════════════════════════╝${NC}"
        
        echo -e "${CYAN}${ARROW} Total files:${NC} ${BOLD}$total_files${NC}"
        echo -e "${GREEN}${CHECKMARK} Verified:${NC} ${BOLD}$verified_files${NC}"
        echo -e "${RED}${CROSSMARK} Failed:${NC} ${BOLD}$failed_files${NC}"
        echo -e "${YELLOW}⚠ Missing:${NC} ${BOLD}$missing_files${NC}"
        
        if [[ $failed_files -eq 0 && $missing_files -eq 0 ]]; then
            log_message "SUCCESS" "All checksums verified successfully!"
            return 0
        else
            log_message "ERROR" "Checksum verification failed"
            return 1
        fi
    fi
    
    echo ""
}

# Main function
main() {
    local command=""
    local verbose=false
    
    # Parse global options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_main_help
                return 0
                ;;
            --version|-v)
                printf "${BOLD}Advanced URL Downloader v${VERSION}${NC}\n"
                printf "${CYAN}Author: ${AUTHOR}${NC}\n"
                return 0
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --quiet)
                exec 2>/dev/null
                shift
                ;;
            --no-color)
                # Disable colors
                RED='' GREEN='' YELLOW='' BLUE='' PURPLE='' CYAN='' NC='' BOLD=''
                CHECKMARK="[OK]" CROSSMARK="[FAIL]" ARROW="-->" DOWNLOAD="[DL]"
                SHIELD="[SEC]" GEAR="[CFG]" INFO="[INFO]" CLUSTER="[HPC]"
                shift
                ;;
            download|verify|slurm|help|version)
                command="$1"
                shift
                break
                ;;
            -*)
                log_message "ERROR" "Unknown global option: $1"
                show_main_help
                return 1
                ;;
            *)
                log_message "ERROR" "Unknown command: $1"
                show_main_help
                return 1
                ;;
        esac
    done
    
    # Execute command
    case "$command" in
        download)
            download_urls "$@"
            ;;
        verify)
            verify_checksums "$@"
            ;;
        slurm)
            check_dependencies true || return 1
            slurm_management "$@"
            ;;
        help)
            show_main_help
            ;;
        version)
            printf "${BOLD}Advanced URL Downloader v${VERSION}${NC}\n"
            printf "${CYAN}Author: ${AUTHOR}${NC}\n"
            ;;
        "")
            log_message "ERROR" "No command specified"
            show_main_help
            return 1
            ;;
        *)
            log_message "ERROR" "Unknown command: $command"
            show_main_help
            return 1
            ;;
    esac
}

# Command line interface
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
