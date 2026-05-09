# shellcheck shell=bash
# scripts/lib/utils.sh
# 通用工具函数。依赖：logger.sh 已被 source

# ---------- 版本比较 ----------
version_ge() {
    [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

# ---------- 命令存在性 ----------
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        log_error "未找到命令：$1。请先安装"
        return 1
    }
}

# ---------- 带超时的端口等待 ----------
wait_for_port() {
    local host="$1" port="$2" timeout="${3:-30}"
    local elapsed=0
    while ! (exec 3<>"/dev/tcp/${host}/${port}") 2>/dev/null; do
        exec 3<&- 3>&- 2>/dev/null || true
        if (( elapsed >= timeout )); then
            log_error "等待 ${host}:${port} 超时（${timeout}s）"
            return 1
        fi
        sleep 1
        (( elapsed++ ))
    done
    exec 3<&- 3>&- 2>/dev/null || true
    return 0
}

# ---------- 带超时的 HTTP 健康检查 ----------
wait_for_http() {
    local url="$1" timeout="${2:-30}"
    local elapsed=0 code
    while true; do
        code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 3 "${url}" 2>/dev/null || echo "000")
        if [[ "${code}" == "200" ]]; then
            return 0
        fi
        if (( elapsed >= timeout )); then
            log_error "健康检查失败 ${url}（最后 HTTP=${code}，${timeout}s 超时）"
            return 1
        fi
        sleep 2
        (( elapsed += 2 ))
    done
}

# ---------- 清理旧日志 ----------
cleanup_old_logs() {
    local keep="${1:-10}"
    [[ -d "${LOG_DIR}" ]] || return 0
    (cd "${LOG_DIR}" && find . -maxdepth 1 -name 'deploy-*.log' -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | tail -n +$((keep+1)) | cut -d' ' -f2- | xargs -r rm -f)
}

# ---------- 确认提示 ----------
confirm() {
    local prompt="${1:-确认继续?} [y/N] "
    read -r -p "${prompt}" reply
    [[ "${reply}" =~ ^[Yy]$ ]]
}

# ---------- 远端部署辅助 ----------
remote_check_ssh() {
    local host="$1"
    log_info "测试 SSH 连接：${host}"
    # shellcheck disable=SC2086
    if ! ssh ${REMOTE_SSH_OPTS} "${host}" "echo ok" >/dev/null 2>&1; then
        log_error "SSH 不通：${host}"
        log_error "修复：ssh ${host}  先手动验证能登录"
        return 1
    fi
    log_ok "SSH 可达"
}

remote_preflight() {
    local host="$1"
    log_info "远端体检"
    # shellcheck disable=SC2086
    ssh ${REMOTE_SSH_OPTS} "${host}" bash <<'REMOTE_EOF'
        set -euo pipefail
        command -v docker >/dev/null || { echo "远端没装 docker"; exit 1; }
        docker info >/dev/null 2>&1 || { echo "远端 docker daemon 不通"; exit 1; }
        df -BG /var/lib/docker | awk 'NR==2 {g=$4; gsub("G","",g); if (g+0 < 5) { print "远端磁盘不足 5GB"; exit 1 }}'
        echo "OK"
REMOTE_EOF
}

remote_sync() {
    local host="$1"
    local src="${PROJECT_ROOT}/"
    local dst="${host}:${REMOTE_APP_DIR}/"
    log_step "同步代码到 ${host}:${REMOTE_APP_DIR}"

    # shellcheck disable=SC2086,SC2029
    ssh ${REMOTE_SSH_OPTS} "${host}" "mkdir -p ${REMOTE_APP_DIR}"

    local excludes=()
    for e in "${REMOTE_RSYNC_EXCLUDES[@]}"; do
        excludes+=("--exclude=${e}")
    done

    rsync -az --delete \
        -e "ssh ${REMOTE_SSH_OPTS}" \
        "${excludes[@]}" \
        "${src}" "${dst}"
    log_ok "代码已同步"
}

remote_deploy() {
    local host="$1"
    log_step "在远端执行部署"
    local remote_args=""
    (( DRY_RUN ))    && remote_args+=" --dry-run"
    (( SKIP_BUILD )) && remote_args+=" --skip-build"
    (( SKIP_TESTS )) && remote_args+=" --skip-tests"

    # shellcheck disable=SC2086,SC2029
    ssh ${REMOTE_SSH_OPTS} "${host}" "cd ${REMOTE_APP_DIR} && ./scripts/deploy.sh${remote_args}"
}
