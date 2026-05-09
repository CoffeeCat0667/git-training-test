# shellcheck shell=bash
# scripts/lib/logger.sh
# 分级日志：INFO / WARN / ERROR / OK / STEP
# 同时输出到终端和日志文件
# 依赖：colors.sh 已被 source、LOG_DIR 已定义

[[ -n "${_LOGGER_LOADED:-}" ]] && return
readonly _LOGGER_LOADED=1

logger_init() {
    mkdir -p "${LOG_DIR}"
    LOG_FILE="${LOG_DIR}/deploy-$(date +%Y%m%d-%H%M%S).log"
    ln -sf "$(basename "${LOG_FILE}")" "${LOG_DIR}/latest.log"
    echo "=== 部署开始 $(date -Iseconds) ===" > "${LOG_FILE}"
}

_log_to_file() {
    [[ -n "${LOG_FILE:-}" ]] && echo "[$(date +%H:%M:%S)] $*" >> "${LOG_FILE}"
}

log_info()  { echo -e "${C_BLUE}[INFO]${C_RESET}  $*";        _log_to_file "[INFO]  $*"; }
log_warn()  { echo -e "${C_YELLOW}[WARN]${C_RESET}  $*" >&2;  _log_to_file "[WARN]  $*"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2;     _log_to_file "[ERROR] $*"; }
log_ok()    { echo -e "${C_GREEN}[ OK ]${C_RESET}  $*";       _log_to_file "[ OK ]  $*"; }

log_step() {
    echo ""
    echo -e "${C_BOLD}${C_CYAN}==> $*${C_RESET}"
    _log_to_file "==> $*"
}
